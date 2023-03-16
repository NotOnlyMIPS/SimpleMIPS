`include "..\cpu_defs.svh"
module BPU (
    input   clk,
    input   reset,
    input   logic           correct_finish,
    input   ds_to_bpu_bus_t ds_to_bpu_bus,
    input   verify_result_t es_to_bpu_bus,
    output  br_result_t     bpu_predict_bus,
    output  logic           flush,
    output  virt_t          correct_target
);



endmodule