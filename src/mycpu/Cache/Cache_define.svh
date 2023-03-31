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
    logic 		    	sign;//婵炶揪缍€濞夋洟寮敓锟�0闁荤偞绋忛崝搴ㄥΦ濮濈signed 1闁荤偞绋忛崝搴ㄥΦ濮濈gned
    logic   [2:0]   	size;//闁哄鏅滈悷銈夋煂濠婂懏鍋橀柕濞т椒绮甸梺璺ㄥ櫐閹凤拷? 00 word 01 half  00 word
	logic               ReadMem;//闂佸憡鐟禍婵嗭耿娑擄箰ad闂佸綊娼х粔鐑藉礂濡吋鍠嗛柨鏇楀亾鐟滈绺糴adMem
	logic   [1:0]       LeftOrRight; // 10闁荤偞绋忛崝搴ㄥΦ濮濈挱ft 01 闁荤偞绋忛崝搴ㄥΦ濮濈牫ght
} LoadType;//

`endif