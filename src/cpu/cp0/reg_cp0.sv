`include "../cpu.svh"

module reg_cp0 (
    input clk   ,
    input reset ,

    // control
    CP0_Control_Interface.CP0 control

);


exception_t exception;
assign exception = control.exception;


//CP0_STATUS: CR_STATUS, SEL 0
logic [31:0] cp0_status_out;
cp0_status_t cp0_status;

always @(posedge clk) begin
    if(reset)
        cp0_status.bev <= 1'b1;
    else if(control.we && control.addr == `CR_STATUS)
        cp0_status.bev <= control.wdata[22];
end

always @(posedge clk) begin
    if(control.we && control.addr == `CR_STATUS)
        cp0_status.im <= control.wdata[15:8];
end

always @(posedge clk) begin
    if(reset)
        cp0_status.exl <= 1'b0;
    else if(exception.ex)
        cp0_status.exl <= 1'b1;
    else if(control.eret_flush)
        cp0_status.exl <= 1'b0;
    else if(control.we && control.addr == `CR_STATUS)
        cp0_status.exl <= control.wdata[1];
end

always @(posedge clk) begin
    if(reset)
        cp0_status.ie <= 1'b0;
    else if(control.we && control.addr == `CR_STATUS)
        cp0_status.ie <= control.wdata[0];
end

assign cp0_status_out = {9'b0, cp0_status.bev, 6'b0, cp0_status.im, 6'b0, cp0_status.exl, cp0_status.ie};

//CP0_CAUSE: CR_CAUSE, SEL 0
logic [31:0] cp0_cause_out;
cp0_cause_t  cp0_cause;

always @(posedge clk) begin
    if(reset)
        cp0_cause.bd <= 1'b0;
    else if(exception.ex && !cp0_status.exl)
        cp0_cause.bd <= exception.bd;
end

logic count_eq_compare;
always @(posedge clk) begin
    if(reset)
        cp0_cause.ti <= 1'b0;
    else if(control.we && control.addr == `CR_COMPARE)
        cp0_cause.ti <= 1'b0;
    else if(count_eq_compare)
        cp0_cause.ti <= 1'b1;
end

always @(posedge clk) begin
    if(reset)
        cp0_cause.ip[7:2] <= 6'b0;
    else begin
        cp0_cause.ip[7]   <= control.ext_int[5] | cp0_cause.ti;
        cp0_cause.ip[6:2] <= control.ext_int[4:0];
    end

    if(reset)
        cp0_cause.ip[1:0] <= 2'b0;
    else if(control.we && control.addr == `CR_CAUSE)
        cp0_cause.ip[1:0] <= control.wdata[9:8];
end

always @(posedge clk) begin
    if(reset)
        cp0_cause.exccode <= 5'b0;
    else if(exception.ex)
        cp0_cause.exccode <= exception.exccode;
end

assign cp0_cause_out = {cp0_cause.bd, cp0_cause.ti, 14'b0, cp0_cause.ip, 1'b0, cp0_cause.exccode, 2'b0};

//CP0_EPC: CR_EPC, SEL 0
virt_t cp0_epc;
always @(posedge clk) begin
    if(exception.ex && !cp0_status.exl)
        cp0_epc <= exception.bd ? control.pc-3'h4 : control.pc;
    else if(control.we && control.addr == `CR_EPC)
        cp0_epc <= control.wdata;
end

//CP0_BADVADDR: CR_BADVADDR, SEL 0
virt_t cp0_badvaddr;
always @(posedge clk) begin
    if(exception.ex && (exception.exccode == `EXCCODE_ADEL || exception.exccode == `EXCCODE_ADES
                      ||exception.exccode == `EXCCODE_TLBL || exception.exccode == `EXCCODE_TLBS
                      ||exception.exccode == `EXCCODE_MOD))
        cp0_badvaddr <= exception.badvaddr;
end

//CP0_COUNT: CR_COUNT, SEL 0
reg        tick    ;
reg [31:0] cp0_count;
always @(posedge clk) begin
    if(reset)
        tick <= 1'b0;
    else
        tick <= ~tick;

    if(control.we && control.addr == `CR_COUNT)
        cp0_count <= control.wdata;
    else if(tick)
        cp0_count <= cp0_count + 1'b1;
end

//CP0_COMPARE: CR_COMPARE, SEl 0
reg [31:0] cp0_compare;
always @(posedge clk) begin
    if(control.we && control.addr == `CR_COMPARE)
        cp0_compare <= control.wdata;
end

assign count_eq_compare = cp0_count == cp0_compare;

//TLB
uint32_t cp0_entry_hi, cp0_entry_lo0, cp0_entry_lo1, cp0_index;
tlb_entry_t tlbrw_rdata;

assign control.tlb_asid    = cp0_entry_hi[7:0];
assign control.tlbrw_index = cp0_index[$clog2(`TLB_ENTRIES_NUM)-1:0];
assign control.tlbrw_we    = control.tlb_op[`TLBOP_TLBWI];
assign control.tlbrw_wdata = {
    cp0_entry_lo0[ 5: 3],
    cp0_entry_lo1[ 5: 3],
    cp0_entry_hi [ 7: 0],
    cp0_entry_hi [31:13],
    cp0_entry_lo0[25: 6],
    cp0_entry_lo1[25: 6],
    cp0_entry_lo0[2],
    cp0_entry_lo0[1],
    cp0_entry_lo1[2],
    cp0_entry_lo1[1],
    cp0_entry_lo0[0] & cp0_entry_lo1[0]
};
assign control.tlbp_entry_hi = cp0_entry_hi;

assign tlbrw_rdata = control.tlbrw_rdata;


always @(posedge clk) begin
    if(reset) cp0_entry_hi <= '0;
    else if(exception.ex && (exception.exccode == `EXCCODE_TLBL
                    || exception.exccode == `EXCCODE_TLBS
                    || exception.exccode == `EXCCODE_MOD))
        cp0_entry_hi[31:13] <= exception.badvaddr[31:13];
    else if(control.tlb_op[`TLBOP_TLBR])
        cp0_entry_hi <= {
            tlbrw_rdata.vpn2,
            5'b0,
            tlbrw_rdata.asid
        };
    else if(control.we && control.addr == `CR_ENTRYHI)
        cp0_entry_hi <= {
            control.wdata[31:13],
            5'b0,
            control.wdata[7:0]
        };

    if(control.tlb_op[`TLBOP_TLBR])
        cp0_entry_lo0 <= {
            6'b0,
            tlbrw_rdata.pfn0,
            tlbrw_rdata.c0,
            tlbrw_rdata.d0,
            tlbrw_rdata.v0,
            tlbrw_rdata.G
        };
    else if(control.we && control.addr == `CR_ENTRYLO0)
        cp0_entry_lo0 <= {
            6'b0,
            control.wdata[25:0]
        };

    if(control.tlb_op[`TLBOP_TLBR])
        cp0_entry_lo1 <= {
            6'b0,
            tlbrw_rdata.pfn1,
            tlbrw_rdata.c1,
            tlbrw_rdata.d1,
            tlbrw_rdata.v1,
            tlbrw_rdata.G
        };
    else if(control.we && control.addr == `CR_ENTRYLO1)
        cp0_entry_lo1 <= {
            6'b0,
            control.wdata[25:0]
        };

    if(control.tlb_op[`TLBOP_TLBP])
        cp0_index <= control.tlbp_index;
    else if(control.we && control.addr == `CR_INDEX)
        cp0_index <= {{(32-$clog2(`TLB_ENTRIES_NUM)){1'b0}},control.wdata[$clog2(`TLB_ENTRIES_NUM)-1:0]};
end

// Cache TagLo
logic [31:0] cp0_tag_lo;
always @(posedge clk) begin
    if(reset)
        cp0_tag_lo <= '0;
    if(control.we && control.addr == `CR_TAGLO)
        cp0_tag_lo <= control.wdata[31:10];
end
// logic  tag_from_cp0;
// logic  cache_is_index;
assign tag_from_cp0 = (control.cache_op == I_Index_Store_Tag || control.cache_op == D_Index_Store_Tag);

assign control.cache_valid = cp0_tag_lo[10];
assign control.cache_dirty = cp0_tag_lo[11];
assign control.cache_tag   = tag_from_cp0 ? cp0_tag_lo[31:12] : control.cache_paddr[31:12];
assign control.cache_way   = control.cache_paddr[12];
assign control.cache_index = control.cache_vaddr[11:4];


// CP0_PRID
uint32_t cp0_prid;

always_ff @(posedge clk) begin
    if(reset)
        cp0_prid <= 32'h0000_4220;
end


// CP0_EBase
uint32_t cp0_ebase;
uint32_t offset, base;

always_ff @(posedge clk) begin
    if(reset)
        cp0_ebase <= 32'h8000_0000;
    else if(control.we && control.addr == `CR_EBASE)
        cp0_ebase <= control.wdata;
end

always_comb begin
    unique case(control.exception.exccode)
        `EXCCODE_TLBL, `EXCCODE_TLBS:
            offset = (exception.tlb_refill) ? 32'h0 : 32'h180;
        default:
            offset = 32'h180;
    endcase

    base = (cp0_status.exl || exception.ex) ? 32'hbfc00200 : cp0_ebase;
end


// Config x
logic [31:0] cp0_config0, cp0_config1;
always @(posedge clk) begin
    if(reset) begin
        cp0_config0 <= {
            1'b1,    // M
            15'b0,   // 0
            1'b0,    // BE
            2'b0,    // AT
            3'b0,    // AR
            3'b1,    // MT
            4'b0,    // 0
            3'b011   // K0  
        };
        cp0_config1 <= {
            1'b1,    // M
            6'd15,   // MMUSize-1
            3'd2,    // IS
            3'd4,    // IL
            3'd3,    // IA
            3'd2,    // DS
            3'd4,    // DL
            3'd3,    // DA
            1'd0,    // C2
            1'd0,    // CMD
            1'd0,    // PC
            1'd0,    // WR
            1'd0,    // CA
            1'd0,    // EP
            1'd0     // FP
        };
    end
    if(control.we && control.addr == `CR_CONFIG0)
        cp0_config0[2:0] <= control.wdata[2:0];
end

assign control.kseg0_uncached = (cp0_config0[2:0] != 3'd3);


// mtc0/mfc0
assign control.rdata =   ({32{control.addr==`CR_INDEX   }} & cp0_index      )
                       | ({32{control.addr==`CR_ENTRYLO0}} & cp0_entry_lo0  )
                       | ({32{control.addr==`CR_ENTRYLO1}} & cp0_entry_lo1  )
                       | ({32{control.addr==`CR_BADVADDR}} & cp0_badvaddr   )
                       | ({32{control.addr==`CR_COUNT   }} & cp0_count      )
                       | ({32{control.addr==`CR_ENTRYHI }} & cp0_entry_hi   )
                       | ({32{control.addr==`CR_COMPARE }} & cp0_compare    )
                       | ({32{control.addr==`CR_STATUS  }} & cp0_status_out )
                       | ({32{control.addr==`CR_CAUSE   }} & cp0_cause_out  )
                       | ({32{control.addr==`CR_EPC     }} & cp0_epc        )
                       | ({32{control.addr==`CR_PRID    }} & cp0_prid       )
                       | ({32{control.addr==`CR_EBASE   }} & cp0_ebase      )
                       | ({32{control.addr==`CR_CONFIG0 }} & cp0_config0    )
                       | ({32{control.addr==`CR_CONFIG1 }} & cp0_config1    )
                       | ({32{control.addr==`CR_TAGLO   }} & cp0_tag_lo     );

// interrupt
assign {control.hw, control.sw} = {8{~cp0_status.exl}} & {8{cp0_status.ie}} & cp0_cause.ip & cp0_status.im;

// exception
assign control.epc = cp0_epc;
assign control.exception_vector = offset + base;


endmodule
