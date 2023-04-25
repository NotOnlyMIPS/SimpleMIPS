`include "../cpu.svh"

module mem_stage (
    input clk,
    input reset,
    // pipeline
    input  pms_to_valid,
    output ms_allowin,
    input  ws_allowin,
    output ms_to_valid,

    input  pms_to_ms_bus_t  pms_to_ms_bus,
    output ms_to_ws_bus_t   ms_to_ws_bus,

    // control
    Memmory_Control_Interface.Memory control

);

// MEM
logic ms_valid;
logic ms_ready_go;

// from pre_MEM
logic res_from_mem;
logic res_to_mem;
pms_to_ms_bus_t pms_to_ms_bus_r;
assign res_from_mem = pms_to_ms_bus_r.res_from_mem & ms_valid;
assign res_to_mem   = pms_to_ms_bus_r.res_to_mem & ms_valid;

// mem_load
logic [3:0] rf_we;
uint32_t    mem_result;

// exception
logic op_mfc0;
logic op_tlb;
logic op_cache;
logic op_eret;
exception_t exception;

// to WB
uint32_t final_result;

// MEM stage
assign ms_ready_go = (control.dcache_data_ok) && !control.data_cancel || !(res_from_mem || res_to_mem) || exception.ex;
assign ms_allowin  = !ms_valid || ms_ready_go && ws_allowin;
assign ms_to_valid = ms_valid && ms_ready_go;
always @(posedge clk) begin
    if (reset || control.pipeline_flush) begin
        ms_valid <= 1'b0;
    end
    else if (ms_allowin) begin
        ms_valid <= pms_to_valid;
    end

    if (pms_to_valid && ms_allowin) begin
        pms_to_ms_bus_r  <= pms_to_ms_bus;
    end
end

// mem_load
mem_load u_mem_load (
    .load_op    (pms_to_ms_bus_r.load_op ),
    .rf_wr      (pms_to_ms_bus_r.rf_we   ),
    .mem_addr   (pms_to_ms_bus_r.mem_addr),

    .data_sram_rdata(control.dcache_rdata),

    .rf_we      (rf_we     ),
    .mem_result (mem_result)
);


// forward bus
assign control.load_op = ms_valid & res_from_mem;
assign control.rf_we   = rf_we;
assign control.dest    = {5{ms_valid}} & pms_to_ms_bus_r.dest;
assign control.result  = final_result;


// exception
assign op_mfc0   = pms_to_ms_bus_r.c0_op[2] & ms_valid;
assign op_tlb    = (|pms_to_ms_bus_r.tlb_op) & ms_valid;
assign op_cache  = (pms_to_ms_bus_r.cache_op != Cache_Code_EMPTY) & ms_valid;
assign op_eret   = pms_to_ms_bus_r.c0_op[0];

assign control.wr_disable = ms_valid & (op_eret | exception.ex);
assign control.mfc0  = ms_valid & op_mfc0;
assign control.stall = ms_valid & (op_tlb | op_cache);


assign exception.bd = pms_to_ms_bus_r.exception.bd;
assign {exception.ex, exception.exccode} = {6{ms_valid}} & (pms_to_ms_bus_r.exception.ex ? 
                                            {pms_to_ms_bus_r.exception.ex, pms_to_ms_bus_r.exception.exccode} :
                                            {control.data_tlb_ex, control.data_tlb_exccode});
assign exception.tlb_refill = exception.ex ? pms_to_ms_bus_r.exception.tlb_refill : control.data_tlb_refill;
assign exception.badvaddr = pms_to_ms_bus_r.exception.ex ? pms_to_ms_bus_r.exception.badvaddr :
                                                           pms_to_ms_bus_r.mem_addr;


// to WB
assign final_result = res_from_mem ? mem_result : pms_to_ms_bus_r.result;
assign ms_to_ws_bus = { rf_we,
                        pms_to_ms_bus_r.dest,
                        final_result,
                        pms_to_ms_bus_r.pc,
                        exception,
                        pms_to_ms_bus_r.c0_op,
                        pms_to_ms_bus_r.c0_addr,
                        pms_to_ms_bus_r.cache_op,
                        pms_to_ms_bus_r.tlb_op,
                        control.phy_addr
                        };

endmodule
