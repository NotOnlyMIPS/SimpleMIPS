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

//! SoC
logic soc_clk;
logic soc_rstn;

//! RAM
logic [4:0] ram_random_mask;

axi_t axi_ram;

//! core
logic cpu_clk;
logic cpu_rstn;
logic cpu_clk_wrap;
logic cpu_rstn_wrap;

logic [31:0] debug_wb_pc;
logic [3:0] debug_wb_rf_wen;
logic [4:0] debug_wb_rf_wnum;
logic [31:0] debug_wb_rf_wdata;

axi_t axi_cpu;
axi_t axi_cpu_wrap;
axi_t axi_cpu_sync;

//! GPIO
axi_t axi_confreg;

//! clock control
logic [2:0] soc_rstn_sync;
logic [2:0] cpu_rstn_sync;

always_ff @(posedge soc_clk) begin
    soc_rstn_sync <= {soc_rstn_sync[1:0], ~rstn};
end

always_ff @(posedge cpu_clk) begin
    cpu_rstn_sync <= {cpu_rstn_sync[1:0], ~rstn};
end

assign soc_rstn = sys_rstn_sync[2];
assign cpu_rstn = cpu_rstn_sync[2];

//! ===
//! RAM
//! ===

axi_wrap_ram u_axi_wrap_ram (
    //! common
    .aclk    ( soc_clk  ),
    .aresetn ( soc_rstn ),
    //! AXI
    .axi_arid    ( axi_ram.arid              ),
    .axi_araddr  ( axi_ram.req.araddr        ),
    .axi_arlen   ( {4'd0, axi_ram.req.arlen} ),
    .axi_arsize  ( axi_ram.req.arsize        ),
    .axi_arburst ( axi_ram.req.arburst       ),
    .axi_arlock  ( axi_ram.req.arlock        ),
    .axi_arcache ( axi_ram.req.arcache       ),
    .axi_arprot  ( axi_ram.req.arprot        ),
    .axi_arvalid ( axi_ram.req.arvalid       ),
    .axi_arready ( axi_ram.resp.arready      ),
    .axi_rid     ( axi_ram.rid               ),
    .axi_rready  ( axi_ram.req.rready        ),
    .axi_rdata   ( axi_ram.resp.rdata        ),
    .axi_rresp   ( axi_ram.resp.rresp        ),
    .axi_rlast   ( axi_ram.resp.rlast        ),
    .axi_rvalid  ( axi_ram.resp.rvalid       ),
    .axi_awid    ( axi_ram.awid              ),
    .axi_awaddr  ( axi_ram.req.awaddr        ),
    .axi_awlen   ( {4'd0, axi_ram.req.awlen} ),
    .axi_awsize  ( axi_ram.req.awsize        ),
    .axi_awburst ( axi_ram.req.awburst       ),
    .axi_awlock  ( axi_ram.req.awlock        ),
    .axi_awcache ( axi_ram.req.awcache       ),
    .axi_awprot  ( axi_ram.req.awprot        ),
    .axi_awvalid ( axi_ram.req.awvalid       ),
    .axi_awready ( axi_ram.resp.awready      ),
    .axi_wid     ( axi_ram.wid               ),
    .axi_wdata   ( axi_ram.req.wdata         ),
    .axi_wstrb   ( axi_ram.req.wstrb         ),
    .axi_wlast   ( axi_ram.req.wlast         ),
    .axi_wvalid  ( axi_ram.req.wvalid        ),
    .axi_wready  ( axi_ram.resp.wready       ),
    .axi_bid     ( axi_ram.bid               ),
    .axi_bresp   ( axi_ram.req.bresp         ),
    .axi_bvalid  ( axi_ram.req.bvalid        ),
    .axi_bready  ( axi_ram.resp.bready       ),
    //! RAM mask
    .ram_random_mask
);

//! ===
//! core
//! ===

SimpleMIPS u_core (
    //! common
    .clk    ( cpu_clk  ),
    .resetn ( cpu_rstn ),
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
    .bresp   ( axi_cpu.req.bresp    ),
    .bvalid  ( axi_cpu.req.bvalid   ),
    .bready  ( axi_cpu.resp.bready  ),
    //! debug interface
    .debug_wb_pc,
    .debug_wb_rf_wen,
    .debug_wb_rf_wnum,
    .debug_wb_rf_wdata
);

axi_wrap u_cpu_axi_wrap (
    //! common
    .m_aclk    ( cpu_clk       ),
    .m_aresetn ( cpu_rstn      ),
    .s_aclk    ( cpu_clk_wrap  ),
    .s_aresetn ( cpu_rstn_wrap ),
    //! AXI master
    .m_arid    ( axi_cpu.arid         ),
    .m_araddr  ( axi_cpu.req.araddr   ),
    .m_arlen   ( axi_cpu.req.arlen    ),
    .m_arsize  ( axi_cpu.req.arsize   ),
    .m_arburst ( axi_cpu.req.arburst  ),
    .m_arlock  ( axi_cpu.req.arlock   ),
    .m_arcache ( axi_cpu.req.arcache  ),
    .m_arprot  ( axi_cpu.req.arprot   ),
    .m_arvalid ( axi_cpu.req.arvalid  ),
    .m_arready ( axi_cpu.resp.arready ),
    .m_rid     ( axi_cpu.rid          ),
    .m_rready  ( axi_cpu.req.rready   ),
    .m_rdata   ( axi_cpu.resp.rdata   ),
    .m_rresp   ( axi_cpu.resp.rresp   ),
    .m_rlast   ( axi_cpu.resp.rlast   ),
    .m_rvalid  ( axi_cpu.resp.rvalid  ),
    .m_awid    ( axi_cpu.awid         ),
    .m_awaddr  ( axi_cpu.req.awaddr   ),
    .m_awlen   ( axi_cpu.req.awlen    ),
    .m_awsize  ( axi_cpu.req.awsize   ),
    .m_awburst ( axi_cpu.req.awburst  ),
    .m_awlock  ( axi_cpu.req.awlock   ),
    .m_awcache ( axi_cpu.req.awcache  ),
    .m_awprot  ( axi_cpu.req.awprot   ),
    .m_awvalid ( axi_cpu.req.awvalid  ),
    .m_awready ( axi_cpu.resp.awready ),
    .m_wid     ( axi_cpu.wid          ),
    .m_wdata   ( axi_cpu.req.wdata    ),
    .m_wstrb   ( axi_cpu.req.wstrb    ),
    .m_wlast   ( axi_cpu.req.wlast    ),
    .m_wvalid  ( axi_cpu.req.wvalid   ),
    .m_wready  ( axi_cpu.resp.wready  ),
    .m_bid     ( axi_cpu.bid          ),
    .m_bresp   ( axi_cpu.req.bresp    ),
    .m_bvalid  ( axi_cpu.req.bvalid   ),
    .m_bready  ( axi_cpu.resp.bready  ),
    //! AXI slave
    .s_arid    ( axi_cpu_wrap.arid         ),
    .s_araddr  ( axi_cpu_wrap.req.araddr   ),
    .s_arlen   ( axi_cpu_wrap.req.arlen    ),
    .s_arsize  ( axi_cpu_wrap.req.arsize   ),
    .s_arburst ( axi_cpu_wrap.req.arburst  ),
    .s_arlock  ( axi_cpu_wrap.req.arlock   ),
    .s_arcache ( axi_cpu_wrap.req.arcache  ),
    .s_arprot  ( axi_cpu_wrap.req.arprot   ),
    .s_arvalid ( axi_cpu_wrap.req.arvalid  ),
    .s_arready ( axi_cpu_wrap.resp.arready ),
    .s_rid     ( axi_cpu_wrap.rid          ),
    .s_rready  ( axi_cpu_wrap.req.rready   ),
    .s_rdata   ( axi_cpu_wrap.resp.rdata   ),
    .s_rresp   ( axi_cpu_wrap.resp.rresp   ),
    .s_rlast   ( axi_cpu_wrap.resp.rlast   ),
    .s_rvalid  ( axi_cpu_wrap.resp.rvalid  ),
    .s_awid    ( axi_cpu_wrap.awid         ),
    .s_awaddr  ( axi_cpu_wrap.req.awaddr   ),
    .s_awlen   ( axi_cpu_wrap.req.awlen    ),
    .s_awsize  ( axi_cpu_wrap.req.awsize   ),
    .s_awburst ( axi_cpu_wrap.req.awburst  ),
    .s_awlock  ( axi_cpu_wrap.req.awlock   ),
    .s_awcache ( axi_cpu_wrap.req.awcache  ),
    .s_awprot  ( axi_cpu_wrap.req.awprot   ),
    .s_awvalid ( axi_cpu_wrap.req.awvalid  ),
    .s_awready ( axi_cpu_wrap.resp.awready ),
    .s_wid     ( axi_cpu_wrap.wid          ),
    .s_wdata   ( axi_cpu_wrap.req.wdata    ),
    .s_wstrb   ( axi_cpu_wrap.req.wstrb    ),
    .s_wlast   ( axi_cpu_wrap.req.wlast    ),
    .s_wvalid  ( axi_cpu_wrap.req.wvalid   ),
    .s_wready  ( axi_cpu_wrap.resp.wready  ),
    .s_bid     ( axi_cpu_wrap.bid          ),
    .s_bresp   ( axi_cpu_wrap.req.bresp    ),
    .s_bvalid  ( axi_cpu_wrap.req.bvalid   ),
    .s_bready  ( axi_cpu_wrap.resp.bready  )
);

axi_clock_converter u_axi_clock_sync (
    //! common
    .s_axi_aclk    ( cpu_clk  ),
    .s_axi_aresetn ( cpu_rstn ),
    .m_axi_aclk    ( soc_clk  ),
    .m_axi_aresetn ( soc_rstn ),
    //! AXI slave
    .s_axi_arid    ( axi_cpu_wrap.arid         ),
    .s_axi_araddr  ( axi_cpu_wrap.req.araddr   ),
    .s_axi_arlen   ( axi_cpu_wrap.req.arlen    ),
    .s_axi_arsize  ( axi_cpu_wrap.req.arsize   ),
    .s_axi_arburst ( axi_cpu_wrap.req.arburst  ),
    .s_axi_arlock  ( axi_cpu_wrap.req.arlock   ),
    .s_axi_arcache ( axi_cpu_wrap.req.arcache  ),
    .s_axi_arprot  ( axi_cpu_wrap.req.arprot   ),
    .s_axi_arqos   ( 4'd0                      ),
    .s_axi_arvalid ( axi_cpu_wrap.req.arvalid  ),
    .s_axi_arready ( axi_cpu_wrap.resp.arready ),
    .s_axi_rid     ( axi_cpu_wrap.rid          ),
    .s_axi_rready  ( axi_cpu_wrap.req.rready   ),
    .s_axi_rdata   ( axi_cpu_wrap.resp.rdata   ),
    .s_axi_rresp   ( axi_cpu_wrap.resp.rresp   ),
    .s_axi_rlast   ( axi_cpu_wrap.resp.rlast   ),
    .s_axi_rvalid  ( axi_cpu_wrap.resp.rvalid  ),
    .s_axi_awid    ( axi_cpu_wrap.awid         ),
    .s_axi_awaddr  ( axi_cpu_wrap.req.awaddr   ),
    .s_axi_awlen   ( axi_cpu_wrap.req.awlen    ),
    .s_axi_awsize  ( axi_cpu_wrap.req.awsize   ),
    .s_axi_awburst ( axi_cpu_wrap.req.awburst  ),
    .s_axi_awlock  ( axi_cpu_wrap.req.awlock   ),
    .s_axi_awcache ( axi_cpu_wrap.req.awcache  ),
    .s_axi_awprot  ( axi_cpu_wrap.req.awprot   ),
    .s_axi_awqos   ( 4'd0                      ),
    .s_axi_awvalid ( axi_cpu_wrap.req.awvalid  ),
    .s_axi_awready ( axi_cpu_wrap.resp.awready ),
    .s_axi_wid     ( axi_cpu_wrap.wid          ),
    .s_axi_wdata   ( axi_cpu_wrap.req.wdata    ),
    .s_axi_wstrb   ( axi_cpu_wrap.req.wstrb    ),
    .s_axi_wlast   ( axi_cpu_wrap.req.wlast    ),
    .s_axi_wvalid  ( axi_cpu_wrap.req.wvalid   ),
    .s_axi_wready  ( axi_cpu_wrap.resp.wready  ),
    .s_axi_bid     ( axi_cpu_wrap.bid          ),
    .s_axi_bresp   ( axi_cpu_wrap.req.bresp    ),
    .s_axi_bvalid  ( axi_cpu_wrap.req.bvalid   ),
    .s_axi_bready  ( axi_cpu_wrap.resp.bready  ),
    //! AXI master
    .m_axi_arid    ( axi_cpu_sync.arid         ),
    .m_axi_araddr  ( axi_cpu_sync.req.araddr   ),
    .m_axi_arlen   ( axi_cpu_sync.req.arlen    ),
    .m_axi_arsize  ( axi_cpu_sync.req.arsize   ),
    .m_axi_arburst ( axi_cpu_sync.req.arburst  ),
    .m_axi_arlock  ( axi_cpu_sync.req.arlock   ),
    .m_axi_arcache ( axi_cpu_sync.req.arcache  ),
    .m_axi_arprot  ( axi_cpu_sync.req.arprot   ),
    .m_axi_arqos   ( /* left floating */       ),
    .m_axi_arvalid ( axi_cpu_sync.req.arvalid  ),
    .m_axi_arready ( axi_cpu_sync.resp.arready ),
    .m_axi_rid     ( axi_cpu_sync.rid          ),
    .m_axi_rready  ( axi_cpu_sync.req.rready   ),
    .m_axi_rdata   ( axi_cpu_sync.resp.rdata   ),
    .m_axi_rresp   ( axi_cpu_sync.resp.rresp   ),
    .m_axi_rlast   ( axi_cpu_sync.resp.rlast   ),
    .m_axi_rvalid  ( axi_cpu_sync.resp.rvalid  ),
    .m_axi_awid    ( axi_cpu_sync.awid         ),
    .m_axi_awaddr  ( axi_cpu_sync.req.awaddr   ),
    .m_axi_awlen   ( axi_cpu_sync.req.awlen    ),
    .m_axi_awsize  ( axi_cpu_sync.req.awsize   ),
    .m_axi_awburst ( axi_cpu_sync.req.awburst  ),
    .m_axi_awlock  ( axi_cpu_sync.req.awlock   ),
    .m_axi_awcache ( axi_cpu_sync.req.awcache  ),
    .m_axi_awprot  ( axi_cpu_sync.req.awprot   ),
    .m_axi_awqos   ( /* left floating */       ),
    .m_axi_awvalid ( axi_cpu_sync.req.awvalid  ),
    .m_axi_awready ( axi_cpu_sync.resp.awready ),
    .m_axi_wid     ( axi_cpu_sync.wid          ),
    .m_axi_wdata   ( axi_cpu_sync.req.wdata    ),
    .m_axi_wstrb   ( axi_cpu_sync.req.wstrb    ),
    .m_axi_wlast   ( axi_cpu_sync.req.wlast    ),
    .m_axi_wvalid  ( axi_cpu_sync.req.wvalid   ),
    .m_axi_wready  ( axi_cpu_sync.resp.wready  ),
    .m_axi_bid     ( axi_cpu_sync.bid          ),
    .m_axi_bresp   ( axi_cpu_sync.req.bresp    ),
    .m_axi_bvalid  ( axi_cpu_sync.req.bvalid   ),
    .m_axi_bready  ( axi_cpu_sync.resp.bready  )
);

//! ===
//! GPIO
//! ===

assign num_a_g_dp = 1'b0; //!< unused in CONFREG

confreg #(
    .SIMULATION ( 1'b0 ) //!< disable simulation by default
) u_confreg (
    //! common
    .aclk      ( soc_clk  ),
    .aresetn   ( soc_rstn ),
    .timer_clk ( soc_clk  ),
    //! AXI
    .arid    ( axi_confreg.arid         ),
    .araddr  ( axi_confreg.req.araddr   ),
    .arlen   ( axi_confreg.req.arlen    ),
    .arsize  ( axi_confreg.req.arsize   ),
    .arburst ( axi_confreg.req.arburst  ),
    .arlock  ( axi_confreg.req.arlock   ),
    .arcache ( axi_confreg.req.arcache  ),
    .arprot  ( axi_confreg.req.arprot   ),
    .arvalid ( axi_confreg.req.arvalid  ),
    .arready ( axi_confreg.resp.arready ),
    .rid     ( axi_confreg.rid          ),
    .rready  ( axi_confreg.req.rready   ),
    .rdata   ( axi_confreg.resp.rdata   ),
    .rresp   ( axi_confreg.resp.rresp   ),
    .rlast   ( axi_confreg.resp.rlast   ),
    .rvalid  ( axi_confreg.resp.rvalid  ),
    .awid    ( axi_confreg.awid         ),
    .awaddr  ( axi_confreg.req.awaddr   ),
    .awlen   ( axi_confreg.req.awlen    ),
    .awsize  ( axi_confreg.req.awsize   ),
    .awburst ( axi_confreg.req.awburst  ),
    .awlock  ( axi_confreg.req.awlock   ),
    .awcache ( axi_confreg.req.awcache  ),
    .awprot  ( axi_confreg.req.awprot   ),
    .awvalid ( axi_confreg.req.awvalid  ),
    .awready ( axi_confreg.resp.awready ),
    .wid     ( axi_confreg.wid          ),
    .wdata   ( axi_confreg.req.wdata    ),
    .wstrb   ( axi_confreg.req.wstrb    ),
    .wlast   ( axi_confreg.req.wlast    ),
    .wvalid  ( axi_confreg.req.wvalid   ),
    .wready  ( axi_confreg.resp.wready  ),
    .bid     ( axi_confreg.bid          ),
    .bresp   ( axi_confreg.req.bresp    ),
    .bvalid  ( axi_confreg.req.bvalid   ),
    .bready  ( axi_confreg.resp.bready  ),
    //! RAM
    .ram_random_mask,
    //! GPIO for LED on FPGA
    .led,
    .led_rg0,
    .led_rg1,
    .num_csn,
    .num_a_g,
    .switch,
    .btn_key_col,
    .btn_key_row,
    .btn_step
);

//! ===
//! crossbar
//! ===

axi_crossbar_1x2 u_axi_crossbar_1x2 (
    //! common
    .aclk    ( soc_clk  ),
    .aresetn ( soc_rstn ),
    //! AXI slave
    .s_axi_arid    ( axi_cpu_sync.arid         ),
    .s_axi_araddr  ( axi_cpu_sync.req.araddr   ),
    .s_axi_arlen   ( axi_cpu_sync.req.arlen    ),
    .s_axi_arsize  ( axi_cpu_sync.req.arsize   ),
    .s_axi_arburst ( axi_cpu_sync.req.arburst  ),
    .s_axi_arlock  ( axi_cpu_sync.req.arlock   ),
    .s_axi_arcache ( axi_cpu_sync.req.arcache  ),
    .s_axi_arprot  ( axi_cpu_sync.req.arprot   ),
    .s_axi_arqos   ( 4'd0                      ),
    .s_axi_arvalid ( axi_cpu_sync.req.arvalid  ),
    .s_axi_arready ( axi_cpu_sync.resp.arready ),
    .s_axi_rid     ( axi_cpu_sync.rid          ),
    .s_axi_rready  ( axi_cpu_sync.req.rready   ),
    .s_axi_rdata   ( axi_cpu_sync.resp.rdata   ),
    .s_axi_rresp   ( axi_cpu_sync.resp.rresp   ),
    .s_axi_rlast   ( axi_cpu_sync.resp.rlast   ),
    .s_axi_rvalid  ( axi_cpu_sync.resp.rvalid  ),
    .s_axi_awid    ( axi_cpu_sync.awid         ),
    .s_axi_awaddr  ( axi_cpu_sync.req.awaddr   ),
    .s_axi_awlen   ( axi_cpu_sync.req.awlen    ),
    .s_axi_awsize  ( axi_cpu_sync.req.awsize   ),
    .s_axi_awburst ( axi_cpu_sync.req.awburst  ),
    .s_axi_awlock  ( axi_cpu_sync.req.awlock   ),
    .s_axi_awcache ( axi_cpu_sync.req.awcache  ),
    .s_axi_awprot  ( axi_cpu_sync.req.awprot   ),
    .s_axi_awqos   ( 4'd0                      ),
    .s_axi_awvalid ( axi_cpu_sync.req.awvalid  ),
    .s_axi_awready ( axi_cpu_sync.resp.awready ),
    .s_axi_wid     ( axi_cpu_sync.wid          ),
    .s_axi_wdata   ( axi_cpu_sync.req.wdata    ),
    .s_axi_wstrb   ( axi_cpu_sync.req.wstrb    ),
    .s_axi_wlast   ( axi_cpu_sync.req.wlast    ),
    .s_axi_wvalid  ( axi_cpu_sync.req.wvalid   ),
    .s_axi_wready  ( axi_cpu_sync.resp.wready  ),
    .s_axi_bid     ( axi_cpu_sync.bid          ),
    .s_axi_bresp   ( axi_cpu_sync.req.bresp    ),
    .s_axi_bvalid  ( axi_cpu_sync.req.bvalid   ),
    .s_axi_bready  ( axi_cpu_sync.resp.bready  ),
    //! AXI master
    .m_axi_arid       ( {axi_ram.arid       , axi_confreg.arid       } ),
    .m_axi_araddr     ( {axi_ram.req.araddr , axi_confreg.req.araddr } ),
    .m_axi_arlen      ( {axi_ram.req.arlen  , axi_confreg.req.arlen  } ),
    .m_axi_arsize     ( {axi_ram.req.arsize , axi_confreg.req.arsize } ),
    .m_axi_arburst    ( {axi_ram.req.arburst, axi_confreg.req.arburst} ),
    .m_axi_arlock     ( {axi_ram.req.arlock , axi_confreg.req.arlock } ),
    .m_axi_arcache    ( {axi_ram.req.arcache, axi_confreg.req.arcache} ),
    .m_axi_arprot     ( {axi_ram.req.arprot , axi_confreg.req.arprot } ),
    .m_axi_arqos      ( /* left floating */                            ),
    .m_axi_arvalid    ( {axi_ram.req.arvalid, axi_confreg.req.arvalid} ),
    .m_axi_arready    ( {axi_ram.resp.arread, axi_confreg.resp.arread} ),
    .m_axi_rid        ( {axi_ram.rid        , axi_confreg.rid        } ),
    .m_axi_rready     ( {axi_ram.req.rready , axi_confreg.req.rready } ),
    .m_axi_rdata      ( {axi_ram.resp.rdata , axi_confreg.resp.rdata } ),
    .m_axi_rresp      ( {axi_ram.resp.rresp , axi_confreg.resp.rresp } ),
    .m_axi_rlast      ( {axi_ram.resp.rlast , axi_confreg.resp.rlast } ),
    .m_axi_rvalid     ( {axi_ram.resp.rvalid, axi_confreg.resp.rvalid} ),
    .m_axi_awid       ( {axi_ram.awid       , axi_confreg.awid       } ),
    .m_axi_awaddr     ( {axi_ram.req.awaddr , axi_confreg.req.awaddr } ),
    .m_axi_awlen      ( {axi_ram.req.awlen  , axi_confreg.req.awlen  } ),
    .m_axi_awsize     ( {axi_ram.req.awsize , axi_confreg.req.awsize } ),
    .m_axi_awburst    ( {axi_ram.req.awburst, axi_confreg.req.awburst} ),
    .m_axi_awlock     ( {axi_ram.req.awlock , axi_confreg.req.awlock } ),
    .m_axi_awcache    ( {axi_ram.req.awcache, axi_confreg.req.awcache} ),
    .m_axi_awprot     ( {axi_ram.req.awprot , axi_confreg.req.awprot } ),
    .m_axi_awqos      ( /* left floating */                            ),
    .m_axi_awvalid    ( {axi_ram.req.awvalid, axi_confreg.req.awvalid} ),
    .m_axi_awready    ( {axi_ram.resp.awread, axi_confreg.resp.awread} ),
    .m_axi_wid        ( {axi_ram.wid        , axi_confreg.wid        } ),
    .m_axi_wdata      ( {axi_ram.req.wdata  , axi_confreg.req.wdata  } ),
    .m_axi_wstrb      ( {axi_ram.req.wstrb  , axi_confreg.req.wstrb  } ),
    .m_axi_wlast      ( {axi_ram.req.wlast  , axi_confreg.req.wlast  } ),
    .m_axi_wvalid     ( {axi_ram.req.wvalid , axi_confreg.req.wvalid } ),
    .m_axi_wready     ( {axi_ram.resp.wready, axi_confreg.resp.wready} ),
    .m_axi_bid        ( {axi_ram.bid        , axi_confreg.bid        } ),
    .m_axi_bresp      ( {axi_ram.req.bresp  , axi_confreg.req.bresp  } ),
    .m_axi_bvalid     ( {axi_ram.req.bvalid , axi_confreg.req.bvalid } ),
    .m_axi_bready     ( {axi_ram.resp.bready, axi_confreg.resp.bready} )
 );

endmodule
