// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Sat Mar 18 17:11:43 2023
// Host        : DESKTOP-DA5086R running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               d:/ChooaaDoc/Study/SimpleMIPS/src/run_vivado/mycpu_v2019.2.srcs/sources_1/ip/multu/multu_sim_netlist.v
// Design      : multu
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a200tfbg676-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "multu,mult_gen_v12_0_16,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "mult_gen_v12_0_16,Vivado 2019.2" *) 
(* NotValidForBitStream *)
module multu
   (CLK,
    A,
    B,
    P);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME clk_intf, ASSOCIATED_BUSIF p_intf:b_intf:a_intf, ASSOCIATED_RESET sclr, ASSOCIATED_CLKEN ce, FREQ_HZ 10000000, PHASE 0.000, INSERT_VIP 0" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:data:1.0 a_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME a_intf, LAYERED_METADATA undef" *) input [31:0]A;
  (* x_interface_info = "xilinx.com:signal:data:1.0 b_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME b_intf, LAYERED_METADATA undef" *) input [31:0]B;
  (* x_interface_info = "xilinx.com:signal:data:1.0 p_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME p_intf, LAYERED_METADATA undef" *) output [63:0]P;

  wire [31:0]A;
  wire [31:0]B;
  wire CLK;
  wire [63:0]P;
  wire [47:0]NLW_U0_PCASC_UNCONNECTED;
  wire [1:0]NLW_U0_ZERO_DETECT_UNCONNECTED;

  (* C_A_TYPE = "1" *) 
  (* C_A_WIDTH = "32" *) 
  (* C_B_TYPE = "1" *) 
  (* C_B_VALUE = "10000001" *) 
  (* C_B_WIDTH = "32" *) 
  (* C_CCM_IMP = "0" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "0" *) 
  (* C_HAS_ZERO_DETECT = "0" *) 
  (* C_LATENCY = "3" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_MULT_TYPE = "1" *) 
  (* C_OPTIMIZE_GOAL = "1" *) 
  (* C_OUT_HIGH = "63" *) 
  (* C_OUT_LOW = "0" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  multu_mult_gen_v12_0_16 U0
       (.A(A),
        .B(B),
        .CE(1'b1),
        .CLK(CLK),
        .P(P),
        .PCASC(NLW_U0_PCASC_UNCONNECTED[47:0]),
        .SCLR(1'b0),
        .ZERO_DETECT(NLW_U0_ZERO_DETECT_UNCONNECTED[1:0]));
endmodule

(* C_A_TYPE = "1" *) (* C_A_WIDTH = "32" *) (* C_B_TYPE = "1" *) 
(* C_B_VALUE = "10000001" *) (* C_B_WIDTH = "32" *) (* C_CCM_IMP = "0" *) 
(* C_CE_OVERRIDES_SCLR = "0" *) (* C_HAS_CE = "0" *) (* C_HAS_SCLR = "0" *) 
(* C_HAS_ZERO_DETECT = "0" *) (* C_LATENCY = "3" *) (* C_MODEL_TYPE = "0" *) 
(* C_MULT_TYPE = "1" *) (* C_OPTIMIZE_GOAL = "1" *) (* C_OUT_HIGH = "63" *) 
(* C_OUT_LOW = "0" *) (* C_ROUND_OUTPUT = "0" *) (* C_ROUND_PT = "0" *) 
(* C_VERBOSITY = "0" *) (* C_XDEVICEFAMILY = "artix7" *) (* ORIG_REF_NAME = "mult_gen_v12_0_16" *) 
(* downgradeipidentifiedwarnings = "yes" *) 
module multu_mult_gen_v12_0_16
   (CLK,
    A,
    B,
    CE,
    SCLR,
    ZERO_DETECT,
    P,
    PCASC);
  input CLK;
  input [31:0]A;
  input [31:0]B;
  input CE;
  input SCLR;
  output [1:0]ZERO_DETECT;
  output [63:0]P;
  output [47:0]PCASC;

  wire \<const0> ;
  wire [31:0]A;
  wire [31:0]B;
  wire CLK;
  wire [63:0]P;
  wire [47:0]PCASC;
  wire [1:0]NLW_i_mult_ZERO_DETECT_UNCONNECTED;

  assign ZERO_DETECT[1] = \<const0> ;
  assign ZERO_DETECT[0] = \<const0> ;
  GND GND
       (.G(\<const0> ));
  (* C_A_TYPE = "1" *) 
  (* C_A_WIDTH = "32" *) 
  (* C_B_TYPE = "1" *) 
  (* C_B_VALUE = "10000001" *) 
  (* C_B_WIDTH = "32" *) 
  (* C_CCM_IMP = "0" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "0" *) 
  (* C_HAS_ZERO_DETECT = "0" *) 
  (* C_LATENCY = "3" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_MULT_TYPE = "1" *) 
  (* C_OPTIMIZE_GOAL = "1" *) 
  (* C_OUT_HIGH = "63" *) 
  (* C_OUT_LOW = "0" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  multu_mult_gen_v12_0_16_viv i_mult
       (.A(A),
        .B(B),
        .CE(1'b0),
        .CLK(CLK),
        .P(P),
        .PCASC(PCASC),
        .SCLR(1'b0),
        .ZERO_DETECT(NLW_i_mult_ZERO_DETECT_UNCONNECTED[1:0]));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2019.1"
`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="cds_rsa_key", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=64)
`pragma protect key_block
HPMPLvpmoX7LOmPj78BMT9X1rCnPz6PdhVGZQ307N9haGfAdMGVirvGR3e0Glyn2ieoWqXA6qOQL
t0xn28+h0g==

`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
Nxv/BnutRgdmHnLyK7kvDGjm7WGfFKW2mxQ6xUKF14zS4ziz5pSV0ueW4VqAzUyEPsErIAEuyV6F
m5KCqRBB197Q2NbZa7O7tdAqboX6tPAJzbB6u4U/MmNS1AQcSgtfj5srMbdBzDa5pR4V3HrI0MRj
0xhV1BWf725FYPP4av0=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
F5KGJgEDQsX2btdjtRUlSmNtuyodIhGXEa3/AXv1Y7qgSO8gknBfiqj5HcIaVA9b4npQpDnNcmq+
1ONAqLeLhdOm9TES+GsTAkh/lClvl89bzfqgOV33iqwQHYIHwSsWMRXT9JSUx+YWu+g6xKpT1Ycn
8BCPsq4QUJIqL6W16fheEHB/lkMgnespIWEYJJG6R6zvv2zG8GiU6cG8zHrRjdvAj8kOkhmiMvSd
YjGXJSMfjw7ojCPSUF+nb6WWhUEmoMA/6lgSVaXRm00YHSZ09k7rKTJWSXFSpTmkL2WOsQhNS0ek
jdTK2KF5K6z2YOK4zkfHgZ+fB0KJyANaLLJH/Q==

`pragma protect key_keyowner="ATRENTA", key_keyname="ATR-SG-2015-RSA-3", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
lFuQXeJ0hi7qnIKAR+37XCSOwp8bGLukonngcICceOVpL87+rxvhP5TyNJ/zXpAWDF0BaRYlGr7d
isPiUStrvUthNyOqCr4vFZyhCdY8n+Mrv3OCvLoLQSarxVXbaKbXb0tPsXJCUdXTrCt9mr5x0Nda
6DAI8FBPlFMAiqnFXnYMwlUiSlkNWUpInuNw7+1eD8kUdckEUV1PDwZ0yjpFqMokMH9oJjN6z0Yy
65D8Tqo288ZMfZQuIimjski+X6EK157XbpyuoZIuYLJ7j6oaATdintgfZpgGzVvhCZtMbx6/SJtR
efW5vLBGiGs7rPBPE2T8fosHGOvmeC9QBSj8Ww==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2019_02", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Q8VVvHzTNgU3tZr4+8ia7ylST+kbNPWskONHDOT1dTkB7cHZIAWyzXpQZPuEgk2wJq21PoqmVlG9
t08IYzkfC8vYQ2LRf2Co3SXc7p3gF2OFMC68J9Nf9D+/PXJCJy3QO4H8oO39l6bn8c56K2ARnK0R
mMIALbCWSBDGCWGQmXWZJ+xmDGs1KgTeiSW3bZRftWJ6K8l8BhMit8BLOY2Mi3jJ0WRhN8kKd6JT
D4NU1jTZT6jEtmI7Gnj/AXG6auTqDPHsVQzf+ZzBsLTfw83CFoO70xM997L5cZXlqz8fEDmxezkr
wWxPwJbJeVkRV3tUxlo2Bs2x1uVkXQeNVMI8jg==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
oUeTLA0HA2uKORUHo1HidNC3lw54gxwlLUkv28qRPv1pz7AEVUbIJ7wsyu2Scju+EkC2Ivi8HbBn
jxkeqRDTAwAbAqIKnY3AdyfojN9Hb8SMLcLnpWLLCpb6E0vwA09r7uqKRZ8wYAgT9CPFvzpQ3zKt
9DTLgQ3rZtFxx2nfCug=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Fayrlym1l14Y48yZ195XboT9ZQmp/mAzUyHby3Y9qJTzDF+m6mRQ/ZbebObo8bu4VAm45JeETPx1
YI4UZNOK4IqKv0BZsAlzUfAYAmqmkmIJYbn2gWUCwXyKX5AoA4ONnlxEHxzZhqtsmEXvxwTEs25/
R7iLzeoMfmwwNHgPNQkteiR4zDlB76CYmgu6EOSUX5Nnitq1oh7qRuU8WqWN7lLfgIC6T7qNHwGD
RPze2yiP06fSG45jPrOn2fvBX9SRbUXjNtiFgmqim4anwJU46v7y3ubit/I6giZhz5PJMZfkDaFX
ag+uCMq4Q8ZEolqMBmjUjat86BdVd4Nmr0yUaA==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
kIpxh3qIIkWUg8aLJSPKvKhKTPFH7T8fisti5RtNaftS7xh3KDsGLYnF1lYhH2RVXgzbdaVqvtED
5QJazVo6wUFI91xgFeOR5jX+Ny5UBUX2MngsK+UZyZg5+EdtSiDtiJNtQqgjq1Rn+XQCGF3xP80n
7YvuVMbgRHCAfWrWw7ZJ7Y3raRzeIkx+koPFio7XnC+QdRJ0ItO1YtQgF4Sg1Ihr5TH8/RrNn903
kPa+anH9spo3SFCf2Ts11UXAGLdIBmOLMtEAKjjCUbtmjGSeSc0gn2q2I+xRTFcegLevlr/iuLTw
3lFndBAoW40xOiCDjWZ6Rz7J+jZhsRl3D0Bhwg==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
I1T/BPHsaryLbeEZ1Ac0fTZ0xg0/0mkwoNSUtmmEMfPMEdqclQZgqyRfMaYAjBClPY+9py2wDR51
BDIkqLXx6XrxDQ1rptpdm4k6kWAjRetYNXKbCp81b5AqfisRVwA3YrAQYYEWZyJErY2wvwFIdE7L
0ZdlKfM4bOVGr9GwCzImVZvEedFv43jxHMTCVfaETkZGxeGler6IVQ7ccBvKaVlymnU+wWvZDv6U
Lyr5VM32Z6A6nnnbmqDh6avciKjp8o9+NdtKqAd7zelG8M9K8XkQ6pI/HNOfSFNTDPCMjJBfDsDV
w42LakPpw5D7D4OMtLFuk8IOfuuIhYdCR14hJQ==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
S9MGXj64vcFkZC4ZLJbnlFEqxuhwDlZODwImUVkHEkOevzYCKtGeVfGBpDP4tm8z18TGvQBbPoVH
jdvqm7MhsfEUrnWrPV+FoVSRZvWZft0khT1nWbxB9vk95Q5L/ACKloys/hno+Lh+zZL3aGKPY8tV
TPRUUDkHvfehX8un1+Z3e6dJdnNIeOhckrWp2ot2uvJChFRsdR2vSMLPk26tp9CEVQBRrHujNxng
4A4/+M2obhgUlgDEXw2lnKjnPkSpWjbKQ8ZTTeI0rA1LRI+9EgviAljwReDRsWOX59E8kx1exzk5
scUKNqmVBNdyn9hoei7K2hDKh8kdqPgWp5M9NA==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 26448)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
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

endmodule
`endif
