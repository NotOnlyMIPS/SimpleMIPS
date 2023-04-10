`include "common.svh"

module cpu_axi_interface (
    //! common
    input  logic clk,
    input  logic reset,
    //! AXI
    inout  axi_t axi,
    //! ICache
    input  logic     icache_uncache,
    input  logic     icache_req,
    input  uint32_t  icache_addr,
    output logic     icache_addr_ready,
    output logic     icache_data_ready,
    output uint128_t icache_rdata,
    //! DCache
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
    //! UnCache
    input  logic       uncache_rd_req,
    input  logic [2:0] uncache_rd_size,
    input  virt_t      uncache_rd_addr,
    output logic       uncache_rd_rdy,
    output logic       uncache_ret_valid,
    output uint32_t    uncache_ret_data,
    input  logic       uncache_wr_req,
    input  logic [2:0] uncache_wr_size,
    input  logic [3:0] uncache_wr_wstrb,
    input  virt_t      uncache_wr_addr,
    input  uint32_t    uncache_wr_data,
    output logic       uncache_wr_rdy,
    output logic       uncache_wr_bvalid
);

//! ICache
axi_t axi_icache;

typedef enum logic[1:0] {
    I_WAIT,
    I_READ,
    I_DONE
} icache_state_t;

icache_state_t  icache_state;
logic [3:0]     icache_target_size;
logic [3:0]     icache_index;
uint128_t       icache_data_buffer;

//! DCache
axi_t axi_dcache;

typedef enum logic [2:0] {
    D_WAIT,
    D_READ,
    D_WRITE,
    D_READ_DONE,
    D_WRITE_DONE
} dcache_state_t;

dcache_state_t dcache_state;
logic [3:0] dcache_target_size;
logic [3:0] dcache_index;
uint128_t dcache_data_buffer;

//! UnCache
axi_t axi_uncache;

typedef enum logic [1:0] {
    U_WAIT,
    U_READ,
    U_WRITE,
    U_WRITE_DONE
} uncache_state_t;

uncache_state_t uncache_rd_state, uncache_wr_state;
uint32_t uncache_wr_data_r;
logic [3:0] uncache_wr_wstrb_r;

//! ===
//! ICache
//! ===

assign icache_addr_ready = icache_state == I_WAIT && axi_icache.resp.arready;
assign icache_data_ready = icache_state == I_DONE;
assign icache_rdata      = icache_data_buffer;

always_ff @(posedge clk) begin
    if (reset || icache_state == I_DONE) begin
        icache_state <= I_WAIT;
    end else if (icache_addr_ready && icache_req) begin
        icache_state <= I_READ;
    end  else if (icache_index == icache_target_size && axi_icache.resp.rvalid) begin
        icache_state <= I_DONE;
    end

    if (reset) begin
        icache_target_size <= 4'd0;
    end else if (icache_addr_ready && icache_req) begin
        icache_target_size <= icache_uncache ? 4'd0 : 4'd3;
    end else if (icache_data_ready) begin
        icache_target_size <= 4'd0;
    end

    if (reset || icache_state == I_DONE) begin
        icache_index <= 4'd0;
    end else if (icache_state == I_READ && axi_icache.resp.rvalid) begin
        icache_index <= icache_index + 4'd1;
    end

    if (reset) begin
        icache_data_buffer <= 128'd0;
    end else if (icache_state == I_READ && axi_icache.resp.rvalid) begin
        icache_data_buffer <= {axi_icache.resp.rdata, icache_data_buffer[127:32]};
    end
end

//! ICache AXI request
assign axi_icache.arid        = 4'b0000;
assign axi_icache.req.araddr  = icache_addr;
assign axi_icache.req.arlen   = icache_uncache ? 8'd0 : 8'd3;
assign axi_icache.req.arsize  = 3'b10;
assign axi_icache.req.arburst = 2'b01;
assign axi_icache.req.arlock  = 2'b00;
assign axi_icache.req.arcache = '1;
assign axi_icache.req.arprot  = 3'b0;
assign axi_icache.req.arvalid = icache_req;
assign axi_icache.req.rready  = icache_state == I_READ;
assign axi_icache.awid        = '0;
assign axi_icache.req.awaddr  = '0;
assign axi_icache.req.awlen   = '0;
assign axi_icache.req.awsize  = '0;
assign axi_icache.req.awburst = '0;
assign axi_icache.req.awlock  = '0;
assign axi_icache.req.awcache = '1;
assign axi_icache.req.awprot  = '0;
assign axi_icache.req.awvalid = '0;
assign axi_icache.wid         = '0;
assign axi_icache.req.wdata   = '0;
assign axi_icache.req.wstrb   = '0;
assign axi_icache.req.wlast   = '0;
assign axi_icache.req.wvalid  = '0;
assign axi_icache.req.bready  = '0;

//! ===
//! DCache
//! ===

assign dcache_rd_rdy    = dcache_state == D_WAIT && axi_dcache.resp.arready;
assign dcache_ret_valid = dcache_state == D_READ_DONE;
assign dcache_ret_data  = dcache_data_buffer;
assign dcache_wr_rdy    = dcache_state == D_WAIT && axi_dcache.resp.awready;
assign dcache_wr_bvalid = dcache_state == D_WRITE_DONE && axi_dcache.resp.bvalid;

always_ff @(posedge clk) begin
    if (reset || dcache_state == D_READ_DONE || (dcache_state == D_WRITE_DONE) && axi_dcache.resp.bvalid) begin
        dcache_state <= D_WAIT;
    end else if (dcache_rd_rdy && dcache_rd_req) begin
        dcache_state <= D_READ;
    end else if (dcache_wr_rdy && dcache_wr_req) begin
        dcache_state <= D_WRITE;
        dcache_data_buffer <= dcache_wr_data;
    end else if (dcache_index == dcache_target_size) begin
        if (dcache_state == D_READ  && axi_dcache.resp.rvalid) begin
            dcache_state <= D_READ_DONE;
        end else if (dcache_state == D_WRITE && axi_dcache.resp.wready) begin
            dcache_state <= D_WRITE_DONE;
        end
    end

    if (reset) begin
        dcache_target_size <= 4'd0;
    end else if (dcache_rd_rdy && dcache_rd_req || dcache_wr_rdy && dcache_wr_req) begin
        dcache_target_size <= 4'd3;
    end else if (dcache_state == D_READ_DONE || dcache_state == D_WRITE_DONE) begin
        dcache_target_size <= 4'd0;
    end

    if (reset || dcache_state == D_READ_DONE || dcache_state == D_WRITE_DONE) begin
        dcache_index <= 4'd0;
    end else if (dcache_state == D_READ  && axi_dcache.resp.rvalid) begin
        dcache_index       <= dcache_index + 4'd1;
        dcache_data_buffer <= {axi_dcache.resp.rdata, dcache_data_buffer[127:32]};
    end else if (dcache_state == D_WRITE && axi_dcache.resp.wready) begin
        dcache_index       <= dcache_index + 4'd1;
        dcache_data_buffer <= {32'd0, dcache_data_buffer[127:32]};
    end
end

//! DCache AXI request
assign axi_dcache.arid        = 4'h1;
assign axi_dcache.req.araddr  = dcache_rd_addr;
assign axi_dcache.req.arlen   = 8'd3;
assign axi_dcache.req.arsize  = 3'b010;
assign axi_dcache.req.arburst = 2'b01;
assign axi_dcache.req.arlock  = 2'b00;
assign axi_dcache.req.arcache = '1;
assign axi_dcache.req.arprot  = 3'b0;
assign axi_dcache.req.arvalid = dcache_state == D_WAIT && dcache_rd_req;
assign axi_dcache.req.rready  = dcache_state == D_READ;
assign axi_dcache.awid        = 4'h1;
assign axi_dcache.req.awaddr  = dcache_wr_addr;
assign axi_dcache.req.awlen   = 8'd3;
assign axi_dcache.req.awsize  = 3'b010;
assign axi_dcache.req.awburst = 2'b01;
assign axi_dcache.req.awlock  = '0;
assign axi_dcache.req.awcache = '1;
assign axi_dcache.req.awprot  = '0;
assign axi_dcache.req.awvalid = dcache_state == D_WAIT && dcache_wr_req;
assign axi_dcache.wid         = 4'b0001;
assign axi_dcache.req.wdata   = dcache_data_buffer[31:0];
assign axi_dcache.req.wstrb   = '1;
assign axi_dcache.req.wlast   = dcache_index == dcache_target_size && dcache_state == D_WRITE;
assign axi_dcache.req.wvalid  = dcache_state == D_WRITE;
assign axi_dcache.req.bready  = dcache_state == D_WRITE_DONE;

//! ===
//! UnCache
//! ===

assign uncache_rd_rdy    = uncache_rd_state == U_WAIT  && uncache_rd_req && axi_uncache.resp.arready;
assign uncache_ret_valid = uncache_rd_state == U_READ  && axi_uncache.resp.rvalid;
assign uncache_ret_data  = axi_uncache.resp.rdata;
assign uncache_wr_rdy    = uncache_wr_state == U_WAIT  && uncache_wr_req && axi_uncache.resp.awready;
assign uncache_wr_bvalid = uncache_wr_state == U_WRITE_DONE && axi_uncache.resp.bvalid;

always_ff @(posedge clk) begin
    if (reset || uncache_ret_valid) begin
        uncache_rd_state <= U_WAIT;
    end else if (uncache_rd_rdy) begin
        uncache_rd_state <= U_READ;
    end

    if (reset || uncache_wr_bvalid) begin
        uncache_wr_state <= U_WAIT;
    end else if (uncache_wr_state == U_WAIT && uncache_wr_rdy) begin
        uncache_wr_state <= U_WRITE;
    end else if (uncache_wr_state == U_WRITE && axi_uncache.resp.wready) begin
        uncache_wr_state <= U_WRITE_DONE;
    end

    if (uncache_wr_rdy) begin
        uncache_wr_data_r <= uncache_wr_data;
        uncache_wr_wstrb_r <= uncache_wr_wstrb;
    end
end

//! UnCache AXI request
assign axi_uncache.arid        = 4'h2;
assign axi_uncache.req.araddr  = uncache_rd_addr;
assign axi_uncache.req.arlen   = 8'b0000;
assign axi_uncache.req.arsize  = uncache_rd_size;
assign axi_uncache.req.arburst = 2'b00;
assign axi_uncache.req.arlock  = 2'b00;
assign axi_uncache.req.arcache = '1;
assign axi_uncache.req.arprot  = 3'b0;
assign axi_uncache.req.arvalid = uncache_rd_state == U_WAIT && uncache_rd_req;
assign axi_uncache.req.rready  = uncache_rd_state == U_READ;
assign axi_uncache.awid        = 4'h2;
assign axi_uncache.req.awaddr  = uncache_wr_addr;
assign axi_uncache.req.awlen   = 8'b0000;
assign axi_uncache.req.awsize  = uncache_wr_size;
assign axi_uncache.req.awburst = 2'b00;
assign axi_uncache.req.awlock  = '0;
assign axi_uncache.req.awcache = '1;
assign axi_uncache.req.awprot  = '0;
assign axi_uncache.req.awvalid = uncache_wr_state == U_WAIT && uncache_wr_req;
assign axi_uncache.wid         = 4'h2;
assign axi_uncache.req.wdata   = uncache_wr_data_r;
assign axi_uncache.req.wstrb   = uncache_wr_wstrb_r;
assign axi_uncache.req.wlast   = uncache_wr_state == U_WRITE;
assign axi_uncache.req.wvalid  = uncache_wr_state == U_WRITE;
assign axi_uncache.req.bready  = uncache_wr_state == U_WRITE_DONE;

//! ===
//! crossbar
//! ===

assign axi.req.arlock = 2'b00;
assign axi.req.awlock = 2'b00;
assign axi.wid        = axi.awid;

axi_crossbar_cache biu (
    //! common
    .aclk    ( clk    ),
    .aresetn ( ~reset ),
    //! AXI slave
    .s_axi_arid    ( {axi_icache.arid, axi_dcache.arid, axi_uncache.arid}                         ),
    .s_axi_araddr  ( {axi_icache.req.araddr, axi_dcache.req.araddr, axi_uncache.req.araddr}       ),
    .s_axi_arlen   ( {axi_icache.req.arlen, axi_dcache.req.arlen, axi_uncache.req.arlen}          ),
    .s_axi_arsize  ( {axi_icache.req.arsize, axi_dcache.req.arsize, axi_uncache.req.arsize}       ),
    .s_axi_arburst ( {axi_icache.req.arburst, axi_dcache.req.arburst, axi_uncache.req.arburst}    ),
    .s_axi_arlock  ( {axi_icache.req.arlock, axi_dcache.req.arlock, axi_uncache.req.arlock}       ),
    .s_axi_arcache ( {axi_icache.req.arcache, axi_dcache.req.arcache, axi_uncache.req.arcache}    ),
    .s_axi_arprot  ( {axi_icache.req.arprot, axi_dcache.req.arprot, axi_uncache.req.arprot}       ),
    .s_axi_arqos   ( 4'd0                                                                         ),
    .s_axi_arvalid ( {axi_icache.req.arvalid, axi_dcache.req.arvalid, axi_uncache.req.arvalid}    ),
    .s_axi_arready ( {axi_icache.resp.arready, axi_dcache.resp.arready, axi_uncache.resp.arready} ),
    .s_axi_rid     ( {axi_icache.rid, axi_dcache.rid, axi_uncache.rid}                            ),
    .s_axi_rready  ( {axi_icache.req.rready, axi_dcache.req.rready, axi_uncache.req.rready}       ),
    .s_axi_rdata   ( {axi_icache.resp.rdata, axi_dcache.resp.rdata, axi_uncache.resp.rdata}       ),
    .s_axi_rresp   ( {axi_icache.resp.rresp, axi_dcache.resp.rresp, axi_uncache.resp.rresp}       ),
    .s_axi_rlast   ( {axi_icache.resp.rlast, axi_dcache.resp.rlast, axi_uncache.resp.rlast}       ),
    .s_axi_rvalid  ( {axi_icache.resp.rvalid, axi_dcache.resp.rvalid, axi_uncache.resp.rvalid}    ),
    .s_axi_awid    ( {axi_icache.awid, axi_dcache.awid, axi_uncache.awid}                         ),
    .s_axi_awaddr  ( {axi_icache.req.awaddr, axi_dcache.req.awaddr, axi_uncache.req.awaddr}       ),
    .s_axi_awlen   ( {axi_icache.req.awlen, axi_dcache.req.awlen, axi_uncache.req.awlen}          ),
    .s_axi_awsize  ( {axi_icache.req.awsize, axi_dcache.req.awsize, axi_uncache.req.awsize}       ),
    .s_axi_awburst ( {axi_icache.req.awburst, axi_dcache.req.awburst, axi_uncache.req.awburst}    ),
    .s_axi_awlock  ( {axi_icache.req.awlock, axi_dcache.req.awlock, axi_uncache.req.awlock}       ),
    .s_axi_awcache ( {axi_icache.req.awcache, axi_dcache.req.awcache, axi_uncache.req.awcache}    ),
    .s_axi_awprot  ( {axi_icache.req.awprot, axi_dcache.req.awprot, axi_uncache.req.awprot}       ),
    .s_axi_awqos   ( 4'd0                                                                         ),
    .s_axi_awvalid ( {axi_icache.req.awvalid, axi_dcache.req.awvalid, axi_uncache.req.awvalid}    ),
    .s_axi_awready ( {axi_icache.resp.awready, axi_dcache.resp.awready, axi_uncache.resp.awready} ),
    //.s_axi_wid     ( /* left floating */                                                          ),  //!< no such named port
    .s_axi_wdata   ( {axi_icache.req.wdata, axi_dcache.req.wdata, axi_uncache.req.wdata}          ),
    .s_axi_wstrb   ( {axi_icache.req.wstrb, axi_dcache.req.wstrb, axi_uncache.req.wstrb}          ),
    .s_axi_wlast   ( {axi_icache.req.wlast, axi_dcache.req.wlast, axi_uncache.req.wlast}          ),
    .s_axi_wvalid  ( {axi_icache.req.wvalid, axi_dcache.req.wvalid, axi_uncache.req.wvalid}       ),
    .s_axi_wready  ( {axi_icache.resp.wready, axi_dcache.resp.wready, axi_uncache.resp.wready}    ),
    .s_axi_bid     ( {axi_icache.bid, axi_dcache.bid, axi_uncache.bid}                            ),
    .s_axi_bready  ( {axi_icache.req.bready, axi_dcache.req.bready, axi_uncache.req.bready}       ),
    .s_axi_bresp   ( {axi_icache.resp.bresp, axi_dcache.resp.bresp, axi_uncache.resp.bresp}       ),
    .s_axi_bvalid  ( {axi_icache.resp.bvalid, axi_dcache.resp.bvalid, axi_uncache.resp.bvalid}    ),
    //! AXI master
    .m_axi_arid       ( axi.arid            ),
    .m_axi_araddr     ( axi.req.araddr      ),
    .m_axi_arlen      ( axi.req.arlen       ),
    .m_axi_arsize     ( axi.req.arsize      ),
    .m_axi_arburst    ( axi.req.arburst     ),
    .m_axi_arlock     ( /* left floating */ ),
    .m_axi_arcache    ( axi.req.arcache     ),
    .m_axi_arprot     ( axi.req.arprot      ),
    .m_axi_arqos      ( /* left floating */ ),
    .m_axi_arvalid    ( axi.req.arvalid     ),
    .m_axi_arready    ( axi.resp.arready    ),
    .m_axi_rid        ( axi.rid             ),
    .m_axi_rready     ( axi.req.rready      ),
    .m_axi_rdata      ( axi.resp.rdata      ),
    .m_axi_rresp      ( axi.resp.rresp      ),
    .m_axi_rlast      ( axi.resp.rlast      ),
    .m_axi_rvalid     ( axi.resp.rvalid     ),
    .m_axi_awid       ( axi.awid            ),
    .m_axi_awaddr     ( axi.req.awaddr      ),
    .m_axi_awlen      ( axi.req.awlen       ),
    .m_axi_awsize     ( axi.req.awsize      ),
    .m_axi_awburst    ( axi.req.awburst     ),
    .m_axi_awlock     ( /* left floating */ ),
    .m_axi_awcache    ( axi.req.awcache     ),
    .m_axi_awprot     ( axi.req.awprot      ),
    .m_axi_awqos      ( /* left floating */ ),
    .m_axi_awvalid    ( axi.req.awvalid     ),
    .m_axi_awready    ( axi.resp.awready    ),
    //.m_axi_wid        ( /* left floating */ ), //!< no such named port
    .m_axi_wdata      ( axi.req.wdata       ),
    .m_axi_wstrb      ( axi.req.wstrb       ),
    .m_axi_wlast      ( axi.req.wlast       ),
    .m_axi_wvalid     ( axi.req.wvalid      ),
    .m_axi_wready     ( axi.resp.wready     ),
    .m_axi_bid        ( axi.bid             ),
    .m_axi_bready     ( axi.req.bready      ),
    .m_axi_bresp      ( axi.resp.bresp      ),
    .m_axi_bvalid     ( axi.resp.bvalid     )
);

endmodule
