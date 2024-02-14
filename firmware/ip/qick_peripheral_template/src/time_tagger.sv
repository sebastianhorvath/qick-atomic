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
        start_time 
        read_time 

    Outputs: 

        fifo_out
        status 
        fifo_empt

*/
//////////////////////////////////////////////////////////////////////////////

module time_tagger #(
    // Add parameters that you want to pass down
    parameter FIFO_DEPTH    = 128,
    parameter T_W           = 32, //Timer Width 
    parameter N_S           = 8,
    parameter DT_W          = 16
) (
    // Tproc Clock and Reset Signal
    input   wire                        clk_i       ,
    input   wire                        rst_ni      ,
    // Axis Stream Signals
    input   wire      [N_S*DT_W-1:0]    tdata       ,
    input   wire                        tvalid      ,
    // Axi Registers 
    input   wire        [31:0]          qp_delay    ,
    input   wire        [31:0]          qp_frac     ,
    // Inputs from the Interface
    input wire                          arm         ,
    input wire          [T_W-1:0]       start_time  ,
    input wire                          read_toa    , // connect to interface pop
    // Outputs to the Interface
    output reg          [31:0]          fifo_out    ,
    output reg          [31:0]          status      , // this might get eliminated
    output reg                          fifo_empty

);

wire triggered;
wire event_stored;
wire wake_up;
wire asleep;
wire start_acq;
wire toa_wren;

///////////////////////////////////////////////////////////////////////////////
// Acquistion Control
///////////////////////////////////////////////////////////////////////////////


acq_ctrl #(

) tagger_ctrl (
    // System Inputs
    .clk_i          (clk_i)             ,
    .rst_ni         (rst_ni)            ,
    // Input from Interface
    .armed          (arm)               ,
    // Inputs from Datapath
    .triggered      (triggered)         ,
    .event_stored   (event_stored)      ,
    .wake_up        (wake_up)           ,
    // Outputs to Datapath
    .start_acq      (start_acq)         ,
    .asleep         (asleep)            ,
    // FIFO Control
    .store_en       (toa_wren)          
);

///////////////////////////////////////////////////////////////////////////////
// Acqusition Datapath
///////////////////////////////////////////////////////////////////////////////
acq_dtp #(
    .DT_W       ()      ,
    .T_W        ()      ,
    .N_S        ()      ,
    .DTR_RST    ()      ,
    .DT_LAT     ()
) tagger_dtp (
    // System Inputs
    .clk_i              (clk_i)         ,
    .rst_ni             (rst_ni)        ,
    // Axis Stream inputs
    .vector_i           (tdata)         ,
    .tvalid             (tvalid)        
    // 
    
    );

/*
toa_dt -> fifo din 
*/  
///////////////////////////////////////////////////////////////////////////////
// Acquisition FIFO
///////////////////////////////////////////////////////////////////////////////

fifo #(
    .N (FIFO_DEPTH),
    .B (TIME_WIDTH)
) data_fifo (
    .rstn   (rst_ni),
    .clk    (clk_i),
    .wr_en  (toa_wren),
    .din    (toa_dt),
    .rd_en  (read_toa),
    .dout   (fifo_out),
    .empty  (fifo_empty)
);









endmodule 