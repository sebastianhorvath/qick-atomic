///////////////////////////////////////////////////////////////////////////////
//  FERMI RESEARCH LAB
///////////////////////////////////////////////////////////////////////////////
//  Author         : Christian Skinker
//  Date           : 1-2024
//  Version        : 1
///////////////////////////////////////////////////////////////////////////////
//  Photon Time Tagger Module: 
/* Description: 
    Module Wrapper for the Entire Time Tagger 

    Includes: 
    
    1. Acquisition State Machine and Control
    2. Acquisition Datapath
    (3.) Maybe the FIR filter for Noise
    (4.) Maybe the FIFO 

    Inputs: 

        clk_i, rst_ni
        arm  
        read_time 

    Outputs: 

        fifo_out
        status 
        fifo_empt

*/
//////////////////////////////////////////////////////////////////////////////
`include "../headers/cmd_err.svh"

module time_tagger #(
    // Add parameters that you want to pass down
    parameter FIFO_DEP      = 128,
    parameter T_W           = 32, // Timer Width 
    parameter N_S           =  8,
    parameter DT_W          = 16,
    parameter RES           = 12, // ADC
    parameter DTR_RST       = 10
) (
    // Tproc Clock and Reset Signal
    input   wire                        clk_i       ,
    input   wire                        rst_ni      ,
    // Axis Stream Signals
    input   wire      [N_S*DT_W-1:0]    tdata       ,
    // DMA AXI Stream 
    // Axi Registers 
    input   wire        [31:0]          threshold   ,
    // Inputs from the Interface
    input wire                          arm         ,
    input wire                          read_toa    , // connect to interface pop
    // Outputs to the Interface
    output reg          [31:0]          fifo_out    ,
    output reg          [31:0]          status      , 
    output reg                          fifo_empty
);
localparam int ERR_W = 3;

wire triggered;
wire store_rdy, store_en;
wire acq_en, wake_up, asleep, dead, toa_wren;

wire [31:0] toa_dt;

///////////////////////////////////////////////////////////////////////////////
// Acquistion Control
///////////////////////////////////////////////////////////////////////////////

acq_ctrl #(

) tagger_ctrl (
    .clk_i          (clk_i)             ,
    .rst_ni         (rst_ni)            ,
    .armed          (arm)               ,
    .triggered      (triggered)         ,
    .store_rdy      (store_rdy)         ,
    .wake_up        (wake_up)           ,
    .acq_en         (acq_en)            ,
    .asleep         (asleep)            ,
    .store_en       (store_en)          
);

///////////////////////////////////////////////////////////////////////////////
// Acqusition Datapath
///////////////////////////////////////////////////////////////////////////////

acq_dtp #(
    .DT_W       (DT_W)      ,
    .N_S        (N_S)       ,
    .T_W        (T_W)       ,
    .RES        (RES)       ,
    .DTR_RST    (DTR_RST)     
) tagger_dtp (
    .clk_i              (clk_i)             ,
    .rst_ni             (rst_ni)            ,
    .data_v             (tdata)             ,
    .armed              (arm)               ,
    .acq_en             (acq_en)            ,
    .store_en           (store_en)          ,
    .asleep             (asleep)            ,
    .threshold          (threshold[RES-1:0]),
    .triggered          (triggered)         ,
    .store_rdy          (store_rdy)         ,
    .wake_up            (wake_up)           ,
    .toa_dt             (toa_dt)
);

///////////////////////////////////////////////////////////////////////////////
// Acquisition FIFO
///////////////////////////////////////////////////////////////////////////////
localparam int DEP_W = $clog2(FIFO_DEP);

wire [DEP_W-1:0] fifo_count; 

assign toa_wren = store_rdy & store_en;

tt_fifo #(
    .N          (FIFO_DEP)  ,
    .N_W        (DEP_W)   ,  
    .B          (32)
) data_fifo (
    .rstn   (rst_ni),
    .clk    (clk_i),
    .wr_en  (toa_wren),
    .din    (toa_dt),
    .rd_en  (read_toa),
    .dout   (fifo_out),
    .d_count(fifo_count),
    .empty  (fifo_empty)
);

//////////////////////////////////////////////////////////////////////////////
// Status Register
//////////////////////////////////////////////////////////////////////////////

always_ff @(posedge clk_i, rst_ni) begin
    if (!rst_ni) status <= 0;
    else begin
        if (read_toa) begin
            if ( fifo_empty )  status[ERR_W+DEP_W-1:DEP_W] = `EMPTY_ERR;
            else status[DEP_W-1:0] <= (fifo_count - 1'b1); // always 1 less because just read value
        end
    end
end


// time tagger -> fifo -> DMA_ctrl -> AXI_DMA


endmodule 