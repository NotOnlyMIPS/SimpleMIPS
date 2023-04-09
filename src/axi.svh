`ifndef AXI_SVH
`define AXI_SVH

//! AXI request
typedef struct packed {
	//! AXI/AR
    logic [31:0] araddr;
    logic [3:0]  arlen;
    logic [2:0]  arsize;
    logic [1:0]  arburst;
    logic        arlock;
    logic [3:0]  arcache;
    logic [2:0]  arprot;
    logic        arvalid;
	//! AXI/R
    logic        rready;
	//! AXI/AW
    logic [31:0] awaddr;
    logic [3:0]  awlen;
    logic [2:0]  awsize;
    logic [1:0]  awburst;
    logic        awlock;
    logic [3:0]  awcache;
    logic [2:0]  awprot;
    logic        awvalid;
	//! AXI/W
    logic [31:0] wdata;
    logic [3:0]  wstrb;
    logic        wlast;
    logic        wvalid;
	//! AXI/B
    logic        bready;
} axi_req_t;

//! AXI response
typedef struct packed {
	//! AXI/AR
	logic        arready;
	//! AXI/R
	logic [31:0] rdata;
	logic [1:0]  rresp;
	logic        rlast;
	logic        rvalid;
	//! AXI/AW
	logic        awready;
	//! AXI/W
	logic        wready;
	//! AXI/B
	logic [1 :0] bresp;
	logic        bvalid;
} axi_resp_t;

typedef struct packed {
    //! master
    axi_req_t   req;
    logic [3:0] arid;
    logic [3:0] rid;
    logic [3:0] awid;
    logic [3:0] wid;
    logic [3:0] bid;
    //! slave
    axi_resp_t  resp;
} axi_t;

`endif
