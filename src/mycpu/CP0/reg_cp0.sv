`include "..\cpu_defs.svh"

module reg_cp0 (
    input clk   ,
    input reset ,
    //from WB
    input ws_to_c0_bus_t ws_to_c0_bus,
    // WB_C0_Interface
    WB_C0_Interface.C0   c0_wb_bus,
    // interrupt 
    input  [ 5:0] ext_int_in,
    output [ 5:0] c0_hw,
    output [ 1:0] c0_sw,
    // C0_TLB_Interface
    output logic[7:0]   tlb_asid,
    output tlb_index_t  tlbrw_index,
    output logic        tlbrw_we,
    output tlb_entry_t  tlbrw_wdata,
    input  tlb_entry_t  tlbrw_rdata,
    output uint32_t     tlbp_entry_hi,
    input  uint32_t     tlbp_index,
    // Cache
    output logic         cache_valid,
    output logic [19:0]  cache_tag,
    output logic         cache_dirty,
    output CacheCodeType cache_op,
    output logic [7:0]   cache_index,
    // epc
    output virt_t epc,
    // kseg0
    output logic  kseg0_uncached
);

// from WB
logic       eret_flush;
exception_t exception;
virt_t      wb_pc;
logic [2:0] tlb_op;
virt_t		  cache_vaddr;
phys_t	      cache_paddr;

assign { eret_flush,
         exception,
         wb_pc,
         tlb_op,
         cache_vaddr, 
         cache_paddr, 
         cache_op } = ws_to_c0_bus;

// WB_C0_Interface
logic        cp0_we   ;
logic [ 7:0] cp0_addr ;
uint32_t     cp0_wdata;

assign cp0_we    = c0_wb_bus.we;
assign cp0_addr  = c0_wb_bus.addr;
assign cp0_wdata = c0_wb_bus.wdata;

//CP0_STATUS: CR_STATUS, SEL 0
logic [31:0] cp0_status_out;
cp0_status_t cp0_status;

assign cp0_status.bev = 1'b1;

always @(posedge clk) begin
    if(cp0_we && cp0_addr == `CR_STATUS)
        cp0_status.im <= cp0_wdata[15:8];
end

always @(posedge clk) begin
    if(reset)
        cp0_status.exl <= 1'b0;
    else if(exception.ex)
        cp0_status.exl <= 1'b1;
    else if(eret_flush)
        cp0_status.exl <= 1'b0;
    else if(cp0_we && cp0_addr == `CR_STATUS)
        cp0_status.exl <= cp0_wdata[1];
end

always @(posedge clk) begin
    if(reset)
        cp0_status.ie <= 1'b0;
    else if(cp0_we && cp0_addr == `CR_STATUS)
        cp0_status.ie <= cp0_wdata[0];
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
    else if(cp0_we && cp0_addr == `CR_COMPARE)
        cp0_cause.ti <= 1'b0;
    else if(count_eq_compare)
        cp0_cause.ti <= 1'b1;
end

always @(posedge clk) begin
    if(reset)
        cp0_cause.ip[7:2] <= 6'b0;
    else begin
        cp0_cause.ip[7]   <= ext_int_in[5] | cp0_cause.ti;
        cp0_cause.ip[6:2] <= ext_int_in[4:0];
    end

    if(reset)
        cp0_cause.ip[1:0] <= 2'b0;
    else if(cp0_we && cp0_addr == `CR_CAUSE)
        cp0_cause.ip[1:0] <= cp0_wdata[9:8];
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
        cp0_epc <= exception.bd ? wb_pc-3'h4 : wb_pc;
    else if(cp0_we && cp0_addr == `CR_EPC)
        cp0_epc <= cp0_wdata;
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

    if(cp0_we && cp0_addr == `CR_COUNT)
        cp0_count <= cp0_wdata;
    else if(tick)
        cp0_count <= cp0_count + 1'b1;
end

//CP0_COMPARE: CR_COMPARE, SEl 0
reg [31:0] cp0_compare;
always @(posedge clk) begin
    if(cp0_we && cp0_addr == `CR_COMPARE)
        cp0_compare <= cp0_wdata;
end

assign count_eq_compare = cp0_count == cp0_compare;

//TLB
logic [31:0] cp0_entry_hi, cp0_entry_lo0, cp0_entry_lo1, cp0_index;

assign tlb_asid    = cp0_entry_hi[7:0];
assign tlbrw_index = cp0_index[$clog2(`TLB_ENTRIES_NUM)-1:0];
assign tlbrw_we    = tlb_op[`TLBOP_TLBWI];
assign tlbrw_wdata = {
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
assign tlbp_entry_hi = cp0_entry_hi;


always @(posedge clk) begin
    if(exception.ex && (exception.exccode == `EXCCODE_TLBL 
                    || exception.exccode == `EXCCODE_TLBS
                    || exception.exccode == `EXCCODE_MOD))
        cp0_entry_hi[31:13] <= exception.badvaddr[31:13];
    else if(tlb_op[`TLBOP_TLBR])
        cp0_entry_hi <= {
            tlbrw_rdata.vpn2,
            5'b0,
            tlbrw_rdata.asid
        };
    else if(cp0_we && cp0_addr == `CR_ENTRYHI)
        cp0_entry_hi <= {
            cp0_wdata[31:13],
            5'b0,
            cp0_wdata[7:0]
        };
    
    if(tlb_op[`TLBOP_TLBR])
        cp0_entry_lo0 <= {
            6'b0,
            tlbrw_rdata.pfn0,
            tlbrw_rdata.c0,
            tlbrw_rdata.d0,
            tlbrw_rdata.v0,
            tlbrw_rdata.G
        };
    else if(cp0_we && cp0_addr == `CR_ENTRYLO0)
        cp0_entry_lo0 <= {
            6'b0,
            cp0_wdata[25:0]
        };
    
    if(tlb_op[`TLBOP_TLBR])
        cp0_entry_lo1 <= {
            6'b0,
            tlbrw_rdata.pfn1,
            tlbrw_rdata.c1,
            tlbrw_rdata.d1,
            tlbrw_rdata.v1,
            tlbrw_rdata.G
        };
    else if(cp0_we && cp0_addr == `CR_ENTRYLO1)
        cp0_entry_lo1 <= {
            6'b0,
            cp0_wdata[25:0]
        };

    if(tlb_op[`TLBOP_TLBP])
        cp0_index <= tlbp_index;
    else if(cp0_we && cp0_addr == `CR_INDEX)
        cp0_index <= {{(32-$clog2(`TLB_ENTRIES_NUM)){1'b0}},cp0_wdata[$clog2(`TLB_ENTRIES_NUM)-1:0]};
end

// Cache TagLo
logic [31:0] cp0_tag_lo;
always @(posedge clk) begin
    if(reset)
        cp0_tag_lo <= '0;
    if(cp0_we && cp0_addr == `CR_TAGLO)
        cp0_tag_lo <= cp0_wdata[31:10];
end
logic  tag_from_cp0;
logic  cache_is_index;
assign tag_from_cp0 = (cache_op == I_Index_Store_Tag || cache_op == D_Index_Store_Tag);
assign cache_is_index = (cache_op == I_Index_Invalid || cache_op == I_Index_Store_Tag 
                       ||cache_op == D_Index_Store_Tag || cache_op == D_Index_Writeback_Invalid);
assign cache_valid = cp0_tag_lo[10];
assign cache_dirty = cp0_tag_lo[11];
assign cache_tag   = tag_from_cp0 ?  cp0_tag_lo[31:12] : cache_is_index ? ws_to_c0_bus.cache_vaddr[31:12] : ws_to_c0_bus.cache_paddr[31:12];
assign cache_index = ws_to_c0_bus.cache_vaddr[11:4];

// Configx
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
    if(cp0_we && cp0_addr == `CR_CONFIG0)
        cp0_config0[2:0] <= cp0_wdata[2:0];
end

assign kseg0_uncached = (cp0_config0[2:0] != 3'd3);

// WB_C0_Interface
assign c0_wb_bus.rdata = ({32{cp0_addr==`CR_BADVADDR}} & cp0_badvaddr   )
                       | ({32{cp0_addr==`CR_COUNT   }} & cp0_count      )
                       | ({32{cp0_addr==`CR_COMPARE }} & cp0_compare    )
                       | ({32{cp0_addr==`CR_STATUS  }} & cp0_status_out )
                       | ({32{cp0_addr==`CR_CAUSE   }} & cp0_cause_out  )
                       | ({32{cp0_addr==`CR_EPC     }} & cp0_epc        )
                       | ({32{cp0_addr==`CR_INDEX   }} & cp0_index      )
                       | ({32{cp0_addr==`CR_ENTRYHI }} & cp0_entry_hi   )
                       | ({32{cp0_addr==`CR_ENTRYLO0}} & cp0_entry_lo0  )
                       | ({32{cp0_addr==`CR_ENTRYLO1}} & cp0_entry_lo1  )
                       | ({32{cp0_addr==`CR_TAGLO   }} & cp0_tag_lo     )
                       | ({32{cp0_addr==`CR_CONFIG0 }} & cp0_config0    )
                       | ({32{cp0_addr==`CR_CONFIG1 }} & cp0_config1    );

assign {c0_hw, c0_sw} = {8{~cp0_status.exl}} & {8{cp0_status.ie}} & cp0_cause.ip & cp0_status.im;

assign epc = cp0_epc;

endmodule
