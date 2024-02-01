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
        fifo_empty


*/
//////////////////////////////////////////////////////////////////////////////


module time_tagger (
    // Add parameters that you want to pass down
    parameter FIFO_DEPTH = 128;
    parameter DATA_WIDTH = 32;
) (
    // Tproc Clock and Reset Signal
    input wire clk_i,
    input wire rst_ni,
    // Inputs from the Interface
    input wire arm,
    input wire [47:0] start_time,
    input wire read_toa, // connect to interface pop
    // Outputs to the Interface
    output reg [31:0] fifo_out,
    output reg [31:0] status, // this might get eliminated
    output reg fifo_empty


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


tagger_ctrl #(

) acq_ctrl (
    .clk_i(clk_i),
    .rst_ni(rst_ni),

    .triggered(triggered),
    .armed(arm),
    .event_stored(event_stored),
    .wake_up(wake_up),

    .start_acq(start_acq),
    .store_en(toa_wren),
    .asleep(asleep)
)

///////////////////////////////////////////////////////////////////////////////
// Acqusition Datapath
///////////////////////////////////////////////////////////////////////////////


/*
toa_dt -> fifo din 
*/
///////////////////////////////////////////////////////////////////////////////
// Acquisition FIFO
///////////////////////////////////////////////////////////////////////////////

data_fifo #(
    .N (FIFO_DEPTH),
    .B (DATA_WIDTH)
) fifo (
    .rstn   (rst_ni),
    .clk    (clk_i),
    .wr_en  (toa_wren),
    .din    (toa_dt),
    .rd_en  (read_toa),
    .dout   (fifo_out),
    .empty  (fifo_empty)
);









endmodule 