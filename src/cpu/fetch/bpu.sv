/*!
 * \brief branch-prediction unit
 */

`include "../cpu.svh"

module BPU (
    input   clk,
    input   reset,
    input   pipeline_flush_t    pipeline_flush,
    input   logic               correct_finish,
    input   ds_to_bpu_bus_t     ds_to_bpu_bus,
    input   verify_result_t     es_to_bpu_bus,
    output  BHT_entry_t         predict_entry,
    output  predict_result_t    bpu_predict_bus,
    output  logic               flush,
    output  logic               is_correction,
    output  virt_t              correct_target
);

BHT_entry_t         w_entry;
BHT_entry_t         r_entry;

ras_t               ras_data;

logic  es_verify_valid;
assign es_verify_valid = (es_to_bpu_bus.br_type != 3'b0 && es_to_bpu_bus.ready);

assign w_entry.tag     = es_to_bpu_bus.predict_entry.tag;
assign w_entry.target  = es_to_bpu_bus.predict_entry.target;
assign w_entry.br_type = es_to_bpu_bus.predict_entry.br_type;


simple_port_ram_without_bypass #(
    .LATENCY(0),
    .dtype(BHT_entry_t)
)mem_data(
    .clk(clk),
    .rst(~reset),
    //write port
    .ena(1'b1),
    .wea(es_verify_valid),
    // .addra(EXE_BResult.Index),
    .addra(es_to_bpu_bus.pc[11:2]),
    .dina(w_entry),
    //read port
    .enb(1'b1),
    // .addrb(Index),
    .addrb(ds_to_bpu_bus.pc[11:2]),
    .doutb(r_entry)
);

always_comb begin
    if(es_to_bpu_bus.predict_sucess) begin
        unique case(es_to_bpu_bus.predict_entry.count)
        `T: begin
            if(es_to_bpu_bus.is_taken) w_entry.count = es_to_bpu_bus.predict_entry.count;
            else w_entry.count = es_to_bpu_bus.predict_entry.count - 1;
        end
        `NT: begin
            if(es_to_bpu_bus.is_taken) w_entry.count = es_to_bpu_bus.predict_entry.count + 1;
            else w_entry.count = es_to_bpu_bus.predict_entry.count;
        end
        default: begin
            if(es_to_bpu_bus.is_taken) w_entry.count = es_to_bpu_bus.predict_entry.count + 1;
            else w_entry.count = es_to_bpu_bus.predict_entry.count - 1;
        end
        endcase
    end
    else begin
        if(es_to_bpu_bus.is_taken) w_entry.count = `WT;
        else w_entry.count = `WNT;
    end
end


virt_t         pc_add8;
virt_t         target;
logic          is_taken;
logic          valid;

// FSM reg
logic          state;
logic          correction_is_taken;
virt_t         correction_target;

always_ff @(posedge clk) begin
    if(reset || pipeline_flush.ex || pipeline_flush.eret || pipeline_flush.tlb_op) begin
        state               <= `IDLE;
        correction_is_taken <= '0;
        correction_target   <= '0;
    end else if (correct_finish && state == `CORRECTION) begin
        state               <= `IDLE;
        correction_is_taken <= '0;
        correction_target   <= '0;
    end else if (~es_to_bpu_bus.predict_sucess && es_verify_valid && state == `IDLE) begin
        state               <= `CORRECTION;
        correction_is_taken <= es_to_bpu_bus.is_taken;
        correction_target   <= es_to_bpu_bus.correct_target;
    end
end

assign pc_add8 = ds_to_bpu_bus.pc + 32'h8;
assign bht_hit = (ds_to_bpu_bus.pc[31:11] == r_entry.tag);
assign valid   = (state == `IDLE) && (ds_to_bpu_bus.br_type != 3'b0);

always_comb begin
    if(~bht_hit) begin
        target = pc_add8;
        is_taken = 1'b0;
    end
    else begin
        unique case(ds_to_bpu_bus.br_type)
        `B_IS_CALL: begin
            target = r_entry.target;
            is_taken = 1'b1;
        end
        `B_IS_RET: begin
            target = valid ? ras_data.data : pc_add8;
            is_taken = 1'b1;
        end
        `B_IS_BRA: begin
            if(r_entry.count[1]) begin
                target = r_entry.target;
                is_taken = 1'b1;
            end
            else begin
                target = pc_add8;
                is_taken = 1'b0;
            end
        end
        `B_IS_J: begin
            target = r_entry.target;
            is_taken = 1'b1;
        end
        default: begin
            target = pc_add8;
            is_taken = 1'b0;
        end
        endcase
    end
end

assign bpu_predict_bus.valid         = valid;
assign bpu_predict_bus.br_op         = (ds_to_bpu_bus.br_type != 3'b0);
assign bpu_predict_bus.br_taken      = is_taken;
assign bpu_predict_bus.target        = target;
assign predict_entry = r_entry;

assign flush                         = es_verify_valid && ~es_to_bpu_bus.predict_sucess;
assign is_correction                 = (state == `CORRECTION);
assign correct_target                = correction_target;

ras ras_instance(
    .clk,
    .reset,
    .push_req  (ds_to_bpu_bus.br_type == `B_IS_CALL),
    .pop_req   (ds_to_bpu_bus.br_type == `B_IS_RET ),
    .push_data ({1'b1, es_to_bpu_bus.pc + 8}),
    .ras_top   (ras_data)
);

endmodule
