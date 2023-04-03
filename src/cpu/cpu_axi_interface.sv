`include "common.svh"

module cpu_axi_interface
(
    input         clk,
    input         reset,

    // ICache
    input  logic     icache_uncache,
    input  logic     icache_req,
    input  uint32_t  icache_addr,
    output logic     icache_addr_ready,
    output logic     icache_data_ready,
    output uint128_t icache_rdata,

    // DCache
    input  logic     dcache_rd_req,
    input  virt_t    dcache_rd_addr,
    output logic     dcache_rd_rdy,
    output logic     dcache_ret_valid,
    output uint128_t dcache_ret_data,
    input  logic     dcache_wr_req,
    input  virt_t    dcache_wr_addr,
    input  uint128_t dcache_wr_data,
    output logic     dcache_wr_rdy,
    output logic     dcache_wr_bvalid,

    // UnCache
    input  logic           uncache_rd_req,
    input  logic [  2:0]   uncache_rd_size,
    input  virt_t          uncache_rd_addr,
    output logic           uncache_rd_rdy,
    output logic           uncache_ret_valid,
    output uint32_t        uncache_ret_data,
    input  logic           uncache_wr_req,
    input  logic [  2:0]   uncache_wr_size,
    input  logic [  3:0]   uncache_wr_wstrb,
    input  virt_t          uncache_wr_addr,
    input  uint32_t        uncache_wr_data,
    output logic           uncache_wr_rdy,
    output logic           uncache_wr_bvalid,

    //axi
    //ar
    output [3 :0] arid         ,
    output [31:0] araddr       ,
    output [7 :0] arlen        ,
    output [2 :0] arsize       ,
    output [1 :0] arburst      ,
    output [1 :0] arlock        ,
    output [3 :0] arcache      ,
    output [2 :0] arprot       ,
    output        arvalid      ,
    input         arready      ,
    //r
    input  [3 :0] rid          ,
    input  [31:0] rdata        ,
    input  [1 :0] rresp        ,
    input         rlast        ,
    input         rvalid       ,
    output        rready       ,
    //aw
    output [3 :0] awid         ,
    output [31:0] awaddr       ,
    output [7 :0] awlen        ,
    output [2 :0] awsize       ,
    output [1 :0] awburst      ,
    output [1 :0] awlock       ,
    output [3 :0] awcache      ,
    output [2 :0] awprot       ,
    output        awvalid      ,
    input         awready      ,
    //w
    output [3 :0] wid          ,
    output [31:0] wdata        ,
    output [3 :0] wstrb        ,
    output        wlast        ,
    output        wvalid       ,
    input         wready       ,
    //b
    input  [3 :0] bid          ,
    input  [1 :0] bresp        ,
    input         bvalid       ,
    output        bready
);

// ICache state
typedef enum logic[1:0] {
    I_WAIT,
    I_READ,
    I_DONE
} icache_state_t;

icache_state_t  icache_state;
logic [3:0]     icache_target_size;
logic [3:0]     icache_index;
uint128_t       icache_data_buffer;

assign icache_addr_ready = icache_state == I_WAIT && icache_axi.arready;
assign icache_data_ready = icache_state == I_DONE;
assign icache_rdata      = icache_data_buffer;

always_ff @(posedge clk) begin
    if(reset || icache_state == I_DONE)
        icache_state <= I_WAIT;
    else if(icache_addr_ready && icache_req)
        icache_state <= I_READ;
    else if(icache_index == icache_target_size && icache_axi.rvalid)
        icache_state <= I_DONE;

    if(reset)
        icache_target_size <= 4'd0;
    else if(icache_addr_ready && icache_req)
        icache_target_size <= icache_uncache ? 4'd0 : 4'd3;
    else if(icache_data_ready)
        icache_target_size <= 4'd0;

    if(reset || icache_state == I_DONE)
        icache_index <= 4'd0;
    else if(icache_state == I_READ && icache_axi.rvalid)
        icache_index <= icache_index + 4'd1;

    if(reset)
        icache_data_buffer <= 128'd0;
    else if(icache_state == I_READ && icache_axi.rvalid)
        icache_data_buffer <= {icache_axi.rdata, icache_data_buffer[127:32]};
end

// ICache AXI
axi_t icache_axi;
// ar
assign icache_axi.arid    = 4'b0000;
assign icache_axi.araddr  = icache_addr;
assign icache_axi.arlen   = icache_uncache ? 8'd0 : 8'd3;
assign icache_axi.arsize  = 3'b10;
assign icache_axi.arburst = 2'b01;
assign icache_axi.arlock  = 2'b00;
assign icache_axi.arcache = '1;
assign icache_axi.arprot  = 3'b0;
assign icache_axi.arvalid = icache_req;
// r
assign icache_axi.rready  = icache_state == I_READ;
// aw
assign icache_axi.awid        = '0;
assign icache_axi.awlen       = '0;
assign icache_axi.awsize      = '0;
assign icache_axi.awburst     = '0;
assign icache_axi.awlock      = '0;
assign icache_axi.awcache     = '1;
assign icache_axi.awprot      = '0;
assign icache_axi.awvalid     = '0;
assign icache_axi.awaddr      = '0;
// w
assign icache_axi.wid         = '0;
assign icache_axi.wdata       = '0;
assign icache_axi.wstrb       = '0;
assign icache_axi.wlast       = '0;
assign icache_axi.wvalid      = '0;
// b
assign icache_axi.bready      = '0;

// DCache state
typedef enum logic [2:0] {
    D_WAIT,
    D_READ,
    D_WRITE,
    D_READ_DONE,
    D_WRITE_DONE
} dcache_state_t;

axi_t dcache_axi;
dcache_state_t  dcache_state;
logic [3:0]     dcache_target_size;
logic [3:0]     dcache_index;
uint128_t       dcache_data_buffer;

assign dcache_rd_rdy    = dcache_state == D_WAIT && dcache_axi.arready;
assign dcache_ret_valid = dcache_state == D_READ_DONE;
assign dcache_ret_data  = dcache_data_buffer;
assign dcache_wr_rdy    = dcache_state == D_WAIT && dcache_axi.awready;
assign dcache_wr_bvalid = dcache_state == D_WRITE_DONE && dcache_axi.bvalid;

always_ff @(posedge clk) begin
    if(reset || dcache_state == D_READ_DONE || (dcache_state == D_WRITE_DONE) && dcache_axi.bvalid)
        dcache_state <= D_WAIT;
    else if(dcache_rd_rdy && dcache_rd_req)
        dcache_state <= D_READ;
    else if(dcache_wr_rdy && dcache_wr_req) begin
        dcache_state <= D_WRITE;
        dcache_data_buffer <= dcache_wr_data;
    end
    else if(dcache_index == dcache_target_size) begin
        if(dcache_state == D_READ  && dcache_axi.rvalid)
        dcache_state <= D_READ_DONE;
        else if(dcache_state == D_WRITE && dcache_axi.wready)
        dcache_state <= D_WRITE_DONE;
    end

    if(reset)
        dcache_target_size <= 4'd0;
    else if(dcache_rd_rdy && dcache_rd_req || dcache_wr_rdy && dcache_wr_req)
        dcache_target_size <= 4'd3;
    else if(dcache_state == D_READ_DONE || dcache_state == D_WRITE_DONE)
        dcache_target_size <= 4'd0;

    if(reset || dcache_state == D_READ_DONE || dcache_state == D_WRITE_DONE) begin
        dcache_index <= 4'd0;
    end
    else if(dcache_state == D_READ  && dcache_axi.rvalid) begin
        dcache_index       <= dcache_index + 4'd1;
        dcache_data_buffer <= {dcache_axi.rdata, dcache_data_buffer[127:32]};
    end
    else if(dcache_state == D_WRITE && dcache_axi.wready) begin
        dcache_index       <= dcache_index + 4'd1;
        dcache_data_buffer <= {32'd0, dcache_data_buffer[127:32]};
    end
end

// DCache AXI
// ar
assign dcache_axi.arid    = 4'h1;
assign dcache_axi.araddr  = dcache_rd_addr;
assign dcache_axi.arlen   = 8'd3;
assign dcache_axi.arsize  = 3'b010;
assign dcache_axi.arburst = 2'b01;
assign dcache_axi.arlock  = 2'b00;
assign dcache_axi.arcache = '1;
assign dcache_axi.arprot  = 3'b0;
assign dcache_axi.arvalid = dcache_state == D_WAIT && dcache_rd_req;
// r
assign dcache_axi.rready  = dcache_state == D_READ;
// aw
assign dcache_axi.awid    = 4'h1;
assign dcache_axi.awaddr  = dcache_wr_addr;
assign dcache_axi.awlen   = 8'd3;
assign dcache_axi.awsize  = 3'b010;
assign dcache_axi.awburst = 2'b01;
assign dcache_axi.awlock  = '0;
assign dcache_axi.awcache = '1;
assign dcache_axi.awprot  = '0;
assign dcache_axi.awvalid = dcache_state == D_WAIT && dcache_wr_req;
// w
assign dcache_axi.wid     = 4'b0001;
assign dcache_axi.wdata   = dcache_data_buffer[31:0];
assign dcache_axi.wstrb   = '1;
assign dcache_axi.wlast   = dcache_index == dcache_target_size && dcache_state == D_WRITE;
assign dcache_axi.wvalid  = dcache_state == D_WRITE;
// b
assign dcache_axi.bready  = dcache_state == D_WRITE_DONE;

// UnCache
typedef enum logic [1:0] {
    U_WAIT,
    U_READ,
    U_WRITE,
    U_WRITE_DONE
} uncache_state_t;

axi_t    uncache_axi;
uncache_state_t  uncache_rd_state, uncache_wr_state;
uint32_t uncache_wr_data_r;
logic [3:0] uncache_wr_wstrb_r;

assign uncache_rd_rdy    = uncache_rd_state == U_WAIT  && uncache_rd_req && uncache_axi.arready;
assign uncache_ret_valid = uncache_rd_state == U_READ  && uncache_axi.rvalid;
assign uncache_ret_data  = uncache_axi.rdata;
assign uncache_wr_rdy    = uncache_wr_state == U_WAIT  && uncache_wr_req && uncache_axi.awready;
assign uncache_wr_bvalid = uncache_wr_state == U_WRITE_DONE && uncache_axi.bvalid;

always_ff @(posedge clk) begin
    if(reset || uncache_ret_valid)
        uncache_rd_state <= U_WAIT;
    else if(uncache_rd_rdy)
        uncache_rd_state <= U_READ;

    if(reset || uncache_wr_bvalid)
        uncache_wr_state <= U_WAIT;
    else if(uncache_wr_state == U_WAIT && uncache_wr_rdy)
        uncache_wr_state <= U_WRITE;
    else if(uncache_wr_state == U_WRITE && uncache_axi.wready)
        uncache_wr_state <= U_WRITE_DONE;

    if(uncache_wr_rdy) begin
        uncache_wr_data_r <= uncache_wr_data;
        uncache_wr_wstrb_r <= uncache_wr_wstrb;
    end
end

// unCache AXI
// ar
assign uncache_axi.arid    = 4'h2;
assign uncache_axi.araddr  = uncache_rd_addr;
assign uncache_axi.arlen   = 8'b0000;
assign uncache_axi.arsize  = uncache_rd_size;
assign uncache_axi.arburst = 2'b00;
assign uncache_axi.arlock  = 2'b00;
assign uncache_axi.arcache = '1;
assign uncache_axi.arprot  = 3'b0;
assign uncache_axi.arvalid = uncache_rd_state == U_WAIT && uncache_rd_req;
// r
assign uncache_axi.rready  = uncache_rd_state == U_READ;
// aw
assign uncache_axi.awid    = 4'h2;
assign uncache_axi.awaddr  = uncache_wr_addr;
assign uncache_axi.awlen   = 8'b0000;
assign uncache_axi.awsize  = uncache_wr_size;
assign uncache_axi.awburst = 2'b00;
assign uncache_axi.awlock  = '0;
assign uncache_axi.awcache = '1;
assign uncache_axi.awprot  = '0;
assign uncache_axi.awvalid = uncache_wr_state == U_WAIT && uncache_wr_req;
// w
assign uncache_axi.wid     = 4'h2;
assign uncache_axi.wdata   = uncache_wr_data_r;
assign uncache_axi.wstrb   = uncache_wr_wstrb_r;
assign uncache_axi.wlast   = uncache_wr_state == U_WRITE;
assign uncache_axi.wvalid  = uncache_wr_state == U_WRITE;
// b
assign uncache_axi.bready  = uncache_wr_state == U_WRITE_DONE;

// axi_crossbar
assign arlock = 2'b00;
assign awlock = 2'b00;
assign wid    = awid;

axi_crossbar_cache biu (
.aclk             ( clk     ),
.aresetn          ( ~reset        ),

.s_axi_arid       ( {icache_axi.arid   ,dcache_axi.arid   ,uncache_axi.arid   } ),
.s_axi_araddr     ( {icache_axi.araddr ,dcache_axi.araddr ,uncache_axi.araddr } ),
.s_axi_arlen      ( {icache_axi.arlen  ,dcache_axi.arlen  ,uncache_axi.arlen  } ),
.s_axi_arsize     ( {icache_axi.arsize ,dcache_axi.arsize ,uncache_axi.arsize } ),
.s_axi_arburst    ( {icache_axi.arburst,dcache_axi.arburst,uncache_axi.arburst} ),
.s_axi_arlock     ( {icache_axi.arlock ,dcache_axi.arlock ,uncache_axi.arlock } ),
.s_axi_arcache    ( {icache_axi.arcache,dcache_axi.arcache,uncache_axi.arcache} ),
.s_axi_arprot     ( {icache_axi.arprot ,dcache_axi.arprot ,uncache_axi.arprot } ),
.s_axi_arqos      ( 0                                        ),
.s_axi_arvalid    ( {icache_axi.arvalid,dcache_axi.arvalid,uncache_axi.arvalid } ),
.s_axi_arready    ( {icache_axi.arready,dcache_axi.arready,uncache_axi.arready } ),

.s_axi_rid        ( {icache_axi.rid    ,dcache_axi.rid    ,uncache_axi.rid   } ),
.s_axi_rdata      ( {icache_axi.rdata  ,dcache_axi.rdata  ,uncache_axi.rdata } ),
.s_axi_rresp      ( {icache_axi.rresp  ,dcache_axi.rresp  ,uncache_axi.rresp } ),
.s_axi_rlast      ( {icache_axi.rlast  ,dcache_axi.rlast  ,uncache_axi.rlast } ),
.s_axi_rvalid     ( {icache_axi.rvalid ,dcache_axi.rvalid ,uncache_axi.rvalid} ),
.s_axi_rready     ( {icache_axi.rready ,dcache_axi.rready ,uncache_axi.rready} ),

.s_axi_awid       ( {icache_axi.awid   ,dcache_axi.awid   ,uncache_axi.awid   } ),
.s_axi_awaddr     ( {icache_axi.awaddr ,dcache_axi.awaddr ,uncache_axi.awaddr } ),
.s_axi_awlen      ( {icache_axi.awlen  ,dcache_axi.awlen  ,uncache_axi.awlen  } ),
.s_axi_awsize     ( {icache_axi.awsize ,dcache_axi.awsize ,uncache_axi.awsize } ),
.s_axi_awburst    ( {icache_axi.awburst,dcache_axi.awburst,uncache_axi.awburst} ),
.s_axi_awlock     ( {icache_axi.awlock ,dcache_axi.awlock ,uncache_axi.awlock } ),
.s_axi_awcache    ( {icache_axi.awcache,dcache_axi.awcache,uncache_axi.awcache} ),
.s_axi_awprot     ( {icache_axi.awprot ,dcache_axi.awprot ,uncache_axi.awprot } ),
.s_axi_awqos      ( 0                                        ),
.s_axi_awvalid    ( {icache_axi.awvalid,dcache_axi.awvalid,uncache_axi.awvalid } ),
.s_axi_awready    ( {icache_axi.awready,dcache_axi.awready,uncache_axi.awready } ),

// .s_axi_wid        ( {icache_axi.wid    ,dcache_axi.wid     } ),
.s_axi_wdata      ( {icache_axi.wdata  ,dcache_axi.wdata  ,uncache_axi.wdata } ),
.s_axi_wstrb      ( {icache_axi.wstrb  ,dcache_axi.wstrb  ,uncache_axi.wstrb } ),
.s_axi_wlast      ( {icache_axi.wlast  ,dcache_axi.wlast  ,uncache_axi.wlast } ),
.s_axi_wvalid     ( {icache_axi.wvalid ,dcache_axi.wvalid ,uncache_axi.wvalid} ),
.s_axi_wready     ( {icache_axi.wready ,dcache_axi.wready ,uncache_axi.wready} ),
.s_axi_bid        ( {icache_axi.bid    ,dcache_axi.bid    ,uncache_axi.bid   } ),
.s_axi_bresp      ( {icache_axi.bresp  ,dcache_axi.bresp  ,uncache_axi.bresp } ),
.s_axi_bvalid     ( {icache_axi.bvalid ,dcache_axi.bvalid ,uncache_axi.bvalid} ),
.s_axi_bready     ( {icache_axi.bready ,dcache_axi.bready ,uncache_axi.bready} ),

.m_axi_arid       ( arid          ),
.m_axi_araddr     ( araddr        ),
.m_axi_arlen      ( arlen         ),
.m_axi_arsize     ( arsize        ),
.m_axi_arburst    ( arburst       ),
// .m_axi_arlock     ( arlock        ),
.m_axi_arcache    ( arcache       ),
.m_axi_arprot     ( arprot        ),
.m_axi_arqos      (               ),
.m_axi_arvalid    ( arvalid       ),
.m_axi_arready    ( arready       ),

.m_axi_rid        ( rid           ),
.m_axi_rdata      ( rdata         ),
.m_axi_rresp      ( rresp         ),
.m_axi_rlast      ( rlast         ),
.m_axi_rvalid     ( rvalid        ),
.m_axi_rready     ( rready        ),

.m_axi_awid       ( awid          ),
.m_axi_awaddr     ( awaddr        ),
.m_axi_awlen      ( awlen         ),
.m_axi_awsize     ( awsize        ),
.m_axi_awburst    ( awburst       ),
// .m_axi_awlock     ( awlock        ),
.m_axi_awcache    ( awcache       ),
.m_axi_awprot     ( awprot        ),
.m_axi_awqos      (               ),
.m_axi_awvalid    ( awvalid       ),
.m_axi_awready    ( awready       ),

// .m_axi_wid        ( wid           ),
.m_axi_wdata      ( wdata         ),
.m_axi_wstrb      ( wstrb         ),
.m_axi_wlast      ( wlast         ),
.m_axi_wvalid     ( wvalid        ),
.m_axi_wready     ( wready        ),
.m_axi_bid        ( bid           ),
.m_axi_bresp      ( bresp         ),
.m_axi_bvalid     ( bvalid        ),
.m_axi_bready     ( bready        )
);


endmodule
