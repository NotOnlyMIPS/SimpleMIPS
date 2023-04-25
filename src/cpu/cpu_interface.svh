`ifndef CPU_INTERFACE_SVH
`define CPU_INTERFACE_SVH


/*------------------------------  Control  -----------------------------*/
interface PreFetch_Control_Interface();
	// pipeline control
	logic valid;
	logic ready_go;
	logic to_valid;
	logic allowin;
	logic flow_en;
	logic pipeline_flush;

	// branch control
    logic            br_flush;
	logic 			 bd;
	predict_result_t predict_result;
	logic 			 is_correction;
	virt_t			 correct_target;

	// mmu
	virt_t inst_vaddr;

	// ICache
    logic       icache_req;
	logic [3:0] icache_offset;
	logic [7:0] icache_index;
    logic       icache_addr_ok;
    logic       icache_data_ok;
    uint32_t    icache_rdata;

	// Exception, CP0, TLB, Cache
	logic       exception_en;
	virt_t      exception_vector;
	logic       eret_en;
	virt_t      epc;
	logic       cache_tlb_op;
	virt_t      cache_tlb_pc;
	logic       inst_tlb_refill;
	logic       inst_tlb_ex;
	logic [4:0] inst_tlb_exccode;

	modport PreFetch(
	// pipeline control
		output valid,
		output ready_go,
		output to_valid,
		output allowin,
		input  pipeline_flush,
	
	// branch control
        input  br_flush,
		input  bd,
		input  predict_result,
		input  is_correction,
		input  correct_target,

	// mmu
		output inst_vaddr,

    // ICache
        output icache_req,
        output icache_offset,
        output icache_index,
    	input  icache_addr_ok,
    	input  icache_data_ok,
    	input  icache_rdata,

	// Exception, CP0, TLB, Cache
		input  exception_en,
		input  exception_vector,
		input  eret_en,
		input  epc,
		input  cache_tlb_op,
		input  cache_tlb_pc,
		input  inst_tlb_refill,
		input  inst_tlb_ex,
		input  inst_tlb_exccode
	);

	modport Control(
	// pipeline control
		input  valid,
		input  ready_go,
		input  to_valid,
		input  allowin,
		output pipeline_flush,
	
	// branch control
        output br_flush,
		output bd,
		output predict_result,
		output is_correction,
		output correct_target,

	// mmu
		input  inst_vaddr,

    // ICache
        input  icache_req,
        input  icache_offset,
        input  icache_index,
    	output icache_addr_ok,
    	output icache_data_ok,
    	output icache_rdata,
		
	// Exception, CP0, TLB, Cache
		output exception_en,
		output exception_vector,
		output eret_en,
		output epc,
		output cache_tlb_op,
		output cache_tlb_pc,
		output inst_tlb_refill,
		output inst_tlb_ex,
		output inst_tlb_exccode
	);
endinterface

interface BPU_Control_Interface();
	// pipeline
	logic 			 pipeline_flush;

	// prediction
	logic 			 br_valid;
	virt_t 			 fetch_pc;
	predict_result_t predict_result;
	BHT_entry_t		 predict_entry;

	// correction
	verify_result_t  verify_result;
	logic 			 br_flush;
	logic 			 is_correction;
	logic 		     correction_finish;
	virt_t 			 correct_target;

	modport BPU (
	// pipeline
		input  pipeline_flush,

	// prediction
		input  br_valid,
		input  fetch_pc,
		output predict_result,
		output predict_entry,

	// correction
		input  verify_result,
		input  correction_finish,
		output br_flush,
		output is_correction,
		output correct_target
	);

	modport Control (
	// pipeline
		output pipeline_flush,

	// prediction
		output br_valid,
		output fetch_pc,
		input  predict_result,
		input  predict_entry,

	// correction
		output verify_result,
		output correction_finish,
		input  br_flush,
		input  is_correction,
		input  correct_target
	);

endinterface

interface Fetch_Control_Interface();
	// pipeline control
	logic valid;
	logic ready_go;
	logic to_valid;
	logic allowin;
	logic pipeline_flush;

	// branch control
    logic  br_flush;
	logic  bd;
	logic  br_op;
	virt_t pc;

	// ICache
    logic 	 data_cancel;
	logic    icache_data_ok;
	uint32_t icache_rdata;

	// Exception, CP0, TLB, Cache
	logic       inst_tlb_refill;
	logic       inst_tlb_ex;
	logic [4:0] inst_tlb_exccode;

	modport Fetch(
	// pipeline control
		output valid,
		output ready_go,
		output to_valid,
		output allowin,
        input  pipeline_flush,
	
	// branch control
        input  br_flush,
		input  bd,
		output br_op,
		output pc,

	// ICache
        input  data_cancel,
		input  icache_data_ok,
		input  icache_rdata,

	// Exception, CP0, TLB, Cache
	    input  inst_tlb_refill,
	    input  inst_tlb_ex,
	    input  inst_tlb_exccode
	);

	modport Control(
	// pipeline control
		input  valid,
		input  ready_go,
		input  to_valid,
		input  allowin,
        output pipeline_flush,

	// branch control
        output br_flush,
		output bd,
		input  br_op,
		input  pc,

	// ICache
        output data_cancel,
		output icache_data_ok,
		output icache_rdata,

	// Exception, CP0, TLB, Cache
	    output inst_tlb_refill,
	    output inst_tlb_ex,
	    output inst_tlb_exccode
	);
endinterface

interface Decode_Control_Interface();
	// pipeline control
	logic valid;
	logic allowin;
	logic pipeline_flush;

	// branch prediction
	predict_result_t predict_result;
	BHT_entry_t		 predict_entry;

	// bypass
	reg_addr_t rs;
	reg_addr_t rt;
	uint32_t   rs_value;
	uint32_t   rt_value;

	// Exception, CP0, TLB, Cache
	logic stall;
	logic hw;
	logic sw;

	modport Decode(
	// pipeline control
		output valid,
		output allowin,
		input  pipeline_flush,

	// branch prediction
		input  predict_result,
		input  predict_entry,

	// bypass
		output rs,
		output rt,
		input  rs_value,
		input  rt_value,
	
	// Exception, CP0, TLB, Cache
		input  stall,
		input  hw,
		input  sw
	);

	modport Control(
	// pipeline control
		input  valid,
		input  allowin,
		output pipeline_flush,
	
	// branch prediction
		output predict_result,
		output predict_entry,

	// bypass
		input  rs,
		input  rt,
		output rs_value,
		output rt_value,

	// Exception, CP0, TLB, Cache
		output stall,
		output hw,
		output sw
	);

endinterface

interface Execute_Control_Interface();
	// pipeline control
	logic pipeline_flush;

	// branch control
	verify_result_t verify_result;
	
	// bypass
	logic 	    load_op;
	logic [5:0] dest;
	uint32_t	result;

	// Exception, CP0, TLB, Cache
	logic wr_disable;
	logic mfc0;
	logic stall;

	modport Execute(
	// pipeline control
		input  pipeline_flush,
	
	// branch control
		output verify_result,

	// bypass
		output load_op,
		output dest,
		output result,
	
	// Exception, CP0, TLB, Cache
		input  wr_disable,
		output mfc0,
		output stall
	);

	modport Control(
	// pipeline control
		output pipeline_flush,

	// branch control
		input  verify_result,
	
	// bypass
		input  load_op,
		input  dest,
		input  result,

	// Exception, CP0, TLB, Cache
		output wr_disable,
		input  mfc0,
		input  stall
	);
endinterface

interface PreMemory_Control_Interface();
	// pipeline control
	logic pipeline_flush;

	// bypass
	logic 	    load_op;
	logic [5:0] dest;
	uint32_t	result;

	// mmu
	logic  	     data_mmu_valid;
    virt_t       data_vaddr;

	// DCache
	logic 		 dcache_req;
	logic 		 dcache_addr_ok;
    logic        dcache_wr;
    logic [2:0]  dcache_size;
    logic [3:0]  dcache_wstrb;
	logic [3:0]  dcache_offset;
	logic [7:0]  dcache_index;
    uint32_t     dcache_wdata;
	
	// Exception, CP0, TLB, Cache
	logic op_cache;
	logic wr_disable;
	logic mfc0;
	logic stall;

	modport PreMemory(
	// pipeline control
		input  pipeline_flush,
	
	// bypass
		output load_op,
		output dest,
		output result,

	// mmu
		output data_vaddr,
		
	// DCache
		output dcache_req,
		input  dcache_addr_ok,
    	output dcache_wr,
    	output dcache_size,
    	output dcache_wstrb,
		output dcache_offset,
		output dcache_index,
    	output dcache_wdata,

	// Exception, CP0, TLB, Cache
		output op_cache,
		output wr_disable,
		output mfc0,
		output stall
	);

	modport Control(
	// pipeline control
		output pipeline_flush,
	
	// bypass
		input  load_op,
		input  dest,
		input  result,

	// mmu
		input  data_vaddr,
		
	// DCache
		input  dcache_req,
		output dcache_addr_ok,
    	input  dcache_wr,
    	input  dcache_size,
    	input  dcache_wstrb,
		input  dcache_offset,
		input  dcache_index,
    	input  dcache_wdata,

	// Exception, CP0, TLB, Cache
		input  op_cache,
		input  wr_disable,
		input  mfc0,
		input  stall
	);
endinterface

interface Memmory_Control_Interface();
	// pipeline control
	logic pipeline_flush;

	// bypass
	logic 	    load_op;
	logic [3:0] rf_we;
	logic [5:0] dest;
	uint32_t	result;

	// mmu
	phys_t	 phy_addr;
	
	// DCache
	logic  	 	data_cancel;
	logic    	dcache_data_ok;
	uint32_t 	dcache_rdata;

	// Exception, CP0, TLB, Cache
	logic       data_tlb_refill;
	logic       data_tlb_ex;
	logic [4:0] data_tlb_exccode;

	logic		wr_disable;
	logic		mfc0;
	logic		stall;

	modport Memory(
	// pipeline control
		input  pipeline_flush,
	
	// bypass
		output load_op,
		output rf_we,
		output dest,
		output result,

	// mmu
		input  phy_addr,

	// DCache
		input  data_cancel,
		input  dcache_data_ok,
		input  dcache_rdata,

	// Exception, CP0, TLB, Cache
		input  data_tlb_refill,
		input  data_tlb_ex,
		input  data_tlb_exccode,

		output wr_disable,
		output mfc0,
		output stall
	);

	modport Control(
	// pipeline control
		output pipeline_flush,
	
	// bypass
		input  load_op,
		input  rf_we,
		input  dest,
		input  result,

	// mmu
		output phy_addr,

	// DCache
		output data_cancel,
		output dcache_data_ok,
		output dcache_rdata,

	// Exception, CP0, TLB, Cache
		output data_tlb_refill,
		output data_tlb_ex,
		output data_tlb_exccode,

		input  wr_disable,
		input  mfc0,
		input  stall
	);
endinterface

interface Writeback_Control_Interface();
	// pipeline control
	logic pipeline_flush;

	// reg file
	logic [3:0] rf_we;
	logic [5:0] rf_waddr;
	uint32_t	rf_wdata;

	// bypass
	logic [5:0] dest;
	uint32_t	result;

	// Exception
	logic 		wr_disable;
	logic 		mfc0;
	logic 		stall;

	logic 		eret;
	logic  		cache_tlb_op;
	exception_t exception;
	virt_t		pc;

	// mtc0/mfc0
	logic 		cp0_we;
	logic [7:0] cp0_addr;
	uint32_t 	cp0_wdata;
	uint32_t 	cp0_rdata;

	// TLB
	logic [2:0]  tlb_op;

	// Cache
	CacheCodeType cache_op;
	virt_t		  cache_vaddr;
	phys_t		  cache_paddr;

	modport Writeback(
	// pipeline control
		output pipeline_flush,
	
	// reg file
		output rf_we,
		output rf_waddr,
		output rf_wdata,

	// bypass
		output dest,
		output result,

	// Exception
		output wr_disable,
		output mfc0,
		output stall,

		output eret,
		output cache_tlb_op,
		output exception,
		output pc,

	// mtc0/mfc0
		output cp0_we,
		output cp0_addr,
		output cp0_wdata,
		input  cp0_rdata,

	// TLB
		output tlb_op,

	// Cache
		output cache_op,
		output cache_vaddr,
		output cache_paddr

	);

	modport Control(
	// pipeline control
		input  pipeline_flush,
	
	// reg file
		input  rf_we,
		input  rf_waddr,
		input  rf_wdata,

	// bypass
		input  dest,
		input  result,

	// Exception
		input  wr_disable,
		input  mfc0,
		input  stall,

		input  eret,
		input  cache_tlb_op,
		input  exception,
		input  pc,

	// mtc0/mfc0
		input  cp0_we,
		input  cp0_addr,
		input  cp0_wdata,
		output cp0_rdata,

	// TLB
		input  tlb_op,

	// Cache
		input  cache_op,
		input  cache_vaddr,
		input  cache_paddr

	);
endinterface

interface CP0_Control_Interface();
	// mtc0/mfc0
	logic 		 we;
	logic [7:0]  addr;
	uint32_t 	 wdata;
	uint32_t 	 rdata;

	// interrupt
    logic [5:0]  ext_int;
	logic [5:0]  hw;
	logic [1:0]  sw;

	// exception
	logic       eret_flush;

	exception_t exception;
	virt_t      pc;
    virt_t 		epc;
	virt_t		exception_vector;

	// TLB
    logic  		 kseg0_uncached;
	logic [2:0]  tlb_op;
    logic [7:0]  tlb_asid;
    tlb_index_t  tlbrw_index;
    logic        tlbrw_we;
    tlb_entry_t  tlbrw_wdata;
    tlb_entry_t  tlbrw_rdata;
    uint32_t     tlbp_entry_hi;
    uint32_t     tlbp_index;

	// Cache
    CacheCodeType cache_op;
	virt_t		  cache_vaddr;
	phys_t	      cache_paddr;

    logic         cache_valid;
    logic [19:0]  cache_tag;
    logic         cache_dirty;
    logic [7:0]   cache_index;
    logic         cache_way;

	modport CP0(
	// mtc0/mfc0
		input  we,
		input  addr,
		input  wdata,
		output rdata,

	// interrupt
    	input  ext_int,
		output hw,
		output sw,

	// exception
		input  eret_flush,
		input  exception,
		input  pc,
    	output epc,
		output exception_vector,

	// TLB
    	output kseg0_uncached,
		input  tlb_op,
    	output tlb_asid,
    	output tlbrw_index,
    	output tlbrw_we,
    	output tlbrw_wdata,
    	input  tlbrw_rdata,
    	output tlbp_entry_hi,
    	input  tlbp_index,

	// Cache
    	input  cache_op,
		input  cache_vaddr,
		input  cache_paddr,

    	output cache_valid,
    	output cache_tag,
    	output cache_dirty,
    	output cache_index,
    	output cache_way

	);

	modport Control(
	// mtc0/mfc0
		output we,
		output addr,
		output wdata,
		input  rdata,

	// interrupt
    	output ext_int,
		input  hw,
		input  sw,

	// exception
		output eret_flush,
		output exception,
		output pc,
    	input  epc,
		input  exception_vector,

	// TLB
    	input  kseg0_uncached,
		output tlb_op,
    	input  tlb_asid,
    	input  tlbrw_index,
    	input  tlbrw_we,
    	input  tlbrw_wdata,
    	output tlbrw_rdata,
    	input  tlbp_entry_hi,
    	output tlbp_index,

	// Cache
    	output cache_op,
		output cache_vaddr,
		output cache_paddr,

    	input  cache_valid,
    	input  cache_tag,
    	input  cache_dirty,
    	input  cache_index,
    	input  cache_way

	);

endinterface

interface MMU_Control_Interface();
    logic [7:0]  asid;
    logic        kseg0_uncached;
    logic        is_user_mode;

	logic 		 inst_valid;
	virt_t 		 inst_vaddr;
	mmu_result_t inst_mmu_result;
	logic 	     data_valid;
	virt_t 		 data_vaddr;
	mmu_result_t data_mmu_result;

	// TLBR/TLBWI/TLBWR
	tlb_index_t  tlbrw_index;
	logic        tlbrw_we;
	tlb_entry_t  tlbrw_wdata;
	tlb_entry_t  tlbrw_rdata;

	// TLBP
	uint32_t     tlbp_entry_hi;
	uint32_t     tlbp_index;

	// exception
	logic  		 load_op;
	logic  		 store_op;
    exception_t  inst_tlb_ex;
    exception_t  data_tlb_ex;

	modport MMU (
		input  asid,
		input  kseg0_uncached,
		input  is_user_mode,

		input  inst_valid,
		input  inst_vaddr,
		output inst_mmu_result,
		input  data_valid,
		input  data_vaddr,
		output data_mmu_result,

	// TLBR/TLBWI/TLBWR
		input  tlbrw_index,
		input  tlbrw_we,
		input  tlbrw_wdata,
		output tlbrw_rdata,

	// TLBP
		input  tlbp_entry_hi,
		output tlbp_index,

	// exception
		input  load_op,
		input  store_op,
    	output inst_tlb_ex,
    	output data_tlb_ex
	);

	modport Control (
		output asid,
		output kseg0_uncached,
		output is_user_mode,

		output inst_valid,
		output inst_vaddr,
		input  inst_mmu_result,
		output data_valid,
		output data_vaddr,
		input  data_mmu_result,

	// TLBR/TLBWI/TLBWR
		output tlbrw_index,
		output tlbrw_we,
		output tlbrw_wdata,
		input  tlbrw_rdata,

	// TLBP
		output tlbp_entry_hi,
		input  tlbp_index,

	// exception
		output load_op,
		output store_op,
    	input  inst_tlb_ex,
    	input  data_tlb_ex
	);

endinterface


/*----------------------------------- Cache ---------------------------------*/
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
	CacheType    cache_type;
	logic        cache_valid;
	logic [19:0] cache_tag;
	logic [ 7:0] cache_index;
	// exception
	logic        tlb_ex;

	modport	ICache(
		input  req,
		input  iscache,
		input  offset,
		input  index,
		input  tag,
		input  cache_type,
		input  cache_valid,
		input  cache_tag,
		input  cache_index,
		input  tlb_ex,
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
		output cache_type,
		output cache_valid,
		output cache_tag,
		output cache_index,
		output tlb_ex,
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
	logic        tlb_ex;
	logic 		 addr_ok;
	logic 		 data_ok;
	// Cache Instruction
	CacheType    cache_type;
	logic        cache_valid;
	logic [19:0] cache_tag;
	logic 		 cache_way;
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
		input  cache_type,
		input  cache_valid,
		input  cache_tag,
		input  cache_way,
		input  cache_dirty,
		input  cache_index,
		input  tlb_ex,
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
		output cache_type,
		output cache_valid,
		output cache_tag,
		output cache_way,
		output cache_dirty,
		output cache_index,
		output tlb_ex,
		input  addr_ok,
		input  data_ok,
		input  rdata
	);
endinterface


`endif