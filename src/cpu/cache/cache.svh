`ifndef CACHE_DEFINES_SVH
`define CACHE_DEFINES_SVH

typedef struct packed {
    logic 		    	sign;//濞达綀娉曢弫锟�?0閻炴稏鍔庨妵姝秐signed 1閻炴稏鍔庨妵姝磇gned
    logic   [2:0]   	size;//閺夆晜鐟ら柌婊呮偘閵娧佷粵闁跨噦鎷�? 00 word 01 half  00 word
	logic               ReadMem;//闁告瑯浜濆﹢涓﹐ad闁归潧绉烽崗妯兼喆閿曗偓瑜颁縼eadMem
	logic   [1:0]       LeftOrRight; // 10閻炴稏鍔庨妵姝璭ft 01 閻炴稏鍔庨妵姝砳ght
} LoadType;//

`endif
