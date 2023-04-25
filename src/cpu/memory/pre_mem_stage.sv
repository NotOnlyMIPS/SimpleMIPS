`include "../cpu.svh"

module pre_mem_stage(
    input  clk  ,
    input  reset,
    // pipeline
    input  es_to_valid,
    output pms_allowin,
    input  ms_allowin ,
    output pms_to_valid,

    input  es_to_pms_bus_t   es_to_pms_bus,
    output pms_to_ms_bus_t   pms_to_ms_bus,

    // control
    PreMemory_Control_Interface.PreMemory control
);


// pre_MEM
logic   pms_valid;
logic   pms_ready_go;
logic   pms_to_ms_valid;


// from EXE
es_to_pms_bus_t es_to_pms_bus_r;


// exception
logic       op_mfc0;
logic       op_tlb;
logic       op_cache;
logic       op_eret;
logic       mem_ex;
logic [4:0] mem_exccode;
exception_t exception;


// DCache interface
logic    req_valid;
logic    req_invalid;
logic    res_from_mem;
logic    res_to_mem;


// pre_MEM stage
assign pms_ready_go = control.dcache_req && control.dcache_addr_ok || !(res_from_mem || res_to_mem) || exception.ex;
assign pms_allowin  = !pms_valid || pms_ready_go && ms_allowin;
assign pms_to_valid = pms_valid && pms_ready_go;

always_ff @(posedge clk) begin
    if(reset || control.pipeline_flush)
        pms_valid <= 1'b0;
    else if(pms_allowin)
        pms_valid <= es_to_valid;

    if(es_to_valid && pms_allowin)
        es_to_pms_bus_r <= es_to_pms_bus;
end


// DCache interface
assign res_from_mem = es_to_pms_bus_r.res_from_mem;
assign res_to_mem   = es_to_pms_bus_r.res_to_mem;
assign control.dcache_req = pms_valid && req_valid && !req_invalid && (res_from_mem || res_to_mem) && !exception.ex;

always_ff @(posedge clk) begin
    if(reset)
        req_valid <= 1'b0;
    else if(ms_allowin || control.pipeline_flush)
        req_valid <= 1'b1;

    if(reset || control.pipeline_flush)
        req_invalid <= 1'b0;
    else if(exception.ex || op_eret)
        req_invalid <= 1'b1;
end

mem_req u_mem_req (
    .pms_valid      (pms_valid),

    .res_from_mem   (es_to_pms_bus_r.res_from_mem),
    .load_op        (es_to_pms_bus_r.load_op     ),
    .res_to_mem     (es_to_pms_bus_r.res_to_mem  ),
    .store_op       (es_to_pms_bus_r.store_op    ),
    .mem_addr       (es_to_pms_bus_r.mem_addr    ),
    .mem_wdata      (es_to_pms_bus_r.result      ),
    // exception
    .mem_ex         (mem_ex     ),
    .mem_exccode    (mem_exccode),
    // data_sram interface
    .data_wr        (control.dcache_wr    ),
    .data_size      (control.dcache_size  ),
    .data_wstrb     (control.dcache_wstrb ),
    .data_vaddr     (control.data_vaddr   ),
	.data_offset    (control.dcache_offset),
	.data_index     (control.dcache_index ),
    .data_wdata     (control.dcache_wdata )
);


// forward bus
assign control.load_op = load_op;
assign control.dest    = {5{pms_valid}} & es_to_pms_bus_r.dest;
assign control.result  = es_to_pms_bus_r.result;


// exception
assign op_tlb   = (|es_to_pms_bus_r.tlb_op) & pms_valid;
assign op_cache = (es_to_pms_bus_r.cache_op != Cache_Code_EMPTY) & pms_valid;
assign op_eret  = es_to_pms_bus_r.c0_op[0] & pms_valid;
assign op_mfc0  = es_to_pms_bus_r.c0_op[2] & pms_valid;
assign load_op  = es_to_pms_bus_r.res_from_mem & pms_valid;
assign store_op = es_to_pms_bus_r.res_to_mem   & pms_valid;

assign control.op_cache   = op_cache;
assign control.wr_disable = exception.ex | op_eret;
assign control.mfc0    = pms_valid & op_mfc0;
assign control.stall   = pms_valid & (op_tlb | op_cache);

assign exception.bd = es_to_pms_bus_r.exception.bd;
assign {exception.ex,
        exception.exccode,
        exception.tlb_refill} = {7{pms_valid}} & 
                               (es_to_pms_bus_r.exception.ex ? {es_to_pms_bus_r.exception.ex,
                                                                es_to_pms_bus_r.exception.exccode,
                                                                es_to_pms_bus_r.exception.tlb_refill} :
                                mem_ex                       ? {1'b1, mem_exccode, 1'b0} : 'b0 );
assign exception.badvaddr = es_to_pms_bus_r.exception.ex ? es_to_pms_bus_r.exception.badvaddr :
                            (mem_ex) & pms_valid         ? es_to_pms_bus_r.mem_addr  : 32'h0;


// to MEM
assign pms_to_ms_bus = {es_to_pms_bus_r.load_op,
                        es_to_pms_bus_r.res_from_mem,
                        es_to_pms_bus_r.res_to_mem,
                        es_to_pms_bus_r.rf_we,
                        es_to_pms_bus_r.mem_addr,
                        es_to_pms_bus_r.dest,
                        es_to_pms_bus_r.result,
                        es_to_pms_bus_r.pc,
                        exception,
                        es_to_pms_bus_r.c0_op,
                        es_to_pms_bus_r.c0_addr,
                        es_to_pms_bus_r.tlb_op,
                        es_to_pms_bus_r.cache_op
                        };

endmodule
