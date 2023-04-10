`include "../common.svh"
`include "cpu.svh"

module SimpleMIPS (
    input logic clk,
    input logic rstn,
    //! exception
    input logic [5:0] ext_int,
    //! AXI
    //! AXI/AR read address
    output [3 :0]   arid   ,
    output virt_t   araddr ,
    output [7 :0]   arlen  ,
    output [2 :0]   arsize ,
    output [1 :0]   arburst,
    output [1 :0]   arlock ,
    output [3 :0]   arcache,
    output [2 :0]   arprot ,
    output          arvalid,
    input           arready,
    //! AXI/R read data
    input  [3 :0]   rid    ,
    input  uint32_t rdata  ,
    input  [1 :0]   rresp  ,
    input           rlast  ,
    input           rvalid ,
    output          rready ,
    //! AXI/AW write address
    output [3 :0]   awid   ,
    output virt_t   awaddr ,
    output [7 :0]   awlen  ,
    output [2 :0]   awsize ,
    output [1 :0]   awburst,
    output [1 :0]   awlock ,
    output [3 :0]   awcache,
    output [2 :0]   awprot ,
    output          awvalid,
    input           awready,
    //! AXI/W write data
    output [3 :0]   wid    ,
    output uint32_t wdata  ,
    output [3 :0]   wstrb  ,
    output          wlast  ,
    output          wvalid ,
    input           wready ,
    //! AXI/B write response
    input  [3 :0]   bid    ,
    input  [1 :0]   bresp  ,
    input           bvalid ,
    output          bready ,
    //! debug interface for trace
    output [31:0] debug_wb_pc,
    output [ 3:0] debug_wb_rf_wen,
    output [ 4:0] debug_wb_rf_wnum,
    output [31:0] debug_wb_rf_wdata
);

reg reset;
always @(posedge clk) reset <= ~rstn;

// CPU_ICache
CPU_ICache_Interface CPU_ICache();
logic     icache_uncache;
logic     icache_req;
uint32_t  icache_addr;
logic     icache_addr_ready;
logic     icache_data_ready;
uint128_t icache_rdata;

// CPU_DCache
CPU_DCache_Interface CPU_DCache();
logic           dcache_rd_req;
logic [ 31:0]   dcache_rd_addr;
logic           dcache_rd_rdy;
logic           dcache_ret_valid;
logic [127:0]   dcache_ret_data;
logic           dcache_wr_req;
logic [ 31:0]   dcache_wr_addr;
logic [127:0]   dcache_wr_data;
logic           dcache_wr_rdy;
logic           dcache_wr_bvalid;

// CPU_UnCache
logic           uncache_rd_req;
logic [  2:0]   uncache_rd_size;
logic [ 31:0]   uncache_rd_addr;
logic           uncache_rd_rdy;
logic           uncache_ret_valid;
logic [ 31:0]   uncache_ret_data;
logic           uncache_wr_req;
logic [  2:0]   uncache_wr_size;
logic [  3:0]   uncache_wr_wstrb;
logic [ 31:0]   uncache_wr_addr;
logic [ 31:0]   uncache_wr_data;
logic           uncache_wr_rdy;
logic           uncache_wr_bvalid;

//! AXI
axi_t axi;

assign axi.arid         = arid;
assign axi.req.araddr   = araddr;
assign axi.req.arlen    = arlen;
assign axi.req.arsize   = arsize;
assign axi.req.arburst  = arburst;
assign axi.req.arlock   = arlock;
assign axi.req.arcache  = arcache;
assign axi.req.arprot   = arprot;
assign axi.req.arvalid  = arvalid;
assign axi.resp.arready = arready;
assign axi.rid          = rid;
assign axi.req.rready   = rready;
assign axi.resp.rdata   = rdata;
assign axi.resp.rresp   = rresp;
assign axi.resp.rlast   = rlast;
assign axi.resp.rvalid  = rvalid;
assign axi.awid         = awid;
assign axi.req.awaddr   = awaddr;
assign axi.req.awlen    = awlen;
assign axi.req.awsize   = awsize;
assign axi.req.awburst  = awburst;
assign axi.req.awlock   = awlock;
assign axi.req.awcache  = awcache;
assign axi.req.awprot   = awprot;
assign axi.req.awvalid  = awvalid;
assign axi.resp.awready = awready;
assign axi.wid          = wid;
assign axi.req.wdata    = wdata;
assign axi.req.wstrb    = wstrb;
assign axi.req.wlast    = wlast;
assign axi.req.wvalid   = wvalid;
assign axi.resp.wready  = wready;
assign axi.bid          = bid;
assign axi.req.bready   = bready;
assign axi.resp.bresp   = bresp;
assign axi.resp.bvalid  = bvalid;

cpu_core u_cpu_core (
    //! common
    .clk,
    .reset,
    //! exception
    .ext_int,
    //! ICache
    .IBus             (CPU_ICache.CPU   ),
    //! data_sram
    .DBus             (CPU_DCache.CPU   ),
    //! debug interface
    .debug_wb_pc      (debug_wb_pc      ),
    .debug_wb_rf_wen  (debug_wb_rf_wen  ),
    .debug_wb_rf_wnum (debug_wb_rf_wnum ),
    .debug_wb_rf_wdata(debug_wb_rf_wdata)
);

icache u_icache(
    .clk_g(clk),
    .resetn(~reset),

    .IBus           (CPU_ICache.ICache),

    .rd_uncache     (icache_uncache   ),
    .rd_req         (icache_req       ),
    .rd_addr        (icache_addr      ),
    .rd_rdy         (icache_addr_ready),
    .ret_valid      (icache_data_ready),
    .ret_data       (icache_rdata     )
);

dcache u_dcache(
    .clk_g(clk),
    .resetn(~reset),

    .DBus           (CPU_DCache.DCache),
    // DCache
    .rd_req         (dcache_rd_req   ),
    .rd_addr        (dcache_rd_addr  ),
    .rd_rdy         (dcache_rd_rdy   ),
    .ret_valid      (dcache_ret_valid),
    .ret_data       (dcache_ret_data ),
    .wr_req         (dcache_wr_req   ),
    .wr_addr        (dcache_wr_addr  ),
    .wr_data        (dcache_wr_data  ),
    .wr_rdy         (dcache_wr_rdy   ),
    .wr_bvalid      (dcache_wr_bvalid),
    // UnCache
    .urd_req       (uncache_rd_req   ),
    .urd_size      (uncache_rd_size  ),
    .urd_addr      (uncache_rd_addr  ),
    .urd_rdy       (uncache_rd_rdy   ),
    .uret_valid    (uncache_ret_valid),
    .uret_data     (uncache_ret_data ),
    .uwr_req       (uncache_wr_req   ),
    .uwr_size      (uncache_wr_size  ),
    .uwr_addr      (uncache_wr_addr  ),
    .uwr_wstrb     (uncache_wr_wstrb ),
    .uwr_data      (uncache_wr_data  ),
    .uwr_rdy       (uncache_wr_rdy   ),
    .uwr_bvalid    (uncache_wr_bvalid)
);

cpu_axi_interface u_cpu_axi_interface (
    .*
);

endmodule
