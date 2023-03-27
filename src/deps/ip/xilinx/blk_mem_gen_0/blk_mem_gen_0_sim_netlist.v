// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Sun Apr  2 15:58:44 2023
// Host        : LTMELAII running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               e:/Storage/FreeSpace/workspace/SimpleMIPS/src/deps/ip/xilinx/blk_mem_gen_0/blk_mem_gen_0_sim_netlist.v
// Design      : blk_mem_gen_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a200tfbg676-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "blk_mem_gen_0,blk_mem_gen_v8_4_5,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_5,Vivado 2022.2" *) 
(* NotValidForBitStream *)
module blk_mem_gen_0
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
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [3:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [15:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB EN" *) input enb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [3:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [15:0]doutb;

  wire [3:0]addra;
  wire [3:0]addrb;
  wire clka;
  wire clkb;
  wire [15:0]dina;
  wire [15:0]doutb;
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
  wire [15:0]NLW_U0_douta_UNCONNECTED;
  wire [3:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [15:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "4" *) 
  (* C_ADDRB_WIDTH = "4" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "1" *) 
  (* C_COUNT_36K_BRAM = "0" *) 
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
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     3.01735 mW" *) 
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
  (* C_INIT_FILE = "blk_mem_gen_0.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "1" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "16" *) 
  (* C_READ_DEPTH_B = "16" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "16" *) 
  (* C_READ_WIDTH_B = "16" *) 
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
  (* C_WRITE_DEPTH_A = "16" *) 
  (* C_WRITE_DEPTH_B = "16" *) 
  (* C_WRITE_MODE_A = "NO_CHANGE" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "16" *) 
  (* C_WRITE_WIDTH_B = "16" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  blk_mem_gen_0_blk_mem_gen_v8_4_5 U0
       (.addra(addra),
        .addrb(addrb),
        .clka(clka),
        .clkb(clkb),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(NLW_U0_douta_UNCONNECTED[15:0]),
        .doutb(doutb),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(enb),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[3:0]),
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
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[3:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[15:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 21248)
`pragma protect data_block
DV7r5a2g7+0CU8MKV0I/6XAa7/TjiCLLU06QCSUtexhPAmREc0s93QkogDWguUmyUQmmsHZTUF5i
rmXbYFMyYtYXavqsXTTIVSGuYjyNXrwgf88+OxkSvgne36GTpeLBcotitE1phSw69lhSuYHIz4rF
N4DNhBnhFPD6Ati3Rg88CtxGjrw5M3SB1MN5vVYGrS+z8x/hyCei7GGhKRyRWlrDmAs/Th+PjJf0
FuPZrz5oA1m/tX04GH9Q1cX68O1WTH3iu5nirzUejocZqgUZpL57j8bRU1O4r8stTwIJVj6xciyJ
PH/28dYJxzCV3+VG793nu7m6GHLmZJ6+WRM1N0V+fTvAdGDVDo90NJLWXcaFa62wX9BnMEm3Zicv
gC256TH6ZDiBIAYow3ngm7KkUUkYzpzKkeMp1oVfKfkmMuCSrkNFJxD+EutE2DMOz0OF4brmfILM
miN5cUEqA8zJJZ4qjwbicDgCVt1H71fucxJzaiB3dN162dYPKi61MyIYLouIECXPvZzOOKzaC6NJ
R/4ue4jE94Rm7kpRYmmliTV8xSC9gNzaMzEx1BJf6Hjmlui9flUZ9fUEoA9ETRmcwUbvK32dgpB+
OxawBeMVmeG0waRx9QgXrULeaEaoo/fU0aafyAd5pKMAxd6N2alafE3LVHEVBv1ohFrq5lZFukPe
xfYGgaqQkgy92O28EHPqDVsqg4uAJI1UbEUzAar8bq9CepaEYKOAd3SCXhf2jmHDacF8uWi6nyYZ
Sc+dE2vSJHe5ey19+PgkjdZWlKn49EpyfjDQG3brHLLIG19xKl7tCulNqMqC3CwMPOYNmiivnhG8
ov4prhdViIl/F03B5Cf4CEFvZgilM6vdDK7xGaxiTUYEd6FIf0gzQ6KQi9FoJIO6t3kbCCm+1mtE
RNpF8AJ4g1nX/hHaJ8R9LIcb+2p+bY2g0TJu5dDnms6+zMf+BAPw8mdlFAmyU0QSbX6UVTvjxmxu
8odigjeK1SgcITOTMdN0Opbxt948Y8fP1dl+SRMUFOldYHDeL9bRuxljtOO68flIMswtZSBAl7dX
HwIHSm4HP4AOClkk29lf+ng5+Pe/hkQGbJ+v6ZxkQUPupg9rOs6fQfMfPzlS5EkM6V6QggzmPGzm
dGB0R2aKZej/ER83tmqJgxkfKh6Bezwxf2iK9hzuRVhBGKv6OQ0U3Tm35OoHGvsjnDMqCkYJM1iP
vdrTnPTaNHheQypRhPOrJYkEfsFo35WoMovnGU7fsq5UTwSTks1QclfbWFUx3xaEBhhhMBkLvr4/
NRUn9divXB4rIdf+mvWcDPYLlrDoYGD2Bsfsat/G5CTyRxYEDbTVMLRFTvWJcGGsj+7s1ERNriw2
nuHkufQvpZGL5d7MZXQZHDXm+tEGDzSBwAjl64TSOoI+3HakVhs9My6TzlXn8yBJsSOsJH1dyLtW
5SjH3Xsji6RCOnR+GZghWRPL2iWnaZSBFovArtOkxlRbrE7aBFbNgpwdmEE0nLiInvgQcAgWfYDE
MtSPY8r7Am7A9BVizROD+pVmv/YjBh2pQj/nQZ4oN/+gY2pHU7hVNC16lyh92E0iuERso7DhY+ZJ
oU3EFUNw1tejId2Pa/qAHBPZYD7KBUDk20jyQr41QjaIloGaaBON0+F5mFCOIMON/k//t47UI+0M
ysALoRvQzQPzjzU8S7tBdd7v2lAJyB6lZ3vGPKCnTiKRKKk7DTX7rGd2azKUo/FjTdnnk5SWzekh
CbXwIYHFDaIph0BifHTJgUi7eUQjnyPYyDjIlYiQdI/HCwhntcvXQ+EJbvlyRy893Eq0I60HTPhP
2qp9igjUbbxvOgvOF95veZlywSTS7Wgdmpegzgo5Ejw8rUfL4/PoKQaEtAwpvpOPEAGRpVWgDLq2
Ms5j2sfgCeDytZ4yPg823kMDdjxewZ04GugNFaRLCsn7HSs7hdnDYBioquGbfPCDoHt/SLhc31Ov
wb1N8OL/YxUTJ3TnWxRZN0L0PM7U37C4jKNBGpRGA+UyLkGO3bHFeBMiuQ8+pZdAdzIHGrsXNaD1
5Arxbi/oT7xjLER2dbIDpsVdaC81hwIVCuMzAd2bEGgeuC7qJf+HQQLlKXyO3LKAh873qGXYeiw+
jyWdvGMCVp8LDdw0k5C2hIqpEk9NeNU0MGbLWR/Vot4b57XAIJ3pZgqcu9CkNu6TCSkMNePZH63V
Bv3p629sf0ax5AsV3tdXbNpaKWluWeQktvCipcn4vHrnei01qb0KwFXlogfrJHvQpwciQdlkoIOk
xkJnrbay1e+Pg1amCFv1k1LXlLM51ghjx+5la1aHUmgx8kxND5uLXq7zWHYnjAbgc1FxJQbnzV+a
LbtqAcpJ3z2LBtUxMMl0iSpep2Yex+MfvKGnY5M9hv7Ubwb5tuoFmGQ8FsQyvA/RDB+Ega2fRYg9
DVLC2AxFo8km2lDm+Vz2AJzpGyM2fe84JFHNci4XjXBFcdrfgGnhi+AuYWwtI47FURYhgTQBdKBo
Ql7PeUn9AY3ZMx7rP6kRGU/vGnU/Z9jLyuJLHY5Fnb/4cEBwHRVZWNq6cMZ31M9p1W+MJm54dxya
nyr2BP4QGoF7EXDBovxMKWTVf6OFvZ1FyhIjUOtgFhRcW9MwHinFG0JavDnKzMx1//6uhZhMH1JB
fCr5CWOlrRMq5/Z1ulmuDixlO0iZck5pDjio/is9R3NCDrvS106x8xxXekmHPKq7+jAvOkL7va4Q
APGZbyXbPr6XNMTLbtQgSoZ/Bfm19ssDazacKojnW+aA2f4n6oVdMIi1KltpLgIE5M8gUP5W8Y5E
MGjwuguCqdHn830bk/YUi80GMOQol/jCL9auQ0nfHGqELOgxhdyEKtnVrMs5IlDqxcFJxdvQDmPB
FMiKgxD7iGyWS18k4L0Xfr4/5eo727xflYnMRTmW08eQ8N0GPj3kklCZvNyexFLqd8YJ0LljKOKu
tJZKGaBTB0VHoDo+oGdzGVXGfJa/MtoKvOfgcTOvf1e2jvXLUCfQdTkVRDHGr4RlwbXKI5VO9aXp
/IfthDfD4AFsubXolrrhb7PUxY+5YyFOOX4f4eZKZfMtrGxANMILq/KLPIbGn55Ce0aYIzHj2cZ/
PvUVzodymn4GKFmKHi+KPIRXccRf2Yt75Rn1ZXyUoNBgyOc+b/+wL+mUjN32TqSCRll3xUFWwl/j
PRtTmbqW9sSY9AMZovo2oxQ4KxAfcV818he76DUqih+PokHm4v8X2VwTDDUclfh+Kkk2EwYef6bv
KO0se3XhGsCWXogfLeUzVAIcPYfw7IXspJjIFbzm3ph5/q53G6HvNh1xUnknWlz4X1wLlwVKAYSt
E6VO1MPLwRbtKCIgs8Zq/H9jw9NOXOvBVRXhfYXUhj+YGCEjCoVvLqp6bfW7ALbXO1iBB0eAUPe5
fzk4IsWdEuaQqup7mnMFSTQ14egowoRpPHRUMTXesVwaXaK9pvwoyVHVOVbXINdyuTEGobN2F7fw
0MC6/A3PczySHTktVHQ9Tt6lzOOJr76AjJBOvbe7cFfSL6UvXpkhHxN1FwxNqJYf7bPGgRKueMmZ
FHOw5i7QOJcaULFjSPycXHGzpMa6qvzTSyiB8XhYEgW6CLNkp/anX44+OZ9qgMOPZHN5Cr8/An/t
Bu2kZsOfo95BqCuUfgzhTIF4Ji6381XVe30ZlHYT2eOQLjW/NMK41nK0LxiGEu9Tr4WG4qSDqDSQ
LpjpUE/nbJYqRua5XUq2DrmeH1E7D46BxzcRutwvenW3+M+ELfxXMMJ0n8mDCCgKarXFhOIJNuyI
CkXKneKycNWPUXu2HjlBc2HGtzcuDGkqC3KyjSdce8oo+Dx8QladoL3Zb4pUW57nzxKAB0W+OOIP
gU9yFuHdJSW181LpOIcN6smTilltEwqMH/5BC+Ofz6j/77F0IhCuD4LlMuFWFRCEn1ERDad8nKC8
kowYpHhiLEnfHyCe6ArdPNi3CI4387ZiG8BStVt9GDJ8YXDmknEd2ka180mW7V46CC4LJ73BNfhM
B8LdVhZivgJX/spuOaELM2UmhZr4xqrdAYnIrc2piSZwVksiOuSoTsiw27U9eaiCOhlFY1LJT3bw
xm4uBZ+AG5jHMlRKD7UOSuYZLEV2tNysYPxC8tPR6vtH69fZqxMF7wYzoETke7vOFFoXxZfMmGD3
+xF1d30jL26ZwELWrvgxDHcJoz/p8sM3NPntOlarPaSKMlb6EKI5yBAROsMt+lz2IbxypGT9CFwY
97l8Fr6a+Y8ku1gJ6/XSlFWwtn54Ht14lY5AK4ltbolA1LVn38Wgu0jxgpkWw3OqsbjAcIjjYXjr
u7B9ow7Ih1xyAMznMlhJcGD8wQ8wu/G/3ZzAfOv0btfibVFnr4us5NzrRq8R/ptRycqA4ITM1xCG
zVYtpmx6k0gdEgpJ3sg0PzD1ivRi3QO6aIhECaLZkFQYqS3N62AE2V4gEjYX++x+o7EZaXAlHqjW
Q8WiPT7sy9LaEJIQzPmo4GNgkfo1rL7FTmJz3/g+TjYZO0/j8aulg2C94Qm1xoZ0QRTVHUBbNloF
x1BTXFgpnwPBYg8rCWNX0fSww33Rz9aWMY/JyMKkhggG5X6l7RWiQYYt3n7h13JOqJHmwxFXfOhb
fxlPfRn2SXfnyFbpe0i4uMgWpqjUuBCRr52UVyQYwlK77aV0Vhlz8soUHhjYfIZaO8uZ5M8ROk6F
u1pu9fF6BQomhzA85tjsJTcaEjjjBShPXugB/avM1/PN0lxZcjwgLAc9CT+v8cCThxH982J0Jogg
xJrROTkbUgwQbf8zH68T5yOOevap8Lw0G3BjCTqE2i1Ih+78sB4VmMj2qsdL+GbJ+uwpZMameywi
5m1LNJOqdpRK1QoYcrEhInA53FD6bzyNzRB37pN3vuTLUf23F5NFjS/M40wyN4DNwHe7NWJl2v1q
VdZm8cvmrF9B79E+kG02+0LuWPjNBcibsKHgQBdQ9krizIEjqfBPgno3d5ecKkJqV5BjdzsudqFf
fOpCgy2P0psMVcjTk6t34F1g/oqfNX7uJqZVlpwqEecu2Fq9cM+B8sBTY1ZVbTGbehuKgWIISo/l
ND/St9eGqOdOGR8UX+BQ8+MRDg3Ha71hB8lggKrabeFKGvJ5I5mWctI0+TxhXr0W0Zs6zA5vaEW0
whl+9Gs/cy9+C8Eun5LpGPcz988+y9Woi5XDBXF1BwHQOxavMn/bnr+JWtbx+JDakAPQQY4oPiBo
ukH0cX8YKF9Y/qbn39hzJMRRUIeqeMyXBew8c/zWdcBypQ77ozyVLGtwO+hvXk43QGr9enOK1m8W
GLYIGLT4j71zRsYspm8on4b7jitLrpRDmB0su+nKwvgXgWDOo9U5U6QNIh2/my1P+nT/HGEzK8FX
qLWxyLZcUxelnPmNTKxasHxxQW77GneCXdzwBBuc6rPlQm5+69SmEwRRrZFE8sY32MG9NL3tCt4r
TUxh4H4bVFwlszN8kNNKwyjo4BNzdDbUCYbsW1CYIQvpGert/Wqk/Q3Mq2OGqVbpwhHpDHM1ytjr
2MmDPB4jbVEdsjkp82pRxCQkxiQaAkXVzX3APNofF21CCCCCHjuJNyE7wq9D0NLcSs42wbEhdhuc
wLYqc4R8ugBrRZSPbKwLfGWfDmiRX3Gob6Uhm8PPUVLYq4es9VKM/pr17bz5JwxrdY9FO1l4ME4W
rIn5SOuOUGKieMX54PszcqycnNyUZS1fZvUKvqre2jpmmyrHyDpUTh7mzaUyPeKO4XBCfZs2D2Nb
atvmYws9dNTACVT5VrpZB6N1dgi5GjHjh2hQe+ULRcZTwDBCxLtj0Gl9fvscvhGDhpfpqMDdvCjl
mqASdr8uTOd2f8QA8JBhjtoxhrBBKUDx5Scmi8I/0/hPcUrLDMJ+qLva+dn4FJNdy0IE4N2QWQ2W
iT+puTL9t7Z7cL+lAQuEVbaMhcL7v5ztsYh5KxF50fpq7XgdwvPinwo5zHIxGhPNBl35uECTSwx5
NiR+lgPjc1eFkfjAWPGLrbx80yQx0hlHu6RvjrqZl8zUvuJTBlJTktRdcCKKOHRoHWabXGpwcaSA
AiqF+MqK+VYO0a9TY0EwYI+u6lxc5BX270djE68AfNkuZ93lxBjkuWJ2aT+7FB/ArG6TL/WxIu26
7CejqXf8+/ZL7tntUhfYKNuRhxFSJ1V7TghvCAC24HT92/62uUtSO65TwPikw5e2Sale6HbPsZTN
LuSI988MQLF+003wQicGSm+hG67aNXrxjCY/QFY+Ff43JMnDL0DJIylm/VE/+LcIbK1renlV8jGd
eCb1iLbl+H3RkghBwUZaOE2G8b2rUps0oLI9asgSeoI7EOellxmnW/H0MiefAdSejJfP9JLNcm6h
pk9P+gSLoeWLsjCWbBLxtjNl3ilRaghSxsCQDcXE9SCO3bmUwgsr8RKC64ulgR3YGSXKKrZ4FbMu
R0I0nnbYt9cUfLs+r4iZOOE82+Cljvwf4xSGK2xFb5yxxwlSrPxgpJgKQfad40FUlm2j60hYGajv
auG11+2Uv3nrM6GAyoYfAhYqBT9b8YtpUHoFqB/lm/ydehfL+0SvibTTw75owBg/QNNQ6VQ9ZW9t
x+z7HsoqJ7BFHDWc4hBeEX8Ewa0zbhAxy8IReHpxGuDQ5u17VrtH5XQZrg2oYo2Tj2ALzlXBVFBR
SD/e06Ryzbl/BGI7QBbq71ZEwMeygU/xL/qTer91AEogkeAx/IcXc4QpzIxBwC+cNEDW5UB9o8z7
9vX/cZg920xwTryEnH5yad4b/smnIi5PhqYFf3AcKOydNq99epFGYPvT9nSb0vdwVK0K7BGSb8Dd
3nKmyvnzE7A+KOgZlrnIIobagplP+WQOWLtJ1HXYZetEu1eSeTdSwdmd42E4YKPC9qImNmvgofLF
BNn81c8BChrDy6eO7Puk2+S612eH7tjqBIVLZVymY8c4+pttlDW15y9PMBMzt3nYpa2eV5Ytms/X
R2Xm3uOwkQSVaGzd+yZp0n+yTBhuP57EkXPW34S2TEQcY5rW+hlENkUEc3XFuXsTxrWjRxugoHHj
sRRhKW+G/fjX0G5aE/FTevPHhKRaLDegTN2LxcNxTwO19UuMNH+8lTOC3ukc656Brh22tMt4HS1o
B/uFDeLX+GlZYCte13co4SPyx0RVYqE/fP9RlnQtf/AUbCMgOlTl7uBCvDVJ7bHsj/ZGHjstcswm
9nA3SLM6ufSx8HYz2z3v3P6Hl4t/zArk6DM7klxYfVWdtXu4wzrng0FuSyKOeJeNpfyAzZlxSUGV
QsJQGlQAjXhCaX3JFVmnBUWSrlGxq+3Uzivg+D1XLr4ZYjfYl/9SA9c+rIKH7oDmtMINdPpXL/e4
pRrc68x6VFLz6EcN00EbYboKeKICnXUFaAIHpjDeHTMEcy59tlKjICy2FGEz5XmEJ/x/BTGyNnB8
KviarSjsjz4RxZuBZvTiie4BLgdhgoDqrPwMzPUxGcTLPhl9Zo6r4r17wSo1kdIPXfaga16ulhFw
CMmApSdmcLMbiNVAYSR2iejJmJoq5XcUiLGMs7eOrsexWDOAO5wPjNNs0Q1yzYN0pWUEI9Xbk9Tk
1H70BPSDqDQzhBKREaAzaqMs6lWJwpW1HMwRd3MJ/NLBUyUZFG3FPaw8eyn6LRyK/H9G11DqxpEs
BQ1tmx1vd52Da3uR3Aid3S9ifCqJzJhusr+aiTZAHW7R9R75Yj6J9sDPVI49mnTtOAiEs8NlXGWU
bkgyXdT8BJbK+W8LXVoxfgAZd2uuaEDO/4SqLCshS0Eo9TeFJDgd+NVEBazjLVRSq7QYTKeGnfZU
nwEv0sJZfKrnC3Z765nviZD+BWkSuII82v2a9GCnizkWsTqbAaqgMdoYMSzUTqFzit5PDZvxpi++
QoaZnC/o7xoqNpRAncD9SypgGpBxyLSdt/r7FBL45kzsArNRYUajHaq1ydUeBw300F3M4+l3LM9Y
AEUUjg625ROS0yfvkL2B4Ksyi9ULUgXH1pz4juGhVh/i0ay62nXTErruHkwWWw6075TSjNNiklyl
rQCnDjC7CJOizIGU7zDurwpKV1DCxChhbLfgggn2Z3KkjGSqMGU/TahntsCp0Lqp1CZHEQId1Z+z
X3pEB9iieE2ck+CpKkNiabBKlpoK28v/HOymXh1xOXxby9C5DPd5s6TC3PkEVeY0VyM62YUqoAx4
soiY9KPrRCvVU9dD4p3X7GlSlv2ueat6gmDE0zF1pHSYawBAZuY7J1phsgjdtNlNqhevyaOO8Xnb
WCJelHoX4zwW5Ro7LvIuFlm36uyHslP3ZjYp24xNd9oiOVgFu2u2vYmMgFmPNNWLNStjXKCb7X1j
dli7h5aOIv5EVeauPEFXg3/8UCzoVxJyp+1TfM4tl68dn5AwLmKOAL+VWiMSAZLYTsAgZGDU7++3
ZaGTCgRD+0puflShAZZ6wvwwn8MKlgaqBjXnQznfKtk+8Rdr/jWY2zWacP1YCHgj+QKlaIqe/VBj
Ll2EBJNSoQMOGeF5jncuZVUPNG8aO29NfoAeE75a9ow+5yWlawJQijKYMDp645OGS1PE5cfbIMCA
w70oTmUENiND4Y0e3c0SexbjfjdyKt0cp9bdIJXPTJVpeOz6/hKBK6D2nyz12fQZKx8s/pNuUTH5
0OPd2E5FTZebS2WjTGqUn1etmDm5OD/JE0I3A0Ylc3fKIUcI5IPc/LOTd0pEDcOyFQ6bmyUjqSeq
oCQGEkVKU4kiDXRvuC6/uC1JP+vXIHA8btolwYskk3NrW/UE8LhdyNOF0QWwUwKaKbw0PcbgL3tL
IukniTzeMWFwdNWDgLtZBth0TOYMoELRzHB8c3CWUO4JR3u4XHxF342cALEVrmuE5dRQ7JcgLTm0
V96Wfyu48Sk6hrofdrBssVX4mEKBKH+JxPqlM8XxIOxDfEX3J28UteYW1YtC2KEre3ww+BPnMJlB
rCDDFSlp1zMY+fu7D3qemSiwuATi1r3EtsVYI+TOVdBoDiz+7ix3r/scNQraTco+KUoDk21ZLIkm
NhEqiPjwva/frYaEUq5/L8QgH3LGsbjKBLLr798S0nsTrb3IUAhYnPv+RNB5Jzu6iF9fQvmqDWlz
SCO+a4O74CRXBrFNgNackcYPHBX7FibtLE2VjZJZxwQrqiqnLhYuhtf/JMythyLQzANC1M03gYzS
a9/f1xIsdioD5ft5iMO89SA6QgB64tSgk7Rzl8IOPK7TBE6e9SkVHtmtTtXqAElAfzprn+NkOlEl
7n/4sksj4bXRxvy48cuo/S/WrZyIVC8g1JUugX3ZEkCjzOcMk+j0FB4zX66ktC4zQchItuIOaVKi
j5wxCrLH0vx6pwAogtNrWJhLC7Zw4jl4ggK+wijDmB3jWh5ILZvHJo66JXCmnZrvFbluOt2HSRGk
DtP9mwi/yC7/dwIEWHDPKJdQf/fOKPnMNEOtK8CcijpGztP/B/yU02MbjVIyYply7gCyLLkaJH99
pZvvLJsF5XcVTPvXEKwhmIHRsdK6IrCSdSLQidqYE1BV8Bjm25TW8s8CCmWz2tinrWUtX4bRC5Bt
k8gPRLToNLq2l4Tshdeja8VkCCL211plW4ceIjoDqz+gnNx+zjQo1dgtw4ARf9dvDOxx+fIFzOx7
4Jz/PDh5OLSJczjAzdI15+ZbXTIncsA5747q9Rghcg/U0J48GJyDS1SqNQN/nsq2K0lpgVUmNtLx
wIJOQ+j/Jl/Zcl9x2DfwwfIxPcgc8df1fzaZfsMxa16UkLxN2YqaRzQp2/JjzjBZuqOxlaGhbnUj
+v9jluuFjP07kE1osM6+FtcbUkyhXpT85uBfy9MOo3/GX6tP0W2mbJPs3HmIJppfE/QWurpYmIPe
eGZmXzlJSKgrRQgUK35iJ3SP4y9x1qYuNxMZc6E56lpUO3XV1V4hE2c4O26jd926L6isrjCFP1xg
Ldtn3whHwh3roxzlTYPCNfppG3BHf5pWAkrxzMSOU2aV24pRUSSuFIaVW2ALefqedqWf+RcmhJOf
TIGC+Y92xZrg7WQ/JQ16CS0ZKaluPlzoEvRuRfwev2Ywk8+v7nBQhKnH/8gJrTBWSSFVLuK3A3Rv
ldlFfiF66YbB50gSUfU6XZEP0pLo0Mh072TDNOVWK/sIXa6mCFcLsmq6AQy7qCjHtxlGLrwsCI52
DLBLKS7SKaxGy3IoBucxmLiCdetulngs1XX6sfkZs9ZQui/WMpsGPvzBtojeGckYCTVgfhG3+2Al
L/2l2/TVfyAcpOqRyZxPKCN04eQTXTHf20d0qcAS9MFmLaYEdJ8+ygtYtuuIYtOnKLT5Xd/h2fne
c/cU0gMz31mL/DRFg253PqPYBmZ8/QKM/snvMLhRegfXv7FrrZv8/1xl0NsuVk9RurEj3g7O5DZd
KnhI2rLFd6hILVHMIPbL8Ff7/dzm5I49yKJhq0GK1CrH9BSNQ3SNE8XnxyjrP8BxEwGvCAFTGjDL
xsDFdkInTzCpzMg4qPac7EXP66A5IlZ1rQiNoRAPbfNYtJZhe8+1sVm9Y1EaqBwRpkLZBKyFUP0+
IWeCS8rsWrj2T2pdkiJ9ocMupgSDV6L2PHktuVkXeLCE7fLfpHNofwdEue1MBIm01UzrfXBtHOOQ
dcnZrGrrTVYpJGqgvaxS/wRf30N/TvStZ6A6bP4XFMwQQ9nHhaQxZ/WphUznLnUChp1Vuuav9HbJ
6CLv5zb7Jw9vv/6u+p3ses2oTjLaS1tIR1FpT2WcXYkJQmMB6e6jsuLdx1fdGdTaRx08EwQBh8gQ
wqGOTdk1OLRoq45NXzoDHDwHDlXPjzP8llpThttLUhkLXCS3L/+Q1dSW/H+Yo1mMMR5gAw2x54dg
uS0wGMjumx35zNooNWDjpeU/91KHH3RlCxgGTmfq2yYIvy3olAs4fsXNFvyWCx95+trZ6dFUB0Mp
EIuLPuukNfM6/1UojNfJ5xzWKK/YNXLAyz6RuGIOqd9267EoRjBXpv+H0oLspXB0yMoCyf33s8+I
84W6i031MWeKxMNp/gXGymDskMfl9+Kcpk+kRRRKkXV2DAQaVnxmCZ0u6jY09AtqP2IbfgD+EmX+
IlN2nIZ1QpyhjtlQ0O6lAZrHDTHIDCV6THZlROFVECjMsw8BM4DZOJJty/AFfoB5PP/xOoQqqHHu
64FayuMyHNdg3kKpECXHs1HkiQKNp5LlvtoZ60h9Iah+0GVIygVVPz9dWntyaWR0dKS8SalBJG5V
2p9qCZ+UxrdiSpgQVr7xlx3+N4JHRylei9Dj+yUrU2GUElrasn8Zcsdve88cacfTssAzmtKqN0fQ
DB5vQsYgmkE2azKusnbjP+AZq1kOGKRMh6EM7T50jgl7Jnai+KXBlzA2PVpn0qddeAkZOvuKssHt
vowQPYaOGun8lTG2oFlX1ARgcmLtKDc50NqBK0L0Sch4go0u+var/PkDL8iGFum2D6wKKWV8NHAD
Jk50yshL9GFPichhO1hgNPhYj8imNbaB/sMp4PslXx3uO60PsstEAMv6RYZTbbd7eQD3MLkppgXT
pYqMqxQb+6YPHNef635vxWB/Q7rvpQ+4bpQi33G1FtBWgOHRWow8EQJ6BElVHl7CWVP0+XEcYupV
IdYubNJBxTY2OXCFbElRd+skXA3yCl7F7yxKQoWUnR+81fSQhP9v1H6oF9XGTgtkRopEsJ4ND7Fh
g83ypQrh1dblqNfNfYjcCwZtc8BecmnITgXHTDO+/+9Qci5xvX2tKEcXKya2GFWfhTk/TfJ87PM4
Wmsi+lXJP3emWxyr15jFv6uBEd9YTgGFcxiCDp38du53XFdt5hzTHvMqBJVR3SxnZehaC1q41V92
sI/IeKF7uffOrc++ftK1Qro+ot0g0I4KupQV9eb3ejAEivCi/j9+L/zrYomZNJ9dE1km2oAuVJYZ
0v+A4YUmPNB+oRS3nw8BLDzFrKiyaVVDKuR+XZYzhrQkAIxvnbls4h7J3Bs7UD9LGKO4OnVuU20R
eyq6nlZ2jBL/m+8etY4zOy58MKFzl7Ek3al/hA9C1nWwd6utQWAxOj28TuY4h25+ROTFDiDlhaJt
TrEYZL82TXCMe38MKwpIoFLmzzZPrEig6gSGzOZyV6jOVtG73/D8IKqjgo4Dk/bVJm/9l0irTGq3
wJmu3oKbE5JiITUQxLLa09joj/iu1dV9uANefq6a2TKi+C8oOtaUOEqYiHNVSrH7AKyBrMha2hRp
0a3MKkHdPLjN5GEYs0vteoOhC2IHRNyFxGm3YVuFIWgTv2cbkGvyPCWLrCM/hqg27dv6ts2r22r3
smQboMFgDY9lm/DFhgPUbuZJsGRud9iQZHKzDyc2VsfCj1l9HSQZwNrZTmRLPEqUz5WyfX2y+F1W
QPhVQpZU22zXLrTtJqDcRkHILxuun+HtTqIwatnCrFnLHrl//ii6/S4J/p+0Z+E/u2MtepLDL8m5
mbeai+gb80zA3GZu2hZC1xSjtCBm0xpJRomOkCM2u6jBJRd/U5+GuQhbaT4yK52xVAFQenKwKyqZ
mu6HjKGx0yThz/E8nwSrl2UMzgR6Zon5RdAWaCk1XqYPd+x5ZJbbJ+h2lOS7OfBMKpJmTCq/YmF7
wSn5Pea1CAy5+lthLicn6wwm2kIqjpUsyLGslESG8JqW0R9K4sktzvzFwO3LerCxMIt3huR0nhFR
jQLBUWaUrvzSbyAYyIrocscfEpw1SQ08f1Hjqe9kGajVNZWs0akGHj+28GzBeIab4StGZqvBbS0I
KJ9WzVaPhy/89WgYcF8AcioMzdVf9nGsfnPq99fFJDEpIL71Ie54pIZ1A1RpVJ3y7Nj3vjU5rvL5
QIGZH9Sjmiis01u7F3cDRbw/5274welrb4uAt1KAfNMfDgbOQlqpn7LKIw3rEY8ceIV72idE3R4d
KZCsa/PF2jm1KUBKwlNi+YNcx7wILenakXYCmx65xe5JMZSjf5oboCDeJpCqZseEoNgHVx70zPJL
KERLFfVLBkjJ2A38efx3J9U5lpQtaSpR3kT4js6ciP3JNsxsoFZ3VMmngQlVdxVRn2plemX7Q+Ht
7TGh3hhDd5577cXldv7jw0kOhSX1BTjfnzcmgcgesRieCqYY6L3gA1pJ+2pkIEd8cdWts8U60Lzs
+IBeqV4nZPUjAtZLlxGtNpvh78KiC8e7Fc4C2xkLSa/2xjy5DC+ncaku9o37Is8kYR5DTQT3q/qd
lDefyjOSE+iFP+6G1TbyowXD27oRobzjWS1fSRX9IgdxW/PQU3/H8H9VePjaknq6OSFZugjIb7p4
6xrHFAK0jIf1ut1yYZAfYGMLzrwQw3nopi4XSvpclvz2cQlvwpxO5jJ/Ydtp50/M+LIWm0rHGPhU
J92Oxc1GJ9CVXauCEoLf7EIWPZCOnpHuR6aT2WSJ6nxgeQh6Ye7nKOUt9Utrwx/1va7fuUUGY5s+
BSEV0LL2/BZIzo2CTzTIe8iRen2CBvH1XEayvblCc3dfDdQkkO8Ro+oQQ751dItjTE2r/Pb3VdVg
r+ROa2LD2WzXdJYglK3SD0ygiH8RW/ypo+zsp+F//ycDlecC+6TBCU3uoRe7SQ0GFiY+puKjYPdk
E5Jb/t9mVQCXI/E9KEU7FBbYh1ocT3/NUusAeZf55O2bHcZXkt2vA0OvSaH3EKIb5DzVCKrDHVdc
V6bMI4Z7BcZC6irsS0LvPZGtjytWCjtp7tVv19Y3kYP+7nOkAakOfjyPrzB+UO9u/IzMcdeKexo6
W15xW/uJonULdDO2dbX9MSWipxPg+bWX4afwCm2MiZWrS/7Wui2Dx87wQJc8WZJrJolNiMvgBl7t
KZYiW+L0g5LigBKJ+/x7FOg2R8BbDjDYQyBMTjk4fAFHCS6uismUyjXk1QD10gxzBTgtOqMMyDmR
ap7KGcV82YvuU+wnk3A8D1IpczeEWgkp0ntCdZDyxqcvjwPE3M4ZLeHujKaXDufLQbudfp+pogy+
vg3lGxcCUZgC7b4ZtXgtiZaJUwgHRzG73a1vh4M5krJsgY+8I/Y0s0ipUNnA8OrymNN2dgNokr7i
ppYmGmB41Yy8uFxlEQ6R2KtwBx/u0kfZ9gx9OGETyq3QV+RL5wTBPoXyD6qKRPN8jSVChid1JAYp
jnra0Nnw3NmgFTv5BfEYlg6woxMg18q8OulaXAr6yeZZTWc4iY15SlNuOJ8tcnjvTeWWQWXjZaVB
Y6CdBkH2XauQDylTtGLKpdjCJc25YZljx1pgZzKg6y/dqPXnNQ4TbI+GRP60z4C+IbzhJ2FIZ2UD
+flEZwaW2nhHgs9i8KiRva2/JcUkeXY5WVxqStRJpgiQqv0qDFGdxW5NneJNDm7bsNxDM+u5Vbpo
7BdYKxGqegsbX8a6I70G6OzDHkbMDPJaJ/gP3Kp6768n689oyEc7MsrTAZ7qbcvp3vktDtY471S/
fVIQ5J51/LszuSUOFC32yp1bUjTytAbaauXeSseV4JJY8eazyS4VhTwXuwGV8SlsdtWDVQh4KB4q
5z5ghgsJCidDKuzb42PKL8LXcQplWl6o/uvN3xlQP2PxlpQc2yPTNs3DFbYuPBZ2RWwchDUmJT5a
dXTcQyqQlycCwimw8DPtm01p0U+IbahBMvEOnPVd7eGSU9VRZ4j4a7qzxpFRrEHteUkH1Xd3p10m
7VZ7UdP9qalKmL2kgZmLD8u2GwrB2SZDBNivIaqi6kIFwhtscyBJF5lsqeZX0N1rakQZAP7m0oJ0
6rFsG4eP4QUwDfd1H8sHOxUhjduZnKXSAXxkFWZLZJOQiHFW32ucJOfPqFShiTgm76gK80qui62P
Rm5ZiFlqk/MWCrxwZxFifju7veIS08QTnm/Uw28uYsNCQKgL5j+hncBbTKAxD9H3hGhXqap9XReY
y7q6S96dXX6qQRtWF5uQwOFNfXe9eJ3R0G8psQ3lB5RiUgYxg3f2k0+jUcz2Cxmanb7BLQYRxlSX
ipoVcWl7emfF+MXz1vzu6KYM4mf+sJTOqTnhUzZyytjQpNY6/rryTCLqotW0Vm2kbfaBFZbXquoI
OrnrNWMo+xA+7SNXWPtaWiaLL4u71VWQ37RBxR0UTJAOZvMRYxaVEDMK41pfO9xYkMwQBOnOl2aE
ZIZ2H7oOUyRf7STpVeU0IYtWQMVl93wt+pj3QDLCWw37WQX+h2prPyCtvlKVxr+BjUqKXAzqXOeo
3jz7hrOea8BSPs/PRZJtGACvfDGs/5YRHVVZxooq9VQGCl9SuWIAxp++S+Dc2e2uZbXICwGZml5r
WII7Ld6n7T5HtUokVEDjh5xbK/Bd9Ys1/Nd6EFef/ai4wiUkEojFE71MX73caRHwjgWY5RQ7bHgV
cR6MeGJjF1z4mskENBrSohx83hMaUhnq8tQfiE148KIx8d5aSvGnEJKlEZDXJcx46hWLke9pRAGr
9q1kO82aYJ/ian4RwXfJBZy7C2vYBGThwH6so+JtDoAkmR7vL1OqQ+1MsXboXvUfEkS+0NE6MdKr
vxgfC6YNNa0Bsbc72OAoT0yjOFUn8Tc6g9ANgg6agHaMpAnokAaWQVxXwH0J6D5MQ9siS8NVWPeM
4N2lHWbluY27sKIn8wldqLd/t6hJJ7Hez/FKJQgWRiXqfwvMUTL8LzXFaDhHddeSzfejC8IR7kXl
WY17aoi8FEQfYOiFmarwgV+PYgEXrgYmBgtg620Hf7+VjRKN1aDLNJ59dHiJez04aHN6fhogssty
bWX4G8gUW+SUKo+dj/8P+GAdYtmvF2auF/yjG4kJBkr3uSeu4T9atHcb03HJCZBX6A7l6VHRO/tl
MCcyn+2bxTMi1zBLcPPnXHY64NN285gqc16/YGg7yPCcJbTHyEVWfswpSZyaiEzjbP69jHHcMUrU
s9htaods4LWnvEjIGsmWpf1zdTx53qV89tFFfWjQqVM4PY8oi7+R42JjJQO5k3HA+nxpy4wGcpcA
Tqv5ulWjmbt0tRwgU2Eoua/sL8caJJK6wb8bA9+s7ClCHAu9zYP2+oiqMIL7tPlszyzDBjnQrDRJ
0FGw2KDLU9pCmm5uL5Tec75UaUTgbgHRsAX06B58JPunb1xprMM+B5G7PM6CUcMz+/mP3hWw61Iz
jv1yBc8oEb39wt+J5YQ+sI90+GUgo8oMznd6l6/xTKBTQ0dGItF/zxizMsVjUr/WysbaAk/wpNCN
4Xz1xZODFcMS+cEz7kXuLB1g4iHqukiFDJXUAjPHk3MdGqxn+DG/j01ZoiCl3Y/FUHf7kV9BY+DD
QAUPo3NbQSqcmyeuuQ/87EokYIsucIClOomL+Ky4YWNXr7p1+IF+0/54qZyIwUHi92sj/vFDT88v
8754PrU7V1lgrWHFV+ncioSkN+nlEXCybKpYpwT7y+r3XfJCNxGsH0t0kKa6ngLydso0JCAfaxLl
U1rS032uUHKrKd2kSauVlpC84wtAaYRm6EPF9T2MKxp0lb5NkkBhc7Onht3UO6J1B0Ac6Y4NktQg
2+KJMD95Xb5S2bBzD93fdxtzjOOU/Cgdjo8wy4YZUyY6acPofFvn07Klzv5XSdJwIs+wy6bGM40v
BWnyJNeIu5zXFXTd2u+U0BU83ZraMS9PL797SavaLwK3uDSmCuMwGN0gcdX2MqycrJ7CdVXpTAJV
rS/0ID36SaDrh/JaK99SHqgjhjOpRphUWFBy/5nlnjI/8J39Y1kfIZoAUnXs0ynKlyCFYYNtoY8p
hRN6vkdbQOQUrPelRLrHYJWeFwxIddaqTsjGp0T0/ZT41xE9PeHSYXBYjddlKxezXxS49YUVt37J
WFpT4k1wdo9xvbhp5GwWIB6uhP8bUNtMzlM6VTscqKtTs8jJ1NveZr08KmrhvHsAR0HYgsm/3s+L
Z0cYAW2U7eIV04W9us+cjifw5fN5xgqEu/RNWZcNgI6zG6cb3+6bnq9u0lI3eJQ/LnosS1Kzw+Ia
RwA9cBFw7/GQPwR0IGSp6StvT1MIQYsd61xWkDVv4QjpqI9pD3Tdqi9xx4aHPKEXnY3W5Uwdq01/
MFjhFGIni9aZhWSYlwq6EaW8LG8smtedMd6KsEQ5rLm3ZLk3jB8JmdBoC0KGhz0rAcgpLcMEKaNl
XD66J/wP1BtsZ64jyqqD0uGQoB5p48gd/ZwkdiPJanImswe8Lurzl3/zbGD4gMufFV/9i1ZsuAUW
h8XViOhsvfgxoxBoymGw8XlKjV+ZZqEBfIHYzam4tKHberBkBaiF8L98cSx0zVCbsJH3FtHT9qk0
W+DazX/kORo3sgNsWzh+2VsV5VCUMzMEnyp2okbJQEMJPe3GOmYHETrGtusZVkH6mKrdOIGKiK2P
f3pl1SrniwHn1avP8zlakYa+nKwD/r7zUZSmZJAXzcWEbEEyAo082NfPBv9zi2xEt9kfxmPjWj1Y
9xdjDZiBP5IJEc21ZrUk8uyOsy78A3eznZi7IP0TljvaUVwBzUgfeY3lOVJgtJKtLdgzhpe5wWpb
SDmMMwad7lVc0fYEWsjjQGeQP5kWJHYiigMy0ObNQEWJVHreMCdMdaUTZg0Ko1BKwDvDA1vpBmbV
wgp0uUY1mSPJ0jJPxarbelyQd2eKfA1ixtwinf8oAb9Q7aJYBd6R49/Ssi2+P6ic+99w2aO0WJR/
ba7fIQwqPagwqy9fnvaZYYycxcnTBR8ONDjCfA4ijfEeh/j0MoDLZqL/QZH8SoCJYE/oojuDhUDy
+lVcawX/oFyBaCb4bXRVPU1wh2AsAzXEpfiwwhEJ+4LQ/JwSwH6Yd2qsCGEqqUxiyQad0tnrk7pF
CN+4ThZ1giJiekcOWSBow6+lRZbiBwDIvFoXDhXyvicuRxURkhOdjVlm6r8qYixDkD3n62Y8gRbo
hC5Ng5b+HzQXyz+3Dd5gVuguoh3Ydu+8EcioodwVWKRmjMl9UI9u4fs/kTlb/VQNFrLDFcCA0+GG
uwfalxc6qJwDKbobhwDksFhb6B24Xil5R4KH2wQC4iD+f8yMrw8ynPXNlCCBoD+phZALYrc550M2
mxucUTPp/Vl2hSYhoahxuMBTx9vNdbPeMTvkXKDjyMK2PFpBvaYNxSI6Vu9aetS6ux4P+xOrMFai
pkEpECHba2ox5zpOxzEJQ7fcsO0zo29NRdo31b9U9ZmmjUhUWkScwrLveDkbR2b21hWvl0hyS2YG
n4m5wUeD495iU7Ua0rmWxE1X8Ev7HfGXt5dWO8EGf2QjLSOtr1HnVx871SR18OLL1EXpy7uwT0yv
NGD8R1IYsXykDarRFYg4LCGrT0kdyg9qxnBsEbbvMcMCUvEwSmuhy4e3c1S2o4HYQolvYUiJQFJ1
Cci3YOLFQCiMYpqwJbCi1jX0DACQRkfUoN7k15IyLMgNmMBTvQ3MFw1F/VxD9ruMQ8HLFbLOJNxM
ZNrfMQEQ4KlmVRtzqO5SnMVcA9T9Phda48SEq115Y+D1iFBuevUXy1ZWzzUjtxalbphvzQzmdMan
KpcAGqwsJG5gx/a1X0qvxe/W3Jxj4W2eaMmU7NoyvqQZp+wNcpkMQYE1fgKkLowIVDEQ0mw39+iM
hFE0tqtjDeRtootRY4Ni2imj4+9jPupv3R8ZzWv9hHVEB/TggYarnADhEHqoklj/Nxsv5/tYGwoC
yQlkk1r2yIr82JvcaqgKQLMsajpHX0OeoIbIY/vt9VkiQjfNJIB7H78F0D9Da5ybjkzs65MzhqZm
TULJCaTRqxB5zDi2j/gv8Hg+uUxLVFkmvhp1FTOQ5DU/QvlWWTUe42auHmU1UUarIrp/T6YSaRZv
Pl0ts8CkPCuCz6ABweCKyjRhPu95CgcaijkyrNRcUCQ3SPQnG63Arjzf1XLw2cZD9PFdQGQKNxCl
Cauj1QUcHstc97JKIW8KPoObs0CmvClcV5JoYDmOQRht5Y0OzZW/v59+DRXTUqvwNN6u0zm1vWwZ
q5HeMVlyrdrJj1nhvZAIs6kvrZP3AG4Q2Xzud/9Wmci1p5CzisCgXcwofXcgvVkO7LmFSSZCrHvp
WlVIWZ08doQtrRz1teJWT6CZiW+ZIOLnJiVeJ/5U6XsG9ztpE/WiimGV8u8Kha4KDR9zenZWmdvG
eIdfNS/FBjo5QUfpb9D92Yx13igH6DEmGM2nPTvIbqnq7eWCQcKohSPCtkL5jWuXwe+WSGQX9eWq
gzSe9QVG/s+JXzRUb7HuQkkxmaA8OcLI7YFWpU34FoI2afDU7WsLaca6VwuL7Ta6v6MjFLIvj1RU
QXYV9jNlql8lyPHficiyehhWP3DZFBHHWls9KCdvF2Gm/ykp2m899/PtI64eFIy2E34VYgNZGVWX
oBLszOgFBwcAe1RMZglVBepUJBkvXcLGK2pU0P/hVgfd0GxyWz147fq3hgIbTJsR06ZrBlDSfV17
nXw0CEDuGBnnWw4dK6J7uVyx0tuYiJEB3Cl3i/z/CLwzFSJ1m3KCo892JlQiJPuZ4lhX4aouBwYq
vzmIHwhMobUMP1++2LO31murKSRpWyMH5BTI4wcGOZUVonDCUnt8rVrMibDcl8ouYzJ9tNXjJE4B
PZojSdeq+bc7JpU/xS9FMvGwB8QjZVKKkRQJLOosr9MAQmLwqmdITPWaBdlmyU/cg6mXPvxaqcc0
w3mTafFi8rk7lOWw8X7n+RireDpDvyD7deS8pCaGE4tDg8i2WbMVBVwi7AeMCxcd2r5bmnyiqk27
cjr5Y+rptWEokVDLm5Yi3NTpLH2HTj/1OZwC5b2YYh31cICLOTJvVn2h2aC90XWedzwGUT9G/STK
SUpV1axbxG0Dqpp3QpUWXUvjd6rd7xhsNPPYuYoCsvKVZeELsKodbAHbfAmsYf4Jwg/2NXaJ73FU
qSkN16cUNInRdsDzsDBTBGCQCnLeXBP5Lht8sR1votOkNORfr0q1mYUskYn/x6IhTvNuo1rX+mdd
PFusWglBiCImvYFDTSc7kBQo+fNcOAfzt8e/1JzTq5nI7ZSQGJ/IvnL1sUMP4UYcJpPj+v4VxZj+
Cc3rHR3ZZPOzSRX3eKyCvHM0WkQFofa/mVXUac+2EyruCc6TmGoLFTFMa1jJtVpCaRlXeSvSkwFS
mpnJ7nBBMtoGbdOGqhhPT+chihzzr2k6M9CbG7fgdqkctrakj0rZWQPPrqn+0H1L2zPG6uCazHNm
YSn0QFdp+KkDlhHOdGnxKZa/qAbeNt5+zS6SC5YJZrGvD8QDoP1jGPXD0EiZxzZhq/7ulCBwTBq6
MlPIX03eeQhv2e1JXdqgF8o/RItdSj8ofKtLIZPwHumtWbMLZ+2ErSqPUII2uoy/PDWG2LN+1df0
BSq+hrHd8ahnDLdnXHskM443zhER5tFDnmfSaQJqbBGdrjaoZP6CnpJbFOehuMJK6kqKHx/L1yVg
4wJDlIs+pw2cLTie0cjgvxCJkPQ6BV4tj/G1epe49owBbO6kyGRh07b9HAz9gJFuAWkuTsGjZ0NN
XyRKmiCTLlFILi0Sgejrigk+6CXfy+NiMK/Pqe/3aaUB9Tu/GuVt5WIAosIcKJAER+srs9luaMJS
XwaradoI1gh908aOD5p/fFm4BLlmVj9zWQPlrYL5BLeS89qMSpFN6nQwZTTQrXqE33Ggvs3Yj05i
lc3ISXoONPhC4fhufXWj61OU2RsxisH8r153oJ+ECnPZBldVK4UWshc/qTHnVo44Cuk+FsUCuZMe
Ont/VYiQP1OYr692OndSxOTfNzeOVj2fQ3gNT2t0H4g0QjBs0pjZ8xRHkEqV0tYch8Zg+3MUbyDa
sPrn7UREmGzpyd3PlQN7R2LSD5p26bkebG/GbHlulaok17ugeIo7rROCvJiFLpYRVMODa0DwZ6Jp
LMmS5PE+Za47GzIx8LdXI1BHewB9rqJPc81cimuMr7GUd9G6eki0buPIjRy5x2QPmoqS+TonhjRg
ZOowVZp3pJZcnHAAMspRVpz1fS1r5bMqT6iw613+ZnTQEU+MikSXv3TK+EeLLxysQgRhNqQFiETG
13+ytnR4RR9SRsv9ZwiXe1r7LxH2GL3WwunvkcB+zEzRX88x9sWC3RFUSoIjvB8MHAVp+/FGGJ5J
FpX3/A75z9sCCDQOAzOhujfjCm9esco2ILmBhTUGgd2VOHCVrVg591C6IboD5m5DikugU/qvivD8
GrLrbgr43B5kkHU8iAFlZ8gYayZiNowbtMUXHEpxITQXPBs0RamSyXvLmV6rgTyUZ7Jip6D/LyYN
/W5P2/kXw+W6Ek3pMgmDF1B/mXHrde/No10F2sleav4Mr/gb278KkXo4cLJOQjsYI870JPJjNgIW
YFcMw2Fk2Gf7xWoaxymWMTOjgd9bBoxjYV2z3AhVkavppjkHNX3btxKPMIF2kEZUKnj0pb++PonY
x8vPL99nbeAv6cQRIvEUez8ilreodtJsLi7c+Yu/p2hm7d9qRPG/n76FCjeQbahWVjNLto3IR3bm
iBdkAV4V6yQ+QHGpz5E7VWdI/WHzfSolM7P+mGKRAjT5O6J3KK3n9q+Khya5qqe+aUPXPbIHIih3
pgrbBLLyrvSzLu3Xy9vfDpO2T7cx1akpVfxrXVge4kiWTB+jXSSz0VECagA9jwQyHufda2D+2yFD
GXhOu4pg4SqWOO4G9y9Mb4SXYBLudcRaqvfj56q+xGypI8cOahr8H+nPfxkPwde2q2ExAGfHdGHf
zip+5cVCW0R9cwIcENdzsMVb1NwD1FAcEqDbluU9KScZa7Otr5OS36T2RxSKssmzfKinMhoQySGZ
Q+Mz2Osv39hYAJcac+3rM19UsNF6Fz+y6jn01cYmKG4M/0LjgAqc8w577FRp8t2uUplQZNJAlyQd
roQ3deJsHwcy1VnP6ILnLaUmwtEt4t3HGmuIPD3w/kzVuSSni+CHBVakGDlp9hzF7GN9ZvuMaR+W
DVQV2FNrcvYBi1umNlbAAka/kl6H+14DU0eS5pjvIIJvMWhiYGUzchxkYQgA0MbVa00a6mRIgDQX
gx+tz0uUyKZrSOaP8ZHreU/QUwJG3XSRXzb7+tJKgZxqzKXsjg65MnvXHbar4EXpb4dKm3w6p/pY
7CiyBM+EDp1VSSLutZ1CuhO8Y4R9Bd5PmgPgnApTggJb6NyE5nK/qhK+b/GtWJi92YFcID5sOJxL
Dgw8SSDE1lqQnLyGPvGKFACkhqyC/an7rXwV21zRo5ON+t1Ji3VJhLurenThILr2gNG+7rsP5hj/
j4cxc5J9xKwFH33KLKjnFWztC4U7CUijhZHbxcC56rGZNe1rhcCzzUN6NMKBkkBsgmBYVn3jP+Ht
7+VO1HGmpOjX/vOBd0zYhc+S8ylVdcJnU7zC17d6r+nfmHaJVh8QzBiit0y1rbWRaBTDmDd56TGR
vIrBt6nlZhehFZLKH4QtxpDqyG+Q5UcHHpVzXODOmTC8HXJcwRqXNvBRjcx8JV+ylMmCbawHiXEs
c/FLwb4dtZjkRr3u3f9HgUbDpPx7aMrtznMb8ABIhgTISeyBFvDN6xwuFPAXyfjChi51LyMd2sJ2
tBMU1sPFnhKoV9Yzy/4QshND0zQYITIzGWFHC1KdEaHKEwPdS64P/dVtyDwT4DJhajDCEi1xvThw
0HwcAbwffNYjOfP6PMXyPxjco/Gqm6KwcYYzjJaBjBj0wMfKjfz3tP+iuiBHqPIaogMtkKzXmBNF
4E3Rc8YonFoHf/jKFiUeaDPZ6Wq7NGZ2B279kK++YvbYDqjGqjh5t2stRwSfIdR7IXvm71YdH6D6
lVed1WhFXdqaFB3EXfcqiKJpYvSAIbdlmampgipAKFwgRPFmNxAfZFYvwS6vBKFf+GjX3ea19VEy
bZdPS27e9zm7QYAyKDVZ4vwtoewn/Vj9O2aWMCeS849b8hTacdsj1kdYdPrMLN2kGnpe6hLEihaA
tVf8dsYec2ioTN7RdIy9M5b9KNghWcwqzHk1F3ecOtj9vxTXwtq3lgFy9MRPY4NcQqHOiNftF0Xl
ckGZAn6+JIrWOE1f5nxtGLHJyIJ0sqPiwFL4e6YeiU3SyKfYkzmsvgHsv9wxvR3jeJ/LzXv2ur/P
iFgzZs/j50BfXlmamCS+fzwtFfG2ee4NpgQWFKS3ZZa8nNWxu8rAzXS2Vbtc9sWxhIbOeClkmlTu
F+ricHGa3Ol3uEfQxWPACr9q/z0lnVWtZqr9JYK9ZRg/giiJeRdh8kXKekXpd+3ZnzK1YUs8P42+
vyJKiWrWryk6X/sSXnI/dmErCHhWp6f1VP1OoRfr4X1fcdc6FCqwq5rbuZdho3ea9wDwoEFMdrNR
48ULFUujG0E61pI9G/IFcTibSz6261tuprkJRhK1ZhmeIyQ2RrAVH7zy+KeGudQdLSs41kVKrJeo
48u3iXf+kZmSgAHTpWUrJLWsEhGDNgxgLTxxSkJRtlMxyIsoyT2LSu9Ut9/HO3yCDkXqc/DC9WLQ
dIqpjlFbc1yJUFv9PqkNk97OyuGW2VltYiNUfG39btZgY0pDeMhuKC6nx3FLM+2gkmNXHfrmXq1T
LnPuoytkYZ13xJXUlyOSe6ho9iUJkPRUZHg2X+1GZAZk51CfW4gf2ILV//Tab6qag3+tpvR8OiyP
tv1vKD3ifMPjuaZoCsuVOGTIj6EfbYJeDRU7Sh2jS6LbYrKMpgAOcv0eCyn5pUJ2y75c3chJmvge
q45uBqtHl3NYmfIkcw0oXWRzQl8J9cKoZw6J7CVvmdEXrFX6187kku1cm0UVCr/CFx4gwYIlH95s
oOKaUlujV65UUQS49U2+qUe1SjIUVlrB+J2YBGRfbu24xwTU7hMWWZZQfK5VPRtxUnEECs1jEN6V
/hhqoSZVjs8qwe/VIvMOOKtFa7Ar8Fm4hX33boRHkKEmCH+YJYazIv+vL20yv0GFONOVtUDmJF9/
QVQNNd4QTBCbrAioC36VrtzK6ydb54M3J/fZ3TWAiHQnAnDinn1UHgESqc1zUUw7Vksngrc/4tCT
suN+j8pItxz496rKZZjrOOGny92EoOiRxgnS+hHtLjJP5wq9Bfj/tFb/Z5aI605IE8HHPC6B6/2q
0WaKIQJ2uPzY5iFzllogGZ19E8h8dSlhmUXBk/JG1jEWdOzmr8qSV52q72NJcVVP3KbEn/kTqXq8
VkyIZgdWdvrWAtrqiKsX90ZG6gvaOVz2eP0xuY+woIgCW7ry+sA+gZZbEzH1NGEg+QM6jzrj+bGQ
2YDivZrfGlxIBjiofGjLGN2xqypIuMmv3h31Fw0OMa5vYJRw9++eKoPEXwG9R/gj+t1DG4ib5n/T
kwJLeyuYmDLuLa115Hi9czusZ4PSiimIRLl3LS36H7IM12ssTEktWXJOBR95Dgz+/8oJcTs/5V3q
/g/4wcIu9Dbz8kou3X7QEJRhkRZb+gxCYNYQS1Wr9h0XHDAeca/nqrL7d4wL+6Bv2E6nufaKRK81
cY7iZHum+c+eDUG+53EPqsjFBzYhvbj1j0bScUG2Mr00xtvRtXNcdXed1Ob1fOnFbsIc/Q8zPGmL
H4L8Kb4itML7S3tdgORKGtRHRcb79Vnu8D2/2GT56M/51WVQ0ZG3DtYZlfrf6wPcuFMwWauIddC2
gHU2wziVpr3b9cj2UB1llebjNyhLQH5f0JQqS5D9sxzpS3mf0kyUbePVIyvZrHvJpfLeZYI6DeHJ
w9bJUgSjhSPjbkqBOoLKytDTJRjTyM50WnquI9kBMK8ycQnQaSEF39F69R9OfHtCIq+0peGle+jp
H+Z3hSlgHnSL7Sjg6jaeATw3YawbMo+qnuZ5mqmHUA/KYcoWTjYDZ/RNzISJEQWnQ5aSbYvktCB9
9RKyqK7EMpnziD6qN0R4F8RJKrieTIo5DYNcUubbsvvHNBiF8Ph2pXTyaJb5VIKgqAHUxBx610ZB
U0h3SlfDtG2vfhO1LXecyETB7uueg3dFuMhR2GUp8v6JNSsrAxU2aAcIUcK8LYFq+/hkX7itL6sh
rJAnd8/2zQGjMO2A/p20Te0neu5CbjAvPKjUi+4Lxqbft5E42exH3P0YaRMWRfGyO/ZLS20cuxT9
K0quYHUf9drGygFyQT+0UKwXTeds+nTKvm9M4votU0L+6ShLdMIH4EgmYGz2JpyepHPUOO0WrCq7
sdCAkST1nvF6IkdlTpVfH6fbyYc0RcpDh0LJhxGrU8V0mf2YH5S/+dTjkRYK1eoa2joxxd829nI+
qhuG8lXFmYgEM7rtmY2LF3/uHZQ7Mgm2Kv0m1L/sIlSLQcop54z5r5Udd6vaX2bkktdtexsm4Nb2
UVcnY4LvjMyBWGQb69PJGbKPevgXSPd+Fdqdn8G9NTri3yCZXV9Djf5YSRdQSK6qNCYAfHpLtMES
mCJWgt4kMe0T8obb9V9Jcz/KMXP+VZymMCuIJnXdqinYL1UV/e+To4mSyc23bIls3FRjNNwoKgzq
pUt6Fv+3Yff7kdugQbziBiIdReEJpkDaF2cnluCpET8GeIxPvOqMQfjSzxZhRpD53XUsv50vq22v
n5/VQx2fwoEcQiXCN4jfRFzo8iZNjKqmt8LOFxH/i0njKe7+V3NXUu2w1JnvaopGW5ecs6o+UDxM
rIT72klITtqyVcSvEd1xiNkOduw+zR7vF4tV56b3IX8o9N2MFDUThmm3o6znW+ezlIFZJVlZr7i8
FQ07PgAWn6oV8IuKyAjfnaODgCSwdmYFJwaVhoce0/zpa50WfNUbinPev/mHnoN1/z+TNBJGUiGA
UCMF4GeVuSer0VUsJaXEaY+yeI0ePIo0Nv+UrJ4lRRgYA9e41qbu0GydrGFpN5WoQCxkfppI92BP
+c558bAFqc57UUpRNLTdkNk+fToHP+WgyIFQJEliKKVuAYpisTHZY8w03ZdQS1wg8pWy9A3UuTS/
6DHERk3e77D44w8D8DfPgj8mSHsIfp0nRKyc3A+PfMiDM2m7t5u/x1k1Ce/en1dsmZ7usGVaeD+1
EyeXx3CX3FoMSyFhZQMrq5ZZ3Fhvs0AcFtoO3W0m4KekdPXlgXVXqkyU4DImG9DjUBeK8uQCZk2z
kFiIlfO6nRWFOuXaYlWgr1frevJxG4dD12A/ouA/0/UzvQ5uKwGNu1QW1TCPqCLWiEFrkQegkLpM
U445Lbpom81l6wnUj3KUiCvGRbDZKnwNJCb0B+2yUzlDUNkYrCTcdo4NAjskPFKIXwdyvCYwTi/J
mbWdnH2duC9ra9s7ByQxucE9p4ZXpj3D21/Dknaqt1mHmgVp2S3lud/Vqk0tr+iWOo7DXCijGLx1
8ahGytfXixj7RhH+YMt4HBEW6oThhDPILdAsIDM0uIGbzOhdl2HScaXFkG9aANzoOBABcMpcZCt6
/1PEpUXsvQ3BzUCxBXPSQ3R+VteZ5aeS5yazgo5uHeP5XZA6TgznjZeq4GZo8/Nc8tVEr6gLW1wn
9s4eShPDzTGV3tdgWL6JUfQPw3jaWOBdUxHi6EplnlmCtbX9bIWQmFXu21/ixMvEfw2O3qTKColq
JZIy7jBKhP1KHdW2iURvph0NrOQ2cZs8T4lGFzAIey+6+j9gnF71bN10FMucDPHaLQTxHt06324H
FnLq81Td6ML8HW0WPrvro7/P9O1pIxAqs3JfWDb0KONonTbAJyNXtnpMCOvXXYPMyrOQQ02VesL6
ApcPV3B13DGXxhrrH1iZtdwCk0+KbikDhFvJwG21Rr9Z4o8PyIARdcU39uoLlgNxVGzctEKG4kqD
LzrHZql3wzaFJhGKQRLaex7r0OFT/0VP7RDCof0gC1J0R0rr/TyLwc5pLSEn+tFSRBfToMIhjWzt
nXweJMAaVcPsQVwmw5s3ayel8od3f6MQDnzGIedtM591fUOSBrmhJekIgq8qtHxzsBdam/PX1scn
Ta+fMw2rbNzsnVWy/90eMwYXVtnyyemHG4aDJ0ROSwDung9Erf/1BQaaLGAtDkcgNwpK+bEij/Bp
3R+dy6hXLV2FthdbpHwDz/6imKqia6cg9icTDXb2+WOHs0YKIBiARwg2zd8e0TLYdXlG88neB1hM
u3UsF4wgwjGLFMfYD5Sjz3aRlhSlDRMRiQAwGQNg+YdsZ3Tj5XEjjq9swvNnejB/zm0phL4zZ5TS
hX7LnuPaRF8SxpHT/SoNPz1OrVxxwaY4xWSQjy+w7Nd9F48wPZe5BxITeQyeWBPwEocdLHS0PlEs
pmdcwHBPURODoocVR5NyFdbsNqjDUKrimbSdGK0A+hlFusgFiU+YLQayMbKzsGgH/8SgL819wmEZ
PrJimJ9y4ePeS7XL3E0NuB0nVnenzBJ1Q2O88tB6DWPyVV05eQnYszaX1tT8UoBRAblN8Vg6jBNM
vCJv75KK14mRq+LDw09S+xq6hdulafFRnkGnbOwg5N6+FTnLKvh8lmvMU5FVA28uhuTOnrAw9ZXO
h6JLSvopcLFODuH1PXSy6uRw7k9K8mHusY53c9u6FQqdv9YK9NjM6sfYLYA9oAkTy33Jg6lGcARW
NitmCcjauNo/Zlr20pZzAKIvvQwIZ78MCsKyRwdRprIyrXga2UNL1tTKAQvrfuS0FUO0CpmOGQn1
J0+Oh3RmSwLXjB/vpOM1KBeazy+BlkhBlbY5vwNMvYAgXBX1Wmy8xnkLwsd9PQL2iNG7qMld0JnK
A8udvWmkYdnEnNQQcAh+i2d8YMv20hR9cgbLBWuhztqYLVt4qygtgXNpy5s2gHXDBJWNNbOo0/Pl
CQtyN7NjhCaGLojhx8bc/1FPdAo/pqOYu1yzNQu8btAlKUKbbQSf/gQg8pVJh2b+/SPhwL5tTDQw
V+bkm3pVa6S9eCAv+asr9g1WsUSey6O3e8depsp/0vCFFSxnSzI6o4f9v+tegNBLbNptooyFZRIS
7qunXbZFMfFcqrP13au3O6KNXvAUBIYEAo8xdGW9oJM4hlE9yQJikXPlEXMXrVA+KLvKqYkBxUJz
WQZwcpff9PHuTNDXXyzD8Hl2N+H5NrBZ6R2fBwHP8jk8jFI0qKqBeZ6Ov5HCoBMSj9KCIMVRJqTY
aPjwR4+xbKbegr8sUYnQ6jYG3jE5PwOdOu/rC6PFYF0VErTIwM4GB8ZoVpThZKELR40zutZ9Zmow
IWL1L0ciShx5VGaYeKB3y/OYMKqNPN9LGBNpY3LyEt3Id/pJsPKGseC/0UKUgYvYzguH1mYFX8JL
JdxI5SpnJlGN1wL5fx42/LU3Cvfnw0RbYNhTArx6MamGULVLbl542QIrii0I7an3fHxMU7+1uNRp
7FKIxzsln1kHRWFotG05wtKkxGAmZJZTLsTzHrRPRrmhYd/9uG6fOUsA2VI2cqnbQO6ngHZfn9oW
tS1lTTSs53tqR083q6TaJpybTeR70ZZQU2eHuk5XjmgJQCy8nh6/w+VZvU4=
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
