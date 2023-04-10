/*!
 * \brief 通用结构及 AXI 接口定义
 */

`ifndef COMMON_SVH
`define COMMON_SVH

`default_nettype wire
`timescale 1ns / 1ps

typedef logic [  7:0] uint8_t;
typedef logic [ 15:0] uint16_t;
typedef logic [ 31:0] uint32_t;
typedef logic [ 63:0] uint64_t;
typedef logic [127:0] uint128_t;
typedef uint32_t      virt_t;
typedef uint32_t      phys_t;

`include "axi.svh"

//! debug info of writeback stage
typedef struct packed {
    uint32_t pc;        //!< PC
    uint32_t data;      //!< data writing to regfiles
    logic [3:0] en;     //!< enable signals writing to regfiles
    logic [4:0] num;    //!< number writing to regfiles
} wb_debug_t;

`endif
