`include "cpu.svh"

module SimpleMIPS(
    input logic clk,
    input logic resetn,
    // ex
    input logic [5:0] ext_int,
    // axi
    //ar
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
    //r
    input  [3 :0]   rid    ,
    input  uint32_t rdata  ,
    input  [1 :0]   rresp  ,
    input           rlast  ,
    input           rvalid ,
    output          rready ,
    //aw
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
    //w
    output [3 :0]   wid    ,
    output uint32_t wdata  ,
    output [3 :0]   wstrb  ,
    output          wlast  ,
    output          wvalid ,
    input           wready ,
    //b
    input  [3 :0]   bid    ,
    input  [1 :0]   bresp  ,
    input           bvalid ,
    output          bready ,
    // trace debug interface
    output [31:0] debug_wb_pc,
    output [ 3:0] debug_wb_rf_wen,
    output [ 4:0] debug_wb_rf_wnum,
    output [31:0] debug_wb_rf_wdata
);
reg reset;
always @(posedge clk) reset <= ~resetn;

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

cpu_core u_cpu_core(
    .clk,
    .reset,

    .ext_int,

    // ICache
    .IBus             (CPU_ICache.CPU   ),
    // data_sram
    .DBus             (CPU_DCache.CPU   ),
    //debug interface
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

cpu_axi_interface u_cpu_axi_interface(
    .clk,
    .reset,
    // ICache
    .icache_uncache    ,
    .icache_req        ,
    .icache_addr       ,
    .icache_addr_ready ,
    .icache_data_ready ,
    .icache_rdata      ,
    // DCache
    .dcache_rd_req,
    .dcache_rd_addr,
    .dcache_rd_rdy,
    .dcache_ret_valid,
    .dcache_ret_data,
    .dcache_wr_req,
    .dcache_wr_addr,
    .dcache_wr_data,
    .dcache_wr_rdy,
    .dcache_wr_bvalid,
    // UnCache
    .uncache_rd_req,
    .uncache_rd_size,//
    .uncache_rd_addr,
    .uncache_rd_rdy,
    .uncache_ret_valid,
    .uncache_ret_data,
    .uncache_wr_req,
    .uncache_wr_size,//
    .uncache_wr_addr,
    .uncache_wr_wstrb,//
    .uncache_wr_data,
    .uncache_wr_rdy,
    .uncache_wr_bvalid,
    // axi
    // ar
    .arid            ,
    .araddr          ,
    .arlen           ,
    .arsize          ,
    .arburst         ,
    .arlock          ,
    .arcache         ,
    .arprot          ,
    .arvalid         ,
    .arready         ,
    // r
    .rid            (rid              ),
    .rdata          (rdata            ),
    .rresp          (rresp            ),
    .rlast          (rlast            ),
    .rvalid         (rvalid           ),
    .rready         (rready           ),
    // aw
    .awid           (awid             ),
    .awaddr         (awaddr           ),
    .awlen          (awlen            ),
    .awsize         (awsize           ),
    .awburst        (awburst          ),
    .awlock         (awlock           ),
    .awcache        (awcache          ),
    .awprot         (awprot           ),
    .awvalid        (awvalid          ),
    .awready        (awready          ),
    // w
    .wid            (wid              ),
    .wdata          (wdata            ),
    .wstrb          (wstrb            ),
    .wlast          (wlast            ),
    .wvalid         (wvalid           ),
    .wready         (wready           ),
    // b
    .bid            (bid              ),
    .bresp          (bresp            ),
    .bvalid         (bvalid           ),
    .bready         (bready           )
);

endmodule
