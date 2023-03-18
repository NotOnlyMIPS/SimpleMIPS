`include "..\cpu_defs.svh"

module id_stage (
    input clk,
    input reset,
    // pipeline
    input  es_allowin,
    output ds_allowin,
    // from IF
    input fs_to_ds_bus_t fs_to_ds_bus,
    // from WB
    input ws_to_rf_bus_t ws_to_rf_bus,
    // forward bus
    input es_forward_bus_t  es_forward_bus,
    input pms_forward_bus_t pms_forward_bus,
    input ms_forward_bus_t  ms_forward_bus,
    input ws_forward_bus_t  ws_forward_bus,
    // branch prediction
    input  logic            branch_resolved,
    input  logic            predict_is_taken,
    input  virt_t           predict_target,
    input  BHT_entry_t      predict_entry,
    output ds_to_bpu_bus_t  ds_to_bpu_bus,
    // to EXE
    output ds_to_es_bus_t   ds_to_es_bus,
    // cp0 and exception
    input logic [5:0] c0_hw,
    input logic [1:0] c0_sw,
    input pipeline_flush_t pipeline_flush
);

// ID
logic ds_valid;
logic ds_ready_go;
logic ds_to_es_valid;

// from IF
fs_to_ds_bus_t fs_to_ds_bus_r;

// cp0 and exception
exception_t exception;

// stall
logic ds_stall;

// decoder
decoded_inst_t inst_d;

inst_decoder u_inst_decoder(
    .inst       (fs_to_ds_bus_r.inst),
    .inst_d     (inst_d             )
);

// regfile
uint32_t rf_rdata1, rf_rdata2;

regfile u_regfile (
    .clk    (clk            ),
    .raddr1 (inst_d.rs      ),
    .rdata1 (rf_rdata1      ),
    .raddr2 (inst_d.rt      ),
    .rdata2 (rf_rdata2      ),
    .we     (ws_to_rf_bus.we),
    .waddr  (ws_to_rf_bus.waddr),
    .wdata  (ws_to_rf_bus.wdata)
);

// register forward
uint32_t rs_value, rt_value;

register_forward u_register_forward(
    .ds_valid   (ds_valid),
    .inst_d     (inst_d),
    // regfile
    .rf_rdata1  (rf_rdata1),
    .rf_rdata2  (rf_rdata2),
    // es forward
    .es_mfc0    (es_forward_bus.op_mfc0),
    .es_tlb     (es_forward_bus.op_tlb ),
    .es_load    (es_forward_bus.op_load),
    .es_dest    (es_forward_bus.dest   ),
    .es_result  (es_forward_bus.result ),
    // pms forward
    .pms_mfc0   (pms_forward_bus.op_mfc0),
    .pms_tlb    (pms_forward_bus.op_tlb ),
    .pms_load   (pms_forward_bus.op_load),
    .pms_dest   (pms_forward_bus.dest   ),
    .pms_result (pms_forward_bus.result ),
    // ms forward
    .ms_mfc0    (ms_forward_bus.op_mfc0),
    .ms_tlb     (ms_forward_bus.op_tlb ),
    .ms_load    (ms_forward_bus.op_load),
    .ms_rf_we   (ms_forward_bus.rf_we  ),
    .ms_dest    (ms_forward_bus.dest   ),
    .ms_result  (ms_forward_bus.result ),
    // ws forward
    .ws_mfc0    (ws_forward_bus.op_mfc0),
    .ws_tlb     (ws_forward_bus.op_tlb ),
    .ws_rf_we   (ws_forward_bus.rf_we  ),
    .ws_dest    (ws_forward_bus.dest   ),
    .ws_result  (ws_forward_bus.result ),
    // result
    .rs_value   (rs_value),
    .rt_value   (rt_value),
    // stall
    .ds_stall   (ds_stall)
);

// ID stage
assign ds_ready_go  = ds_valid && !ds_stall;
assign ds_allowin   = !ds_valid || ds_ready_go && es_allowin;
assign ds_to_es_valid = ds_valid && ds_ready_go;
always @(posedge clk) begin
    if(reset) begin
        ds_valid <= 1'b0;
    end
    else if(pipeline_flush.eret | pipeline_flush.ex) begin
        ds_valid <= 1'b0;
    end
    else if(ds_allowin) begin
        ds_valid <= fs_to_ds_bus.valid;
    end

    if (fs_to_ds_bus.valid && ds_allowin) begin
        fs_to_ds_bus_r <= fs_to_ds_bus;
    end
end

// cp0 and exception
assign exception.bd = fs_to_ds_bus_r.exception.bd;
assign {exception.ex, exception.exccode} = {6{ds_valid}} & ((|c0_hw) | (|c0_sw)         ? {1'b1, `EXCCODE_INT}      :
                                                            fs_to_ds_bus_r.exception.ex ? {fs_to_ds_bus_r.exception.ex, fs_to_ds_bus_r.exception.exccode} :
                                                            inst_d.invalid              ? {1'b1, `EXCCODE_RI }      :
                                                            inst_d.op_syscall           ? {1'b1, `EXCCODE_SYS}      :
                                                            inst_d.op_break             ? {1'b1, `EXCCODE_BP }      :
                                                                                           6'h0              );
assign exception.badvaddr = fs_to_ds_bus_r.exception.badvaddr;
assign exception.tlb_refill =  exception.exccode == `EXCCODE_TLBL ?
                               fs_to_ds_bus_r.exception.tlb_refill : 1'b0;

// br_bus
logic       is_branch, is_call, is_ret, is_jump;
logic       br_bus_en;
logic       br_bus_r_valid;
logic [2:0] br_op_r;
logic [2:0] br_type;
assign is_branch = |inst_d.br_op[7:0];
assign is_ret    = inst_d.br_op[10];
assign is_call   = inst_d.br_op[11] | inst_d.br_op[9];
assign is_jump   = inst_d.br_op[8];
assign br_bus_en = (|inst_d.br_op) & ds_ready_go & es_allowin & ds_valid;
always_ff @(posedge clk) begin
    if(reset || pipeline_flush.ex || pipeline_flush.eret || pipeline_flush.tlb_op || branch_resolved)
        br_bus_r_valid <= 1'b0;
    else if(br_bus_en) begin
        br_bus_r_valid <= 1'b1;
        br_op_r        <= {3{is_jump}} & 3'h1 | {3{is_call}} & 3'h2 | {3{is_ret}} & 3'h3 |{3{is_branch}} & 3'h4;
    end
end
assign br_type = br_bus_r_valid ? br_op_r : {3{ds_valid}} & ({3{is_jump}} & 3'h1 | {3{is_call}} & 3'h2 | {3{is_ret}} & 3'h3 |{3{is_branch}} & 3'h4);

// to BPU
assign ds_to_bpu_bus = { br_type,
                         br_bus_en,
                         fs_to_ds_bus_r.pc};

// to EXE
assign ds_to_es_bus = { ds_to_es_valid,
                        inst_d.alu_op,
                        inst_d.alu_ov,
                        br_type,
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
                        inst_d.res_from_mem,
                        inst_d.res_to_mem,
                        inst_d.rf_we,
                        inst_d.dest,
                        inst_d.imm,
                        inst_d.jidx,
                        rs_value,
                        rt_value,
                        fs_to_ds_bus_r.pc,
                        predict_is_taken,
                        predict_target,
                        predict_entry,
                        exception,
                        inst_d.tlb_op
                        };

endmodule