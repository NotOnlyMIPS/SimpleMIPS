`ifndef CACHE_DEFINES_SVH
`define CACHE_DEFINES_SVH

typedef enum logic [2:0] { 
	I_Index_Invalid,
	I_Index_Store_Tag,
	I_Hit_Invalid,

	D_Index_Writeback_Invalid,
	D_Index_Store_Tag,
	D_Hit_Invalid,
	D_Hit_Writeback_Invalid
} CacheCodeType;

typedef struct packed {
	CacheCodeType       	cacheCode;
	logic                   isCache;
	logic 					isIcache;
	logic 					isDcache;	
} CacheType;

typedef struct packed {
    logic 		    	sign;//浣跨敤0琛ㄧずunsigned 1琛ㄧずsigned
    logic   [1:0]   	size;//杩欎釜琛ㄧず锟�? 00 word 01 half  00 word
	logic               ReadMem;//鍙湁Load鎵嶈兘瑙﹀彂ReadMem
	logic   [1:0]       LeftOrRight; // 10琛ㄧずleft 01 琛ㄧずright
} LoadType;//

`endif