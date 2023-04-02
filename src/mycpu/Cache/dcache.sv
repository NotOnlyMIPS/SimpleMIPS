`include "Cache_define.svh"
`include "../cpu_defs.svh"

module dcache #(
    parameter STORE_BUFFER_SIZE = 32,
    parameter DATA_WIDTH    = 32,
    parameter LINE_WORD_NUM = 4,
    parameter ASSOC_NUM     = 2,
    parameter WAY_SIZE      = 4*1024*8,
    parameter GROUP_NUM     = WAY_SIZE/(LINE_WORD_NUM*DATA_WIDTH) 

)(
    input  logic           clk_g,
    input  logic           resetn,
    //cpu
    CPU_DCache_Interface.DCache DBus,
    //axi 
    output logic           rd_req,
    output logic [ 31:0]   rd_addr,
    input  logic           rd_rdy,
    input  logic           ret_valid,
    input  logic [127:0]   ret_data,
    output logic           wr_req,
    output logic [ 31:0]   wr_addr,
    output logic [127:0]   wr_data,
    input  logic           wr_rdy,
    input  logic           wr_bvalid,
    //uncache
    output logic           urd_req,
    output logic [  2:0]   urd_size,//
    output logic [ 31:0]   urd_addr,
    input  logic           urd_rdy,
    input  logic           uret_valid,
    input  logic [ 31:0]   uret_data,
    output logic           uwr_req,
    output logic [  2:0]   uwr_size,//
    output logic [  3:0]   uwr_wstrb,//
    output logic [ 31:0]   uwr_addr,
    output logic [ 31:0]   uwr_data,
    input  logic           uwr_rdy,
    input  logic           uwr_bvalid
);
localparam int unsigned BYTES_PER_WORD = 4;
localparam int unsigned INDEX_WIDTH    = $clog2(GROUP_NUM) ;
localparam int unsigned OFFSET_WIDTH   = $clog2(LINE_WORD_NUM*BYTES_PER_WORD);
localparam int unsigned TAG_WIDTH      = 32-INDEX_WIDTH-OFFSET_WIDTH ;


typedef struct packed {
    logic valid;
    //logic dirty;
    logic [TAG_WIDTH-1:0] tag;  
} tagv_t; 

typedef struct packed {
    logic [31:0] address;
    logic [31:0] data;
    logic [3:0] wstrb;
} uncache_store_t;

typedef logic                                     dirty_t;
typedef logic [ASSOC_NUM-1:0]                     hit_t;
typedef logic [TAG_WIDTH-1:0]                     tag_t;
typedef logic [INDEX_WIDTH-1:0]                   index_t;
typedef logic [OFFSET_WIDTH-1:0]                  offset_t;

typedef logic [ASSOC_NUM-1:0]                     gpwe_t;
typedef logic [DATA_WIDTH-1:0]                    data_t;

function index_t rt_index( input logic [31:0] addr );
    return addr[OFFSET_WIDTH + INDEX_WIDTH - 1 : OFFSET_WIDTH];
endfunction

function tag_t rt_tag( input logic [31:0] addr );
    return addr[31 : OFFSET_WIDTH + INDEX_WIDTH];
endfunction

function offset_t rt_offset( input logic [31:0] addr );
    return addr[OFFSET_WIDTH - 1 : 0];
endfunction

function logic  [31:0] mux_byteenable(
    input logic [31:0] rdata,
    input logic [31:0] wdata,
    input logic [3:0] sel 
);
    return { 
        sel[3] ? wdata[31:24] : rdata[31:24],
        sel[2] ? wdata[23:16] : rdata[23:16],
        sel[1] ? wdata[15:8]  : rdata[15:8],
        sel[0] ? wdata[7:0]   : rdata[7:0]
    };
endfunction

// function logic[1:0] clog2(
//     input logic [ASSOC_NUM-1:0] hit
// );
//     return{
//         (hit[3] == 1'b1) ? 2'b11 : 
//         (hit[2] == 1'b1) ? 2'b10 : 
//         (hit[1] == 1'b1) ? 2'b01 : 2'b00
//     };
// endfunction

function logic clog2(
    input logic [ASSOC_NUM-1:0] hit
);
    return{
        hit[1] ? 1'b1 : 1'b0
    };
endfunction

typedef enum logic [3:0] { 
        MISSDIRTY,
        WRITEBACK,

        LOOKUP,
        MISSCLEAN,
        REFILL,
        REFILLDONE
} state_t;

typedef enum logic [2:0] { 
        WB_IDLE,
        WB_STORE
} wb_state_t;

typedef struct packed {
    logic             valid;
    logic             wr;
    tag_t             tag;
    index_t           index;
    offset_t          offset;
    logic[3:0]        wstrb; 
    logic[31:0]       wdata; 
    logic[ 2:0]       size;
    logic             isCache;
    CacheType         cacheType;
    logic             cache_dirty;
    logic             cache_valid;
} request_t;


typedef struct packed {
    logic [ASSOC_NUM-1:0] hit;
    logic                 valid;
    tag_t                 tag;
    index_t               index;
    offset_t              offset;
    logic[3:0]            wstrb;
    data_t                wdata;
} store_t;

typedef enum logic [1:0]{ 
    UNCACHE_IDLE,
    UNCACHE_READ_WAIT_AXI,
    UNCACHE_READ,
    UNCACHE_READ_DONE
} uncache_state_t;

// typedef enum logic [1:0] { 
//     CACHE_IDLE,
//     CACHE_LOOKUP,
//     CACHE_WAIT_WRITE,
//     CACHE_WRITEBACK
// } cache_state_t;

// cache_state_t cache_state,cache_state_next;
uncache_state_t uncache_state,uncache_state_next;
store_t  store_buffer;
state_t  state,state_next;

wb_state_t wb_state,wb_state_next;

logic [31:0] uncache_rdata;

index_t read_addr, write_addr, tagv_addr;

tagv_t [ASSOC_NUM-1:0] tagv_rdata;
tagv_t                 tagv_wdata;
gpwe_t                 tagv_we;

index_t                 dirty_addr;
dirty_t [ASSOC_NUM-1:0] dirty_rdata;
dirty_t                 dirty_wdata;
gpwe_t                  dirty_we;

gpwe_t wb_we;//store

data_t                                                        data_rdata [ASSOC_NUM-1:0][LINE_WORD_NUM-1:0];
logic [31:0]                                                  data_rdata_sel[ASSOC_NUM-1:0];
logic [31:0]                                                  data_rdata_final1;
logic [31:0]                                                  data_rdata_final2;
data_t                                                        data_wdata[LINE_WORD_NUM-1:0];
logic  [ASSOC_NUM-1:0][LINE_WORD_NUM-1:0][3:0]                data_we;
logic                                                         data_read_en;

request_t req_buffer;
logic req_buffer_en;

logic [$clog2(ASSOC_NUM)-1:0]                                 lru[GROUP_NUM-1:0] ;
logic [ASSOC_NUM-1:0]                                         hit;
logic                                                         cache_hit;

logic [ASSOC_NUM-1:0]                                         pipe_hit;
logic                                                         pipe_cache_hit;
tagv_t [ASSOC_NUM-1:0]                                        pipe_tagv_rdata;
logic                                                         pipe_wr;

//fifo

uncache_store_t fifo_din;//input
logic fifo_wr_en;
logic fifo_rd_en;

logic fifo_rd_rst_busy;// output
logic fifo_full;
logic fifo_empty;
uncache_store_t fifo_dout;
logic fifo_data_valid;
logic fifo_wr_ack;
logic fifo_wr_rst_busy;


assign fifo_din   = {req_buffer.tag,req_buffer.index,req_buffer.offset,req_buffer.wdata,req_buffer.wstrb};
assign fifo_wr_en = (fifo_wr_rst_busy || fifo_full || (~(req_buffer.valid & req_buffer.wr & (~req_buffer.isCache))) ) ?  1'b0 : 1'b1;
assign fifo_rd_en = (uwr_rdy && (!fifo_empty) && (!fifo_rd_rst_busy)) ? 1'b1 :1'b0; 
//cpu

assign DBus.addr_ok   = ( state_next == LOOKUP) && DBus.req;

assign DBus.data_ok   = req_buffer.isCache ? ((state == LOOKUP || state == REFILLDONE) && state_next == LOOKUP && req_buffer.valid) 
                                           : (req_buffer.wr ? req_buffer.valid : (uncache_state == UNCACHE_READ_DONE  && req_buffer.valid));

assign DBus.rdata     =  ( req_buffer.valid ) ? data_rdata_final1 : '0;
//axi
assign rd_req = (state == MISSCLEAN) ? 1'b1 : 1'b0;
assign rd_type = '0;
assign rd_addr = {req_buffer.tag,req_buffer.index, {OFFSET_WIDTH{1'b0}}};
assign wr_req = (state == MISSDIRTY) ? 1'b1 : 1'b0;
assign wr_type = '0;
assign wr_wstrb = '0;
// assign wr_addr = {pipe_tagv_rdata[lru[req_buffer.index]].tag, req_buffer.index, {OFFSET_WIDTH{1'b0}}};
always_comb begin : axi_bus_wraddr_blockName
    if (req_buffer.cacheType.isDcache) begin
        case (req_buffer.cacheType.cacheCode)
            D_Index_Writeback_Invalid:begin
                //2闁荤姳璀﹂崹顖涚箾閸ヮ剚鍋ㄩ柨鐕傛嫹
                wr_addr = {pipe_tagv_rdata[req_buffer.tag[0]].tag,req_buffer.index,{OFFSET_WIDTH{1'b0}}};
                //4闁荤姳璀﹂崹顖涚箾閸ヮ剚鍋ㄩ柨鐕傛嫹
                // wr_addr = {pipe_tagv_rdata[req_buffer.tag[1:0]].tag,req_buffer.index,{OFFSET_WIDTH{1'b0}}};
            end
            D_Hit_Writeback_Invalid:begin
                wr_addr = {req_buffer.tag,req_buffer.index,{OFFSET_WIDTH{1'b0}}};
            end
            default: begin
                wr_addr = '0;
            end
        endcase
    end else begin
        wr_addr = {pipe_tagv_rdata[lru[req_buffer.index]].tag,req_buffer.index,{OFFSET_WIDTH{1'b0}}};
    end
end

// generate;
//     for (genvar  i=0; i<LINE_WORD_NUM; ++i) begin
//         assign wr_data[32*(i+1)-1:32*(i)] = data_rdata[lru[req_buffer.index]][i];
//     end
// endgenerate

logic[127:0] wr_data1,wr_data2,wr_data3;

generate;
    for (genvar  i=0; i<LINE_WORD_NUM; ++i) begin
        assign wr_data1[32*(i+1)-1:32*(i)] = data_rdata[req_buffer.tag[1:0]][i];
    end
endgenerate

generate;
    for (genvar  i=0; i<LINE_WORD_NUM; ++i) begin
        assign wr_data2[32*(i+1)-1:32*(i)] = data_rdata[clog2(hit)][i];
    end
endgenerate

generate;
    for (genvar  i=0; i<LINE_WORD_NUM; ++i) begin
        assign wr_data3[32*(i+1)-1:32*(i)] = data_rdata[lru[req_buffer.index]][i];
    end
endgenerate

always_comb begin : axi_bus_wr_data_blockName
    if (req_buffer.cacheType.isDcache) begin
        case (req_buffer.cacheType.cacheCode)
            D_Index_Writeback_Invalid:begin
                wr_data = wr_data1;
            end
            D_Hit_Writeback_Invalid:begin
                wr_data = wr_data2;
            end
            default: begin
               wr_data = '0;
            end
        endcase
    end else begin
        for (int i=0; i<LINE_WORD_NUM; i++) begin
                wr_data = wr_data3;
            end
    end    
end


assign urd_req   = (uncache_state == UNCACHE_READ_WAIT_AXI && fifo_empty) ? 1'b1:1'b0;
assign urd_size  = req_buffer.size;
assign urd_addr  = {req_buffer.tag , req_buffer.index, req_buffer.offset};
assign uwr_req   = (fifo_empty || fifo_rd_rst_busy) ? 1'b0:1'b1;
assign uwr_size  = req_buffer.size;
assign uwr_addr  = {fifo_dout.address}; //
assign uwr_data  = {fifo_dout.data};
assign uwr_wstrb = fifo_dout.wstrb;

assign ststall = 0;
assign cache_hit        = |hit;//ok

assign read_addr        = req_buffer_en ? DBus.index : req_buffer.index;
assign write_addr       = ( state == REFILL ) ? req_buffer.index : store_buffer.index;
assign tagv_addr        = req_buffer.index;

assign data_rdata_final1 =   (uncache_state == UNCACHE_READ_DONE )? uncache_rdata: data_rdata_final2;

assign pipe_wr          = (state_next == MISSCLEAN || state_next == MISSDIRTY); // ??????????????????

//req_buffer
assign req_buffer_en    = (state_next == LOOKUP && DBus.req || DBus.data_ok) || DBus.cachetype.isDcache;

generate;//
    for (genvar i=0; i<LINE_WORD_NUM; i++) begin
        assign data_wdata[i] = (state == REFILL) ? ret_data[(i+1)*32-1:i*32] : store_buffer.wdata;
    end
endgenerate

always_comb begin : tagv_wdata_blockName
    if(req_buffer.cacheType.isDcache)begin
        case (req_buffer.cacheType.cacheCode)
            D_Index_Store_Tag:begin
                tagv_wdata = {req_buffer.cache_valid, req_buffer.tag};
            end
            default : begin
                tagv_wdata = {1'b0,req_buffer.tag};
            end
        endcase
    end else begin
        tagv_wdata = (state == REFILL) ? {1'b1,req_buffer.tag} : '0;
    end
end

assign data_read_en     = 1'b1;

always_comb begin : dirty_wdata_blockName
    if(req_buffer.cacheType.isDcache)begin
        case (req_buffer.cacheType.cacheCode)
            D_Index_Store_Tag:begin
                dirty_wdata = req_buffer.cache_dirty;
            end
            default : begin
                dirty_wdata = 1'b0;
            end
        endcase
    end else begin
        dirty_wdata = (state == REFILL) ? 1'b0 : 1'b1;
    end
end

assign dirty_addr       = req_buffer.index;

//generate
generate;
    for (genvar i = 0;i<ASSOC_NUM ;i++ ) begin
        simple_port_lutram #(
            .SIZE(GROUP_NUM),
            .dtype(dirty_t)
        )mem_dirty(
            .clka(clk_g),
            .rsta(~resetn),

            .ena(1'b1),
            .wea(dirty_we[i]),
            .addra(dirty_addr),
            .dina(dirty_wdata),
            .douta(dirty_rdata[i])            
        );

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
            .SIZE(GROUP_NUM),
            .BYTE_PER_DATA(4)
        )mem_data(
            .clk(clk_g),
            .rst(~resetn),

            .ena(1'b1),
            .wea(data_we[i][j]),
            .addra(write_addr),
            .dina(data_wdata[j]),

            .enb(data_read_en),
            .addrb(read_addr),
            .doutb(data_rdata[i][j])
        );
    end
    end
endgenerate

generate;//PLRU 
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

generate;
    for(genvar i = 0; i < ASSOC_NUM; i++ ) begin
        assign hit[i]= (tagv_rdata[i].valid & (req_buffer.tag == tagv_rdata[i].tag) ) ? 1'b1:1'b0 ;
    end
endgenerate

generate;
    for(genvar i = 0;i < ASSOC_NUM; i++) begin
        assign data_rdata_sel[i] = data_rdata[i][req_buffer.offset[OFFSET_WIDTH-1:2]];
    end
endgenerate

always_comb begin : dirty_we_block
    if(req_buffer.cacheType.isDcache)begin
        case (req_buffer.cacheType.cacheCode)
            D_Index_Writeback_Invalid:begin
                if (state == REFILL && ret_valid)
                    dirty_we = (req_buffer.tag[0]) ? 2'b10 : 2'b01;
                else 
                    dirty_we = '0;
            end
            D_Index_Store_Tag:begin
                dirty_we = (req_buffer.tag[0]) ? 2'b10 : 2'b01;
            end
            D_Hit_Invalid:begin
                dirty_we = (cache_hit) ? ( (hit[0]) ? 2'b01:2'b10 )  : '0;
            end
            D_Hit_Writeback_Invalid: begin
                if (state == REFILL && ret_valid)
                    dirty_we = (cache_hit) ? ( (hit[0]) ? 2'b01:2'b10 )  : '0;
                else 
                    dirty_we = '0;
            end
            default: begin
                dirty_we = '0;
            end
        endcase
        // case (DBus.cacheType.cacheCode)
        //     D_Index_Writeback_Invalid,D_Index_Store_Tag:begin
        //         dirty_we =  (DBus.cache_tag[1:0] == 2'b00) ? 4'b0001 :
        //                     (DBus.cache_tag[1:0] == 2'b01) ? 4'b0010 :
        //                     (DBus.cache_tag[1:0] == 2'b10) ? 4'b0100 : 4'b1000;
        //     end
        //     D_Hit_Invalid,D_Hit_Writeback_Invalid:begin
        //         dirty_we = (cache_hit) ? hit : '0;
        //     end
        //     default: begin
        //         dirty_we = '0;
        //     end
        // endcase
    end else if (state == REFILL && ret_valid) begin
        dirty_we = '0;
        dirty_we[lru[req_buffer.index]] =1'b1;
    end else if(req_buffer.valid && req_buffer.wr && req_buffer.isCache)begin
        dirty_we = hit;
    end else begin
        dirty_we = '0;
    end
end

always_comb begin : data_rdata_final2__blockname
    data_rdata_final2 = ( (|data_we[clog2(store_buffer.hit)])  && store_buffer.hit == hit 
                        && {store_buffer.tag,store_buffer.index,store_buffer.offset[OFFSET_WIDTH-1:2]} == {req_buffer.tag,req_buffer.index,req_buffer.offset[OFFSET_WIDTH-1:2]} ) ?
                            store_buffer.wdata : data_rdata_sel[clog2(hit)];
end

always_comb begin : tagv_we_blockName
    if(req_buffer.cacheType.isDcache)begin
        case (req_buffer.cacheType.cacheCode)
            D_Index_Writeback_Invalid:begin
                if (state == REFILL && ret_valid)
                    tagv_we = (req_buffer.tag[0]) ? 2'b10 : 2'b01;
                else 
                    tagv_we = '0;
            end
            D_Index_Store_Tag:begin
                tagv_we = (req_buffer.tag[0]) ? 2'b10 : 2'b01;
            end
            D_Hit_Invalid:begin
                tagv_we = (cache_hit) ? ( (hit[0]) ? 2'b01:2'b10 )  : '0;
            end
            D_Hit_Writeback_Invalid:begin
                if (state == REFILL && ret_valid)
                    tagv_we = (cache_hit) ? ( (hit[0]) ? 2'b01:2'b10 )  : '0;
                else 
                    tagv_we = '0;
            end
            default: begin
                tagv_we = '0;
            end
        endcase
        // case (DBus.cachetype.cacheCode)
        //     D_Index_Writeback_Invalid,D_Index_Store_Tag:begin
        //         tagv_we =   (DBus.cache_tag[1:0] == 2'b00) ? 4'b0001 :
        //                     (DBus.cache_tag[1:0] == 2'b01) ? 4'b0010 :
        //                     (DBus.cache_tag[1:0] == 2'b10) ? 4'b0100 : 4'b1000;
        //     end
        //     D_Hit_Invalid,D_Hit_Writeback_Invalid:begin
        //         tagv_we = (cache_hit) ? hit : '0;
        //     end
        //     default: begin
        //         tagv_we = '0;
        //     end
        // endcase
    end else if (state == REFILL && ret_valid) begin
        tagv_we = '0;
        tagv_we[lru[req_buffer.index]] =1'b1;
    end else begin
        tagv_we = '0;
    end
end

always_comb begin : data_we_blockName
    data_we = '0;
    if (state == REFILL && ret_valid) begin
        data_we[lru[req_buffer.index]] ='1;
    end else if((wb_state == WB_STORE || wb_state_next == WB_STORE) && store_buffer.valid)begin
        data_we[clog2((wb_state_next == WB_STORE && wb_state == WB_IDLE) ? hit : store_buffer.hit)][store_buffer.offset[OFFSET_WIDTH-1:2]] = store_buffer.wstrb;
    end else begin
        data_we = '0;
    end   
end

always_ff @( posedge clk_g ) begin : store_buffer_blockName
    if ( !resetn ) begin
        store_buffer <= '0;
    end else if( req_buffer.valid && ~ststall) begin
        store_buffer.hit   <= hit;
        store_buffer.valid <= (req_buffer.valid & req_buffer.wr);
        store_buffer.tag   <= req_buffer.tag;
        store_buffer.index <= req_buffer.index;
        store_buffer.offset <=req_buffer.offset;
        store_buffer.wstrb <= req_buffer.wstrb;
        store_buffer.wdata <= mux_byteenable(data_rdata_final2, req_buffer.wdata, req_buffer.wstrb);  
    end else if ( req_buffer.valid==1'b0 ) begin
        store_buffer <= '0;
    end

end


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

always_ff @(posedge clk_g) begin : pipe_hitblockName
    if (pipe_wr) begin
        pipe_cache_hit           <= cache_hit;
        pipe_hit                 <= hit;
    end 
end

always_ff @( posedge clk_g ) begin : req_buffer_block
    if( !resetn )begin
        req_buffer          <= '0;
    end else if(req_buffer_en) begin 
        req_buffer.valid    <=  DBus.req      ;
        req_buffer.wr       <=  DBus.wr       ;  
        req_buffer.tag      <=  DBus.cachetype.isDcache ? DBus.cache_tag : DBus.tag;
        req_buffer.index    <=  DBus.cachetype.isDcache ? DBus.cache_index : DBus.index;
        req_buffer.offset   <=  DBus.offset   ;
        req_buffer.wstrb    <=  DBus.wstrb    ;
        req_buffer.wdata    <=  DBus.wdata    ;
        req_buffer.size     <=  DBus.size     ;
        req_buffer.isCache  <=  DBus.iscache  ;
        req_buffer.cacheType<=  DBus.cachetype;
        req_buffer.cache_dirty <= DBus.cache_dirty;
        req_buffer.cache_valid <= DBus.cache_valid;
    end
end

always_ff @( posedge clk_g ) begin : uncache_rdata_blockName
    if (uret_valid) begin
        uncache_rdata <= uret_data;
    end
end


always_ff @( posedge clk_g ) begin : state_switch_blockName
    if( !resetn ) begin
        state <= LOOKUP ;
    end else begin 
        state <= state_next ;
    end
end


always_comb begin : state_next_blockName
    
    
    state_next = LOOKUP ;

    unique case (state)
        LOOKUP:begin
            if ( req_buffer.cacheType.isDcache && 
                 ((req_buffer.cacheType.cacheCode == D_Index_Writeback_Invalid && dirty_rdata[req_buffer.tag[0]])||
                 (req_buffer.cacheType.cacheCode == D_Hit_Writeback_Invalid && cache_hit && dirty_rdata[clog2(hit)]) ))
                state_next = MISSDIRTY;
            else if ( req_buffer.valid ) begin
                if ( req_buffer.isCache == 1'b0 ) begin
                    state_next = LOOKUP;
                end else begin
                    if ( cache_hit ) begin
                        state_next = LOOKUP;
                    end else begin
                        if (dirty_rdata[lru[req_buffer.index]]) begin
                            state_next = MISSDIRTY ;
                        end else begin
                            state_next = MISSCLEAN ;
                        end
                    end
                end     
            end else begin
                state_next = LOOKUP;
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
            if( wb_state == WB_STORE) begin
                state_next = REFILLDONE;
            end
            else begin
                state_next = LOOKUP ;
            end
        end
        MISSDIRTY:begin
            if ( wr_rdy ) begin
                state_next = WRITEBACK;
            end else begin
                state_next =  MISSDIRTY;
            end
        end
        WRITEBACK:begin
            if ( wr_bvalid ) begin
                state_next = MISSCLEAN;
            end else begin
                state_next = WRITEBACK;
            end
        end
        default: begin
            state_next =LOOKUP;
        end
    endcase
end

//wb_store_state
always_ff @( posedge clk_g ) begin :wb_state_blockname
    if ( !resetn ) begin
        wb_state <= WB_IDLE;
    end else begin
        wb_state <= wb_state_next;
    end
end

always_comb begin : wb_state_next_blockname
    if (req_buffer.valid && req_buffer.wr && cache_hit ) begin
        wb_state_next = WB_STORE;
    end else begin
        wb_state_next = WB_IDLE;
    end

end

always_ff @( posedge clk_g ) begin : uncache_state_blockName
    if (!resetn) begin
        uncache_state <= UNCACHE_IDLE;
    end else begin
        uncache_state <= uncache_state_next;
    end
end

always_comb begin : uncache_state_next_blockName

    //uncache_state_next = uncache_state;
    uncache_state_next = UNCACHE_IDLE;

    case (uncache_state)
        UNCACHE_IDLE:begin
            if (DBus.req & (~DBus.iscache)) begin 
                if (DBus.wr ==1'b0 ) begin
                    uncache_state_next = UNCACHE_READ_WAIT_AXI;
                end else begin
                    uncache_state_next = UNCACHE_IDLE;
                end
            end 
        end
        UNCACHE_READ_WAIT_AXI:begin
            if (urd_rdy) begin
                uncache_state_next = UNCACHE_READ;
            end
            else uncache_state_next = UNCACHE_READ_WAIT_AXI;
        end
        UNCACHE_READ:begin
            if (uret_valid) begin
                uncache_state_next = UNCACHE_READ_DONE;
            end
            else uncache_state_next = UNCACHE_READ;
        end
        UNCACHE_READ_DONE:begin
            if (DBus.req && (~DBus.iscache))  begin 
                if (DBus.wr ==1'b0) begin
                    uncache_state_next = UNCACHE_READ_WAIT_AXI;
                end else begin
                    uncache_state_next = UNCACHE_IDLE;
                end
            end
            else begin
                uncache_state_next = UNCACHE_IDLE;
                // end
            end
        end
        default:begin
            uncache_state_next = UNCACHE_IDLE;
        end
    endcase
end

// always_ff @( posedge clk_g ) begin : cache_state_blockName
//     if ( !resetn ) begin
//         cache_state <= CACHE_IDLE;
//     end else begin
//         cache_state <= cache_state_next;
//     end
// end

// always_comb begin : cache_state_next_blockName
//     case (cache_state)
//         CACHE_IDLE:begin
//             if (req_buffer.cacheType.isDcache) begin
//                 cache_state_next = CACHE_LOOKUP;
//             end else begin
//                 cache_state_next = CACHE_IDLE;
//             end
//         end
//         CACHE_LOOKUP:begin
//             case (req_buffer.cacheType.cacheCode)
//                 D_Index_Store_Tag:begin
//                     cache_state_next = CACHE_IDLE;
//                 end
//                 D_Index_Writeback_Invalid:begin
// //2
//                 if (req_buffer.tag[0]) begin
//                     if (pipe_tagv_rdata[1].valid & dirty_rdata[1]) begin
//                         cache_state_next = CACHE_WAIT_WRITE;
//                     end else begin
//                         cache_state_next = CACHE_IDLE;
//                     end
//                 end else begin
//                     if (pipe_tagv_rdata[0].valid & dirty_rdata[0]) begin
//                         cache_state_next = CACHE_WAIT_WRITE;
//                     end else begin
//                         cache_state_next = CACHE_IDLE;
//                     end
//                 end
// //4闁荤姳璀﹂崹顖涚箾閸ヮ剚鍋ㄩ柨鐕傛嫹               
//                 // case (req_buffer.tag[1:0])
//                 //     2'b00 : begin
//                 //         if(pipe_tagv_rdata[0].valid && dirty_rdata[0]) begin
//                 //             cache_state_next = CACHE_WAIT_WRITE ;
//                 //         end else begin
//                 //             cache_state_next = CACHE_IDLE ;
//                 //         end
//                 //     end
//                 //     2'b01 : begin
//                 //         if(pipe_tagv_rdata[1].valid && dirty_rdata[1]) begin
//                 //             cache_state_next = CACHE_WAIT_WRITE ;
//                 //         end else begin
//                 //             cache_state_next = CACHE_IDLE ;
//                 //         end
//                 //     end
//                 //     2'b10 : begin
//                 //         if(pipe_tagv_rdata[2].valid && dirty_rdata[2]) begin
//                 //             cache_state_next = CACHE_WAIT_WRITE ;
//                 //         end else begin
//                 //             cache_state_next = CACHE_IDLE ;
//                 //         end
//                 //     end
//                 //     2'b11 : begin
//                 //         if(pipe_tagv_rdata[3].valid && dirty_rdata[3]) begin
//                 //             cache_state_next = CACHE_WAIT_WRITE ;
//                 //         end else begin
//                 //             cache_state_next = CACHE_IDLE ;
//                 //         end
//                 //     end
//                 // endcase
//             end
//             D_Hit_Invalid:begin
//                 cache_state_next = CACHE_IDLE;
//             end
//             D_Hit_Writeback_Invalid:begin
// //2
//                 case (hit)
//                     2'b01:begin
//                         if (dirty_rdata[0]) begin
//                             cache_state_next = CACHE_WAIT_WRITE;
//                         end else begin
//                             cache_state_next = CACHE_IDLE;
//                         end
//                     end
//                     2'b10:begin
//                         if (dirty_rdata[1]) begin
//                             cache_state_next = CACHE_WAIT_WRITE;
//                         end else begin
//                             cache_state_next = CACHE_IDLE;
//                         end                            
//                     end
//                     default: begin
//                         cache_state_next = CACHE_IDLE;
//                     end
//                 endcase  
// //4 
//                 // case (hit)
//                 //     4'b0001:begin
//                 //         if (dirty_rdata[0]) begin
//                 //             cache_state_next = CACHE_WAIT_WRITE;
//                 //         end else begin
//                 //             cache_state_next = CACHE_IDLE;
//                 //         end
//                 //     end
//                 //     4'b0010:begin
//                 //         if (dirty_rdata[1]) begin
//                 //             cache_state_next = CACHE_WAIT_WRITE;
//                 //         end else begin
//                 //             cache_state_next = CACHE_IDLE;
//                 //         end                            
//                 //     end
//                 //     4'b0100:begin
//                 //         if (dirty_rdata[2]) begin
//                 //             cache_state_next = CACHE_WAIT_WRITE;
//                 //         end else begin
//                 //             cache_state_next = CACHE_IDLE;
//                 //         end                            
//                 //     end
//                 //     4'b1000:begin
//                 //         if (dirty_rdata[3]) begin
//                 //             cache_state_next = CACHE_WAIT_WRITE;
//                 //         end else begin
//                 //             cache_state_next = CACHE_IDLE;
//                 //         end                            
//                 //     end
//                 //     default: begin
//                 //         cache_state_next = CACHE_IDLE;
//                 //     end
//                 // endcase                 
//             end
//             default: begin
//                 cache_state_next = CACHE_IDLE;
//             end
//             endcase
//         end
//         CACHE_WAIT_WRITE:begin
//             if (wr_rdy) begin
//                 cache_state_next = CACHE_WRITEBACK;
//             end else begin
//                 cache_state_next = CACHE_WAIT_WRITE;
//             end
//         end
//         CACHE_WRITEBACK:begin
//             if (wr_bvalid) begin
//                 cache_state_next = CACHE_IDLE;
//             end else begin
//                 cache_state_next = CACHE_WRITEBACK;
//             end            
//         end
//         default: begin
//                 cache_state_next = CACHE_IDLE;
//         end
//     endcase
// end


FIFO #(
    .SIZE(STORE_BUFFER_SIZE),
    .dtype(uncache_store_t),
    .LATENCY (0) 
)

FIFO_dut (
    .clk (clk_g),
    .rst (~resetn),
    .din (fifo_din),
    .rd_en (fifo_rd_en ),
    .wr_en (fifo_wr_en ),
    .rd_rst_busy (fifo_rd_rst_busy ),
    .full (fifo_full ),
    .empty (fifo_empty ),
    .dout (fifo_dout ),
    .data_valid (fifo_data_valid ),
    .wr_ack (fifo_wr_ack ),
    .wr_rst_busy  (fifo_wr_rst_busy)
);

endmodule


