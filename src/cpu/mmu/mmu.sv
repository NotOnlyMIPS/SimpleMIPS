/*!
 * \brief memory-management unit
 */

`include "../cpu.svh"
module mmu(
    input  logic        clk,
    input  logic        reset,
    input  logic [7:0]  asid,
    input  logic        kseg0_uncached,
    input  logic        is_user_mode,
    input  virt_t       inst_vaddr,
    input  virt_t       data_vaddr,

    output mmu_result_t inst_result,
    output mmu_result_t data_result,

    // for TLBR/TLBWI/TLBWR
	input  tlb_index_t  tlbrw_index,
	input  logic        tlbrw_we,
	input  tlb_entry_t  tlbrw_wdata,
	output tlb_entry_t  tlbrw_rdata,

	// for TLBP
	input  uint32_t     tlbp_entry_hi,
	output uint32_t     tlbp_index,

    // exception
    input  logic        load_op,
    input  logic        store_op,
    output exception_t  inst_tlb_ex,
    output exception_t  data_tlb_ex
);

function logic is_vaddr_mapped(
    input virt_t vaddr
);
    // useg (0xx), kseg2 (110), kseg3 (111)
	return (~vaddr[31] || vaddr[31:30] == 2'b11);
endfunction

function logic is_vaddr_uncached(
	input virt_t vaddr
);
	return vaddr[31:29] == 3'b101 || (kseg0_uncached && vaddr[31:29] == 3'b100);
endfunction

mmu_result_t inst_result_r;
mmu_result_t data_result_r;
exception_t  inst_tlb_ex_r;
exception_t  data_tlb_ex_r;

generate if(`CPU_MMU_ENABLED)
begin: generate_mmu_enabled_code

    logic inst_mapped;
    logic data_mapped;
    tlb_result_t inst_tlb_result;
    tlb_result_t data_tlb_result;
    
    assign inst_mapped         = is_vaddr_mapped(inst_vaddr);
    assign data_mapped         = is_vaddr_mapped(data_vaddr);

    always_ff @ (posedge clk) begin
        if(reset) begin
            inst_result_r       <= '0;
            data_result_r       <= '0;
        end else begin
            inst_result_r.dirty     <= 1'b0;
            inst_result_r.miss      <= (inst_mapped & inst_tlb_result.miss);
            inst_result_r.illegal   <= (is_user_mode & inst_vaddr[31]);
            inst_result_r.invalid   <= (inst_mapped & ~inst_tlb_result.valid);
            inst_result_r.uncached  <= is_vaddr_uncached(inst_vaddr);
            inst_result_r.phy_addr  <= inst_mapped ? inst_tlb_result.phy_addr : {3'b0, inst_vaddr[28:0]};
            inst_result_r.virt_addr <= inst_vaddr;
            data_result_r.uncached  <= is_vaddr_uncached(data_vaddr) | (data_mapped && data_tlb_result.cache_flag == 3'd2);
            data_result_r.dirty     <= (~data_mapped | data_tlb_result.dirty);
            data_result_r.miss      <= (data_mapped & data_tlb_result.miss);
            data_result_r.illegal   <= (is_user_mode & data_vaddr[31]);
            data_result_r.invalid   <= (data_mapped & ~data_tlb_result.valid);
            data_result_r.phy_addr  <= data_mapped ? data_tlb_result.phy_addr : {3'b0, data_vaddr[28:0]};
            data_result_r.virt_addr <= data_vaddr;
        end
    end
    tlb tlb_instance(
        .clk,
		.reset,
		.asid,
		.inst_vaddr,
		.data_vaddr,
		.inst_result(inst_tlb_result),
		.data_result(data_tlb_result),

		.tlbrw_index,
		.tlbrw_we,
		.tlbrw_wdata,
		.tlbrw_rdata,

		.tlbp_entry_hi,
		.tlbp_index
    );
end else begin: generate_mmu_disabled_code
    always_ff @ (posedge clk) begin
        if(reset) begin
            inst_result_r        <= '0;
            data_result_r        <= '0;
        end else begin
            inst_result_r.dirty    <= 1'b0;
            inst_result_r.phy_addr <= {3'b0, inst_vaddr[28:0]};
            data_result_r.dirty    <= 1'b1;
            data_result_r.uncached <= is_vaddr_uncached(data_vaddr);
            data_result_r.phy_addr <= {3'b0, data_vaddr[28:0]};
        end
    end
end
endgenerate
assign inst_result = inst_result_r;
assign data_result = data_result_r;


// exception
always_ff @ (posedge clk) begin
    inst_tlb_ex_r.tlb_refill    <= inst_result.miss;
    inst_tlb_ex_r.badvaddr      <= inst_vaddr;
    inst_tlb_ex_r.ex            <= inst_result.invalid | inst_result.miss;
    inst_tlb_ex_r.exccode       <= `EXCCODE_TLBL;
    inst_tlb_ex_r.bd            <= 1'b0;

    data_tlb_ex_r.tlb_refill    <= data_result.miss;
    data_tlb_ex_r.badvaddr      <= data_vaddr;
    data_tlb_ex_r.ex            <= ((data_result.invalid | data_result.miss) & (load_op | store_op))
                                   | (store_op & ~data_result.miss & ~data_result.dirty & ~data_result.invalid);
    data_tlb_ex_r.exccode       <= load_op ? `EXCCODE_TLBL :
                                 (store_op & ~data_result.miss & ~data_result.dirty & ~data_result.invalid) ? `EXCCODE_MOD :
                                 `EXCCODE_TLBS;
    data_tlb_ex_r.bd            <= 1'b0;
end

assign inst_tlb_ex = inst_tlb_ex_r;
assign data_tlb_ex = data_tlb_ex_r;

endmodule
