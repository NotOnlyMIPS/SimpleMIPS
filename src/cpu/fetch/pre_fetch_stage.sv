`include "../cpu.svh"

module pre_fetch_stage (
    input clk,
    input reset,
    // pipeline
    input  logic fs_allowin,
    // from IF
    input  logic fs_valid,
    // branch bus
    input  logic br_op,
    // branch prediction
    input  logic            bpu_flush,
    input  predict_result_t predict_result,
    input  logic            is_correction,
    input  virt_t           correct_target,
    output logic            branch_resolved,
    // to IF
    output pfs_to_fs_bus_t  pfs_to_fs_bus,
    // cp0 and exception
    input  pipeline_flush_t pipeline_flush,
    input  virt_t           c0_epc,
    // tlb/mmu
    input  virt_t           tlb_cache_pc,
    output virt_t           inst_vaddr,
    input  exception_t      inst_tlb_ex,
    // icache
    output logic            icache_req,
    output logic [ 3:0]     icache_offset,
    output logic [ 7:0]     icache_index,
    input  logic            icache_addr_ok,
    input  logic            icache_data_ok,
    input  uint32_t         icache_rdata
);

// pre_IF
logic   to_pfs_valid;
logic   pfs_valid;
logic   pfs_ready_go;
logic   pfs_allowin;
logic   pfs_to_fs_valid;

virt_t  seq_pc;
virt_t  next_pc;
virt_t  pc;

// exception
exception_t exception;

// inst_sram interface
logic    br_op_r;
logic    req_valid;
logic    inst_rec_valid;
logic    inst_valid;
logic    data_cancel;
uint32_t inst;

// pre_IF stage
assign to_pfs_valid = ~reset;
assign pfs_ready_go = (icache_req && icache_addr_ok || inst_rec_valid) || exception.ex;
assign pfs_allowin  = !pfs_valid || pfs_ready_go && fs_allowin;
assign pfs_to_fs_valid  = pfs_valid && pfs_ready_go;

assign pfs_bd    = br_op_r & ~fs_valid;
assign seq_pc    = pc + 4;
assign next_pc   = pfs_bd               ? seq_pc                :
                   predict_result.valid ? (predict_result.br_taken ? predict_result.target : seq_pc) :
                   is_correction        ? correct_target        :
                                          seq_pc;

always_ff @(posedge clk) begin
    if(reset)
        pfs_valid <= 1'b0;
    else if(pfs_allowin)
        pfs_valid <= to_pfs_valid;

    if (reset) begin
        pc <= 32'hbfbffffc;  //trick: to make nextpc be 0xbfc00000 during reset
    end
    else if(pipeline_flush.ex) begin
        pc <= pipeline_flush.tlb_refill ? 32'hbfc001fc : 32'hbfc0037c;
    end
    else if(pipeline_flush.eret) begin
        pc <= c0_epc - 32'h4;
    end
    else if(pipeline_flush.tlb_op || pipeline_flush.cache_op) begin
        pc <= tlb_cache_pc + 32'h4;
    end
    else if (to_pfs_valid && fs_allowin && pfs_ready_go) begin
        pc <= next_pc;
    end
end

// inst req
always_ff @(posedge clk) begin
    if(reset)
        req_valid <= 1'b0;
    else if(fs_allowin)
        req_valid <= 1'b1;
    else if(!fs_allowin && icache_addr_ok)
        req_valid <= 1'b0;

    if(reset || fs_allowin || pipeline_flush.flush || bpu_flush)
        inst_rec_valid <= 1'b0;
    else if(icache_addr_ok && !fs_allowin)
        inst_rec_valid <= 1'b1;

    if(reset || fs_allowin || pipeline_flush.flush || bpu_flush) begin
        inst_valid <= 1'b0;
        inst       <= 32'd0;
    end
    else if(inst_rec_valid && icache_data_ok) begin
        inst_valid <= 1'b1;
        inst       <= icache_rdata;
    end

    if(reset)
        data_cancel <= 1'b0;
    else if((pipeline_flush.flush || bpu_flush) && inst_rec_valid && !inst_valid)
        data_cancel <= 1'b1;
    else if(icache_data_ok)
        data_cancel <= 1'b0;
end

// branch_prediction
assign branch_resolved = !pfs_bd && pfs_ready_go && fs_allowin && (br_op_r || is_correction);

always_ff @(posedge clk) begin
    if(reset || branch_resolved || pipeline_flush.ex || pipeline_flush.eret || pipeline_flush.tlb_op || pipeline_flush.cache_op)
        br_op_r <= 1'b0;
    else if(br_op)
        br_op_r <= 1'b1;
end

// to IF
assign pfs_to_fs_bus = {pfs_to_fs_valid,
                        inst_rec_valid && icache_data_ok || inst_valid,
                        inst_rec_valid && icache_data_ok ? icache_rdata : inst,
                        data_cancel && fs_allowin && pfs_ready_go,
                        icache_addr_ok,
                        br_op_r,
                        next_pc,
                        exception
                        };

// to ID
assign pfs_pc = next_pc;

// MMU
assign inst_vaddr = next_pc;

// exception
assign exception.bd = 1'b0;
assign {exception.ex, exception.exccode} = {6{pfs_valid}} & (next_pc[1:0] != 2'b0 ? {1'b1, `EXCCODE_ADEL} :
                                                             6'b0);
assign exception.badvaddr = next_pc;
// assign exception.tlb_refill =  exception.exccode == `EXCCODE_TLBL ?
//                                inst_tlb_ex.tlb_refill : 1'b0;

// inst_sram interface
assign icache_req     = req_valid && !exception.ex && pfs_valid && !bpu_flush;
assign icache_offset  = inst_vaddr[ 3:0];
assign icache_index   = inst_vaddr[11:4];

endmodule
