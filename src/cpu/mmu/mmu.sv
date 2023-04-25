/*!
 * \brief memory-management unit
 */

`include "../cpu.svh"
module mmu(
    input  logic        clk,
    input  logic        reset,

    // control
    MMU_Control_Interface.MMU control

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
	return vaddr[31:29] == 3'b101 || (control.kseg0_uncached && vaddr[31:29] == 3'b100);
endfunction

// interface
virt_t       inst_vaddr;
virt_t       data_vaddr;

assign inst_vaddr = control.inst_vaddr;
assign data_vaddr = control.data_vaddr;


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
            inst_result_r            <= '0;
            inst_tlb_ex_r            <= '0;
        end if(control.inst_valid) begin
            inst_result_r.dirty      <= 1'b0;
            inst_result_r.miss       <= (inst_mapped & inst_tlb_result.miss);
            inst_result_r.illegal    <= (control.is_user_mode & inst_vaddr[31]);
            inst_result_r.invalid    <= (inst_mapped & ~inst_tlb_result.valid);
            inst_result_r.uncached   <= is_vaddr_uncached(inst_vaddr);
            inst_result_r.phy_addr   <= inst_mapped ? inst_tlb_result.phy_addr : {3'b0, inst_vaddr[28:0]};
            inst_result_r.virt_addr  <= inst_vaddr;
            // exception 
            inst_tlb_ex_r.tlb_refill <= (inst_mapped & inst_tlb_result.miss);
            inst_tlb_ex_r.badvaddr   <= inst_vaddr;
            inst_tlb_ex_r.ex         <= (inst_mapped & ~inst_tlb_result.valid) || (inst_mapped & inst_tlb_result.miss);
            inst_tlb_ex_r.exccode    <= `EXCCODE_TLBL;
            inst_tlb_ex_r.bd         <= 1'b0;
        end else begin
            inst_result_r            <= '0;
            inst_tlb_ex_r            <= '0;
        end

        if(reset) begin
            data_result_r            <= '0;
            data_tlb_ex_r            <= '0;
        end else if(control.data_valid)begin
            data_result_r.uncached   <= is_vaddr_uncached(data_vaddr) | (data_mapped && data_tlb_result.cache_flag == 3'd2);
            data_result_r.dirty      <= (~data_mapped | data_tlb_result.dirty);
            data_result_r.miss       <= (data_mapped & data_tlb_result.miss);
            data_result_r.illegal    <= (control.is_user_mode & data_vaddr[31]);
            data_result_r.invalid    <= (data_mapped & ~data_tlb_result.valid);
            data_result_r.phy_addr   <= data_mapped ? data_tlb_result.phy_addr : {3'b0, data_vaddr[28:0]};
            data_result_r.virt_addr  <= data_vaddr;
            // exception
            data_tlb_ex_r.tlb_refill    <= (data_mapped & data_tlb_result.miss);
            data_tlb_ex_r.badvaddr      <= data_vaddr;
            data_tlb_ex_r.ex            <= (((data_mapped & ~data_tlb_result.valid) | (data_mapped & data_tlb_result.miss)) & (control.load_op | control.store_op))
                                           | (control.store_op & ~(data_mapped & data_tlb_result.miss) & ~(~data_mapped | data_tlb_result.dirty) & ~(inst_mapped & ~inst_tlb_result.valid));
            data_tlb_ex_r.exccode       <= control.load_op ? `EXCCODE_TLBL :
                                         (control.store_op & ~(data_mapped & data_tlb_result.miss) & ~(~data_mapped | data_tlb_result.dirty) & ~(data_mapped & ~data_tlb_result.valid)) ? `EXCCODE_MOD :
                                         `EXCCODE_TLBS;
            data_tlb_ex_r.bd            <= 1'b0;
        end else begin
            data_result_r            <= '0;
            data_tlb_ex_r            <= '0;
        end
    end
    tlb tlb_instance(
        .clk,
		.reset,
		.asid       (control.asid   ),
		.inst_vaddr,
		.data_vaddr,
		.inst_result(inst_tlb_result),
		.data_result(data_tlb_result),

		.tlbrw_index(control.tlbrw_index),
		.tlbrw_we   (control.tlbrw_we   ),
		.tlbrw_wdata(control.tlbrw_wdata),
		.tlbrw_rdata(control.tlbrw_rdata),

		.tlbp_entry_hi(control.tlbp_entry_hi),
		.tlbp_index   (control.tlbp_index   )
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

            // exception
            inst_tlb_ex_r          <= '0;
            data_tlb_ex_r          <= '0;
        end
    end
end
endgenerate
assign control.inst_mmu_result = inst_result_r;
assign control.data_mmu_result = data_result_r;
assign control.inst_tlb_ex = inst_tlb_ex_r;
assign control.data_tlb_ex = data_tlb_ex_r;

endmodule
