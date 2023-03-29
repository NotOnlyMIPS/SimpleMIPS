`include "..\cpu_defs.svh"

module pre_if_stage (
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
    input  virt_t           tlb_pc,
    output virt_t           inst_vaddr,
    input  mmu_result_t     inst_result,
    input  exception_t      inst_tlb_ex,
    // icache
    output logic            icache_req,
    output logic            icache_iscache,
    output logic [ 3:0]     icache_offset,
    output logic [ 7:0]     icache_index,
    output logic [19:0]     icache_tag,
    input  logic            icache_addr_ok
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
logic   req;
assign  req = !exception.ex & pfs_valid & fs_allowin & ~bpu_flush;

// pre_IF stage
assign to_pfs_valid = ~reset;
assign pfs_ready_go = (req & icache_addr_ok) | exception.ex;
assign pfs_allowin  = !pfs_valid || pfs_ready_go && fs_allowin;
assign pfs_to_fs_valid  = pfs_valid && pfs_ready_go;

assign pfs_bd    = br_op & ~fs_valid;
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
    else if(pipeline_flush.tlb_op) begin
        pc <= tlb_pc + 32'h4;
    end
    else if (to_pfs_valid && fs_allowin && pfs_ready_go) begin
        pc <= next_pc;
    end
end

// branch_prediction
assign branch_resolved = !pfs_bd && pfs_ready_go && fs_allowin;

// to IF
assign pfs_to_fs_bus = {pfs_to_fs_valid,
                        req & icache_addr_ok,
                        br_op,
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
                                                             {inst_tlb_ex.ex, inst_tlb_ex.exccode});
assign exception.badvaddr = next_pc;
assign exception.tlb_refill =  exception.exccode == `EXCCODE_TLBL ?
                               inst_tlb_ex.tlb_refill : 1'b0;

// inst_sram interface
assign icache_req     = req;
assign icache_iscache = ~inst_result.uncached;
assign icache_offset  = inst_vaddr[ 3:0];
assign icache_index   = inst_vaddr[11:4];
assign icache_tag     = inst_result.phy_addr[31:12];

endmodule
