// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Sun Apr  2 15:58:23 2023
// Host        : LTMELAII running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               e:/Storage/FreeSpace/workspace/SimpleMIPS/src/deps/ip/xilinx/clk_pll/clk_pll_stub.v
// Design      : clk_pll
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tfbg676-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_pll(cpu_clk, timer_clk, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="cpu_clk,timer_clk,clk_in1" */;
  output cpu_clk;
  output timer_clk;
  input clk_in1;
endmodule
