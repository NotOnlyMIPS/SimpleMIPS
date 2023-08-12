`include "../cpu.svh"

module writeback_stage (
    input  clk,
    input  reset,
    // pipeline
    input  ms_to_valid,
    output ws_allowin,

    input  ms_to_ws_bus_t   ms_to_ws_bus,

    // control
    Writeback_Control_Interface.Writeback control,

    // trace dubug interface
    output logic            debug_wb_valid,
    output virt_t           debug_wb_pc,
    output logic [3:0]      debug_wb_rf_wen,
    output reg_addr_t       debug_wb_rf_wnum,
    output uint32_t         debug_wb_rf_wdata
);

// WB
logic ws_valid;
logic ws_ready_go;

// from MEM
ms_to_ws_bus_t ms_to_ws_bus_r;

// forward
uint32_t final_result;

// Exception, CP0
logic ex_en;
logic op_eret;
logic op_mtc0;
logic op_mfc0;
logic op_tlb;
logic op_cache;

// Exception, CP0, TLB, Cache
logic pipeline_flush;


// WB stage
assign ws_ready_go = 1'b1;
assign ws_allowin  = !ws_valid || ws_ready_go;

assign control.pipeline_flush = pipeline_flush;

always @(posedge clk) begin
    if (reset || pipeline_flush) begin
        ws_valid <= 1'b0;
    end
    else if (ws_allowin) begin
        ws_valid <= ms_to_valid;
    end

    if (ms_to_valid && ws_allowin) begin
        ms_to_ws_bus_r <= ms_to_ws_bus;
    end
end

// to regfile
assign control.rf_we    = {4{ws_valid & ~ex_en}} & ms_to_ws_bus_r.rf_we;
assign control.rf_waddr = ms_to_ws_bus_r.dest;
assign control.rf_wdata = final_result;


// bypass
assign final_result = op_mfc0 ? control.cp0_rdata : ms_to_ws_bus_r.result;

assign control.dest   = {5{ws_valid}} & ms_to_ws_bus_r.dest;
assign control.result = final_result;


// Exception
assign pipeline_flush = ws_valid & (ms_to_ws_bus_r.exception.ex | op_eret | op_tlb | op_cache);

assign ex_en    = ws_valid & ms_to_ws_bus_r.exception.ex;
assign op_eret  = ws_valid & ms_to_ws_bus_r.c0_op[0];
assign op_mtc0  = ws_valid & ms_to_ws_bus_r.c0_op[1];
assign op_mfc0  = ws_valid & ms_to_ws_bus_r.c0_op[2];
assign op_tlb   = ws_valid & (|ms_to_ws_bus_r.tlb_op);
assign op_cache = ws_valid & (ms_to_ws_bus_r.cache_op != Cache_Code_EMPTY);

assign control.wr_disable = ex_en  | op_eret;
assign control.mfc0       = op_mfc0;
assign control.stall      = op_tlb | op_cache;

assign control.eret      = op_eret;
assign control.exception = ws_valid ? ms_to_ws_bus_r.exception : 'b0;
assign control.pc        = ms_to_ws_bus_r.pc;
assign control.cache_tlb_op = op_tlb | op_cache;

// CP0
assign control.cp0_we    = ws_valid & op_mtc0;
assign control.cp0_addr  = ms_to_ws_bus_r.c0_addr;
assign control.cp0_wdata = ms_to_ws_bus_r.result;

// TLB
assign control.tlb_op = {3{ws_valid}} & ms_to_ws_bus_r.tlb_op;

// Cache
assign control.cache_op    = ws_valid ? ms_to_ws_bus_r.cache_op : Cache_Code_EMPTY;
assign control.cache_vaddr = ms_to_ws_bus_r.result;
assign control.cache_paddr = ms_to_ws_bus_r.phy_addr;


// trace debug interface
assign debug_wb_valid    = ws_valid;
assign debug_wb_pc       = ms_to_ws_bus_r.pc;
assign debug_wb_rf_wen   = ms_to_ws_bus_r.rf_we & {4{ws_valid & ~ex_en}};
assign debug_wb_rf_wnum  = ms_to_ws_bus_r.dest;
assign debug_wb_rf_wdata = (ms_to_ws_bus_r.exception.exccode == `EXCCODE_ADEL
                        ||  ms_to_ws_bus_r.exception.exccode == `EXCCODE_ADES) ? ms_to_ws_bus_r.exception.badvaddr    :
                                                                                 final_result;

endmodule
