`include "../cpu.svh"

module pre_fetch_stage (
    input clk,
    input reset,

    // pipeline
    input  logic fs_allowin,
    output logic pfs_to_valid,

    output pfs_to_fs_bus_t  pfs_to_fs_bus,

    // control
    PreFetch_Control_Interface.PreFetch control
);

// pre_IF
logic   to_pfs_valid;
logic   pfs_valid;
logic   pfs_ready_go;
logic   pfs_allowin;

virt_t  seq_pc;
virt_t  next_pc;
virt_t  pc;

// exception
exception_t exception;
logic       inst_tlb_refill_r;
logic       inst_tlb_ex_r;
logic [4:0] inst_tlb_exccode_r;

// ICache interface
logic    req_valid;
logic    inst_recv_valid;
logic    inst_valid;
uint32_t inst_r;

// pre_IF stage
assign to_pfs_valid = ~reset;
assign pfs_ready_go = (control.icache_req && control.icache_addr_ok || inst_recv_valid) || exception.ex;
assign pfs_allowin  = !pfs_valid || pfs_ready_go && fs_allowin;
assign pfs_to_valid  = pfs_valid && pfs_ready_go;

assign control.valid    = pfs_valid;
assign control.ready_go = pfs_ready_go;
assign control.to_valid = pfs_to_valid;
assign control.allowin  = pfs_allowin;

assign next_pc   = (control.bd                 ) ? seq_pc :
                   control.predict_result.valid  ? (control.predict_result.br_taken ? control.predict_result.target : seq_pc) :
                   control.is_correction         ? control.correct_target        :
                                                   seq_pc;

always_ff @(posedge clk) begin
    if(reset)
        pfs_valid <= 1'b0;
    else if(pfs_allowin)
        pfs_valid <= to_pfs_valid;

    if (reset) begin
        pc     <= 32'hbfbf_fffc;
        seq_pc <= 32'hbfc0_0000;
    end
    else if(control.exception_en) begin
        pc     <= control.exception_vector - 4;
        seq_pc <= control.exception_vector;
    end
    else if(control.eret_en) begin
        pc     <= control.epc - 32'h4;
        seq_pc <= control.epc;
    end
    else if(control.cache_tlb_op) begin
        pc     <= control.cache_tlb_pc;
        seq_pc <= control.cache_tlb_pc + 4;
    end
    else if (pfs_to_valid && fs_allowin) begin
        pc     <= next_pc;
        seq_pc <= next_pc + 4;
    end
end

// inst req
always_ff @(posedge clk) begin
    if(reset)
        req_valid <= 1'b0;
    else if(fs_allowin || control.pipeline_flush || control.br_flush && !control.bd)
        req_valid <= 1'b1;
    else if(!fs_allowin && control.icache_addr_ok)
        req_valid <= 1'b0;

    if(reset || fs_allowin || control.pipeline_flush || control.br_flush && !control.bd)
        inst_recv_valid <= 1'b0;
    else if(!fs_allowin && control.icache_addr_ok)
        inst_recv_valid <= 1'b1;

    if(reset || fs_allowin || control.pipeline_flush || control.br_flush && !control.bd) begin
        inst_valid <= 1'b0;
        inst_r     <= 32'd0;
        inst_tlb_refill_r  <= 1'b0;
        inst_tlb_ex_r      <= 1'b0;
        inst_tlb_exccode_r <= 5'b0;
    end
    else if(inst_recv_valid && control.icache_data_ok) begin
        inst_valid <= 1'b1;
        inst_r     <= control.icache_rdata;
        inst_tlb_refill_r  <= control.inst_tlb_refill;
        inst_tlb_ex_r      <= control.inst_tlb_ex;
        inst_tlb_exccode_r <= control.inst_tlb_exccode;
    end
end

// to IF
logic       final_inst_valid;
uint32_t    final_inst;
logic       final_inst_tlb_refill;
logic       final_inst_tlb_ex;
logic [4:0] final_inst_tlb_exccode;

assign final_inst_valid  = inst_recv_valid && control.icache_data_ok || inst_valid;
assign final_inst        = inst_recv_valid && control.icache_data_ok ? control.icache_rdata : inst_r;
assign final_inst_tlb_refill  = inst_recv_valid && control.icache_data_ok ? control.inst_tlb_refill : inst_tlb_refill_r;
assign final_inst_tlb_ex      = inst_recv_valid && control.icache_data_ok ? control.inst_tlb_ex : inst_tlb_ex_r;
assign final_inst_tlb_exccode = inst_recv_valid && control.icache_data_ok ? control.inst_tlb_exccode : inst_tlb_exccode_r;

assign pfs_to_fs_bus = {final_inst_valid,
                        final_inst,
                        next_pc,
                        exception
                        };

// mmu
assign control.inst_vaddr = next_pc;

// exception
assign exception.tlb_refill = final_inst_tlb_refill;
assign exception.bd = 1'b0;
assign {exception.ex, exception.exccode} = {6{pfs_valid}} & (next_pc[1:0] != 2'b0 ? {1'b1, `EXCCODE_ADEL} :
                                                             {final_inst_tlb_ex, final_inst_tlb_exccode});
assign exception.badvaddr   = next_pc;

// ICache
assign control.icache_req     = pfs_valid && req_valid && !exception.ex;
assign control.icache_offset  = next_pc[ 3:0];
assign control.icache_index   = next_pc[11:4];

endmodule
