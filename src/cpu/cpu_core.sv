`include "cpu.svh"

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
logic pfs_to_valid, fs_to_valid, ds_to_valid, es_to_valid, pms_to_valid, ms_to_valid, ws_to_valid;

// pipeline bus
pfs_to_fs_bus_t pfs_to_fs_bus;
fs_to_ds_bus_t  fs_to_ds_bus;
ds_to_es_bus_t  ds_to_es_bus;
es_to_pms_bus_t es_to_pms_bus;
pms_to_ms_bus_t pms_to_ms_bus;
ms_to_ws_bus_t  ms_to_ws_bus;

// interface
PreFetch_Control_Interface  pre_fetch_control();
BPU_Control_Interface       branch_predict();
Fetch_Control_Interface     fetch_control();
Decode_Control_Interface    decode_control();
Execute_Control_Interface   execute_control();
PreMemory_Control_Interface pre_memory_control();
Memmory_Control_Interface   memory_control();
Writeback_Control_Interface writeback_control();
CP0_Control_Interface       cp0_control();
MMU_Control_Interface       mmu_control();


// control
control u_control(
    .clk,
    .reset,

    .ext_int,

    .bpu        (branch_predict.Control     ),
    .pre_fetch  (pre_fetch_control.Control  ),
    .fetch      (fetch_control.Control      ),
    .decode     (decode_control.Control     ),
    .execute    (execute_control.Control    ),
    .pre_memory (pre_memory_control.Control ),
    .memory     (memory_control.Control     ),
    .writeback  (writeback_control.Control  ),
    .cp0        (cp0_control.Control        ),
    .mmu        (mmu_control.Control        ),

    .IBus,
    .DBus

);


// BPU
BPU u_BPU (
    .clk  ,
    .reset,

    .control (branch_predict.BPU)

);

// pre_IF stage
pre_fetch_stage u_pre_if_stage (
    .clk  ,
    .reset,

    // pipeline control
    .fs_allowin,
    .pfs_to_valid,

    .pfs_to_fs_bus,

    // control
    .control (pre_fetch_control.PreFetch)

);

// IF stage
fetch_stage u_if_stage (
    .clk  ,
    .reset,
    // pipeline control
    .pfs_to_valid,
    .fs_allowin,
    .ds_allowin,
    .fs_to_valid,

    .pfs_to_fs_bus,
    .fs_to_ds_bus,

    // control
    .control (fetch_control.Fetch)

);

// ID stage
decode_stage u_idstage (
    .clk,
    .reset,

    // pipeline control
    .fs_to_valid,
    .ds_allowin,
    .es_allowin,
    .ds_to_valid,

    .fs_to_ds_bus,
    .ds_to_es_bus,

    // control
    .control (decode_control.Decode)

);

// EXE stage
execute_stage u_execute_stage (
    .clk,
    .reset,

    // pipeline control
    .ds_to_valid,
    .es_allowin,
    .pms_allowin,
    .es_to_valid,

    .ds_to_es_bus,
    .es_to_pms_bus,

    // control
    .control (execute_control.Execute)

);

// pre_MEM stage
pre_mem_stage u_pre_mem_stage (
    .clk,
    .reset,

    // pipeline control
    .es_to_valid,
    .pms_allowin,
    .ms_allowin,
    .pms_to_valid,

    .es_to_pms_bus,
    .pms_to_ms_bus,

    // control
    .control (pre_memory_control.PreMemory)

);

// MEM stage
mem_stage u_mem_stage(
    .clk,
    .reset,

    // pipeline control
    .pms_to_valid,
    .ms_allowin,
    .ws_allowin,
    .ms_to_valid,

    .pms_to_ms_bus,
    .ms_to_ws_bus,

    // control
    .control (memory_control.Memory)

);

// WB stage
writeback_stage u_wb_stage(
    .clk,
    .reset,

    // pipeline control
    .ms_to_valid,
    .ws_allowin,

    .ms_to_ws_bus,
    
    // control
    .control (writeback_control.Writeback),

    //trace debug interface
    .debug_wb_pc      ,
    .debug_wb_rf_wen  ,
    .debug_wb_rf_wnum ,
    .debug_wb_rf_wdata
);

// CP0
reg_cp0 u_reg_cp0(
    .clk,
    .reset,

    // control
    .control (cp0_control.CP0)

);

// MMU
mmu u_mmu (
    .clk,
    .reset,

    // control
    .control (mmu_control.MMU)

);

endmodule
