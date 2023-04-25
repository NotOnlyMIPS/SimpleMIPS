`include "../cpu.svh"

module control (
    input  logic clk  ,
    input  logic reset,
    
    input  logic [5:0] ext_int,

    BPU_Control_Interface.Control       bpu       ,
    PreFetch_Control_Interface.Control  pre_fetch ,
    Fetch_Control_Interface.Control     fetch     ,
    Decode_Control_Interface.Control    decode    ,
    Execute_Control_Interface.Control   execute   ,
    PreMemory_Control_Interface.Control pre_memory,
    Memmory_Control_Interface.Control   memory    ,
    Writeback_Control_Interface.Control writeback ,
    CP0_Control_Interface.Control       cp0       ,
    MMU_Control_Interface.Control       mmu       ,

    CPU_ICache_Interface.CPU            IBus      ,
    CPU_DCache_Interface.CPU            DBus      

);

/* pipeline control */
logic pipeline_flush;


/* branch control */
logic br_valid;
logic br_bd_valid;
// logic br_resolved;


/* data cancel */
logic inst_recv_valid;
logic bd_data_cancel;
logic inst_data_cancel;

logic data_recv_valid;
logic data_data_cancel;


/* bypass */
logic es_rs_wait, pms_rs_wait, ms_rs_wait, ws_rs_wait;
logic es_rt_wait, pms_rt_wait, ms_rt_wait, ws_rt_wait;
logic    rs_wait, rt_wait;


/* reg file */
uint32_t rs_rdata, rt_rdata;


/* Exception, CP0, TLB, Cache */
logic  flush_en;


/* branch control */
assign pre_fetch.br_flush = bpu.br_flush;
assign pre_fetch.bd       = br_bd_valid && !fetch.valid;
assign pre_fetch.predict_result = bpu.predict_result;
assign pre_fetch.is_correction  = bpu.is_correction;
assign pre_fetch.correct_target = bpu.correct_target;

assign bpu.pipeline_flush = pipeline_flush;
assign bpu.br_valid       = fetch.to_valid && decode.allowin;
assign bpu.fetch_pc       = fetch.pc;
assign bpu.verify_result  = execute.verify_result;
assign bpu.correction_finish = !pre_fetch.bd && pre_fetch.to_valid && fetch.allowin;

assign fetch.bd       = br_bd_valid;
assign fetch.br_flush = bpu.br_flush;

assign decode.predict_result = bpu.predict_result;
assign decode.predict_entry  = bpu.predict_entry;

always_ff @(posedge clk) begin
    if(reset || pipeline_flush || br_bd_valid && fetch.to_valid && decode.allowin)
        br_bd_valid <= 1'b0;
    else if(fetch.br_op && fetch.to_valid && decode.allowin && !bpu.br_flush)
        br_bd_valid <= 1'b1;
end


/* bypass */
assign es_rs_wait  = decode.rs != 5'd0 && decode.rs == execute.dest;
assign pms_rs_wait = decode.rs != 5'd0 && decode.rs == pre_memory.dest;
assign ms_rs_wait  = decode.rs != 5'd0 && decode.rs == memory.dest;
assign ws_rs_wait  = decode.rs != 5'd0 && decode.rs == writeback.dest;

assign es_rt_wait  = decode.rt != 5'd0 && decode.rt == execute.dest;
assign pms_rt_wait = decode.rt != 5'd0 && decode.rt == pre_memory.dest;
assign ms_rt_wait  = decode.rt != 5'd0 && decode.rt == memory.dest;
assign ws_rt_wait  = decode.rt != 5'd0 && decode.rt == writeback.dest;

assign rs_wait = es_rs_wait | pms_rs_wait | ms_rs_wait | ws_rs_wait;
assign rt_wait = es_rt_wait | pms_rt_wait | ms_rt_wait | ws_rt_wait;

assign decode.stall = decode.valid &&
                    ( (execute.load_op    && ( es_rs_wait  || es_rt_wait ))
                   || (pre_memory.load_op && ( pms_rs_wait || pms_rt_wait))
                   || (memory.load_op     && ( ms_rs_wait  || ms_rt_wait ))
                   || ( (execute.mfc0  || pre_memory.mfc0  || memory.mfc0  || writeback.mfc0 ) && (rs_wait || rt_wait) )
                   || ( (execute.stall || pre_memory.stall || memory.stall || writeback.stall)) );

assign decode.rs_value = !rs_wait    ? rs_rdata :
                         es_rs_wait  ? execute.result    :
                         pms_rs_wait ? pre_memory.result :
                         ms_rs_wait  ? {memory.rf_we[3]    ? memory.result[31:24]    : rs_rdata[31:24],
                                        memory.rf_we[2]    ? memory.result[23:16]    : rs_rdata[23:16],
                                        memory.rf_we[1]    ? memory.result[15: 8]    : rs_rdata[15: 8],
                                        memory.rf_we[0]    ? memory.result[ 7: 0]    : rs_rdata[ 7: 0]} :
                                       {writeback.rf_we[3] ? writeback.result[31:24] : rs_rdata[31:24],
                                        writeback.rf_we[2] ? writeback.result[23:16] : rs_rdata[23:16],
                                        writeback.rf_we[1] ? writeback.result[15: 8] : rs_rdata[15: 8],
                                        writeback.rf_we[0] ? writeback.result[ 7: 0] : rs_rdata[ 7: 0]} ;
assign decode.rt_value = !rt_wait    ? rt_rdata :
                         es_rt_wait  ? execute.result    :
                         pms_rt_wait ? pre_memory.result :
                         ms_rt_wait  ? {memory.rf_we[3]    ? memory.result[31:24]    : rt_rdata[31:24],
                                        memory.rf_we[2]    ? memory.result[23:16]    : rt_rdata[23:16],
                                        memory.rf_we[1]    ? memory.result[15: 8]    : rt_rdata[15: 8],
                                        memory.rf_we[0]    ? memory.result[ 7: 0]    : rt_rdata[ 7: 0]} :
                                       {writeback.rf_we[3] ? writeback.result[31:24] : rt_rdata[31:24],
                                        writeback.rf_we[2] ? writeback.result[23:16] : rt_rdata[23:16],
                                        writeback.rf_we[1] ? writeback.result[15: 8] : rt_rdata[15: 8],
                                        writeback.rf_we[0] ? writeback.result[ 7: 0] : rt_rdata[ 7: 0]} ;


/* reg file */
regfile u_regfile(
    .clk,

    .raddr1(decode.rs),
    .rdata1(rs_rdata ),
    .raddr2(decode.rt),
    .rdata2(rt_rdata ),

    .we   (writeback.rf_we   ),
    .waddr(writeback.rf_waddr),
    .wdata(writeback.rf_wdata)
);


/* Cache */
// ICache
assign pre_fetch.icache_addr_ok = IBus.addr_ok;
assign pre_fetch.icache_data_ok = IBus.data_ok;
assign pre_fetch.icache_rdata   = IBus.rdata;

assign fetch.icache_data_ok = IBus.data_ok;
assign fetch.icache_rdata   = IBus.rdata;

assign IBus.iscache = ~mmu.inst_mmu_result.uncached;
assign IBus.req     = pre_fetch.icache_req;
assign IBus.offset  = pre_fetch.icache_offset;
assign IBus.index   = pre_fetch.icache_index;
assign IBus.tag     = mmu.inst_mmu_result.phy_addr[31:12];

assign IBus.cache_type  = {cp0.cache_op, cp0.cache_op != Cache_Code_EMPTY, 1'b0};
assign IBus.cache_valid = cp0.cache_valid;
assign IBus.cache_tag   = cp0.cache_tag;
assign IBus.cache_index = cp0.cache_index;

assign IBus.tlb_ex = mmu.inst_tlb_ex.ex;

// DCache
assign pre_memory.dcache_addr_ok = DBus.addr_ok;

assign memory.dcache_data_ok = DBus.data_ok;
assign memory.dcache_rdata   = DBus.rdata;

assign DBus.iscache = ~mmu.data_mmu_result.uncached;
assign DBus.req     = pre_memory.dcache_req;
assign DBus.wr      = pre_memory.dcache_wr;
assign DBus.size    = pre_memory.dcache_size;
assign DBus.wstrb   = pre_memory.dcache_wstrb;
assign DBus.wdata   = pre_memory.dcache_wdata;
assign DBus.offset  = pre_memory.dcache_offset;
assign DBus.index   = pre_memory.dcache_index;
assign DBus.tag     = mmu.data_mmu_result.phy_addr[31:12];

assign DBus.cache_type  = {cp0.cache_op, 1'b0, cp0.cache_op != Cache_Code_EMPTY};
assign DBus.cache_valid = cp0.cache_valid;
assign DBus.cache_tag   = cp0.cache_tag;
assign DBus.cache_dirty = cp0.cache_dirty;
assign DBus.cache_index = cp0.cache_index;
assign DBus.cache_way   = cp0.cache_way;

assign DBus.tlb_ex = mmu.data_tlb_ex.ex;

/* data cancel */
assign fetch.data_cancel  = inst_data_cancel && !bd_data_cancel;
assign memory.data_cancel = data_data_cancel;

always_ff @(posedge clk) begin
    // inst
    if(reset)
        inst_data_cancel <= 1'b0;
    else if((inst_recv_valid || IBus.addr_ok) && (pipeline_flush || bpu.br_flush && !pre_fetch.bd))
        inst_data_cancel <= 1'b1;
    else if(IBus.data_ok)
        inst_data_cancel <= 1'b0;

    if(reset)
        inst_recv_valid <= 1'b0;
    else if(IBus.addr_ok)
        inst_recv_valid <= 1'b1;
    else if(IBus.data_ok)
        inst_recv_valid <= 1'b0;

    if(reset || bd_data_cancel && IBus.data_ok)
        bd_data_cancel <= 1'b0;
    else if(fetch.br_op && IBus.data_ok && !bpu.br_flush)
        bd_data_cancel <= 1'b1;


    // data
    if(reset || DBus.data_ok && data_data_cancel)
        data_data_cancel <= 1'b0;
    else if((data_recv_valid || DBus.addr_ok) && pipeline_flush)
        data_data_cancel <= 1'b1;

    if(reset)
        data_recv_valid <= 1'b0;
    else if(DBus.addr_ok)
        data_recv_valid <= 1'b1;
    else if(DBus.data_ok)
        data_recv_valid <= 1'b0;
end


/* mmu */
// inst
assign mmu.inst_valid = IBus.addr_ok;
assign mmu.inst_vaddr = pre_fetch.inst_vaddr;

assign pre_fetch.inst_tlb_refill  = mmu.inst_tlb_ex.tlb_refill;
assign pre_fetch.inst_tlb_ex      = mmu.inst_tlb_ex.ex;
assign pre_fetch.inst_tlb_exccode = mmu.inst_tlb_ex.exccode;

assign fetch.inst_tlb_refill  = mmu.inst_tlb_ex.tlb_refill;
assign fetch.inst_tlb_ex      = mmu.inst_tlb_ex.ex;
assign fetch.inst_tlb_exccode = mmu.inst_tlb_ex.exccode;

// data
assign mmu.data_valid  = DBus.addr_ok || pre_memory.op_cache;
assign mmu.data_vaddr  = pre_memory.data_vaddr;
assign memory.phy_addr = mmu.data_mmu_result.phy_addr;

assign memory.data_tlb_refill  = mmu.data_tlb_ex.tlb_refill;
assign memory.data_tlb_ex      = mmu.data_tlb_ex.ex;
assign memory.data_tlb_exccode = mmu.data_tlb_ex.exccode;

// cp0
assign mmu.asid           = cp0.tlb_asid;
assign mmu.kseg0_uncached = cp0.kseg0_uncached;
assign mmu.is_user_mode   = 1'b1;

assign mmu.tlbrw_index = cp0.tlbrw_index;
assign mmu.tlbrw_we    = cp0.tlbrw_we;
assign mmu.tlbrw_wdata = cp0.tlbrw_wdata;

assign mmu.tlbp_entry_hi = cp0.tlbp_entry_hi;

assign mmu.load_op  = pre_memory.dcache_req & ~pre_memory.dcache_wr;
assign mmu.store_op = pre_memory.dcache_req &  pre_memory.dcache_wr;


/* Exception, CP0, TLB, Cache */
// pipeline flush
assign pipeline_flush = writeback.pipeline_flush;
assign pre_fetch.pipeline_flush  = pipeline_flush;
assign bpu.pipeline_flush        = pipeline_flush;
assign fetch.pipeline_flush      = pipeline_flush;
assign decode.pipeline_flush     = pipeline_flush;
assign execute.pipeline_flush    = pipeline_flush;
assign pre_memory.pipeline_flush = pipeline_flush;
assign memory.pipeline_flush     = pipeline_flush;

// pre_fetch
assign pre_fetch.exception_en     = writeback.exception.ex;
assign pre_fetch.exception_vector = cp0.exception_vector;
assign pre_fetch.eret_en          = writeback.eret;
assign pre_fetch.epc              = cp0.epc;
assign pre_fetch.cache_tlb_op     = writeback.cache_tlb_op;
assign pre_fetch.cache_tlb_pc     = writeback.pc;

// decode
assign decode.hw = |cp0.hw;
assign decode.sw = |cp0.sw;

// execute
assign execute.wr_disable = pre_memory.wr_disable | memory.wr_disable | writeback.wr_disable;

// mfc0/mtc0
assign cp0.we = writeback.cp0_we;
assign cp0.addr = writeback.cp0_addr;
assign cp0.wdata = writeback.cp0_wdata;
assign writeback.cp0_rdata = cp0.rdata;

// interrupt
assign cp0.ext_int = ext_int;

// exception
assign cp0.eret_flush = writeback.eret;
assign cp0.exception  = writeback.exception;
assign cp0.pc = writeback.pc;

// TLB
assign cp0.tlb_op      = writeback.tlb_op;
assign cp0.tlbrw_rdata = mmu.tlbrw_rdata;
assign cp0.tlbp_index  = mmu.tlbp_index;

// Cache
assign cp0.cache_op = writeback.cache_op;
assign cp0.cache_vaddr = writeback.cache_vaddr;
assign cp0.cache_paddr = writeback.cache_paddr;

endmodule
