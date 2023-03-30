//data_wdata tagv_wdata
`include "Cache_define.svh"
`include "../cpu_defs.svh"

module icache #(
    parameter STORE_BUFFER_SIZE = 32,
    parameter DATA_WIDTH    = 32,//cache閿熸枻鎷穋pu 閿熸枻鎷烽敓鏂ゆ嫹閿熸枻鎷烽敓鏂ゆ嫹浣嶉敓鏂ゆ嫹涓篸ata_width 32浣嶉敓鏂ゆ嫹???
    parameter LINE_WORD_NUM = 4,//cache line閿熸枻鎷峰皬 ???閿熸枻鎷烽敓鏂ゆ嫹閿熸枻鎷烽敓锟�16閿熻鏂ゆ嫹 4???
    parameter ASSOC_NUM     = 4,//assoc_num閿熸枻鎷烽敓鏂ゆ嫹???2???
    parameter WAY_SIZE      = 4*1024*8,//???璺痗ache 閿熸枻鎷烽敓鏂ゆ嫹閿熸枻鎷峰皬涓簑ay_size bit 4kB
    parameter GROUP_NUM     = WAY_SIZE/(LINE_WORD_NUM*DATA_WIDTH) //256閿熸枻鎷烽敓鏂ゆ嫹/???

)(
    input  logic           clk_g,
    input  logic           resetn,
    //cpu
    CPU_DCache_Interface   CPU_DCache_Bus,
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
    input  logic           wr_b_valid,
    //uncache
    output logic           urd_req,
    output logic [  2:0]   urd_type,//
    output logic [ 31:0]   urd_addr,
    input  logic           urd_rdy,
    input  logic           uret_valid,
    input  logic [ 31:0]   uret_data,
    input  logic [ 31:0]   uwr_req,
    output logic [  2:0]   uwr_type,//
    output logic [ 31:0]   uwr_addr,
    output logic [  3:0]   uwr_wstrb,//
    output logic [ 31:0]   uwr_data,
    input  logic           uwr_rdy
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

typedef logic [ASSOC_NUM-1:0]                     gpwe_t;//姣忎竴璺敓鏂ゆ嫹鍐欎娇???
typedef logic [DATA_WIDTH-1:0]                    data_t;//姣忎竴璺竴閿熸枻鎷穋ache_line

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

function logic[1:0] clog2(
    input logic [ASSOC_NUM-1:0] hit
);
    return{
        (hit[3] == 1'b1) ? 2'b11 : 
        (hit[2] == 1'b1) ? 2'b10 : 
        (hit[1] == 1'b1) ? 2'b01 : 2'b00
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
    logic[3:0]        wstrb; //鍐欎娇???
    logic[31:0]       wdata; //store閿熸枻鎷烽敓鏂ゆ嫹
    LoadType          size;//load缁鐎�
    logic             isCache;
    //CacheType         cacheType;
} request_t;


typedef struct packed {//store鎸囬敓鏂ゆ嫹閿熻妭璁规嫹閿熸枻鎷烽敓鏂ゆ嫹鏃�???閿熸枻鎷烽敓鏂ゆ嫹鍐欎娇閿熸枻鎷烽敓鑺ユ崲
    logic [ASSOC_NUM-1:0] hit;
    logic                 valid;
    tag_t                 tag;
    index_t               index;
    offset_t              offset;
    data_t                wdata;
} store_t;

typedef enum logic [1:0]{ 
    UNCACHE_IDLE,//缁屾椽妫介幀锟�
    UNCACHE_READ_WAIT_AXI,//缁涘绶熺拠缁樺綑閹碉拷
    UNCACHE_READ,//缁涘绶熺拠缁樻殶閹癸拷
    UNCACHE_READ_DONE//鐠囪鐣幋锟�
} uncache_state_t;

uncache_state_t uncache_state,uncache_state_next;
store_t  store_buffer; //閿熸枻鎷烽敓鏂ゆ嫹閿熷彨杈炬嫹閿熼叺锟� 鐩撮敓鏂ゆ嫹閿熸枻鎷烽敓鏂ゆ嫹
state_t  state,state_next;

wb_state_t wb_state,wb_state_next;

logic [31:0] uncache_rdata;

index_t read_addr, write_addr, tagv_addr;//閿熻璇ф嫹璇㈤敓渚ョ鎷峰潃 涔熼敓鏂ゆ嫹閿熸枻鎷烽敓鏂ゆ嫹鐗￠敓锟�??? 閿熸枻鎷烽敓鏂ゆ嫹閿熸枻鎷穝tore瑕佸啓cache閿熶茎纰夋嫹???

tagv_t [ASSOC_NUM-1:0] tagv_rdata;
tagv_t                 tagv_wdata;
gpwe_t                 tagv_we;// 閿熸枻鎷烽敓鏂ゆ嫹閿熺粸鎲嬫嫹閿熷彨璇嶇櫢鎷烽敓锟�

index_t                 dirty_addr;
dirty_t [ASSOC_NUM-1:0] dirty_rdata;
dirty_t                 dirty_wdata;
gpwe_t                  dirty_we;

gpwe_t wb_we;//store閿熸枻鎷峰啓浣块敓鏂ゆ嫹

data_t                                                        data_rdata [ASSOC_NUM-1:0][LINE_WORD_NUM-1:0];
logic [31:0]                                                  data_rdata_sel[ASSOC_NUM-1:0];
logic [31:0]                                                  data_rdata_final1;
logic [31:0]                                                  data_rdata_final2;
data_t                                                        data_wdata[LINE_WORD_NUM-1:0];
logic  [ASSOC_NUM-1:0][LINE_WORD_NUM-1:0]                     data_we;//閿熸枻鎷烽敓鎹锋唻鎷峰啓浣块敓鏂ゆ嫹
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

//鏉╃€巌fo閹恒儱褰�
assign fifo_din   = {req_buffer.tag,req_buffer.index,req_buffer.offset,req_buffer.wdata,req_buffer.wstrb};
assign fifo_wr_en = (fifo_wr_rst_busy || fifo_full || (~(req_buffer.valid & req_buffer.wr & (~req_buffer.isCache))) ) ?  1'b0 : 1'b1;//濞翠焦鎸夌痪鍨粻濠婏拷 娑撳秷鍏橀崘锟� fifo濠婏拷 娑撳秵妲竨ncache閸愭瑦瀵氭禒锟�
assign fifo_rd_en = (axi_ubus.wr_rdy && (!fifo_empty) && (!fifo_rd_rst_busy)) ? 1'b1 :1'b0;//闂堢偟鈹� 閼宠棄鍟� 
//cpu
//閸︽澘娼冮幓鈩冨娣団€冲娇
assign CPU_DCache_Bus.addr_ok   = ( state_next == LOOKUP) && CPU_DCache_Bus.req;
//閺佺増宓侀幓鈩冨娣団€冲娇
assign CPU_DCache_Bus.data_ok   = ((state == LOOKUP || state == REFILLDONE) && state_next == LOOKUP && req_buffer.valid);

assign CPU_DCache_Bus.rdata     =  ( req_buffer.valid ) ? data_rdata_final1 : '0;
//axi
assign rd_req = (state == MISSCLEAN) ? 1'b1 : 1'b0;
assign rd_type = '0;
assign rd_addr = {req_buffer.tag,req_buffer.index, {OFFSET_WIDTH{1'b0}}};
assign wr_req = (state == MISSDIRTY) ? 1'b1 : 1'b0;
assign wr_type = '0;
assign wr_wstrb = '0;
assign wr_addr = {pipe_tagv_rdata[lru[req_buffer.index]].tag, req_buffer.index, {OFFSET_WIDTH{1'b0}}};

generate;
    for (genvar  i=0; i<LINE_WORD_NUM; ++i) begin
        assign wr_data[32*(i+1)-1:32*(i)] = data_rdata[lru[req_buffer.index]][i];
    end
endgenerate

//鏉╃€墄i_ubus閹恒儱褰�
assign urd_req   = (uncache_state == UNCACHE_READ_WAIT_AXI) ? 1'b1:1'b0;
assign urd_addr  = {req_buffer.tag , req_buffer.index, req_buffer.offset};
assign uwr_req   = (fifo_empty || fifo_rd_rst_busy) ? 1'b0:1'b1;//閺堝娈ｉ幃锟� fifo娑撳碁mpty 閸欘亝妲搁弮鐘崇《閸戠儤鐖� 鐏忓彉绱扮€佃壈鍤ч弮鐘崇《閸欐垵鍤崘娆掝嚞濮瑰倿鍋呮稊鍫濆讲閼宠棄姘ㄦ导姘愁唨鐠囪鍘涙禍锟� 娑撳秷绻冮柈绲〆setn娴滐拷 閹存垼顕氱亸杈ㄧ梾閺堝顕版禍锟�
assign uwr_addr  = {fifo_dout.address}; //TODO:濞屸剝婀侀幎褰掓祩
assign uwr_data  = {fifo_dout.data};
assign uwr_wstrb = fifo_dout.wstrb;
assign uloadType = req_buffer.size;

assign ststall = 0;
assign cache_hit        = |hit;//ok

assign read_addr        = req_buffer_en ? CPU_ICache_Bus.index : req_buffer.index;
assign write_addr       = ( state == REFILL ) ? req_buffer.index : store_buffer.index;
assign tagv_addr        = req_buffer.index;

assign data_rdata_final1 =   (uncache_state == UNCACHE_READ_DONE )? uncache_rdata: data_rdata_final2;

assign pipe_wr          = (state_next == MISSCLEAN || state_next == MISSDIRTY); // ??????????????????

//req_buffer閸愭瑤濞囬懗锟�
assign req_buffer_en    = (state_next == LOOKUP && CPU_DCache_Bus.req || CPU_DCache_Bus.data_ok);

generate;//
    for (genvar i=0; i<LINE_WORD_NUM; i++) begin
        assign data_wdata[i] = (state == REFILL) ? ret_data[(i+1)*32-1:i*32] : store_buffer.wdata;
    end
endgenerate

assign tagv_wdata       = (state == REFILL) ? {1'b1, req_buffer.tag} : '0;

assign data_read_en     = 1'b1;

assign dirty_wdata      = (state == REFILL) ? 1'b0 : 1'b1;
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
            .SIZE(GROUP_NUM)
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

generate;//PLRU 缁犳纭�
    for (genvar  i=0; i<GROUP_NUM; i++) begin
        PLRU #(
            .ASSOC_NUM(ASSOC_NUM)
        ) plru_reg(
            .clk(clk_g),
            .resetn(resetn),
            .access(hit),
            .update(req_buffer.valid && i[INDEX_WIDTH-1:0] == req_buffer.index),//閿熸枻鎷烽敓绲犻敓鏂ゆ嫹浠€涔�

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
    if (state == REFILL) begin
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
    if (state == REFILL) begin
        tagv_we = '0;
        tagv_we[lru[req_buffer.index]] =1'b1;
    end else begin
        tagv_we = '0;
    end
end

always_comb begin : data_we_blockName
        data_we = '0;
    if (state == REFILL) begin
        data_we[lru[req_buffer.index]] ='1;
    end else if(wb_state == WB_STORE || wb_state_next == WB_STORE)begin
        data_we[clog2((wb_state_next == WB_STORE && wb_state == WB_IDLE) ? hit : store_buffer.hit)][store_buffer.offset[OFFSET_WIDTH-1:2]] = 1'b1;
    end else begin
        data_we = '0;
    end   
end

always_ff @( posedge clk_g ) begin : store_buffer_blockName
    if ( !resetn ) begin
        store_buffer <= '0;
    end else if( req_buffer.valid && ~ststall) begin//閿熸枻鎷烽敓鏂ゆ嫹??? 閿熸枻鎷烽敓鏂ゆ嫹閿熸枻鎷锋晥???
        store_buffer.hit   <= hit;
        store_buffer.valid <= (req_buffer.valid & req_buffer.op);
        store_buffer.tag   <= req_buffer.tag;
        store_buffer.index <= req_buffer.index;
        store_buffer.offset <=req_buffer.offset;
        store_buffer.wdata <= mux_byteenable(data_rdata_final2, req_buffer.wdata, req_buffer.wstrb);  
    end else if ( req_buffer.valid==1'b0 ) begin//閿熻妭鍑ゆ嫹鍋滈敓鏂ゆ嫹鐘�???閿熸枻鎷�??瑕侀敓鏂ゆ嫹?? 閿熸枻鎷烽敓瑙掕揪鎷锋椂閿熺煫杈炬嫹閿熸枻鎷锋晥 ??閿熸枻鎷烽敓鏂ゆ嫹??
        store_buffer <= '0;
    end

end


generate;//閿熸枻鎷烽敓鏂ゆ嫹閿熸枻鎷烽敓鏂ゆ嫹閿熺但ag
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
        pipe_hit                 <= (1<<lru[req_buffer.index]);
    end 
end

always_ff @( posedge clk_g ) begin : req_buffer_block
    if( !resetn )begin
        req_buffer          <= '0;
    end else if(req_buffer_en) begin 
        req_buffer.valid    <=  CPU_DCache_Bus.req     ;
        req_buffer.wr       <=  CPU_DCache_Bus.wr      ;  
        req_buffer.tag      <=  CPU_DCache_Bus.tag     ;
        req_buffer.index    <=  CPU_DCache_Bus.index   ;
        req_buffer.offset   <=  CPU_DCache_Bus.offdrt  ;
        req_buffer.wstrb    <=  CPU_DCache_Bus.wstrb   ;
        req_buffer.wdata    <=  CPU_DCache_Bus.wdata   ;
        req_buffer.size     <=  CPU_DCache_Bus.size    ;
        req_buffer.isCache  <=  CPU_DCache_Bus.iscache ;
    end
end

always_ff @( posedge clk_g ) begin : uncache_rdata_blockName//閺囧瓨鏌妘ncache鐠囪鍤弶銉ф畱閿燂拷?
    if (uret_valid) begin
        uncache_rdata <= uret_data;
    end
end

//鐘�???杞�???
always_ff @( posedge clk_g ) begin : state_switch_blockName
    if( !resetn ) begin
        state <= LOOKUP ;
    end else begin 
        state <= state_next ;
    end
end

//閿熸枻鎷烽敓鏂ゆ嫹鐘�??? 
always_comb begin : state_next_blockName
    
    
    state_next = LOOKUP ;

    unique case (state)
        LOOKUP:begin
            if ( req_buffer.valid ) begin
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
            if ( rd_rdy ) begin//閿熸枻鎷烽敓鏂ゆ嫹???
                state_next = REFILL;
            end else begin
                state_next = MISSCLEAN;
            end
        end
        REFILL:begin
            if ( ret_valid ) begin//鍊奸敓鏂ゆ嫹???
                state_next = LOOKUP;
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
            if ( wr_b_valid ) begin
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
            if (CPU_DCache_Bus.req & (~CPU_DCache_Bus.iscache) & req_buffer_en) begin //婵″倹鐏夐崣顖欎簰閹恒儱褰堟稉瀣╃娑擃亣顕Ч锟�
                if (CPU_DCache_Bus.wr ==1'b0 ) begin
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
        end
        UNCACHE_READ:begin
            if (uret_valid) begin
                uncache_state_next = UNCACHE_READ_DONE;
            end
        end
        UNCACHE_READ_DONE:begin
                if (CPU_DCache_Bus.req & (~CPU_DCache_Bus.iscache) & req_buffer_en) begin //韫囧懐鍔ф稉瀣╃閹峰秷顩﹂崣鎴ｆ崳鐠佸灝鐡�
                    if (CPU_DCache_Bus.wr ==1'b0) begin
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


FIFO #(
    .SIZE(STORE_BUFFER_SIZE),
    .dtype(uncache_store_t),
    .LATENCY (0) //鐠嬪啯鏆ｆ稉锟�0
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



