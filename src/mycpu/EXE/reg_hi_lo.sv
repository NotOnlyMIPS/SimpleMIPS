`include "..\cpu_defs.svh"

module reg_hi_lo (
    input clk,
    input reset,

    input logic [ 7:0] hi_lo_op,
    input uint32_t src1,
    input uint32_t src2,

    output hi_lo_ready,
    output uint32_t hi_lo_result,

    input  wr_disable
);

reg  [31:0] hi   ;
reg  [31:0] lo   ;
wire        hi_we;
wire        lo_we;

wire        op_div  ;
wire        op_divu ;
wire        op_mult ;
wire        op_multu;
wire        op_mthi ;
wire        op_mtlo ;
wire        op_mfhi ;
wire        op_mflo ;

assign op_div   = hi_lo_op[0];
assign op_divu  = hi_lo_op[1];
assign op_mult  = hi_lo_op[2];
assign op_multu = hi_lo_op[3];
assign op_mthi  = hi_lo_op[4];
assign op_mtlo  = hi_lo_op[5];
assign op_mfhi  = hi_lo_op[6];
assign op_mflo  = hi_lo_op[7];

// mul
logic        is_signed;
logic        negtive_result;
logic [1:0]  mul_count;
logic        mul_ready;
uint32_t     abs_src1, abs_src2;
uint64_t     abs_prod;
uint64_t     mul_res;

assign is_signed = op_mult;
assign negtive_result = is_signed && (src1[31] ^ src2[31]);
assign abs_src1 = (is_signed && src1[31]) ? -src1 : src1;
assign abs_src2 = (is_signed && src2[31]) ? -src2 : src2;
assign mul_ready = mul_count == 3;

always_ff @(posedge clk) begin
    if(reset)
        mul_count <= 2'b0;
    else if(op_mult || op_multu)
        mul_count <= mul_count + 2'd1;
    else 
        mul_count <= 2'd0;
end

multu u_multu (
    .CLK(clk     ),
    .A  (abs_src1),
    .B  (abs_src2),
    .P  (abs_prod)
);

assign mul_res = negtive_result ? -abs_prod : abs_prod;

wire [63:0] unsigned_prod ;
wire [63:0] signed_prod   ;

// div
reg         div_in_valid     ;
wire        dividend_tvalid  ;
wire        dividend_tvalid_u;
wire        dividend_tready  ;
wire        dividend_tready_u;
wire        divisor_tvalid   ;
wire        divisor_tvalid_u ;
wire        divisor_tready   ;
wire        divisor_tready_u ;
wire        div_res_tvalid   ;
wire        divu_res_tvalid  ;
wire [63:0] div_res          ;
wire [63:0] divu_res         ;

always @(posedge clk) begin
    if(reset) begin
        div_in_valid <= 1'b0;
    end
    else if(div_res_tvalid || divu_res_tvalid) begin
        div_in_valid <= 1'b0;
    end
    else if((dividend_tvalid && dividend_tready) || (dividend_tvalid_u && dividend_tready_u)) begin
        div_in_valid <= 1'b1;
    end
end

assign hi_we = ~wr_disable & hi_lo_ready & (op_div | op_divu | op_mult | op_multu | op_mthi);
assign lo_we = ~wr_disable & hi_lo_ready & (op_div | op_divu | op_mult | op_multu | op_mtlo);

always @(posedge clk) begin
    if(hi_we) begin
        hi <= ({32{op_div  & div_res_tvalid }} & div_res[31:0]       )
            | ({32{op_divu & divu_res_tvalid}} & divu_res[31:0]      )
            | ({32{op_mult | op_multu       }} & mul_res[63:32]      )
            | ({32{op_mthi                  }} & src1                );
    end
    if(lo_we) begin
        lo <= ({32{op_div  & div_res_tvalid }} & div_res[63:32]     )
            | ({32{op_divu & divu_res_tvalid}} & divu_res[63:32]    )
            | ({32{op_mult | op_multu       }} & mul_res[31:0]      )
            | ({32{op_mtlo                  }} & src1               );
    end
end

assign dividend_tvalid   = (op_div  && ~div_in_valid);
assign dividend_tvalid_u = (op_divu && ~div_in_valid);
assign divisor_tvalid    = (op_div  && ~div_in_valid);
assign divisor_tvalid_u  = (op_divu && ~div_in_valid);

div u_div(
    .aclk                   (clk            ),
    .s_axis_dividend_tvalid (dividend_tvalid),
    .s_axis_dividend_tready (dividend_tready),
    .s_axis_dividend_tdata  (src1           ),
    .s_axis_divisor_tvalid  (divisor_tvalid ),
    .s_axis_divisor_tready  (divisor_tready ),
    .s_axis_divisor_tdata   (src2           ),
    .m_axis_dout_tvalid     (div_res_tvalid ),
    .m_axis_dout_tdata      (div_res        )
);

divu u_divu(
    .aclk                   (clk              ),
    .s_axis_dividend_tvalid (dividend_tvalid_u),
    .s_axis_dividend_tready (dividend_tready_u),
    .s_axis_dividend_tdata  (src1             ),
    .s_axis_divisor_tvalid  (divisor_tvalid_u ),
    .s_axis_divisor_tready  (divisor_tready_u ),
    .s_axis_divisor_tdata   (src2             ),
    .m_axis_dout_tvalid     (divu_res_tvalid  ),
    .m_axis_dout_tdata      (divu_res         )
);

assign hi_lo_ready = op_div  && div_res_tvalid 
                  || op_divu && divu_res_tvalid 
                  || (op_mult || op_multu) && mul_ready
                  || hi_lo_op[3:0] == 4'h0;

assign hi_lo_result = ({32{op_mfhi           }} & hi                 )
                    | ({32{op_mflo           }} & lo                 )
                    | ({32{op_div            }} & div_res[63:32]     )
                    | ({32{op_divu           }} & divu_res[63:32]    )
                    | ({32{op_mult | op_multu}} & mul_res[31:0]      )
                    | ({32{op_mthi | op_mtlo }} & src1               );

endmodule
