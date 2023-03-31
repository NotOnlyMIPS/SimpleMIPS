module PLRU #(
    parameter int unsigned ASSOC_NUM =4
) (
    input clk,
    input resetn,

    input [ASSOC_NUM-1:0] access,//鐙儹鐮侊紝鍝竴浣嶄负1灏辫〃鏄庡摢涓?璺懡涓?
    input update, //琛ㄧず鍛戒腑 鍚﹀垯娌℃硶琛ㄧず娌℃湁璁垮瓨涓嶉渶瑕佹洿鏂發ru鐨勬儏鍐?

    output [$clog2(ASSOC_NUM)-1:0] lru //琛ㄧず濡傛灉鏇挎崲锛屾浛鎹㈢殑鏄摢涓?璺?
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
                state_d[0] = 1;//濡傛灉杩欐鍛戒腑鐨勬槸绗?0璺? 閭ｄ箞涓嬫涓嶅懡涓殑鏃跺?欐浛鎹㈢殑灏辨槸1璺?
            end else begin
                state_d[0] = 0;
            end
        end
    end
end else  begin
    always_comb begin
        state_d = state;    //濂戒範鎯晩

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