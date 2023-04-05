`include "../cpu.svh"

module fetch_stage (
    input clk,
    input reset,
    // pipeline
    input  ds_allowin,
    output fs_allowin,
    // from pre_IF
    input  pfs_to_fs_bus_t  pfs_to_fs_bus,
    // branch prediction
    input  logic            bpu_flush,
    // to IF
    output logic            fs_to_pfs_valid,
    // to ID
    output fs_to_ds_bus_t   fs_to_ds_bus,
    // to BPU
    output logic            if_to_bpu_valid,
    output virt_t           if_pc,
    // branch bus
    output logic            br_op,
    // cp0 and exception
    input pipeline_flush_t  pipeline_flush,
    input virt_t            c0_epc,
    // inst sram interface
    input logic     icache_data_ok,
    input uint32_t  icache_rdata
);

// IF
logic fs_valid;
logic fs_ready_go;
logic fs_to_ds_valid;
logic pfs_fs_lock;
logic    fs_inst_valid;
uint32_t fs_inst;
logic branch_delay_slot;

// from pre_IF
logic      pfs_inst_valid;
uint32_t   pfs_inst;
pfs_to_fs_bus_t pfs_to_fs_bus_r;

assign pfs_inst_valid = pfs_to_fs_bus_r.inst_valid;
assign pfs_inst       = pfs_to_fs_bus_r.inst;

// exception
exception_t exception;
logic data_cancel;

// IF stage
assign pfs_fs_lock = pfs_to_fs_bus.br_op && !pfs_to_fs_bus.valid && fs_valid;
assign fs_ready_go = (icache_data_ok || fs_inst_valid || pfs_inst_valid) && !data_cancel || pfs_to_fs_bus_r.exception.ex;
assign fs_allowin = !fs_valid || fs_ready_go && ds_allowin;
assign fs_to_ds_valid = fs_valid && fs_ready_go && !pfs_fs_lock && !bpu_flush;
assign branch_delay_slot = pfs_to_fs_bus.br_op;

always_ff @( posedge clk ) begin
    if (reset || pipeline_flush.flush || (bpu_flush && !branch_delay_slot)) begin
        fs_valid <= 1'b0;
    end
    else if (fs_allowin && !pfs_fs_lock) begin
        fs_valid <= pfs_to_fs_bus.valid;
    end

    if(pfs_to_fs_bus.valid && fs_allowin && !pfs_fs_lock)
        pfs_to_fs_bus_r <= pfs_to_fs_bus;

    if(reset || pipeline_flush.flush || (bpu_flush && !branch_delay_slot))
        fs_inst_valid <= 1'b0;
    else if(icache_data_ok && (!ds_allowin || pfs_fs_lock) && !fs_inst_valid) begin
        fs_inst_valid <= 1'b1;
        fs_inst       <= icache_rdata;
    end
    else if(ds_allowin && fs_ready_go && !pfs_fs_lock)
        fs_inst_valid <= 1'b0;
end

// to IF
assign fs_to_pfs_valid = fs_valid;

// to BPU
assign if_to_bpu_valid = fs_valid;
assign if_pc           = pfs_to_fs_bus_r.pc;

// fast decoder
uint32_t fs_to_ds_inst;
uint32_t rt_d;
uint64_t op_d, func_d;
logic [ 5:0] op;
logic [ 4:0] rt;
logic [ 5:0] func;

assign fs_to_ds_inst = pfs_inst_valid ? pfs_inst : (fs_inst_valid ? fs_inst : icache_rdata);
assign op   = fs_to_ds_inst[31:26];
assign rt   = fs_to_ds_inst[20:16];
assign rd   = fs_to_ds_inst[15:11];
assign func = fs_to_ds_inst[ 5: 0];
decoder_6_64 u_dec0(.in(op  ), .out(op_d  ));
decoder_6_64 u_dec1(.in(func), .out(func_d));
decoder_5_32 u_dec3(.in(rt  ), .out(rt_d  ));
// branch
assign inst_beq    = op_d[6'h04];
assign inst_bne    = op_d[6'h05];
assign inst_bgez   = op_d[6'h01] & rt_d[5'h01];
assign inst_bgtz   = op_d[6'h07] & rt_d[5'h00];
assign inst_blez   = op_d[6'h06] & rt_d[5'h00];
assign inst_bltz   = op_d[6'h01] & rt_d[5'h00];
assign inst_bgezal = op_d[6'h01] & rt_d[5'h11];
assign inst_bltzal = op_d[6'h01] & rt_d[5'h10];
// jump
assign inst_j      = op_d[6'h02];
assign inst_jal    = op_d[6'h03];
assign inst_jr     = op_d[6'h00] & func_d[6'h08];
assign inst_jalr   = op_d[6'h00] & func_d[6'h09];

assign br_op = (inst_beq | inst_bne | inst_bgez | inst_bgtz | inst_blez | inst_bltz | inst_bgezal | inst_bltzal
             | inst_j   | inst_jal | inst_jr   | inst_jalr) & fs_to_ds_valid; 

// cp0 and ex
always_ff @(posedge clk) begin
    if(reset)
        data_cancel <= 1'b0;
    else if((pipeline_flush.flush || (bpu_flush && !branch_delay_slot)) && (!fs_ready_go && fs_valid)
          || pfs_to_fs_bus.data_cancel && !icache_data_ok)
        data_cancel <= 1'b1;
    else if(icache_data_ok)
        data_cancel <= 1'b0;
end
assign exception = { pfs_to_fs_bus_r.exception.tlb_refill,
                     branch_delay_slot,
                     pfs_to_fs_bus_r.exception.ex,
                     pfs_to_fs_bus_r.exception.exccode,
                     pfs_to_fs_bus_r.exception.badvaddr};
// to ID
assign fs_to_ds_bus = { fs_to_ds_valid,
                        fs_to_ds_inst,
                        pfs_to_fs_bus_r.pc,
                        exception
                      };

endmodule
