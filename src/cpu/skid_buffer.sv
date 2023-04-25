module  singleclock_fifo_lowell
#(

    parameter DATA_WIDTH      = 32,
    parameter FIFO_DEPTH      = 2,
    parameter SHOWAHEAD       = "ON",   // "ON" = showahead mode ('pop' is an acknowledgement); /
        //  "OFF" = normal mode ('pop' is a request).
    parameter RAM_TYPE        = "AUTO", // "AUTO" or "MLAB" or "M20K".
    // Derived                
    parameter ADDR_WIDTH      = $clog2(FIFO_DEPTH) + 1  // e.g. clog2(64) = 6, but 7 bits /
        //  needed to store 64 value
) 
(
    input  wire                   clk,
    input  wire                   rst,
    input  wire  [DATA_WIDTH-1:0] in_data,    // write data
    input  wire                   pop,        // rd request
    input  wire                   push,       // wr request
    output wire                   out_valid,  // not empty
    output wire                   in_ready,   // not full
    output wire [DATA_WIDTH-1:0]  out_data,   // rd data
    output wire [ADDR_WIDTH-1:0]  fill_level
);  
    wire                      scfifo_empty;
    wire                      scfifo_full;
    wire [DATA_WIDTH-1:0]     scfifo_data_out;
    wire [ADDR_WIDTH-1:0]       scfifo_usedw;

    logic [DATA_WIDTH-1:0] out_data_1q;
    logic [DATA_WIDTH-1:0] out_data_2q;
    logic                  out_empty_1q;
    logic                  out_empty_2q;
    logic                  e_pop_1;
    logic                  e_pop_2;
    logic                  e_pop_qual;
    
    assign out_valid         = ~out_empty_2q; 
    assign in_ready          = ~scfifo_full;
    assign out_data          = out_data_2q; 
    assign fill_level        = scfifo_usedw + !out_empty_1q + !out_empty_2q;

// add output pipe 
    assign e_pop_1      = out_empty_1q || e_pop_2; 
    assign e_pop_2      = out_empty_2q || pop; 
    assign e_pop_qual = !scfifo_empty && e_pop_1;
    always_ff@(posedge clk)
    begin
      if(rst == 1'b1) 
      begin
        out_empty_1q <= 1'b1;  // empty is 1 by default
        out_empty_2q <= 1'b1;  // empty is 1 by default
      end 
      else begin 
        if(e_pop_1) 
        begin
          out_empty_1q <= scfifo_empty; 
        end 
        if(e_pop_2) 
        begin
          out_empty_2q <= out_empty_1q; 
        end 
      end 
    end 
    always_ff@(posedge clk)
    begin
      if(e_pop_1) 
        out_data_1q  <= scfifo_data_out; 
      if(e_pop_2) 
        out_data_2q   <= out_data_1q;
    end 

    scfifo scfifo_component 
    (
        .clock        (clk),
        .data         (in_data),

        .rdreq        (e_pop_qual),
        .wrreq        (push),

        .empty        (scfifo_empty),
        .full         (scfifo_full),
        .q            (scfifo_data_out),
        .usedw        (scfifo_usedw),
//        .aclr         (rst),
        .aclr         (1'b0),
        .almost_empty (),
        .almost_full  (),
        .eccstatus    (),
        //.sclr         (1'b0)
        .sclr         (rst)  // switch to sync reset
    );
    defparam
        scfifo_component.add_ram_output_register  = "ON",
        scfifo_component.enable_ecc               = "FALSE",
        scfifo_component.intended_device_family   = "Stratix",
        scfifo_component.lpm_hint                 = (RAM_TYPE == "MLAB") ? "RAM_BLOCK_TYPE=MLAB" : 
                                                   ((RAM_TYPE == "M20K") ? "RAM_BLOCK_TYPE=M20K" : ""),
        scfifo_component.lpm_numwords             = FIFO_DEPTH,
        scfifo_component.lpm_showahead            = SHOWAHEAD,
        scfifo_component.lpm_type                 = "scfifo",
        scfifo_component.lpm_width                = DATA_WIDTH,
        scfifo_component.lpm_widthu               = ADDR_WIDTH,
        scfifo_component.overflow_checking        = "ON",
        scfifo_component.underflow_checking       = "ON",
        scfifo_component.use_eab                  = "ON";


endmodule