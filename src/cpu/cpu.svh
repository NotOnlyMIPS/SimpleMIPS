/*!
 * \brief CPU 参数配置及关联结构声明
 */

`ifndef CPU_SVH
`define CPU_SVH
`include "../common.svh"

//BPU
`define B_IS_J		3'h1
`define B_IS_CALL   3'h2
`define B_IS_RET    3'h3
`define B_IS_BRA    3'h4

`define IDLE        1'b0
`define CORRECTION  1'b1

`define NT      2'b00  //not taken
`define WNT     2'b01  //weakly not taken
`define WT      2'b10  //weakly taken
`define T       2'b11  //taken

//MMU
`define CPU_MMU_ENABLED 1

// TLB
`define TLB_ENTRIES_NUM 16
`define ISSUE_NUM       1

`define TLBOP_TLBP   2'd0
`define TLBOP_TLBR   2'd1
`define TLBOP_TLBWI  2'd2

// coprocesser register
`define CR_INDEX     0
`define CR_ENTRYLO0  2
`define CR_ENTRYLO1  3
`define CR_BADVADDR  8
`define CR_COUNT     9
`define CR_ENTRYHI  10
`define CR_COMPARE  11
`define CR_STATUS   12
`define CR_CAUSE    13
`define CR_EPC      14
`define CR_CONFIG0  16
`define CR_CONFIG1  48
`define CR_TAGLO    28

// cause register exc_code field
`define EXCCODE_INT   5'h00  // interrupt
`define EXCCODE_MOD   5'h01  // TLB modification exception
`define EXCCODE_TLBL  5'h02  // TLB exception (load or instruction fetch)
`define EXCCODE_TLBS  5'h03  // TLB exception (store)
`define EXCCODE_ADEL  5'h04  // address exception (load or instruction fetch)
`define EXCCODE_ADES  5'h05  // address exception (store)
`define EXCCODE_SYS   5'h08  // syscall
`define EXCCODE_BP    5'h09  // breakpoint
`define EXCCODE_RI    5'h0a  // reserved instruction exception
`define EXCCODE_CpU   5'h0b  // coprocesser unusable exception
`define EXCCODE_OV    5'h0c  // overflow
`define EXCCODE_TR    5'h0d  // trap
`define EXCCODE_FPE   5'h0f  // floating point exception

//Cache
typedef enum logic [2:0] {
	EMPTY,

	I_Index_Invalid,
	I_Index_Store_Tag,
	I_Hit_Invalid,

	D_Index_Writeback_Invalid,
	D_Index_Store_Tag,
	D_Hit_Invalid,
	D_Hit_Writeback_Invalid
} CacheCodeType;

typedef struct packed {
	CacheCodeType       	cacheCode;
	logic 					isIcache;
	logic 					isDcache;
} CacheType;

typedef logic [4:0] reg_addr_t;

// exception
typedef struct packed {
	//TLB
	logic        tlb_refill;

    logic        bd;
    logic        ex;
    logic [ 4:0] exccode;
    virt_t 		 badvaddr;
} exception_t;

typedef struct packed {
	logic ex;
	logic eret;
	logic tlb_op;
	logic cache_op;
	logic tlb_refill;
} pipeline_flush_t;

// BPU
typedef struct packed {
	logic [31:10]	tag;
	virt_t          target;
	logic [2:0]     br_type;
	logic [1:0]     count;
} BHT_entry_t;

typedef struct packed {
	logic [2:0]    br_type;
	logic 		   br_verify_ready;
	virt_t         pc;
} ds_to_bpu_bus_t;

typedef struct packed {
	logic          valid;
	logic          br_op;
	logic          br_taken;
	virt_t         target;
} predict_result_t;

typedef struct packed {
	logic          predict_sucess;
	logic [2:0]	   br_type;
	logic          ready;
	BHT_entry_t    predict_entry;
	logic          is_taken;
	virt_t         correct_target;
	virt_t		   pc;
} verify_result_t;


// RAS
typedef struct packed {
	logic valid;
	virt_t data;
} ras_t;

// pre_IF stage
typedef struct packed {
	// pipeline
	logic 	 	valid;
	// pre_IF to IF
	logic   	req;
	logic 	 	br_op;
	virt_t	 	pc;
	// exception
	exception_t exception;
} pfs_to_fs_bus_t;

// IF stage
typedef struct packed {
	// pipeline
	logic 		 valid;
	// IF to ID
    uint32_t 	 inst;
    virt_t 		 pc;
    // ex
	exception_t  exception;
} fs_to_ds_bus_t;

// ID stage
typedef struct packed {
	logic 		 invalid;

	reg_addr_t 	 rs;
	reg_addr_t   rt;
	reg_addr_t 	 rd;

	logic [11:0] alu_op;
	logic    	 alu_ov;
	logic [11:0] br_op;
	logic [ 2:0] tlb_op;
	logic [12:0] hi_lo_op;
	logic [ 6:0] load_op;
	logic [ 4:0] store_op;
	logic [ 2:0] c0_op;
	logic [ 7:0] c0_addr;

	logic        src1_is_sa;
	logic        src1_is_pc;
	logic        src2_is_simm;
	logic        src2_is_zimm;
	logic        src2_is_8;
	logic        res_from_mem;
	logic        res_to_mem;
	logic 		 rf_we;
	reg_addr_t	 dest;
	uint16_t  	 imm;
	logic [25:0] jidx;

	logic  		 op_syscall;
	logic 		 op_break;

	CacheCodeType cache_op;
} decoded_inst_t;

typedef struct packed {
	// pipeline
	logic 		 valid;
	// ID to EXE
	logic [11:0] alu_op;
	logic 		 alu_ov;
	logic [ 2:0] br_type;
	logic [11:0] br_op;
	logic [ 6:0] load_op;
	logic [ 4:0] store_op;
	logic [12:0] hi_lo_op;
	logic [ 2:0] c0_op;
	logic [ 7:0] c0_addr;
	logic 		 src1_is_sa;
	logic   	 src1_is_pc;
	logic  		 src2_is_simm;
	logic 		 src2_is_zimm;
	logic 		 src2_is_8;
	logic 		 res_from_mem;
	logic 		 res_to_mem;
	logic 		 rf_we;
	reg_addr_t 	 dest;
	uint16_t 	 imm;
	logic [25:0] jidx;
	uint32_t 	 rs_value;
	uint32_t 	 rt_value;
	virt_t 	 	 pc;
	// branch prediction
	logic  		 predict_is_taken;
	virt_t		 predict_target;
	BHT_entry_t  predict_entry;
    // ex
	exception_t  exception;
	// tlb
	logic   [2:0]tlb_op;
	// cache
	CacheCodeType cache_op;
} ds_to_es_bus_t;


// EXE stage
typedef struct packed {
	logic 		op_mfc0;
	logic 		op_load;
	logic       op_tlb_cache;
	reg_addr_t 	dest;
	uint32_t 	result;
} es_forward_bus_t;

typedef struct packed {
	// pipeline
	logic 		 valid;
	// EXE to pre_MEM
	logic [ 6:0] load_op;
	logic [ 4:0] store_op;
    logic [ 2:0] c0_op;
	logic [ 7:0] c0_addr;
	logic 		 res_from_mem;
	logic 		 res_to_mem;
	logic 		 rf_we;
	virt_t		 mem_addr;
	reg_addr_t 	 dest;
	uint32_t 	 result;
    virt_t 		 pc;
    // ex
	exception_t  exception;
	// tlb
	logic   [2:0]tlb_op;
	// cache
	CacheCodeType cache_op;
} es_to_pms_bus_t;

// pre_MEM stage
typedef struct packed {
	logic 		op_mfc0;
	logic 		op_load;
	logic       op_tlb_cache;
	reg_addr_t 	dest;
	uint32_t 	result;
} pms_forward_bus_t;

typedef struct packed {
	// pipeline
	logic 		 valid;
	// pre_MEM to MEM
	logic [ 6:0] load_op;
    logic [ 2:0] c0_op;
	logic [ 7:0] c0_addr;
	logic 		 req_ok;
	logic 		 res_from_mem;
	logic 		 res_to_mem;
	logic 		 rf_we;
	reg_addr_t 	 dest;
	uint32_t 	 result;
    virt_t 		 pc;
    // ex
	exception_t  exception;
	// tlb
	phys_t	     phy_addr;
	logic  [2:0] tlb_op;
	// cache
	CacheCodeType cache_op;
} pms_to_ms_bus_t;

// MEM stage
typedef struct packed {
	logic 		 op_mfc0;
	logic 		 op_load;
	logic        op_tlb_cache;
	logic [ 3:0] rf_we;
	reg_addr_t 	 dest;
	uint32_t 	 result;
} ms_forward_bus_t;

typedef struct packed {
	// pipeline
	logic 		 valid;
	// MEM to WB
    logic [ 2:0] c0_op;
	logic [ 7:0] c0_addr;
	logic [ 3:0] rf_we;
	reg_addr_t 	 dest;
	uint32_t 	 result;
    virt_t 		 pc;
    // ex
	exception_t  exception;
	// tlb
	phys_t	     phy_addr;
	logic   [2:0]tlb_op;
	// cache
	CacheCodeType cache_op;
} ms_to_ws_bus_t;

// WB stage
typedef struct packed {
	logic 		 op_mfc0;
	logic        op_tlb_cache;
	logic [ 3:0] rf_we;
	reg_addr_t 	 dest;
	uint32_t 	 result;
} ws_forward_bus_t;

typedef struct packed {
	logic [ 3:0] we;
	reg_addr_t   waddr;
	uint32_t     wdata;
} ws_to_rf_bus_t;


typedef struct packed {
	logic 		 eret_flush;
	exception_t  exception;
	virt_t 		 pc;
	// TLB
	logic  [2:0] tlb_op;
	// Cache
	virt_t		 cache_vaddr;
	phys_t	     cache_paddr;
	CacheCodeType cache_op;
} ws_to_c0_bus_t;

// CP0
typedef struct packed {
	logic 		bev;
	logic [7:0] im;
	logic 		exl;
	logic		ie;
} cp0_status_t;

typedef struct packed {
	logic bd;
	logic ti;
	logic [7:0] ip;
	logic [4:0] exccode;
} cp0_cause_t;

//MMU/TLB
typedef logic [$clog2(`TLB_ENTRIES_NUM)-1:0] tlb_index_t;
typedef struct packed {
	phys_t phy_addr;
	tlb_index_t which;
	logic miss, dirty, valid;
	logic [2:0] cache_flag;
} tlb_result_t;

typedef struct packed {
	logic [2:0] c0;
	logic [2:0] c1;
	logic [7:0] asid;
	logic [18:0] vpn2;
	logic [19:0] pfn0, pfn1;
	logic d0, v0, d1, v1;
	logic G;
} tlb_entry_t;

typedef struct packed {
	phys_t phy_addr;
	virt_t virt_addr;
	logic  uncached;
	logic[2:0] cache_flag;
	logic  invalid, miss, dirty, illegal;
} mmu_result_t;
interface C0_TLB_Interface();
	//for TLBR/TLBWI/TLWR
	tlb_index_t  tlbrw_index;
	logic        tlbrw_we;
	tlb_entry_t  tlbrw_wdata;
	tlb_entry_t  tlbrw_rdata;
	// for TLBP
	uint32_t     tlbp_entry_hi;
	uint32_t     tlbp_index;

	modport C0(
		output  tlbrw_index,
		output  tlbrw_we,
		output  tlbrw_wdata,
		input   tlbrw_rdata,
		output  tlbp_entry_hi,
		input   tlbp_index
	);

	modport TLB(
		input  tlbrw_index,
        input  tlbrw_we,
        input  tlbrw_wdata,
        output tlbrw_rdata,
        input  tlbp_entry_hi,
        output tlbp_index
	);
endinterface


/*--------------------------------------Interface Definition-----------------------------------------------*/

// CP0
interface WB_C0_Interface();
	logic 		 we;
	logic [ 7:0] addr;
	uint32_t 	 wdata;
	uint32_t 	 rdata;

	modport WB(
		output we,
		output addr,
		output wdata,
		input  rdata
	);

	modport C0(
		input  we,
		input  addr,
		input  wdata,
		output rdata
	);

endinterface

// ICache
interface CPU_ICache_Interface();
	logic 	     req;
	logic 		 addr_ok;
	logic 		 iscache;
	logic [ 3:0] offset;
	logic [ 7:0] index;
	logic [19:0] tag;
	logic 		 data_ok;
	uint32_t	 rdata;
	// Cache Instruction
	CacheType    cachetype;
	logic        cache_valid;
	logic [19:0] cache_tag;
	logic [ 7:0] cache_index;

	modport	ICache(
		input  req,
		input  iscache,
		input  offset,
		input  index,
		input  tag,
		input  cachetype,
		input  cache_valid,
		input  cache_tag,
		input  cache_index,
		output addr_ok,
		output data_ok,
		output rdata
	);

	modport CPU(
		output req,
		output iscache,
		output offset,
		output index,
		output tag,
		output cachetype,
		output cache_valid,
		output cache_tag,
		output cache_index,
		input  addr_ok,
		input  data_ok,
		input  rdata
	);
endinterface

// DCache
interface CPU_DCache_Interface();
	logic		 req;
	logic 		 iscache;
	logic	     wr;
	logic [ 3:0] offset;
	logic [ 7:0] index;
	logic [19:0] tag;
	logic [ 3:0] wstrb;
	logic [ 2:0] size;
	uint32_t	 wdata;
	uint32_t	 rdata;
	logic 		 addr_ok;
	logic 		 data_ok;
	// Cache Instruction
	CacheType    cachetype;
	logic        cache_valid;
	logic [19:0] cache_tag;
	logic        cache_dirty;
	logic [ 7:0] cache_index;

	modport	DCache(
		input  req,
		input  iscache,
		input  wr,
		input  offset,
		input  index,
		input  tag,
		input  wstrb,
		input  size,
		input  wdata,
		input  cachetype,
		input  cache_valid,
		input  cache_tag,
		input  cache_dirty,
		input  cache_index,
		output addr_ok,
		output data_ok,
		output rdata
	);

	modport CPU(
		output req,
		output iscache,
		output wr,
		output offset,
		output index,
		output tag,
		output wstrb,
		output size,
		output wdata,
		output cachetype,
		output cache_valid,
		output cache_tag,
		output cache_dirty,
		output cache_index,
		input  addr_ok,
		input  data_ok,
		input  rdata
	);
endinterface

`endif
