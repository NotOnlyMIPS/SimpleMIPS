`include "common.svh"

module soc_top (
    //! common
    input  logic clk,
    input  logic rstn,
    //! GPIO
    output logic [15:0] led,
    output logic [1:0] led_rg0,
    output logic [1:0] led_rg1,
    output logic [7:0] num_csn,
    output logic [6:0] num_a_g,
    output logic num_a_g_dp,
    output logic [3:0] btn_key_col,
    input  logic [3:0] btn_key_row,
    input  logic [1:0] btn_step,
    input  logic [7:0] switch
);

logic cpu_clk;
logic cpu_rstn;

axi_t axi_cpu;

wb_debug_t debug_info;

soc_wrap u_soc_wrap (
    .*
);

SimpleMIPS u_core (
    //! common
    .clk  ( cpu_clk  ),
    .rstn ( cpu_rstn ),
    //! exception
    .ext_int ( 6'd0 ),
    //! AXI
    .arid    ( axi_cpu.arid         ),
    .araddr  ( axi_cpu.req.araddr   ),
    .arlen   ( axi_cpu.req.arlen    ),
    .arsize  ( axi_cpu.req.arsize   ),
    .arburst ( axi_cpu.req.arburst  ),
    .arlock  ( axi_cpu.req.arlock   ),
    .arcache ( axi_cpu.req.arcache  ),
    .arprot  ( axi_cpu.req.arprot   ),
    .arvalid ( axi_cpu.req.arvalid  ),
    .arready ( axi_cpu.resp.arready ),
    .rid     ( axi_cpu.rid          ),
    .rready  ( axi_cpu.req.rready   ),
    .rdata   ( axi_cpu.resp.rdata   ),
    .rresp   ( axi_cpu.resp.rresp   ),
    .rlast   ( axi_cpu.resp.rlast   ),
    .rvalid  ( axi_cpu.resp.rvalid  ),
    .awid    ( axi_cpu.awid         ),
    .awaddr  ( axi_cpu.req.awaddr   ),
    .awlen   ( axi_cpu.req.awlen    ),
    .awsize  ( axi_cpu.req.awsize   ),
    .awburst ( axi_cpu.req.awburst  ),
    .awlock  ( axi_cpu.req.awlock   ),
    .awcache ( axi_cpu.req.awcache  ),
    .awprot  ( axi_cpu.req.awprot   ),
    .awvalid ( axi_cpu.req.awvalid  ),
    .awready ( axi_cpu.resp.awready ),
    .wid     ( axi_cpu.wid          ),
    .wdata   ( axi_cpu.req.wdata    ),
    .wstrb   ( axi_cpu.req.wstrb    ),
    .wlast   ( axi_cpu.req.wlast    ),
    .wvalid  ( axi_cpu.req.wvalid   ),
    .wready  ( axi_cpu.resp.wready  ),
    .bid     ( axi_cpu.bid          ),
    .bready  ( axi_cpu.req.bready   ),
    .bresp   ( axi_cpu.resp.bresp   ),
    .bvalid  ( axi_cpu.resp.bvalid  ),
    //! debug interface
    .debug_wb_pc       ( debug_info.pc   ),
    .debug_wb_rf_wdata ( debug_info.data ),
    .debug_wb_rf_wen   ( debug_info.en   ),
    .debug_wb_rf_wnum  ( debug_info.num  )
);

endmodule
