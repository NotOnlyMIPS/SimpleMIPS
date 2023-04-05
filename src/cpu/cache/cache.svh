`ifndef CACHE_DEFINES_SVH
`define CACHE_DEFINES_SVH

typedef struct packed {
    logic 		    	sign;
    logic   [2:0]   	size;
	logic               ReadMem;
	logic   [1:0]       LeftOrRight; 
} LoadType;//

`endif
