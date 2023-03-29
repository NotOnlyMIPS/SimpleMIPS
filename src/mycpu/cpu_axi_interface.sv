`include "cpu_defs.svh"

module cpu_axi_interface
(
    input         clk,
    input         reset, 

    //icache
    input  logic     icache_uncache,
    input  logic     icache_req,
    input  uint32_t  icache_addr,
    output logic     icache_addr_ready,
    output logic     icache_data_ready,
    output uint128_t icache_rdata,
    
    //data sram-like 
    input         data_req     ,
    input         data_wr      ,
    input  [1 :0] data_size    ,
    input  [3 :0] data_wstrb   ,
    input  [31:0] data_addr    ,
    input  [31:0] data_wdata   ,
    output [31:0] data_rdata   ,
    output        data_addr_ok ,
    output        data_data_ok ,

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
    I_RECV,
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
        icache_state <= I_RECV;
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
    else if(icache_state == I_RECV && icache_axi.rvalid)
        icache_index <= icache_index + 4'd1;

    if(reset)
        icache_data_buffer <= 128'd0;
    else if(icache_state == I_RECV && icache_axi.rvalid)
        icache_data_buffer <= {icache_axi.rdata, icache_data_buffer[127:32]};
end

// ICache AXI
axi_t icache_axi;
// ar
assign icache_axi.arid    = 4'b0000;
assign icache_axi.araddr  = icache_addr;
assign icache_axi.arlen   = icache_uncache ? 4'd0 : 4'd3;
assign icache_axi.arsize  = 3'b10;
assign icache_axi.arburst = 2'b01;
assign icache_axi.arlock  = 2'b00;
assign icache_axi.arcache = '1;
assign icache_axi.arprot  = 3'b0;
assign icache_axi.arvalid = icache_req;
// r
assign icache_axi.rready  = icache_state == I_RECV;
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
typedef enum logic [1:0] { 
    D_WAIT,
    D_READ,
    D_WRITE
} dcache_state_t;

dcache_state_t  dcache_state;
logic dcache_waddr_ready;
logic dcache_raddr_ready;

logic       data_req_r;
logic       data_wr_r;
logic [1:0] data_size_r;
logic [3:0] data_wstrb_r;
uint32_t    data_wdata_r;

assign dcache_waddr_ready = dcache_state == D_WAIT &&  data_wr && dcache_axi.awready;
assign dcache_raddr_ready = dcache_state == D_WAIT && !data_wr && dcache_axi.arready;
assign data_addr_ok = dcache_waddr_ready || dcache_raddr_ready;
assign data_data_ok = dcache_axi.rvalid || dcache_axi.wready;
assign data_rdata   = dcache_axi.rdata;

always_ff @(posedge clk) begin
    if(reset || (dcache_state == D_READ  && dcache_axi.rvalid || 
                 dcache_state == D_WRITE && dcache_axi.wready))
        dcache_state <= D_WAIT;
    else if(data_req && dcache_raddr_ready)
        dcache_state <= D_READ;
    else if(data_req && dcache_waddr_ready)
        dcache_state <= D_WRITE;

    if(reset || (dcache_state == D_WRITE && dcache_axi.wready)) begin
        data_req_r   <= '0;
        data_wr_r    <= '0;
        data_size_r  <= '0;
        data_wstrb_r <= '0;   
        data_wdata_r <= '0;
    end
    else if(data_req && dcache_waddr_ready) begin
        data_req_r   <= data_req;
        data_wr_r    <= data_wr;
        data_size_r  <= data_size;
        data_wstrb_r <= data_wstrb; 
        data_wdata_r <= data_wdata;
    end
end

// DCache AXI
axi_t dcache_axi;
// ar
assign dcache_axi.arid    = 4'b0001;
assign dcache_axi.araddr  = data_addr;
assign dcache_axi.arlen   = 4'b0000;
assign dcache_axi.arsize  = 3'b010;
assign dcache_axi.arburst = 2'b00;
assign dcache_axi.arlock  = 2'b00;
assign dcache_axi.arcache = '1;
assign dcache_axi.arprot  = 3'b0;
assign dcache_axi.arvalid = data_req & ~data_wr;
// r
assign dcache_axi.rready  = dcache_state == D_READ;
// aw
assign dcache_axi.awid    = 4'b0001;           
assign dcache_axi.awaddr  = data_addr;
assign dcache_axi.awlen   = 4'b0000;
assign dcache_axi.awsize  = 3'b010;
assign dcache_axi.awburst = 2'b00;
assign dcache_axi.awlock  = '0;
assign dcache_axi.awcache = '1;
assign dcache_axi.awprot  = '0;
assign dcache_axi.awvalid = data_req & data_wr;
// w
assign dcache_axi.wid     = 4'b0001;
assign dcache_axi.wdata   = data_wdata_r;
assign dcache_axi.wstrb   = data_wstrb_r;
assign dcache_axi.wlast   = dcache_state == D_WRITE;
assign dcache_axi.wvalid  = dcache_state == D_WRITE;
// b
assign dcache_axi.bready  = 1'b1;


// axi_crossbar
assign arlock = 2'b00;
assign awlock = 2'b00;
assign wid    = awid;


axi_crossbar_cache biu (
.aclk             ( clk     ),
.aresetn          ( ~reset        ),

.s_axi_arid       ( {icache_axi.arid   ,dcache_axi.arid    } ),
.s_axi_araddr     ( {icache_axi.araddr ,dcache_axi.araddr  } ),
.s_axi_arlen      ( {4'h0, icache_axi.arlen, 4'h0, dcache_axi.arlen   } ),
.s_axi_arsize     ( {icache_axi.arsize ,dcache_axi.arsize  } ),
.s_axi_arburst    ( {icache_axi.arburst,dcache_axi.arburst } ),
.s_axi_arlock     ( {icache_axi.arlock ,dcache_axi.arlock  } ),
.s_axi_arcache    ( {icache_axi.arcache,dcache_axi.arcache } ),
.s_axi_arprot     ( {icache_axi.arprot ,dcache_axi.arprot  } ),
.s_axi_arqos      ( 0                                        ),
.s_axi_arvalid    ( {icache_axi.arvalid,dcache_axi.arvalid } ),
.s_axi_arready    ( {icache_axi.arready,dcache_axi.arready } ),

.s_axi_rid        ( {icache_axi.rid    ,dcache_axi.rid     } ),
.s_axi_rdata      ( {icache_axi.rdata  ,dcache_axi.rdata   } ),
.s_axi_rresp      ( {icache_axi.rresp  ,dcache_axi.rresp   } ),
.s_axi_rlast      ( {icache_axi.rlast  ,dcache_axi.rlast   } ),
.s_axi_rvalid     ( {icache_axi.rvalid ,dcache_axi.rvalid  } ),
.s_axi_rready     ( {icache_axi.rready ,dcache_axi.rready  } ),

.s_axi_awid       ( {icache_axi.awid   ,dcache_axi.awid    } ),
.s_axi_awaddr     ( {icache_axi.awaddr ,dcache_axi.awaddr  } ),
.s_axi_awlen      ( {4'h0, icache_axi.awlen, 4'h0, dcache_axi.awlen   } ),
.s_axi_awsize     ( {icache_axi.awsize ,dcache_axi.awsize  } ),
.s_axi_awburst    ( {icache_axi.awburst,dcache_axi.awburst } ),
.s_axi_awlock     ( {icache_axi.awlock ,dcache_axi.awlock  } ),
.s_axi_awcache    ( {icache_axi.awcache,dcache_axi.awcache } ),
.s_axi_awprot     ( {icache_axi.awprot ,dcache_axi.awprot  } ),
.s_axi_awqos      ( 0                                        ),
.s_axi_awvalid    ( {icache_axi.awvalid,dcache_axi.awvalid } ),
.s_axi_awready    ( {icache_axi.awready,dcache_axi.awready } ),

// .s_axi_wid        ( {icache_axi.wid    ,dcache_axi.wid     } ),
.s_axi_wdata      ( {icache_axi.wdata  ,dcache_axi.wdata   } ),
.s_axi_wstrb      ( {icache_axi.wstrb  ,dcache_axi.wstrb   } ),
.s_axi_wlast      ( {icache_axi.wlast  ,dcache_axi.wlast   } ),
.s_axi_wvalid     ( {icache_axi.wvalid ,dcache_axi.wvalid  } ),
.s_axi_wready     ( {icache_axi.wready ,dcache_axi.wready  } ),
.s_axi_bid        ( {icache_axi.bid    ,dcache_axi.bid     } ),
.s_axi_bresp      ( {icache_axi.bresp  ,dcache_axi.bresp   } ),
.s_axi_bvalid     ( {icache_axi.bvalid ,dcache_axi.bvalid  } ),
.s_axi_bready     ( {icache_axi.bready ,dcache_axi.bready  } ),

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

