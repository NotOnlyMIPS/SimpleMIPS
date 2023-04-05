/*
 * Filename: c:\Users\86198\Desktop\icache1.sv
 * Path: c:\Users\86198\Desktop
 * Created Date: Wednesday, March 29th 2023, 8:10:07 pm
 * Author: Waitsnow
 *
 * Copyright (c) 2023 Your Company
 */

//Icache直接复用原本的cache逻辑
//并且由于icache不具有写操作
//在原有cache上进行删除即可

`include "cache.svh"
`include "../cpu.svh"

module icache #(
    parameter DATA_WIDTH    = 32,//字的大小
    parameter LINE_WORD_NUM = 4,//cache数据块大小
    parameter ASSOC_NUM     = 4,//组相联路数
    parameter WAY_SIZE      = 4*1024*8,//每一路的大小4KB
    parameter GROUP_NUM     = WAY_SIZE/(LINE_WORD_NUM*DATA_WIDTH)//一共多少组

)(
    input  logic           clk_g,
    input  logic           resetn,
    // cpu_core
    CPU_ICache_Interface.ICache   IBus,
    // AXI4
    output logic           rd_uncache,
    output logic           rd_req,
    output logic [ 31:0]   rd_addr,
    input  logic           rd_rdy,
    input  logic           ret_valid,
    input  logic [127:0]   ret_data
);
localparam int unsigned BYTES_WORD     = 4;
localparam int unsigned INDEX_WIDTH    = $clog2(GROUP_NUM) ;
localparam int unsigned OFFSET_WIDTH   = $clog2(LINE_WORD_NUM*BYTES_WORD);
localparam int unsigned TAG_WIDTH      = 32-INDEX_WIDTH-OFFSET_WIDTH ;

//由于是Icache，所以不需要脏位
typedef struct packed {
    logic valid;
    logic [TAG_WIDTH-1:0] tag;
} tagv_t;

typedef logic [TAG_WIDTH-1:0]                     tag_t;
typedef logic [INDEX_WIDTH-1:0]                   index_t;
typedef logic [OFFSET_WIDTH-1:0]                  offset_t;

typedef logic [ASSOC_NUM-1:0]                     gpwe_t;
typedef logic [DATA_WIDTH-1:0]                    data_t;

// 这个需要配置当4路时用这个函数
function logic[1:0] clog2(
    input logic [ASSOC_NUM-1:0] hit
);
    return{
        (hit[3] == 1'b1) ? 2'b11 :
        (hit[2] == 1'b1) ? 2'b10 :
        (hit[1] == 1'b1) ? 2'b01 : 2'b00
    };
endfunction
//2路时用这个函数
// function logic clog2(
//     input logic [ASSOC_NUM-1:0] hit
// );
//     return{
//         hit[1] ? 1'b1 : 1'b0
//     };
// endfunction

typedef enum logic [3:0] {
        LOOKUP,
        MISSCLEAN,
        REFILL,
        REFILLDONE
} state_t;

typedef struct packed {
    logic             valid;
    tag_t             tag;
    index_t           index;
    offset_t          offset;
    logic             is_cache;//判断时cache还是uncache
    CacheType         cache_type;
} request_t;

state_t  state,state_next;

logic [31:0] uncache_rdata;

index_t read_addr,tagv_addr;//读ram地址

tagv_t                 tagv_rdata[ASSOC_NUM-1:0];//tag的读数据
tagv_t                 tagv_wdata;//tag的写数据
gpwe_t                 tagv_we;//tag的写使能


data_t                                                        data_rdata [ASSOC_NUM-1:0][LINE_WORD_NUM-1:0];//读出的数据
logic [31:0]                                                  data_rdata_sel[ASSOC_NUM-1:0];//选择出某一路的数据
logic [31:0]                                                  data_rdata_final2;

data_t                                                        data_wdata[LINE_WORD_NUM-1:0];//写数据
logic  [ASSOC_NUM-1:0][LINE_WORD_NUM-1:0]                     data_we;//写使能

request_t req_buffer;
logic req_buffer_en;

logic [$clog2(ASSOC_NUM)-1:0]                                 lru[GROUP_NUM-1:0] ;
logic [ASSOC_NUM-1:0]                                         hit;
logic                                                         cache_hit;

logic [ASSOC_NUM-1:0]                                         pipe_hit;
logic                                                         pipe_cache_hit;
tagv_t [ASSOC_NUM-1:0]                                        pipe_tagv_rdata;
logic                                                         pipe_wr;

//cpu
//地址握手信号
assign IBus.addr_ok    = ( state_next == LOOKUP) && IBus.req;
//数据握手信号
assign IBus.data_ok    = ((state == LOOKUP || state == REFILLDONE) && state_next == LOOKUP && req_buffer.valid);
//返回给cpu的数据
assign IBus.rdata      =  ( req_buffer.valid ) ? data_rdata_final2 : '0;
//axi
//读请求
assign rd_req     = state == MISSCLEAN ? 1'b1 : 1'b0;
//读uncache
assign rd_uncache = (req_buffer.is_cache == 1'b0) ? 1'b1 : 1'b0;
//读地址
assign rd_addr    = {req_buffer.tag,req_buffer.index, req_buffer.is_cache ? {OFFSET_WIDTH{1'b0}} : req_buffer.offset};

//判断是否命中
assign cache_hit        = |hit;//ok
//读ram地址
assign read_addr        = req_buffer_en ? IBus.index : req_buffer.index;
assign tagv_addr        = IBus.cachetype.isIcache ? IBus.cache_index : req_buffer.index ;

//pipe写使能
assign pipe_wr          = (state_next == MISSCLEAN); // ??????????????????
//req_buffer写使能
assign req_buffer_en    = (state_next == LOOKUP && IBus.req || IBus.data_ok);

//将axi返回数据写入
generate;//
    for (genvar i=0; i<LINE_WORD_NUM; i++) begin
        assign data_wdata[i] = ret_data[(i+1)*32-1:i*32];
    end
endgenerate

//只有重填时tag有值
// assign tagv_wdata       = (state == REFILL) ? {1'b1, req_buffer.tag} : '0;
always_comb begin : tagv_wdata_blockName
    if(IBus.cachetype.isIcache)begin
        case (IBus.cachetype.cacheCode)
            I_Index_Store_Tag:begin
                tagv_wdata = {IBus.cache_valid, IBus.cache_tag};
            end
            default : begin
                tagv_wdata = {1'b0,req_buffer.tag};
            end
        endcase
    end else begin
        tagv_wdata = (state == REFILL) ? {1'b1,req_buffer.tag} : '0;
    end
end

//generate
generate;
    for (genvar i = 0;i<ASSOC_NUM ;i++ ) begin
        simple_port_lutram  #(
            .SIZE(GROUP_NUM),
            .dtype(tagv_t)
        ) mem_tag(
            .clka(clk_g),
            .rsta(~resetn),

            .ena(1'b1),
            .wea(tagv_we[i]),
            .addra(tagv_addr),
            .dina(tagv_wdata),
            .douta(tagv_rdata[i])
        );
        for (genvar j=0; j<LINE_WORD_NUM; ++j) begin
        simple_port_ram #(
            .SIZE(GROUP_NUM)
        )mem_data(
            .clk(clk_g),
            .rst(~resetn),

            .ena(1'b1),
            .wea(data_we[i]),
            .addra(read_addr),
            .dina(data_wdata[j]),

            .enb(1'b1),
            .addrb(read_addr),
            .doutb(data_rdata[i][j])
        );
    end
    end
endgenerate

generate;//PLRU 算法
    for (genvar  i=0; i<GROUP_NUM; i++) begin
        PLRU #(
            .ASSOC_NUM(ASSOC_NUM)
        ) plru_reg(
            .clk(clk_g),
            .resetn(resetn),
            .access(hit),
            .update(req_buffer.valid && i[INDEX_WIDTH-1:0] == req_buffer.index),

            .lru(lru[i])
        );
    end
endgenerate

//判断时是否命中
generate;
    for(genvar i = 0; i < ASSOC_NUM; i++ ) begin
        assign hit[i]= (tagv_rdata[i].valid & (req_buffer.tag == tagv_rdata[i].tag) & req_buffer.is_cache ) ? 1'b1:1'b0 ;
    end
endgenerate

//选择出某一路的某个字数据
generate;
    for(genvar i = 0;i < ASSOC_NUM; i++) begin
        assign data_rdata_sel[i] = data_rdata[i][req_buffer.offset[OFFSET_WIDTH-1:2]];
    end
endgenerate

always_comb begin : data_rdata_final2__blockname
    if(req_buffer.valid && !req_buffer.is_cache && state_next == LOOKUP)
        data_rdata_final2 = uncache_rdata;
    else if(req_buffer.valid && req_buffer.is_cache) begin
        data_rdata_final2 = data_rdata_sel[clog2(hit)];
    end
    else begin
        data_rdata_final2 = '0 ;
    end
end

always_comb begin : tagv_we_blockName
    if(IBus.cachetype.isIcache)begin
        if(ASSOC_NUM==2) begin
            case (IBus.cachetype.cacheCode)
                I_Index_Invalid, I_Index_Store_Tag:begin
                    tagv_we = (IBus.cache_tag[0]) ? 2'b10 : 2'b01;
                end
                I_Hit_Invalid:begin
                    tagv_we = (cache_hit) ? hit : '0;
                end
                default: begin
                    tagv_we = '0;
                end
            endcase
        end else if(ASSOC_NUM == 4) begin
            case (IBus.cachetype.cacheCode)
                I_Index_Invalid,I_Index_Store_Tag:begin
                    tagv_we =   (IBus.cache_tag[1:0] == 2'b00) ? 4'b0001 :
                                (IBus.cache_tag[1:0] == 2'b01) ? 4'b0010 :
                                (IBus.cache_tag[1:0] == 2'b10) ? 4'b0100 : 4'b1000;
                end
                I_Hit_Invalid:begin
                    tagv_we = (cache_hit) ? hit : '0;
                end
                default: begin
                    tagv_we = '0;
                end
            endcase
        end
    end else if (state == REFILL && ret_valid && req_buffer.is_cache) begin
        tagv_we = '0;
        tagv_we[lru[req_buffer.index]] =1'b1;
    end else begin
        tagv_we = '0;
    end
end

//data的写使能
always_comb begin : data_we_blockName
    if (state == REFILL && ret_valid && req_buffer.is_cache) begin
        data_we = '0;
        data_we[lru[req_buffer.index]] ='1;
    end else begin
        data_we = '0;
    end
end

//uncache的数据
always_ff @( posedge clk_g ) begin : uncache_rdata_blockName
    if (ret_valid && req_buffer.is_cache == 1'b0) begin
        uncache_rdata <= ret_data[127:96];
    end
end

//pipe
generate;
    for (genvar  i=0; i<ASSOC_NUM; i++) begin
    always_ff @( posedge clk_g ) begin : pipe_tagv_rdata_blockName
        if (pipe_wr) begin
            pipe_tagv_rdata[i].tag   <= tagv_rdata[i].tag;
            pipe_tagv_rdata[i].valid <= tagv_rdata[i].valid ;
        end
    end
    end
endgenerate

//锁存
always_ff @(posedge clk_g) begin : pipe_hitblockName
    if (pipe_wr) begin
        pipe_cache_hit           <= cache_hit;
        pipe_hit                 <= (1<<lru[req_buffer.index]);
    end
end

//将请求打入req_buffer
always_ff @( posedge clk_g ) begin : req_buffer_block
    if( !resetn )begin
        req_buffer          <= '0;
    end else if(req_buffer_en) begin
        req_buffer.valid    <=  IBus.req;
        req_buffer.tag      <=  IBus.tag;
        req_buffer.index    <=  IBus.index;
        req_buffer.offset   <=  IBus.offset;
        req_buffer.is_cache  <=  IBus.iscache;
        req_buffer.cache_type<=  IBus.cachetype;
    end
end

//状态转移
always_ff @( posedge clk_g ) begin : state_switch_blockName
    if( !resetn ) begin
        state <= LOOKUP ;
    end else begin
        state <= state_next ;
    end
end

//状态计算
always_comb begin : state_next_blockName

    state_next = LOOKUP ;

    unique case (state)
        LOOKUP:begin
            if ( req_buffer.valid && req_buffer.is_cache == 1'b0) begin
                state_next = MISSCLEAN;
            end else begin
                if(req_buffer.valid && req_buffer.is_cache == 1'b1) begin
                    if(cache_hit) begin
                        state_next = LOOKUP;
                    end else begin
                        state_next = MISSCLEAN;
                    end
                end
            end
        end
        MISSCLEAN:begin
            if ( rd_rdy ) begin
                state_next = REFILL;
            end else begin
                state_next = MISSCLEAN;
            end
        end
        REFILL:begin
            if ( ret_valid ) begin
                state_next = REFILLDONE;
            end else begin
                state_next = REFILL;
            end
        end
        REFILLDONE:begin
            state_next = LOOKUP;
        end
        default: begin
            state_next =LOOKUP;
        end
    endcase
end

endmodule
