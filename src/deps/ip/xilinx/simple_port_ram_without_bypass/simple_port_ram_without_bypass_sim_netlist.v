// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Sun Apr  2 15:58:44 2023
// Host        : LTMELAII running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               e:/Storage/FreeSpace/workspace/SimpleMIPS/src/deps/ip/xilinx/simple_port_ram_without_bypass/simple_port_ram_without_bypass_sim_netlist.v
// Design      : simple_port_ram_without_bypass
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a200tfbg676-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "simple_port_ram_without_bypass,blk_mem_gen_v8_4_5,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_5,Vivado 2022.2" *) 
(* NotValidForBitStream *)
module simple_port_ram_without_bypass
   (clka,
    ena,
    wea,
    addra,
    dina,
    clkb,
    enb,
    addrb,
    doutb);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [0:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [7:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [58:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB EN" *) input enb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [7:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [58:0]doutb;

  wire [7:0]addra;
  wire [7:0]addrb;
  wire clka;
  wire clkb;
  wire [58:0]dina;
  wire [58:0]doutb;
  wire ena;
  wire enb;
  wire [0:0]wea;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_rsta_busy_UNCONNECTED;
  wire NLW_U0_rstb_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [58:0]NLW_U0_douta_UNCONNECTED;
  wire [7:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [7:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [58:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "8" *) 
  (* C_ADDRB_WIDTH = "8" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "0" *) 
  (* C_COUNT_36K_BRAM = "1" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "0" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     6.7901 mW" *) 
  (* C_FAMILY = "artix7" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "1" *) 
  (* C_HAS_ENB = "1" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "1" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "0" *) 
  (* C_HAS_RSTB = "0" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "simple_port_ram_without_bypass.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "1" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "256" *) 
  (* C_READ_DEPTH_B = "256" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "59" *) 
  (* C_READ_WIDTH_B = "59" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "0" *) 
  (* C_USE_BYTE_WEA = "0" *) 
  (* C_USE_BYTE_WEB = "0" *) 
  (* C_USE_DEFAULT_DATA = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "1" *) 
  (* C_WEB_WIDTH = "1" *) 
  (* C_WRITE_DEPTH_A = "256" *) 
  (* C_WRITE_DEPTH_B = "256" *) 
  (* C_WRITE_MODE_A = "NO_CHANGE" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "59" *) 
  (* C_WRITE_WIDTH_B = "59" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  simple_port_ram_without_bypass_blk_mem_gen_v8_4_5 U0
       (.addra(addra),
        .addrb(addrb),
        .clka(clka),
        .clkb(clkb),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(NLW_U0_douta_UNCONNECTED[58:0]),
        .doutb(doutb),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(enb),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[7:0]),
        .regcea(1'b0),
        .regceb(1'b0),
        .rsta(1'b0),
        .rsta_busy(NLW_U0_rsta_busy_UNCONNECTED),
        .rstb(1'b0),
        .rstb_busy(NLW_U0_rstb_busy_UNCONNECTED),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[7:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[58:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb(1'b0),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(wea),
        .web(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2022.2"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
VHPlDkoDlWlBfBMvPBmGYmaek3s9hXXhjF28kllYPnaNm3TSnzzpXHWHc8Ye9/2L2yiQfJ1hTWou
Ia/zeQ8h9/dtr6QB5YkyW4wlb/LbMgXb+DGIXPSllNl0IMsRQIcQDbcQm1bO/nlhb+2pjxiuaQrl
DbvxoDwPs7z3LunRxsg=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
lmIhoX8hXuc7tNV1sXY1K2/gXL7Y7Hq73qQF7+x03UWWTRd3uhGmVQtOMVbhIW+66UkWUHiD26zL
fzqGor8bgSNGpSFyS11k4TwLQT4OfAMGO8C9Qmmh4+VENBnpS9TW+wHzCv8oUwht7xYtYRZvOvYK
F3fMppz2sBkUd1lciw98ZE/UmNkhqBuMfIYF43j45DEJ55PBhOZNg91Ls4v3qBHyBAaYPFFoMry3
d5Fw1PZyFQSEOSSpwgyds2aN0g6oIwl7zm0LJrM9VDAOxBUE50hk+oHr4jj8J8UhHQJnlEHm1Idm
rvxKygNKRvfSpa90NYxZJFYgqnrMYg+19+9aZA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
VkyCjO2onoeZWEoYQ/4ue7X5mkHyTYVW9xjdoTsGS4GdP/Q64VaCZL/jr6R8DVDXPMnH7tRMrDpo
jpYBnyzSgOkfgqM+96ioC2fDyAaG4gYgGLmrBR6qK3/mxXwAZZX+GJ9R/eWXkc9h8xN+gsSSX6/M
jIQCgeT6q7PB4dWT6KY=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Iub91V+TnhVlZCSLu6iKmFjix71y6/l83OPTs8uewWvkE7WcqYxEKi9fonXEkzAtWzuKwEUqnOlN
VBsNJqPUdKcd22q523mrdt89mpdosWD+hvZdO7ELhJniY5u9h49FFkubpN2JiUTcIcKEYxVNlds4
wyvaYUqbPVH5v2ooJwDdimS4GVn9HerCOgPwfshvQDNlMTxLcYju4v8BHMc5Rub9Q/ihvpQU74v2
ouZ9XIwA+C6pBLwvaqS8jE7HXOokgqJilaX/W/t+KEgiFry/txRTMU9WMD7tCN7lcfjCydmS3Lq+
3u6Hsr0S8BwNjcaDpZDnBTygUJd4JSqREnk33w==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
U46EWFmKmpZGaWfyL+dokyQtJtaOYsa7HCW/+fdtw9/yHKTWFpmqKBZngBj5rPkNhtTDDCJkqsYj
tUXg1j4tgIBaCQn9B0q/aG+B3gPLrudp9hLL25mVbsfiTzdekiV2hJMmhuMoavKKPJHC6zyW7kZi
80er82OQy8h+Df/fe6TRjH9xEt3/b80tRKUMbxkLfnnkAyyf1KfOhB6/uyI4mwXuQR+DsAbzybKR
YtXpOiW72tGrXTFlzcwbHamWZefqsilVpBw6V5dh33vYKGx50xwWpj76maAkpQrOpB7zufeldJe4
W1UOEN84AZdRTLkVSxamWo/wp8nP9fiGS/ItRw==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2021_07", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
qczgIJYpE/SzErzK7eWJBGcDFEzDLm8cKbwJbPXuM6YnJxx44W+E60R3war7K2QGFAkOoCDUtDC7
SghJGF32btaDLzeKm0tQ669sBtQmMIaBrlt7I9QBkNM8zN9GL92qxNC9o3UVWMOYy5BmH8nUPgcE
O6lRubeltlrTuDe7UJQ2nEPHcXjpUJJ8dxktyW+LovBy1OxW8g4GRAsmEJsoOEg0HuDdWcc4IshJ
PvwPJ7LblELAKsdkSt65y9VaklaEm7MlH4ImlgIa74TgRmutLUbWxM1QYhGE5rAzFhGU5i3RJOdx
L3N7GGGvLMW2z9NSHbIFX+/eNII9fNJ9nZbgLA==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Ti1NUgDv8YPk90APMwfu/mRr38QYwAxZfv0T6zQ89YS55t2EquEGVqrEafYX6rTydLOw8le1Oucv
f2oERpSSSTih/ScZneSZmuPE/Zh2BU1Ajv0j+/+0uEWXU+5lLPbDJjnapTmJXih1MYPf0SHpZZmE
BKj2IEBI9MPZlh6bxpa5BWJnyPdAvHf+UNaMXU9+pmbtrzUVebql4mFJu45Z3+ehmFY4FBW3zXMF
44C4TlHACLwL3vHVMCVfeKhgdVDbpE+/IFhTStz7mZ9h9RKGanQcs6YDVM1R+2RKA1QT1fX4FiQc
1V+FGmrm1ujxmFGXwpfNKByVlfCY0oWhRJCYYQ==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
HuEXFK0NXt09xU2yxxjng1OLsT+ZEM4EhqBgpr9D2ljw2vDaMBrqEsRQTc2B9soDq3ewDduHJXBd
OGYxkPnoN6LhjULtB2nTgjcH6NxA4puZ1ZNcndDndVBo8rTW5W1OqHq6InAG0CqPpTIkuqz3ECPl
EysI++MCDfH6tIzlekxJFIJ1McJsTq5rFuLzMMcrmkBxgcayDpOcCFuzZzCczxmt/cCCIKmDybwT
OQXmOcLJoYLP4sFu6R9c6xO8i6p++crv2N3eIxZHKbek9xBBZqQM9EYuEtsbkqAs9XZpa16i5njR
BDFxTKcP6r7JgFALJE89AZhBbate5JXWp0v4ECZD18aEL17CipwcWPutNMdG1apzSPP5y59n7rMG
yxBPz1gKHc3Emkl4WcO0hjICxqmO6dMXoY8JvBSf6ry2l0sH9Ihr3Bq5WWmlhPHnoaNr5jl//vNe
KfToWtn97eoVSt1LnmXXnSpdigbHr0UIg8AdkpdkuNRaWdVicDdgSo49

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
mokwst2bn6UxD6V9UdIgCIG1QQ/d0FiJqYGOTI2eHPV6YElaLjnJ8DnQmZnGS95o3x93FDOoa58C
RwYsX1fVoVtXkj1LuZq0k7q9vEe4T8xMjpkeYtIHY9k0Xhy1Lq/xRlfzGAf9fvf9e+f4r7aR/Sb/
uCZxxugG5niTwLENY1n3NthYL0jvo8Fmdw4Qg0nTCGWlVCws+09K0g9/lx6I9EcuHHemcHO3fOZG
lMc4NaPNozKwnyDMoWUkwiVxyFEPFaQLNYqzjvR+CqrWfhFLo96JWhL+eaDoNuZoBVYQtNH5ZwBL
BoO27Pw10lgcReGlZBz3BLO7T4ddynCx0+eSnw==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
PiP7AjOQqqouyQMoBQqgWIDhUSViq94rIvGiIJ/UKMDspM/yXw1caE8AhWHTjYckC4yLpPAz5P6s
1Z6flzDPrzVwg4e59X2cc4IMCHhedna0rDO804njcc6amRDTeLsMLTkWfvomB4xwszm2AgT+PRnB
WHd09ZUDVFjiBXT+Oa9AicgGJHrX3w823yBPuAa704kje/SzgtiDpcTU1eLmLhLW7LpEd9KIHd9s
ER7Uk9Orws0Kq9PMTqMX4hMn5K5mFakOeOURiEbUjdv5RiIJ2g/PlQXSItM8fHsBTQa6fOaJwQTI
vHwK3a8ZBHpfT1YH+n7wNiNUZwD4SFXm1QVx4g==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Ul5ZfTHJwMctaNhYRortUZizYMPYRef7uYqPSuMkxsArnxI/cjGh+KRMwzV86hyp/6TXSJIjm5ec
2wX2UONdPN+DOJ84jYC4JbgJQrPnTj7ioD8uLX/WlyPcQzyF5keqFgj5eR5s13FskVWCuAWf5m9w
mhFEKFjVXDAr7gVgAJh/hL8P6Psrnf+LGfiM8JhnDepsHEYykGlpD3fzru2BGgqHWqPqFMcnyVGl
vysaIXiJz/eYKvO8RGcgd3DJAM/wPm9A0m/DWcmSnczOgTjoqkHcBg2H5uJMLvufzmjImi6LYEqq
v04ESDEN31cSUzqUYcayvMFOnI/WNsWbFIa5+Q==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 31808)
`pragma protect data_block
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
WSU=
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
