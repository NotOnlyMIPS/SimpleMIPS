/*!
 * \brief branch-prediction unit
 */

`include "../cpu.svh"

module BPU (
    input   clk,
    input   reset,

    BPU_Control_Interface.BPU   control
);

predict_result_t    predict_result_r;
BHT_entry_t         predict_entry_r;
BHT_entry_t         w_entry;
BHT_entry_t         r_entry;

ras_t               ras_data;

logic  es_verify_valid;
assign es_verify_valid = (control.verify_result.br_type != 3'b0) && control.verify_result.ready;

assign w_entry.tag     = control.verify_result.predict_entry.tag;
assign w_entry.target  = control.verify_result.predict_entry.target;
assign w_entry.br_type = control.verify_result.predict_entry.br_type;


simple_port_ram_without_bypass_customized #(
    .LATENCY(0),
    .dtype(BHT_entry_t)
)mem_data(
    .clk(clk),
    .rst(~reset),
    //write port
    .ena(1'b1),
    .wea(es_verify_valid),
    // .addra(EXE_BResult.Index),
    .addra(control.verify_result.pc[11:2]),
    .dina(w_entry),
    //read port
    .enb(1'b1),
    // .addrb(Index),
    .addrb(control.fetch_pc[11:2]),
    .doutb(r_entry)
);

always_comb begin
    if(control.verify_result.predict_sucess) begin
        unique case(control.verify_result.predict_entry.count)
        `T: begin
            if(control.verify_result.is_taken) w_entry.count = control.verify_result.predict_entry.count;
            else w_entry.count = control.verify_result.predict_entry.count - 1;
        end
        `NT: begin
            if(control.verify_result.is_taken) w_entry.count = control.verify_result.predict_entry.count + 1;
            else w_entry.count = control.verify_result.predict_entry.count;
        end
        default: begin
            if(control.verify_result.is_taken) w_entry.count = control.verify_result.predict_entry.count + 1;
            else w_entry.count = control.verify_result.predict_entry.count - 1;
        end
        endcase
    end
    else begin
        if(control.verify_result.is_taken) w_entry.count = `WT;
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
    if(reset || control.pipeline_flush) begin
        state               <= `IDLE;
        correction_is_taken <= '0;
        correction_target   <= '0;
    end else if (control.correction_finish && state == `CORRECTION) begin
        state               <= `IDLE;
        correction_is_taken <= '0;
        correction_target   <= '0;
    end else if (~control.verify_result.predict_sucess && es_verify_valid && state == `IDLE) begin
        state               <= `CORRECTION;
        correction_is_taken <= control.verify_result.is_taken;
        correction_target   <= control.verify_result.correct_target;
    end
end

assign pc_add8 = control.fetch_pc + 32'h8;
assign bht_hit = (control.fetch_pc[31:11] == r_entry.tag);
assign valid   = (state == `IDLE) && (r_entry.br_type != 3'b0) && control.br_valid;

always_comb begin
    if(~bht_hit) begin
        target = pc_add8;
        is_taken = 1'b0;
    end
    else begin
        unique case(r_entry.br_type)
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

always_ff @ (posedge clk) begin
    if(reset) begin
        predict_result_r <= '0;
        predict_entry_r  <= '0;
    end else if(control.br_valid) begin
        predict_result_r.br_op    <= (r_entry.br_type != 3'b0);
        predict_result_r.br_taken <= is_taken;
        predict_result_r.target   <= target;
        predict_entry_r           <= r_entry;
    end
    
    predict_result_r.valid  <= valid;
end

assign control.predict_result  = predict_result_r;
assign control.predict_entry   = predict_entry_r;

// assign control.predict_result.valid         = valid;
// assign control.predict_result.br_op         = (r_entry.br_type != 3'b0);
// assign control.predict_result.br_taken      = is_taken;
// assign control.predict_result.target        = target;
// assign predict_entry = r_entry;

logic flush_r;

always_ff @ (posedge clk) begin
    if(reset)
        flush_r <= 1'b0;
    else 
        flush_r <= es_verify_valid && ~control.verify_result.predict_sucess;
end

assign control.br_flush       = es_verify_valid && ~control.verify_result.predict_sucess;
assign control.is_correction  = (state == `CORRECTION);
assign control.correct_target = correction_target;

ras ras_instance(
    .clk,
    .reset,
    .push_req  (r_entry.br_type == `B_IS_CALL),
    .pop_req   (r_entry.br_type == `B_IS_RET ),
    .push_data ({1'b1, control.verify_result.pc + 8}),
    .ras_top   (ras_data)
);

endmodule
