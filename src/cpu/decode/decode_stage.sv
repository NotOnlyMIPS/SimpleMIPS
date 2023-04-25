`include "../cpu.svh"

module decode_stage (
    input clk,
    input reset,
    
    // pipeline
    input  logic fs_to_valid,
    output logic ds_allowin,
    input  logic es_allowin,
    output logic ds_to_valid,

    input  fs_to_ds_bus_t fs_to_ds_bus,
    output ds_to_es_bus_t ds_to_es_bus,

    // control
    Decode_Control_Interface.Decode control
);

// decode stage
typedef enum logic[1:0] { 
    EMPTY,
    BUSY,
    FULL
} decode_state_t;

// exception
exception_t exception;

// branch target
virt_t delay_slot_pc;
virt_t jump_target;
virt_t branch_target;

// decoder
decoded_inst_t inst_d;

// decode stage
decode_state_t ds_state, ds_state_next;
logic ds_valid;
logic push, pop;
logic data_out_we, data_buffer_we, use_buffer_data;

fs_to_ds_bus_t fs_to_ds_bus_r, fs_to_ds_bus_buffer;

assign ds_valid    = (ds_state != EMPTY);
assign ds_allowin  = (ds_state != FULL);
assign ds_to_valid = (ds_state != EMPTY) && !control.stall;

assign push = fs_to_valid && ds_allowin;
assign pop  = ds_to_valid && es_allowin;

assign data_out_we = (ds_state == EMPTY &&  push && !pop)
                  || (ds_state == BUSY  &&  push &&  pop)
                  || (ds_state == FULL  && !push &&  pop);
assign data_buffer_we  = ds_state == BUSY &&  push && !pop; 
assign use_buffer_data = ds_state == FULL && !push &&  pop;

always_comb begin
    unique case(ds_state)
        EMPTY: ds_state_next = push ? BUSY : EMPTY;
        BUSY : ds_state_next = push ? (pop ? BUSY : FULL) : (pop ? EMPTY : BUSY);
        FULL : ds_state_next = pop  ? BUSY : FULL;
    endcase
end

always_ff @(posedge clk) begin
    if(reset || control.pipeline_flush)
        ds_state <= EMPTY;
    else if (push || pop)
        ds_state <= ds_state_next;

    if(data_out_we)
        fs_to_ds_bus_r <= use_buffer_data ? fs_to_ds_bus_buffer : fs_to_ds_bus;
    if(data_buffer_we)
        fs_to_ds_bus_buffer <= fs_to_ds_bus;
end

assign control.valid = ds_valid;
assign control.allowin = ds_allowin;

// bypass
assign control.rs = inst_d.rs;
assign control.rt = inst_d.rt;

// to EXE
assign ds_to_es_bus = { inst_d.alu_op,
                        inst_d.alu_ov,
                        inst_d.br_op,
                        inst_d.load_op,
                        inst_d.store_op,
                        inst_d.hi_lo_op,
                        inst_d.c0_op,
                        inst_d.c0_addr,
                        inst_d.src1_is_sa,
                        inst_d.src1_is_pc,
                        inst_d.src2_is_simm,
                        inst_d.src2_is_zimm,
                        inst_d.src2_is_8,
                        (|inst_d.alu_op) & ~inst_d.res_to_mem,
                        |inst_d.hi_lo_op,
                        inst_d.c0_op[1] | inst_d.res_to_mem,
                        inst_d.res_from_mem,
                        inst_d.res_to_mem,
                        inst_d.rf_we,
                        inst_d.dest,
                        inst_d.imm,
                        control.rs_value,
                        control.rt_value,
                        fs_to_ds_bus_r.pc,
                        jump_target,
                        branch_target,
                        control.predict_result,
                        control.predict_entry,
                        exception,
                        inst_d.tlb_op,
                        inst_d.cache_op
                        };


// decoder
inst_decoder u_inst_decoder(
    .inst       (fs_to_ds_bus_r.inst),
    .inst_d     (inst_d             )
);

// branch prediction
assign delay_slot_pc = fs_to_ds_bus_r.pc+4;
assign jump_target = {delay_slot_pc[31:28], inst_d.jidx[25:0], 2'b0};
assign branch_target = delay_slot_pc + {{14{inst_d.imm[15]}}, inst_d.imm[15:0], 2'b0};

// exception
assign exception.bd = fs_to_ds_bus_r.exception.bd;
assign {exception.ex, exception.exccode} = {6{ds_valid}} & (control.hw | control.sw     ? {1'b1, `EXCCODE_INT}      :
                                                            fs_to_ds_bus_r.exception.ex ? {fs_to_ds_bus_r.exception.ex, fs_to_ds_bus_r.exception.exccode} :
                                                            inst_d.invalid              ? {1'b1, `EXCCODE_RI }      :
                                                            inst_d.op_syscall           ? {1'b1, `EXCCODE_SYS}      :
                                                            inst_d.op_break             ? {1'b1, `EXCCODE_BP }      :
                                                                                           6'h0              );
assign exception.badvaddr = fs_to_ds_bus_r.exception.badvaddr;
assign exception.tlb_refill =  exception.exccode == `EXCCODE_TLBL ?
                               fs_to_ds_bus_r.exception.tlb_refill : 1'b0;

endmodule
