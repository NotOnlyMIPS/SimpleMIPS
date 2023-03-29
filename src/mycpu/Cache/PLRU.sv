module PLRU #(
    parameter int unsigned ASSOC_NUM =4
) (
    input clk,
    input resetn,

    input [ASSOC_NUM-1:0] access,//独热码，哪一位为1就表明哪�?路命�?
    input update, //表示命中 否则没法表示没有访存不需要更新lru的情�?

    output [$clog2(ASSOC_NUM)-1:0] lru //表示如果替换，替换的是哪�?�?
);

    logic [ASSOC_NUM-2:0] state,state_d;

//output
generate
    if(ASSOC_NUM == 2)begin
        assign lru = state;
    end else begin
        assign lru = state[2] == 1'b0 ? state[2:1] : {state[2],state[0]};
    end
endgenerate
    
// Update
generate
if(ASSOC_NUM == 2) begin
    always_comb begin
        state_d = state;

        if(update && |access) begin
            if(access[0]) begin
                state_d[0] = 1;//如果这次命中的是�?0�? 那么下次不命中的时�?�替换的就是1�?
            end else begin
                state_d[0] = 0;
            end
        end
    end
end else  begin
    always_comb begin
        state_d = state;    //好习惯啊

        casez(access)
            4'b1???: begin
                state_d[2] = 1'b0;
                state_d[0] = 1'b0;
            end
            4'b01??: begin
                state_d[2] = 1'b0;
                state_d[0] = 1'b1;
            end
            4'b001?: begin
                state_d[2] = 1'b1;
                state_d[1] = 1'b0;
            end
            4'b0001: begin
                state_d[2] = 1'b1;
                state_d[1] = 1'b1;
            end
        endcase
    end
end 
endgenerate

always_ff @( posedge clk ) begin
    if(!resetn)begin
        state<='0;
    end else if(update)begin
        state<=state_d;
    end
end

endmodule