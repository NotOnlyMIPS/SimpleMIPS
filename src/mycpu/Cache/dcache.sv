`ifndef CACHE_DEFINES_SVH
`define CACHE_DEFINES_SVH
`endif

module dcache #(
    parameter STORE_BUFFER_SIZE = 32,
    parameter DATA_WIDTH    = 32,//cache閿熸枻鎷穋pu 閿熸枻鎷烽敓鏂ゆ嫹閿熸枻鎷烽敓鏂ゆ嫹浣嶉敓鏂ゆ嫹涓篸ata_width 32浣嶉敓鏂ゆ嫹???
    parameter LINE_WORD_NUM = 4,//cache line閿熸枻鎷峰皬 ???閿熸枻鎷烽敓鏂ゆ嫹閿熸枻鎷烽敓锟�16閿熻鏂ゆ嫹 4???
    parameter ASSOC_NUM     = 4,//assoc_num閿熸枻鎷烽敓鏂ゆ嫹???2???
    parameter WAY_SIZE      = 4*1024*8,//???璺痗ache 閿熸枻鎷烽敓鏂ゆ嫹閿熸枻鎷峰皬涓簑ay_size bit 4kB
    parameter GROUP_NUM     = WAY_SIZE/(LINE_WORD_NUM*DATA_WIDTH) //256閿熸枻鎷烽敓鏂ゆ嫹/???

)(
    input  logic           clk_g,
    input  logic           resetn,
    //cpu
    CPU_DCache_Interface   DBus,
    //axi 
    output logic           rd_req,
    output logic [ 31:0]   rd_addr,
    input  logic           rd_rdy,
    input  logic           ret_valid,
    input  logic [127:0]   ret_data,
    output logic           wr_req,
    output logic [ 31:0]   wr_addr,
    output logic [127:0]   wr_data,
    input  logic           wr_rdy,
    input  logic           wr_bvalid,
    //uncache
    output logic           urd_req,
    output logic [  2:0]   urd_type,//
    output logic [ 31:0]   urd_addr,
    input  logic           urd_rdy,
    input  logic           uret_valid,
    input  logic [ 31:0]   uret_data,
    output logic           uwr_req,
    output logic [  2:0]   uwr_size,//
    output logic [  3:0]   uwr_wstrb,//
    output logic [ 31:0]   uwr_addr,
    output logic [ 31:0]   uwr_data,
    input  logic           uwr_rdy,
    input  logic           uwr_bvalid
);
localparam int unsigned BYTES_PER_WORD = 4;
localparam int unsigned INDEX_WIDTH    = $clog2(GROUP_NUM) ;
localparam int unsigned OFFSET_WIDTH   = $clog2(LINE_WORD_NUM*BYTES_PER_WORD);
localparam int unsigned TAG_WIDTH      = 32-INDEX_WIDTH-OFFSET_WIDTH ;


typedef struct packed {
    logic valid;
    //logic dirty;
    logic [TAG_WIDTH-1:0] tag;  
} tagv_t; 

typedef struct packed {
    logic [31:0] address;
    logic [31:0] data;
    logic [3:0] wstrb;
} uncache_store_t;

typedef logic                                     dirty_t;
typedef logic [ASSOC_NUM-1:0]                     hit_t;
typedef logic [TAG_WIDTH-1:0]                     tag_t;
typedef logic [INDEX_WIDTH-1:0]                   index_t;
typedef logic [OFFSET_WIDTH-1:0]                  offset_t;

typedef logic [ASSOC_NUM-1:0]                     gpwe_t;//婵犳鍣徊鐣屾崲鐎ｎ剛鍗氶悗闈涙啞瀹曞銇勯弽顐沪闁哄懏鎮傞弻锟犲磼濡　鍋撻弽顐熷亾濮橆剛绉虹€规洘锚閳诲孩鎯旈埦鈧弸锟�???
typedef logic [DATA_WIDTH-1:0]                    data_t;//婵犳鍣徊鐣屾崲鐎ｎ剛鍗氶悗闈涙啞瀹曞銇勯弽銊ф噮妞ゅ繘浜跺铏规崉閵娿儲鐎鹃梺鍝勵儏椤兘鐛箛鏇犵煔濠殿垰鐛歨e_line

function index_t rt_index( input logic [31:0] addr );
    return addr[OFFSET_WIDTH + INDEX_WIDTH - 1 : OFFSET_WIDTH];
endfunction

function tag_t rt_tag( input logic [31:0] addr );
    return addr[31 : OFFSET_WIDTH + INDEX_WIDTH];
endfunction

function offset_t rt_offset( input logic [31:0] addr );
    return addr[OFFSET_WIDTH - 1 : 0];
endfunction

function logic  [31:0] mux_byteenable(
    input logic [31:0] rdata,
    input logic [31:0] wdata,
    input logic [3:0] sel 
);
    return { 
        sel[3] ? wdata[31:24] : rdata[31:24],
        sel[2] ? wdata[23:16] : rdata[23:16],
        sel[1] ? wdata[15:8]  : rdata[15:8],
        sel[0] ? wdata[7:0]   : rdata[7:0]
    };
endfunction

function logic[1:0] clog2(
    input logic [ASSOC_NUM-1:0] hit
);
    return{
        (hit[3] == 1'b1) ? 2'b11 : 
        (hit[2] == 1'b1) ? 2'b10 : 
        (hit[1] == 1'b1) ? 2'b01 : 2'b00
    };
endfunction

typedef enum logic [3:0] { 
        MISSDIRTY,
        WRITEBACK,

        LOOKUP,
        MISSCLEAN,
        REFILL,
        REFILLDONE
} state_t;

typedef enum logic [2:0] { 
        WB_IDLE,
        WB_STORE
} wb_state_t;

typedef struct packed {
    logic             valid;
    logic             wr;
    tag_t             tag;
    index_t           index;
    offset_t          offset;
    logic[3:0]        wstrb; //闂備礁鎲￠崝鏍偡閵堝棛绠鹃柨鐕傛嫹???
    logic[31:0]       wdata; //store闂傚倷娴囧▔鏇㈠窗閹版澘鍑犲┑鐘宠壘缁狀垶鏌ｉ幋锝呅撻柡鍛倐閺岋繝宕掑Ο琛″亾閺嶎偀鍋撳鐐
    logic[ 2:0]       size;//load缂傚倸鍊风欢锟犲磻婢舵劦鏁嬬憸鏃堝箖濡ゅ懏鏅搁柨鐕傛嫹
    logic             isCache;
    //CacheType         cacheType;
} request_t;


typedef struct packed {//store闂備礁婀辨灙婵炲樊鍙冨顐﹀箻鐠囧弶顥濋梺闈涚墕濡顢旈崼鏇熲拺閻犳亽鍔岄弸娆忊攽閳藉棗骞橀柟宄邦儑閹叉挳宕熼顐＄处闂傚倷娴囧▔鏇㈠窗閹版澘鍑犲┑鐘宠壘缁狀垶鏌ｉ幋锝呅撻柡鍛倐閺岋繝宕掑Ο琛″亾閺嶎偀鍋撳顒傜Ш鐎殿噮鍣ｉ弫鎾绘晸閿燂拷???闂傚倷娴囧▔鏇㈠窗閹版澘鍑犲┑鐘宠壘缁狀垶鏌ｉ幋锝呅撻柡鍛倐閺岋繝宕掑Ο琛″亾閺嶎偀鍋撳顒傜Ш鐎规洘锚閳诲孩鎯旈埦鈧弸蹇涙⒒娴ｈ姤纭堕柛鐘冲姍瀵憡绻濆顒傤唵闂佺粯鍨兼慨銈夊疾閹间焦鐓犻柟顓熷笒閸旀粎鈧娲╅幏锟�
    logic [ASSOC_NUM-1:0] hit;
    logic                 valid;
    tag_t                 tag;
    index_t               index;
    offset_t              offset;
    logic[3:0]            wstrb;
    data_t                wdata;
} store_t;

typedef enum logic [1:0]{ 
    UNCACHE_IDLE,//缂傚倸鍊风粈渚€寮甸鈧—鍐寠婢光晜绋掔粋鎺斺偓锝庝簽閻ｉ亶姊虹捄銊ユ珢闁瑰嚖鎷�
    UNCACHE_READ_WAIT_AXI,//缂傚倸鍊烽悞锔剧矙閹次诲洭顢涘⿰鍕靛仺闂佺粯姊婚崕銈団偓姘皑缁辨挻鎷呮慨鎴簽缁辩偤骞嬮敂鐣屽幍缂佺偓婢橀ˇ鎵偓姘炬嫹
    UNCACHE_READ,//缂傚倸鍊烽悞锔剧矙閹次诲洭顢涘⿰鍕靛仺闂佺粯姊婚崕銈団偓姘皑缁辨挻鎷呴懖鈩冨灥閳绘捇宕奸弴鐔哄幍闂佽皫鍐╁暈閻庢熬鎷�
    UNCACHE_READ_DONE//闂備浇宕垫慨鏉懨洪埡鍜佹晪鐟滄棃骞冩ィ鍐炬晢闁告洦鍋嗛娲⒑鐠恒劌娅愰柟鍑ゆ嫹
} uncache_state_t;

uncache_state_t uncache_state,uncache_state_next;
store_t  store_buffer; //闂傚倷娴囧▔鏇㈠窗閹版澘鍑犲┑鐘宠壘缁狀垶鏌ｉ幋锝呅撻柡鍛倐閺岋繝宕掑Ο琛″亾閺嶎偀鍋撳顒傜Ш闁哄被鍔戦幃銏犵暋閺夎法绱﹂梺鍝勵槸閻楀繘宕戦幘鍨涘亾濮橆剛绉洪柡灞诲姂閹垽鎮℃惔锛勯榾闂備浇娉曢崳锕傚箯閿燂拷 闂備胶鍎甸弲婊堝箰閹惰棄鏋侀柟鎹愵嚙濡﹢鏌曢崼婵囶棞妞ゅ繐鐖煎铏规崉閵娿儲鐎鹃梺鍝勵儏椤兘鐛箛娑欏€婚柤鎭掑劜濞呫垽姊洪崫鍕偓鍫曞磹閺嶎偀鍋撳鐐
state_t  state,state_next;

wb_state_t wb_state,wb_state_next;

logic [31:0] uncache_rdata;

index_t read_addr, write_addr, tagv_addr;//闂傚倷娴囧▔鏇㈠窗閺囶澁缍栨俊銈呭暞鐎氭氨鎲告惔锝傚亾濮橆剚璐￠柟椋庡█婵偓闁靛牆妫欏▍銏＄箾閹炬潙鎼搁柛搴㈠▕閵嗗倿顢氶埀顒勭嵁韫囨挾鏆嬮柣妤€鐗忕粊锟� 濠电偞鍨跺濠氬窗閺嶎厼鏋侀柟鎹愵嚙濡﹢鏌曢崼婵囶棞妞ゅ繐鐖煎铏规崉閵娿儲鐎鹃梺鍝勵儏椤兘鐛箛娑欏€婚柤鎭掑劜濞呫垽姊洪崫鍕偓鍫曞磹閺嶎偀鍋撳顒傜Ш闁诡啫鍥ㄦ櫢闁绘ǹ娅曞▍銏ゆ⒑鐠恒劌娅愰柟鍑ゆ嫹??? 闂傚倷娴囧▔鏇㈠窗閹版澘鍑犲┑鐘宠壘缁狀垶鏌ｉ幋锝呅撻柡鍛倐閺岋繝宕掑Ο琛″亾閺嶎偀鍋撳顒傜Ш闁哄被鍔戦幃銏ゅ川婵犲嫪绱曢梻浣哥秺椤ユ捇鈥︾花宄痳e闂佽崵鍠愬ú鎴犵矆娓氣偓瀹曨垶骞撶粚濉﹉e闂傚倷娴囧▔鏇㈠窗瀹ュ鍤戦幖杈剧到閺嬪牆顭跨捄渚剰妞ゅ骏鎷�???

tagv_t [ASSOC_NUM-1:0] tagv_rdata;
tagv_t                 tagv_wdata;
gpwe_t                 tagv_we;// 闂傚倷娴囧▔鏇㈠窗閹版澘鍑犲┑鐘宠壘缁狀垶鏌ｉ幋锝呅撻柡鍛倐閺岋繝宕掑Ο琛″亾閺嶎偀鍋撳顒傜Ш闁哄被鍔戦幃銏ゆ惞閻熺増鎳欓梻浣筋潐瑜板啴顢栭崱娆屽亾濮橆剛绉洪柡灞诲姂閹垹鐣￠弶璺ㄧ处闂佽崵濮村ú銈囩矓鐠鸿　鏋嶉柕蹇嬪€曠粻顖炴煟閹达絽袚闁哄懏鎮傞弻銊╂偆閸屾稑顏�

index_t                 dirty_addr;
dirty_t [ASSOC_NUM-1:0] dirty_rdata;
dirty_t                 dirty_wdata;
gpwe_t                  dirty_we;

gpwe_t wb_we;//store闂傚倷娴囧▔鏇㈠窗閹版澘鍑犲┑鐘宠壘缁狀垳鈧懓瀚姗€寮茬粙妫靛綊鏁愰崨顔间淮闂佽桨鐒﹂幑鍥ь嚕椤掑嫬围闁糕剝顨忔导锟�

data_t                                                        data_rdata [ASSOC_NUM-1:0][LINE_WORD_NUM-1:0];
logic [31:0]                                                  data_rdata_sel[ASSOC_NUM-1:0];
logic [31:0]                                                  data_rdata_final1;
logic [31:0]                                                  data_rdata_final2;
data_t                                                        data_wdata[LINE_WORD_NUM-1:0];
logic  [ASSOC_NUM-1:0][LINE_WORD_NUM-1:0][3:0]                data_we;//闂傚倷娴囧▔鏇㈠窗閹版澘鍑犲┑鐘宠壘缁狀垶鏌ｉ幋锝呅撻柡鍛倐閺岀喕銇愰幒鎾存殸闂佸摜鍋涢…鐑界嵁韫囨挾鏆嬮柡澶嬪濞呫垺绻涙潏鍓у埌婵炵》绻濆顐﹀箻鐠囧弶顥濋梺闈涚墕濡顢旈敓锟�
logic                                                         data_read_en;

request_t req_buffer;
logic req_buffer_en;

logic [$clog2(ASSOC_NUM)-1:0]                                 lru[GROUP_NUM-1:0] ;
logic [ASSOC_NUM-1:0]                                         hit;
logic                                                         cache_hit;

logic [ASSOC_NUM-1:0]                                         pipe_hit;
logic                                                         pipe_cache_hit;
tagv_t [ASSOC_NUM-1:0]                                        pipe_tagv_rdata;
logic                                                         pipe_wr;

//fifo

uncache_store_t fifo_din;//input
logic fifo_wr_en;
logic fifo_rd_en;

logic fifo_rd_rst_busy;// output
logic fifo_full;
logic fifo_empty;
uncache_store_t fifo_dout;
logic fifo_data_valid;
logic fifo_wr_ack;
logic fifo_wr_rst_busy;

//闂備礁鎼ˇ顐﹀疾濠靛鐒垫い鎺嗗亾缂佸瞼杞闂傚倷娴囬～澶嬬娴犲纾块弶鍫亖娴滃綊鏌ㄩ悤鍌涘
assign fifo_din   = {req_buffer.tag,req_buffer.index,req_buffer.offset,req_buffer.wdata,req_buffer.wstrb};
assign fifo_wr_en = (fifo_wr_rst_busy || fifo_full || (~(req_buffer.valid & req_buffer.wr & (~req_buffer.isCache))) ) ?  1'b0 : 1'b1;//濠电姷鏁搁崑鐔烘崲濠靛鍊块柨鏇炲€哥粻鏉款熆鐠鸿櫣鐏辨俊顐灦閺屾盯鈥﹂幋婵囩亞缂備緡鍠氱划顖滄崲濠靛洨绡€闊洦鏌ㄩ锟� 婵犵數鍋為崹鍫曞箰閸濄儳鐭撻柣鎴ｆ缁€鍌涙叏濡炶浜鹃悗瑙勬礃閿曘垽寮幘缁樻櫢闁跨噦鎷� fifo濠电姷鏁告慨鎾偑閻㈢ǹ绠柨鐕傛嫹 婵犵數鍋為崹鍫曞箰閸濄儳鐭撻梻鍫熷厷閿濆洨鍗氶柍铏瑰ache闂傚倷绀侀幉锟犲礉閺嶎厽鍋￠柨鏃堟暜閸嬫捇宕归銈庢殹缂備礁鍊圭敮锟犲极閹剧粯鏅搁柨鐕傛嫹
assign fifo_rd_en = (uwr_rdy && (!fifo_empty) && (!fifo_rd_rst_busy)) ? 1'b1 :1'b0;//闂傚倸鍊搁崐鎼佹偋韫囨稑纾婚柣鏃傚帶閻撴﹢鏌ㄩ悤鍌涘 闂傚倷鑳堕崢褔鎮块崶顬盯宕熼姘辨焾闂佽法鍣﹂幏锟� 
//cpu
//闂傚倷绶氬濠氭⒔閸曨偒鐔嗘俊顖欒閻掍粙鏌涢幇闈涙灈缂佺姷鏁婚弻宥夊煛娴ｅ憡娈銈冨€撶粈浣藉絹闂佹悶鍎荤徊娲磻閹捐绀冮柟缁樺坊閺嬶拷
assign DBus.addr_ok   = ( state_next == LOOKUP) && DBus.req;
//闂傚倷娴囧銊╂嚄閼稿灚娅犳俊銈傚亾闁伙絽鐏氱粭鐔煎焵椤掑嫮宓侀柟鎹愵嚙閻掓椽鏌涢幇鐢靛帥闁哄顫夌换娑㈡晲閸涱喚顦遍梺閫炲苯澧柛鐔稿缁绘盯鏁撻敓锟�
assign DBus.data_ok   = req_buffer.isCache ? ((state == LOOKUP || state == REFILLDONE) && state_next == LOOKUP && req_buffer.valid) 
                                           : (req_buffer.wr ? req_buffer.valid : (uncache_state == UNCACHE_READ_DONE && uncache_state_next == UNCACHE_IDLE && req_buffer.valid));

assign DBus.rdata     =  ( req_buffer.valid ) ? data_rdata_final1 : '0;
//axi
assign rd_req = (state == MISSCLEAN) ? 1'b1 : 1'b0;
assign rd_type = '0;
assign rd_addr = {req_buffer.tag,req_buffer.index, {OFFSET_WIDTH{1'b0}}};
assign wr_req = (state == MISSDIRTY) ? 1'b1 : 1'b0;
assign wr_type = '0;
assign wr_wstrb = '0;
assign wr_addr = {pipe_tagv_rdata[lru[req_buffer.index]].tag, req_buffer.index, {OFFSET_WIDTH{1'b0}}};

generate;
    for (genvar  i=0; i<LINE_WORD_NUM; ++i) begin
        assign wr_data[32*(i+1)-1:32*(i)] = data_rdata[lru[req_buffer.index]][i];
    end
endgenerate

//闂備礁鎼ˇ顐﹀疾濠靛鐒垫い鎺嗗亾妞わ綇绠燺ubus闂傚倷娴囬～澶嬬娴犲纾块弶鍫亖娴滃綊鏌ㄩ悤鍌涘
assign urd_req   = (uncache_state == UNCACHE_READ_WAIT_AXI && fifo_empty) ? 1'b1:1'b0;
assign urd_size  = req_buffer.size;
assign urd_addr  = {req_buffer.tag , req_buffer.index, req_buffer.offset};
assign uwr_req   = (fifo_empty || fifo_rd_rst_busy) ? 1'b0:1'b1;//闂傚倷绀侀幖顐︽偋閸℃蛋鍥濞戞帗鐏侀梺鎸庣箓椤︻垳绮婚弽顓熺叆闁绘洖鍊圭€氾拷 fifo婵犵數鍋為崹鍫曞箰閸濄儱鏋堝☉鏃傤殢ty 闂傚倷绀侀幉锟犳偡椤栨稓顩叉繝闈涙焾閿濆绠瑰ù锝呮憸閻嫰姊虹紒妯忣亞澹曢銏犖ュ┑鐘叉处閻撴洟鏌熺€电ǹ孝闁告柨顑夐弻锝夊冀閸偄顏� 闂備浇顕х换鎰崲閹邦垬浜瑰璺烘湰椤洟鏌熷▓鍨灀闁稿鎸婚幏鍛村礃椤垶顥嶉梻浣规偠娴煎洭宕惰閻嫰姊虹紒妯忣亞澹曢銏犖ュ┑鐘叉处閻撴洘绻涢崱妯哄闁诲繈鍎甸弻娑㈠Χ鎼粹€崇睄閻庤娲橀敋闁宠閰ｉ獮鎺戔攽閸℃﹩鍞瑰┑鐘愁問閸犳岸骞婇幘璇茬９闁秆勵殔绾惧鏌涘☉鍗炴灓闁崇粯娲熼弻娑㈩敃閿濆洨鐣甸柣鐘辩劍閻擄繝寮婚妶鍥ｅ亾閸︻厼校妞ゃ儱顦伴幈銊ノ熺粙鍨瀴闁诲海鏁搁崢褔锝炲┑瀣疀濞达絽鎲￠弳蹇涙⒑閼姐倕孝婵炴祴鏅犻、姘愁樄鐎规洏鍨归埥澶娾枎閹搭厽閿ら梻浣芥硶閸ｏ箓骞忛敓锟� 婵犵數鍋為崹鍫曞箰閸濄儳鐭撳瀣瀹曟煡鏌涢幇闈涙灍闁绘帒澧界槐鎺斾沪閸屾浜鹃柛鐐存綁tn婵犵數鍋涢悺銊у垝閿濆绠柨鐕傛嫹 闂傚倷鑳堕幊鎾绘偤閵娾晛鍨傚┑鍌氬閺佸鎱ㄥΟ鍝勭秮闁绘帒锕鍫曞醇濞戞ê顬嬪┑顔硷躬缁犳牠寮婚敓鐘查唶婵犲灚鍔栨瓏婵＄偑鍊栧ú婊勬櫠濡ゅ啰鐭夌€广儱顦伴弲鎼佹煥閻曞倹瀚�
assign uwr_size  = req_buffer.size;
assign uwr_addr  = {fifo_dout.address}; //TODO:濠电姷鏁搁崑娑欏緞閸ヮ剙绀堟繝闈涙４閼板灝銆掑锝呬壕濡ょ姷鍋涘锕傚Φ閹版澘绠抽柟鎹愮堪閸嬶拷
assign uwr_data  = {fifo_dout.data};
assign uwr_wstrb = fifo_dout.wstrb;

assign ststall = 0;
assign cache_hit        = |hit;//ok

assign read_addr        = req_buffer_en ? DBus.index : req_buffer.index;
assign write_addr       = ( state == REFILL ) ? req_buffer.index : store_buffer.index;
assign tagv_addr        = req_buffer.index;

assign data_rdata_final1 =   (uncache_state == UNCACHE_READ_DONE )? uncache_rdata: data_rdata_final2;

assign pipe_wr          = (state_next == MISSCLEAN || state_next == MISSDIRTY); // ??????????????????

//req_buffer闂傚倷绀侀幉锟犲礉閺嶎厽鍋￠柕鍫濇缁犻箖鏌涢妷顔煎闁搞倕瀚伴弻銊╂偆閸屾稑顏�
assign req_buffer_en    = (state_next == LOOKUP && DBus.req || DBus.data_ok);

generate;//
    for (genvar i=0; i<LINE_WORD_NUM; i++) begin
        assign data_wdata[i] = (state == REFILL) ? ret_data[(i+1)*32-1:i*32] : store_buffer.wdata;
    end
endgenerate

assign tagv_wdata       = (state == REFILL) ? {1'b1, req_buffer.tag} : '0;

assign data_read_en     = 1'b1;

assign dirty_wdata      = (state == REFILL) ? 1'b0 : 1'b1;
assign dirty_addr       = req_buffer.index;

//generate
generate;
    for (genvar i = 0;i<ASSOC_NUM ;i++ ) begin
        simple_port_lutram #(
            .SIZE(GROUP_NUM),
            .dtype(dirty_t)
        )mem_dirty(
            .clka(clk_g),
            .rsta(~resetn),

            .ena(1'b1),
            .wea(dirty_we[i]),
            .addra(dirty_addr),
            .dina(dirty_wdata),
            .douta(dirty_rdata[i])            
        );

        simple_port_lutram  #(
            .SIZE(GROUP_NUM),
            .dtype(tagv_t)
        ) mem_tag(
            .clka(clk_g),
            .rsta(~resetn),

            .ena(1'b1),
            .wea(tagv_we[i]),
            .addra(tagv_addr),
            .dina(tagv_wdata),
            .douta(tagv_rdata[i])
        );
        for (genvar j=0; j<LINE_WORD_NUM; ++j) begin
        simple_port_ram #(
            .SIZE(GROUP_NUM),
            .BYTE_PER_DATA(4)
        )mem_data(
            .clk(clk_g),
            .rst(~resetn),

            .ena(1'b1),
            .wea(data_we[i][j]),
            .addra(write_addr),
            .dina(data_wdata[j]),

            .enb(data_read_en),
            .addrb(read_addr),
            .doutb(data_rdata[i][j])
        );
    end
    end
endgenerate

generate;//PLRU 缂傚倸鍊烽懗鑸垫叏閻㈡悶鈧啴宕卞▎鎰幑闂佽法鍣﹂幏锟�
    for (genvar  i=0; i<GROUP_NUM; i++) begin
        PLRU #(
            .ASSOC_NUM(ASSOC_NUM)
        ) plru_reg(
            .clk(clk_g),
            .resetn(resetn),
            .access(hit),
            .update(req_buffer.valid && i[INDEX_WIDTH-1:0] == req_buffer.index),//闂傚倷娴囧▔鏇㈠窗閹版澘鍑犲┑鐘宠壘缁狀垶鏌ｉ幋锝呅撻柡鍛憸缁辨帡鎳犻鈧埢鍫ユ煛娴ｈ宕岀€殿噮鍓熸俊鍫曞幢濡ゅ﹣绱﹀┑鐐差嚟婵參宕戦幘鏂ユ闁哄啯鎸荤€氾拷

            .lru(lru[i])
        );
    end
endgenerate

generate;
    for(genvar i = 0; i < ASSOC_NUM; i++ ) begin
        assign hit[i]= (tagv_rdata[i].valid & (req_buffer.tag == tagv_rdata[i].tag) ) ? 1'b1:1'b0 ;
    end
endgenerate

generate;
    for(genvar i = 0;i < ASSOC_NUM; i++) begin
        assign data_rdata_sel[i] = data_rdata[i][req_buffer.offset[OFFSET_WIDTH-1:2]];
    end
endgenerate

always_comb begin : dirty_we_block
    if (state == REFILL && ret_valid) begin
        dirty_we = '0;
        dirty_we[lru[req_buffer.index]] =1'b1;
    end else if(req_buffer.valid && req_buffer.wr && req_buffer.isCache)begin
        dirty_we = hit;
    end else begin
        dirty_we = '0;
    end
end

always_comb begin : data_rdata_final2__blockname
    data_rdata_final2 = ( (|data_we[clog2(store_buffer.hit)])  && store_buffer.hit == hit 
                        && {store_buffer.tag,store_buffer.index,store_buffer.offset[OFFSET_WIDTH-1:2]} == {req_buffer.tag,req_buffer.index,req_buffer.offset[OFFSET_WIDTH-1:2]} ) ?
                            store_buffer.wdata : data_rdata_sel[clog2(hit)];
end

always_comb begin : tagv_we_blockName
    if (state == REFILL && ret_valid) begin
        tagv_we = '0;
        tagv_we[lru[req_buffer.index]] =1'b1;
    end else begin
        tagv_we = '0;
    end
end

always_comb begin : data_we_blockName
    data_we = '0;
    if (state == REFILL && ret_valid) begin
        data_we[lru[req_buffer.index]] ='1;
    end else if((wb_state == WB_STORE || wb_state_next == WB_STORE) && store_buffer.valid)begin
        data_we[clog2((wb_state_next == WB_STORE && wb_state == WB_IDLE) ? hit : store_buffer.hit)][store_buffer.offset[OFFSET_WIDTH-1:2]] = store_buffer.wstrb;
    end else begin
        data_we = '0;
    end   
end

always_ff @( posedge clk_g ) begin : store_buffer_blockName
    if ( !resetn ) begin
        store_buffer <= '0;
    end else if( req_buffer.valid && ~ststall) begin//闂傚倷娴囧▔鏇㈠窗閹版澘鍑犲┑鐘宠壘缁狀垶鏌ｉ幋锝呅撻柡鍛倐閺岋繝宕掑Ο琛″亾閺嶎偀鍋撳鐐??? 闂傚倷娴囧▔鏇㈠窗閹版澘鍑犲┑鐘宠壘缁狀垶鏌ｉ幋锝呅撻柡鍛倐閺岋繝宕掑Ο琛″亾閺嶎偀鍋撳顒傜Ш闁哄被鍔戦幃銏ゅ川婵犲嫪绱曢梻浣告贡閸忔﹢寮ㄩ柆宥呯柧闁跨噦鎷�???
        store_buffer.hit   <= hit;
        store_buffer.valid <= (req_buffer.valid & req_buffer.wr);
        store_buffer.tag   <= req_buffer.tag;
        store_buffer.index <= req_buffer.index;
        store_buffer.offset <=req_buffer.offset;
        store_buffer.wstrb <= req_buffer.wstrb;
        store_buffer.wdata <= mux_byteenable(data_rdata_final2, req_buffer.wdata, req_buffer.wstrb);  
    end else if ( req_buffer.valid==1'b0 ) begin//闂傚倷娴囧▔鏇㈠窗閺囩喍绻嗘い鎾卞灩缁€鍕煏閸繃顥滄い蹇撶埣閺屾稓鈧綆鍋嗛惌鎺楁煛娴ｈ宕岀€殿噮鍓熸俊鍫曞幢濡ゅ﹣绱﹂梻浣虹帛閿曨偊骞忛敓锟�???闂傚倷娴囧▔鏇㈠窗閹版澘鍑犲┑鐘宠壘缁狀垶鏌ㄩ悤鍌涘??闂佽崵鍠愬ú鎴犳濮樿泛鏋侀柟鎹愵嚙濡﹢鏌曢崼婵囶棞妞ゅ骏鎷�?? 闂傚倷娴囧▔鏇㈠窗閹版澘鍑犲┑鐘宠壘缁狀垶鏌ｉ幋锝呅撻柡鍛倐閹嘲鈻庨幇顒傤儎闂佽妞挎禍顏堢嵁韫囨稒鐓ラ悗锝庡亽濡差垶姊绘担鑺ョ《闁哥姵鎹囬幃锟狀敃閿濆棛绉堕梺缁樺姦閸撴瑩顢旈崼鏇熲拺閻犳亽鍔岄弸鎴︽煛鐎ｎ亶鐓兼鐐茬箻閺屻劎鈧綆鍋呴悵锟� ??闂傚倷娴囧▔鏇㈠窗閹版澘鍑犲┑鐘宠壘缁狀垶鏌ｉ幋锝呅撻柡鍛倐閺岋繝宕掑Ο琛″亾閺嶎偀鍋撳鐐??
        store_buffer <= '0;
    end

end


generate;//闂傚倷娴囧▔鏇㈠窗閹版澘鍑犲┑鐘宠壘缁狀垶鏌ｉ幋锝呅撻柡鍛倐閺岋繝宕掑Ο琛″亾閺嶎偀鍋撳顒傜Ш闁哄被鍔戦幃銏ゅ川婵犲嫪绱曢梻浣哥秺椤ユ捇宕楀鈧顐﹀箻鐠囧弶顥濋梺闈涚墕濡顢旈崼鏇熲拺閻犳亽鍔岄弸鏂棵归敐鍛嚄g
    for (genvar  i=0; i<ASSOC_NUM; i++) begin
    always_ff @( posedge clk_g ) begin : pipe_tagv_rdata_blockName
        if (pipe_wr) begin
            pipe_tagv_rdata[i].tag   <= tagv_rdata[i].tag;
            pipe_tagv_rdata[i].valid <= tagv_rdata[i].valid ;
        end 
    end        
    end
endgenerate

always_ff @(posedge clk_g) begin : pipe_hitblockName
    if (pipe_wr) begin
        pipe_cache_hit           <= cache_hit;
        pipe_hit                 <= (1<<lru[req_buffer.index]);
    end 
end

always_ff @( posedge clk_g ) begin : req_buffer_block
    if( !resetn )begin
        req_buffer          <= '0;
    end else if(req_buffer_en) begin 
        req_buffer.valid    <=  DBus.req     ;
        req_buffer.wr       <=  DBus.wr      ;  
        req_buffer.tag      <=  DBus.tag     ;
        req_buffer.index    <=  DBus.index   ;
        req_buffer.offset   <=  DBus.offset  ;
        req_buffer.wstrb    <=  DBus.wstrb   ;
        req_buffer.wdata    <=  DBus.wdata   ;
        req_buffer.size     <=  DBus.size    ;
        req_buffer.isCache  <=  DBus.iscache ;
    end
end

always_ff @( posedge clk_g ) begin : uncache_rdata_blockName//闂傚倷绀侀幖顐⒚洪妶澶嬪仱闁靛ň鏅涢拑鐔封攽閳╁吘鏄猘che闂備浇宕垫慨鏉懨洪埡鍜佹晪鐟滄柨鐣烽悽鍓叉晣闁靛繒濮锋鍥⒑闂堟冻绱￠柛鏇ㄥ幗濞堟悂姊绘担鑺ョ《闁革綇绠撻獮蹇涙晸閿燂拷?
    if (uret_valid) begin
        uncache_rdata <= uret_data;
    end
end

//闂備胶绮敃顐﹀箯閿燂拷???闂佸搫顦遍崕鎴﹀箯閿燂拷???
always_ff @( posedge clk_g ) begin : state_switch_blockName
    if( !resetn ) begin
        state <= LOOKUP ;
    end else begin 
        state <= state_next ;
    end
end

//闂傚倷娴囧▔鏇㈠窗閹版澘鍑犲┑鐘宠壘缁狀垶鏌ｉ幋锝呅撻柡鍛倐閺岋繝宕掑Ο琛″亾閺嶎偀鍋撳顒傜Ш闁诡喒鏅犻弫鎾绘晸閿燂拷??? 
always_comb begin : state_next_blockName
    
    
    state_next = LOOKUP ;

    unique case (state)
        LOOKUP:begin
            if ( req_buffer.valid ) begin
                if ( req_buffer.isCache == 1'b0 ) begin
                        state_next = LOOKUP;
                end else begin
                    if ( cache_hit ) begin
                        state_next = LOOKUP;
                    end else begin
                        if (dirty_rdata[lru[req_buffer.index]]) begin
                            state_next = MISSDIRTY ;
                        end else begin
                            state_next = MISSCLEAN ;
                        end
                    end
                end     
            end else begin
                state_next = LOOKUP;
            end
        end
        MISSCLEAN:begin
            if ( rd_rdy ) begin//闂傚倷娴囧▔鏇㈠窗閹版澘鍑犲┑鐘宠壘缁狀垶鏌ｉ幋锝呅撻柡鍛倐閺岋繝宕掑Ο琛″亾閺嶎偀鍋撳鐐???
                state_next = REFILL;
            end else begin
                state_next = MISSCLEAN;
            end
        end
        REFILL:begin
            if ( ret_valid ) begin//闂備胶枪閿曘倝濡堕幖浣告瀬闁规崘顕уΛ姗€鏌曢崼婵囶棞妞ゅ骏鎷�???
                state_next = LOOKUP;
            end else begin
                state_next = REFILL;
            end
        end
        REFILLDONE:begin
            if( wb_state == WB_STORE) begin
                state_next = REFILLDONE;
            end
            else begin
                state_next = LOOKUP ;
            end
        end
        MISSDIRTY:begin
            if ( wr_rdy ) begin
                state_next = WRITEBACK;
            end else begin
                state_next =  MISSDIRTY;
            end
        end
        WRITEBACK:begin
            if ( wr_bvalid ) begin
                state_next = MISSCLEAN;
            end else begin
                state_next = WRITEBACK;
            end
        end
        default: begin
            state_next =LOOKUP;
        end
    endcase
end

//wb_store_state
always_ff @( posedge clk_g ) begin :wb_state_blockname
    if ( !resetn ) begin
        wb_state <= WB_IDLE;
    end else begin
        wb_state <= wb_state_next;
    end
end

always_comb begin : wb_state_next_blockname
    if (req_buffer.valid && req_buffer.wr && cache_hit ) begin
        wb_state_next = WB_STORE;
    end else begin
        wb_state_next = WB_IDLE;
    end

end

always_ff @( posedge clk_g ) begin : uncache_state_blockName
    if (!resetn) begin
        uncache_state <= UNCACHE_IDLE;
    end else begin
        uncache_state <= uncache_state_next;
    end
end

always_comb begin : uncache_state_next_blockName

    //uncache_state_next = uncache_state;
    uncache_state_next = UNCACHE_IDLE;

    case (uncache_state)
        UNCACHE_IDLE:begin
            if (DBus.req & (~DBus.iscache) & req_buffer_en) begin //婵犵數濮烽。浠嬪焵椤掆偓閸熷潡鍩€椤掆偓缂嶅﹪骞冨Ο璇茬窞闁归偊鍓涢悡鎴濐渻閵堝棛澧柣鐔村€楅懞杈ㄥ鐎涙鍘甸梺璇″幗鐢帡宕濆杈ㄥ枑闁哄娉曟晶娑氱磼鐎ｎ亶妲洪柍褜鍓ㄧ徊娲疾濠靛鏁傞柛妤冨亹濡插牓鏌熼崹顔兼殨婵炴挳鏀遍妵鍕即閵娿儱顫╅柡浣哥墦閺屻劑鎮ら崒娑橆伓
                if (DBus.wr ==1'b0 ) begin
                    uncache_state_next = UNCACHE_READ_WAIT_AXI;
                end else begin
                    uncache_state_next = UNCACHE_IDLE;
                end
            end 
        end
        UNCACHE_READ_WAIT_AXI:begin
            if (urd_rdy) begin
                uncache_state_next = UNCACHE_READ;
            end
            else uncache_state_next = UNCACHE_READ_WAIT_AXI;
        end
        UNCACHE_READ:begin
            if (uret_valid) begin
                uncache_state_next = UNCACHE_READ_DONE;
            end
            else uncache_state_next = UNCACHE_READ;
        end
        UNCACHE_READ_DONE:begin
            if (DBus.req & (~DBus.iscache) & req_buffer_en) begin //闂傚倸饪撮崑鍕洪妶澶婄疇闁圭増婢樼粈澶屾喐鎼达絿鐭欏璺哄閸嬫捇鏁愰崒娑欑彇濡炪倕绻樻禍鍫曞蓟閻旈鏆嬮柟娈垮暕閵夛负浜滈柍鍝勵儑閻ｇ數鈧娲╃紞渚€鐛€ｎ喗鏅查柛鈩冾殜濡兘姊洪懡銈呅＄紒鈧笟鈧幃妯衡攽鐎ｎ偄浠遍梺璺ㄥ櫐閹凤拷
                if (DBus.wr ==1'b0) begin
                    uncache_state_next = UNCACHE_READ_WAIT_AXI;
                end else begin
                    uncache_state_next = UNCACHE_IDLE;
                end
            end
            else begin
                uncache_state_next = UNCACHE_IDLE;
                // end
            end
        end
        default:begin
            uncache_state_next = UNCACHE_IDLE;
        end
    endcase
end


FIFO #(
    .SIZE(STORE_BUFFER_SIZE),
    .dtype(uncache_store_t),
    .LATENCY (0) //闂備浇宕垫慨鎾敄閸涙潙鐤い鏍仜濮规煡鏌ㄥ┑鍡橆棤闁崇粯妫冮弻銊╂偆閸屾稑顏�0
)

FIFO_dut (
    .clk (clk_g),
    .rst (~resetn),
    .din (fifo_din),
    .rd_en (fifo_rd_en ),
    .wr_en (fifo_wr_en ),
    .rd_rst_busy (fifo_rd_rst_busy ),
    .full (fifo_full ),
    .empty (fifo_empty ),
    .dout (fifo_dout ),
    .data_valid (fifo_data_valid ),
    .wr_ack (fifo_wr_ack ),
    .wr_rst_busy  (fifo_wr_rst_busy)
);

endmodule


