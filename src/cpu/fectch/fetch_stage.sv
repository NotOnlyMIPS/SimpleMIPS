`include "../cpu.svh"

module fetch_stage (
    input clk,
    input reset,

    // pipeline
    input  pfs_to_valid,
    output fs_allowin,
    input  ds_allowin,
    output fs_to_valid,

    input  pfs_to_fs_bus_t  pfs_to_fs_bus,
    output fs_to_ds_bus_t   fs_to_ds_bus,

    // control
    Fetch_Control_Interface.Fetch control
);

// IF
logic fs_valid;
logic fs_ready_go;
logic    fs_inst_valid;
uint32_t fs_inst;

// from pre_IF
logic      pfs_inst_valid;
uint32_t   pfs_inst;
pfs_to_fs_bus_t pfs_to_fs_bus_r;

assign pfs_inst_valid = pfs_to_fs_bus_r.inst_valid;
assign pfs_inst       = pfs_to_fs_bus_r.inst;

// exception
exception_t exception;
logic       inst_tlb_refill_r;
logic       inst_tlb_ex_r;
logic [4:0] inst_tlb_exccode_r;

logic       final_inst_tlb_refill;
logic       final_inst_tlb_ex;
logic [4:0] final_inst_tlb_exccode;

// IF stage
assign fs_ready_go = (control.icache_data_ok || pfs_inst_valid || fs_inst_valid) && !control.data_cancel || pfs_to_fs_bus_r.exception.ex;
assign fs_allowin = !fs_valid || fs_ready_go && ds_allowin;
assign fs_to_valid = fs_valid && fs_ready_go && (!control.br_flush || control.bd);

assign control.valid    = fs_valid;
assign control.ready_go = fs_ready_go;
assign control.to_valid = fs_to_valid;
assign control.allowin  = fs_allowin;

always_ff @( posedge clk ) begin
    if (reset || control.pipeline_flush || (control.br_flush && (!control.bd || control.icache_data_ok))) begin
        fs_valid <= 1'b0;
    end
    else if (fs_allowin) begin
        fs_valid <= pfs_to_valid;
    end

    if(pfs_to_valid && fs_allowin)
        pfs_to_fs_bus_r <= pfs_to_fs_bus;

    if(reset || control.pipeline_flush || (control.br_flush && !control.bd) || ds_allowin && fs_to_valid) begin
        fs_inst_valid <= 1'b0;
        fs_inst       <= 32'b0;
        inst_tlb_ex_r <= 1'b0;
        inst_tlb_exccode_r <= 5'b0;
        inst_tlb_refill_r  <= 1'b0;
    end
    else if(control.icache_data_ok && !(ds_allowin && fs_to_valid) && !fs_inst_valid) begin
        fs_inst_valid <= fs_valid;
        fs_inst       <= control.icache_rdata;
        inst_tlb_ex_r <= control.inst_tlb_ex;
        inst_tlb_exccode_r <= control.inst_tlb_exccode;
        inst_tlb_refill_r  <= control.inst_tlb_refill;
    end
end

// branch control
assign control.br_op = br_op;
assign control.pc    = pfs_to_fs_bus_r.pc;

// fast decoder
uint32_t fs_to_ds_inst;
uint32_t rt_d;
uint64_t op_d;
uint64_t func_d;
logic [ 5:0] op;
logic [ 4:0] rt;
logic [ 5:0] func;

assign fs_to_ds_inst = pfs_inst_valid ? pfs_inst :
                       fs_inst_valid  ? fs_inst  :
                                        control.icache_rdata;
assign op   = fs_to_ds_inst[31:26];
assign rt   = fs_to_ds_inst[20:16];
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
              | inst_j   | inst_jal | inst_jr   | inst_jalr) & fs_to_valid; 

// cp0 and ex
assign final_inst_tlb_ex = fs_inst_valid ? inst_tlb_ex_r : control.inst_tlb_ex;
assign final_inst_tlb_exccode = fs_inst_valid ? inst_tlb_exccode_r : control.inst_tlb_exccode;
assign final_inst_tlb_refill  = fs_inst_valid ? inst_tlb_refill_r  : control.inst_tlb_refill;


assign exception.bd = control.bd;
assign {exception.ex, exception.exccode} = {6{fs_valid}} & (pfs_to_fs_bus_r.exception.ex ? 
                                            {pfs_to_fs_bus_r.exception.ex, pfs_to_fs_bus_r.exception.exccode} :
                                            {final_inst_tlb_ex, final_inst_tlb_exccode});
assign exception.tlb_refill = pfs_to_fs_bus_r.exception.ex ? pfs_to_fs_bus_r.exception.tlb_refill : final_inst_tlb_refill;
assign exception.badvaddr   = pfs_to_fs_bus_r.exception.ex ? pfs_to_fs_bus_r.exception.badvaddr :
                                                             pfs_to_fs_bus_r.pc;

// to ID
assign fs_to_ds_bus = { fs_to_ds_inst,
                        pfs_to_fs_bus_r.pc,
                        exception
                      };

endmodule
