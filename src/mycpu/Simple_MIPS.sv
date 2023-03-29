`include "cpu_defs.svh"

module Simple_MIPS(
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
logic        data_sram_req     ;
logic        data_sram_wr      ;
logic [1 :0] data_sram_size    ;
logic [3 :0] data_sram_wstrb   ;
logic [31:0] data_sram_addr    ;
logic [31:0] data_sram_wdata   ;
logic [31:0] data_sram_rdata   ;
logic        data_sram_addr_ok ;
logic        data_sram_data_ok ;

cpu_core u_cpu_core(
    .clk,
    .reset,

    .ext_int,

    // ICache
    .CPU_ICache_Bus (CPU_ICache.CPU),
    // data_sram
    .data_req       (data_sram_req    ),
    .data_wr        (data_sram_wr     ),
    .data_size      (data_sram_size   ),
    .data_wstrb     (data_sram_wstrb  ),
    .data_addr      (data_sram_addr   ),
    .data_wdata     (data_sram_wdata  ),
    .data_addr_ok   (data_sram_addr_ok),
    .data_data_ok   (data_sram_data_ok),
    .data_rdata     (data_sram_rdata  ),
    //debug interface
    .debug_wb_pc      (debug_wb_pc      ),
    .debug_wb_rf_wen  (debug_wb_rf_wen  ),
    .debug_wb_rf_wnum (debug_wb_rf_wnum ),
    .debug_wb_rf_wdata(debug_wb_rf_wdata)
);

icache u_icache(
    .clk_g(clk),
    .resetn(~reset),

    .CPU_ICache_Bus (CPU_ICache.ICache),

    .rd_uncache     (icache_uncache   ),
    .rd_req         (icache_req       ),
    .rd_addr        (icache_addr      ),
    .rd_rdy         (icache_addr_ready),
    .ret_valid      (icache_data_ready),
    .ret_data       (icache_rdata     )
);

cpu_axi_interface u_cpu_axi_interface(
    .clk,
    .reset,
    // icache
    .icache_uncache   (icache_uncache   ),
    .icache_req       (icache_req       ),
    .icache_addr      (icache_addr      ),
    .icache_addr_ready(icache_addr_ready),
    .icache_data_ready(icache_data_ready),
    .icache_rdata     (icache_rdata     ),
    // data sram-like
    .data_req       (data_sram_req    ),
    .data_wr        (data_sram_wr     ),
    .data_size      (data_sram_size   ),
    .data_wstrb     (data_sram_wstrb  ),
    .data_addr      (data_sram_addr   ),
    .data_wdata     (data_sram_wdata  ),
    .data_addr_ok   (data_sram_addr_ok),
    .data_data_ok   (data_sram_data_ok),
    .data_rdata     (data_sram_rdata  ),
    // axi
    // ar
    .arid           (arid             ),
    .araddr         (araddr           ),
    .arlen          (arlen            ),
    .arsize         (arsize           ),
    .arburst        (arburst          ),
    .arlock         (arlock           ),
    .arcache        (arcache          ),
    .arprot         (arprot           ),
    .arvalid        (arvalid          ),
    .arready        (arready          ),
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