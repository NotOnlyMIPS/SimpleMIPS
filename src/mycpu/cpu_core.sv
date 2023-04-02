`include "cpu_defs.svh"

module cpu_core(
    input logic clk,
    input logic reset,
    // ex
    input logic [5:0] ext_int,
    // ICache
    CPU_ICache_Interface.CPU IBus,
    // DCache
    CPU_DCache_Interface.CPU DBus,
    // trace debug interface
    output [31:0] debug_wb_pc,
    output [ 3:0] debug_wb_rf_wen,
    output [ 4:0] debug_wb_rf_wnum,
    output [31:0] debug_wb_rf_wdata
);

// pipeline control
logic fs_allowin, ds_allowin, es_allowin, pms_allowin, ms_allowin, ws_allowin;
// branch prediction
logic   br_op;
logic   fs_valid;
logic   bpu_flush;
logic   is_correction;
logic   branch_resolved;
virt_t  correct_target;
BHT_entry_t      predict_entry;
predict_result_t predict_result;
ds_to_bpu_bus_t  ds_to_bpu_bus;
verify_result_t  es_to_bpu_bus;
// pipeline bus
pfs_to_fs_bus_t pfs_to_fs_bus;
fs_to_ds_bus_t  fs_to_ds_bus;
ds_to_es_bus_t  ds_to_es_bus;
es_to_pms_bus_t es_to_pms_bus;
pms_to_ms_bus_t pms_to_ms_bus;
ms_to_ws_bus_t  ms_to_ws_bus;
ws_to_rf_bus_t  ws_to_rf_bus;
ws_to_c0_bus_t  ws_to_c0_bus;
// forward bus
es_forward_bus_t  es_forward_bus;
pms_forward_bus_t pms_forward_bus;
ms_forward_bus_t  ms_forward_bus;
ws_forward_bus_t  ws_forward_bus;

// interface
WB_C0_Interface WB_C0_Bus();

// cp0 and ex
logic [ 5:0]     c0_hw;
logic [ 1:0]     c0_sw;
virt_t           c0_epc;
pipeline_flush_t pipeline_flush;
logic            pms_wr_disable;
logic            ms_wr_disable;
logic            wr_disable;
assign wr_disable = ms_wr_disable | pipeline_flush.eret | pipeline_flush.ex | pipeline_flush.tlb_op;

// tlb/mmu
virt_t           inst_vaddr;
virt_t           data_vaddr;
mmu_result_t     inst_result;
mmu_result_t     data_result;
logic            load_op;
logic            store_op;
exception_t      inst_tlb_ex;
exception_t      data_tlb_ex;
virt_t           tlb_cache_pc;
tlb_index_t      tlbrw_index;
logic            tlbrw_we;
tlb_entry_t      tlbrw_wdata;
tlb_entry_t      tlbrw_rdata;
uint32_t         tlbp_entry_hi;
uint32_t         tlbp_index;
logic[7:0]       tlb_asid;
// cache
logic         cache_valid;
logic [19:0]  cache_tag;
logic [ 7:0]  cache_index;
logic         cache_dirty;
CacheCodeType cache_op;
logic         kseg0_uncached;

assign IBus.cachetype = {cache_op, cache_op != EMPTY, 1'b0};
assign IBus.cache_valid = cache_valid;
assign IBus.cache_tag   = cache_tag;
assign IBus.cache_index = cache_index;

assign DBus.cachetype = {cache_op, 1'b0, cache_op != EMPTY};
assign DBus.cache_valid = cache_valid;
assign DBus.cache_tag   = cache_tag;
assign DBus.cache_dirty = cache_dirty;
assign DBus.cache_index = cache_index;

// BPU
BPU u_BPU (
    .clk            (clk            ),
    .reset          (reset          ),
    .pipeline_flush (pipeline_flush ),
    .correct_finish (branch_resolved),
    .ds_to_bpu_bus  (ds_to_bpu_bus  ),
    .es_to_bpu_bus  (es_to_bpu_bus  ),
    .predict_entry  (predict_entry  ),
    .bpu_predict_bus(predict_result ),
    .flush          (bpu_flush      ),
    .is_correction  (is_correction  ),
    .correct_target (correct_target )
);

// pre_IF stage
pre_if_stage u_pre_if_stage (
    .clk            (clk            ),
    .reset          (reset          ),
    // pipeline control
    .fs_allowin     (fs_allowin     ),
    // from IF
    .fs_valid       (fs_valid       ),
    // branch bus
    .br_op          (br_op          ),
    // branch prediction
    .bpu_flush      (bpu_flush      ),
    .predict_result (predict_result ),
    .is_correction  (is_correction  ),
    .correct_target (correct_target ),
    .branch_resolved(branch_resolved),
    // to IF
    .pfs_to_fs_bus  (pfs_to_fs_bus  ),
    // cp0 and exception
    .pipeline_flush (pipeline_flush ),
    .c0_epc         (c0_epc         ),
    // tlb/mmu
    .tlb_cache_pc   (tlb_cache_pc   ),
    .inst_vaddr     (inst_vaddr     ),
    .inst_result    (inst_result    ),
    .inst_tlb_ex    (inst_tlb_ex    ),
    // ICache
    .icache_req     (IBus.req       ),
    .icache_iscache (IBus.iscache   ),
    .icache_offset  (IBus.offset    ),
    .icache_index   (IBus.index     ),
    .icache_tag     (IBus.tag       ),
    .icache_addr_ok (IBus.addr_ok   )

);

// IF stage
if_stage u_if_stage (
    .clk            (clk            ),
    .reset          (reset          ),
    // pipeline control
    .ds_allowin     (ds_allowin     ),
    .fs_allowin     (fs_allowin     ),
    // from pre_IF
    .pfs_to_fs_bus  (pfs_to_fs_bus  ),
    // branch prediction
    .bpu_flush      (bpu_flush      ),
    // to IF
    .fs_to_pfs_valid(fs_valid       ),
    // to ID
    .fs_to_ds_bus   (fs_to_ds_bus   ),
    // cp0 and exception
    .pipeline_flush (pipeline_flush ),
    .c0_epc         (c0_epc         ),
    // ICache
    .icache_data_ok (IBus.data_ok   ),
    .icache_rdata   (IBus.rdata     )
);

// ID stage
id_stage u_idstage (
    .clk            (clk            ),
    .reset          (reset          ),
    // pipeline control
    .es_allowin     (es_allowin     ),
    .ds_allowin     (ds_allowin     ),
    // from IF
    .fs_to_ds_bus   (fs_to_ds_bus   ),
    // from WB to regfile
    .ws_to_rf_bus   (ws_to_rf_bus   ),
    // forward bus
    .es_forward_bus (es_forward_bus ),
    .pms_forward_bus(pms_forward_bus),
    .ms_forward_bus (ms_forward_bus ),
    .ws_forward_bus (ws_forward_bus ),
    // branch prediction
    .branch_resolved    (branch_resolved        ),
    .predict_is_taken   (predict_result.br_taken),
    .predict_target     (predict_result.target  ),
    .predict_entry      (predict_entry          ),
    .ds_to_bpu_bus      (ds_to_bpu_bus          ),
    // branch bus
    .br_op          (br_op          ),
    // to EXE
    .ds_to_es_bus   (ds_to_es_bus   ),
    // cp0 and exception
    .c0_hw          (c0_hw          ),
    .c0_sw          (c0_sw          ),
    .pipeline_flush (pipeline_flush )
);

// EXE stage
exe_stage u_exe_stage (
    .clk            (clk            ),
    .reset          (reset          ),
    // pipeline control
    .pms_allowin    (pms_allowin    ),
    .es_allowin     (es_allowin     ),
    // from ID
    .ds_to_es_bus   (ds_to_es_bus   ),
    // branch prediction
    .es_to_bpu_bus  (es_to_bpu_bus  ),
    // to pre_MEM
    .es_to_pms_bus  (es_to_pms_bus  ),
    // forward bus
    .es_forward_bus (es_forward_bus ),
    // cp0 and exception
    .pms_wr_disable (pms_wr_disable ),
    .wr_disable     (wr_disable     ),
    .pipeline_flush (pipeline_flush )
);

// pre_MEM stage
pre_mem_stage u_pre_mem_stage (
    .clk            (clk            ),
    .reset          (reset          ),
    // pipeline
    .ms_allowin     (ms_allowin     ),
    .pms_allowin    (pms_allowin    ),
    // from EXE
    .es_to_pms_bus  (es_to_pms_bus  ),
    // to MEM
    .pms_to_ms_bus  (pms_to_ms_bus  ),
    // forward bus
    .pms_forward_bus(pms_forward_bus),
    // cp0 and exception
    .wr_disable     (wr_disable     ),
    .pms_wr_disable (pms_wr_disable ),
    .pipeline_flush (pipeline_flush ),
    // MMU
    .load_op        (load_op        ),
    .store_op       (store_op       ),
    .data_vaddr     (data_vaddr     ),
    .data_result    (data_result    ),
    .data_tlb_ex    (data_tlb_ex    ),
    // data_sram interface
    .data_req       (DBus.req       ),
    .data_iscache   (DBus.iscache   ),
    .data_wr        (DBus.wr        ),
    .data_offset    (DBus.offset    ),
    .data_index     (DBus.index     ),
    .data_tag       (DBus.tag       ),
    .data_wstrb     (DBus.wstrb     ),
    .data_size      (DBus.size      ),
    .data_wdata     (DBus.wdata     ),
    .data_addr_ok   (DBus.addr_ok   )
);

// MEM stage
mem_stage mem_stage(
    .clk            (clk            ),
    .reset          (reset          ),
    // pipeline control
    .ws_allowin     (ws_allowin     ),
    .ms_allowin     (ms_allowin     ),
    //from pre_MEM
    .pms_to_ms_bus  (pms_to_ms_bus   ),
    //to WB
    .ms_to_ws_bus   (ms_to_ws_bus   ),
    // forward bus
    .ms_forward_bus (ms_forward_bus ),
    // cp0 and exception
    .ms_wr_disable  (ms_wr_disable  ),
    .pipeline_flush (pipeline_flush ),
    //from data-sram
    .data_data_ok   (DBus.data_ok   ),
    .data_rdata     (DBus.rdata     )
);

// WB stage
wb_stage wb_stage(
    .clk            (clk            ),
    .reset          (reset          ),
    // allowin
    .ws_allowin     (ws_allowin     ),
    // from MEM
    .ms_to_ws_bus   (ms_to_ws_bus   ),
    // forward
    .ws_forward_bus (ws_forward_bus ),
    // to regfile
    .ws_to_rf_bus   (ws_to_rf_bus   ),
    // to c0
    .ws_to_c0_bus   (ws_to_c0_bus   ),
    // WB_C0_Interface
    .wb_c0_bus      (WB_C0_Bus.WB   ),
    // exception
    .pipeline_flush (pipeline_flush ),
    // tlb
    .tlb_cache_pc   (tlb_cache_pc         ),
    //trace debug interface
    .debug_wb_pc      (debug_wb_pc      ),
    .debug_wb_rf_wen  (debug_wb_rf_wen  ),
    .debug_wb_rf_wnum (debug_wb_rf_wnum ),
    .debug_wb_rf_wdata(debug_wb_rf_wdata)
);

// CP0
reg_cp0 u_reg_cp0(
    .clk            (clk            ),
    .reset          (reset          ),
    // from WB
    .ws_to_c0_bus   (ws_to_c0_bus   ),
    // interface
    .c0_wb_bus      (WB_C0_Bus.C0   ),
    // interrupt
    .ext_int_in     (ext_int        ),
    .c0_hw          (c0_hw          ),
    .c0_sw          (c0_sw          ),
    // TLB
    .tlb_asid       (tlb_asid       ),
    .tlbrw_index    (tlbrw_index    ),
    .tlbrw_we       (tlbrw_we       ),
    .tlbrw_wdata    (tlbrw_wdata    ),
    .tlbrw_rdata    (tlbrw_rdata    ),
    .tlbp_entry_hi  (tlbp_entry_hi  ),
    .tlbp_index     (tlbp_index     ),
    // Cache
    .cache_valid,
    .cache_tag,
    .cache_dirty,
    .cache_op,
    .cache_index,
    // EPC
    .epc            (c0_epc         ),
    .kseg0_uncached
);

// MMU
mmu u_mmu (
    .clk            (clk            ),
    .reset          (reset          ),
    .asid           (tlb_asid       ),
    .kseg0_uncached ,
    .is_user_mode   (1'b1           ),
    .inst_vaddr     (inst_vaddr     ),
    .data_vaddr     (data_vaddr     ),

    .inst_result    (inst_result    ),
    .data_result    (data_result    ),
    // for TLBR/TLBWI/TLBWR
    .tlbrw_index    (tlbrw_index    ),
    .tlbrw_we       (tlbrw_we       ),
    .tlbrw_wdata    (tlbrw_wdata    ),
    .tlbrw_rdata    (tlbrw_rdata    ),
    // for TLBP
    .tlbp_entry_hi  (tlbp_entry_hi  ),
    .tlbp_index     (tlbp_index     ),

    .load_op        (load_op        ),
    .store_op       (store_op       ),
    .inst_tlb_ex    (inst_tlb_ex    ),
    .data_tlb_ex    (data_tlb_ex    )
);

endmodule