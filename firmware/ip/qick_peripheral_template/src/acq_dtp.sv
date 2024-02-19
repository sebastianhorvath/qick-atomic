///////////////////////////////////////////////////////////////////////////////
//  FERMI RESEARCH LAB
///////////////////////////////////////////////////////////////////////////////
//  Author         : Christian Skinker
//  Date           : 1-2024
//  Version        : 1
///////////////////////////////////////////////////////////////////////////////
//   Acquistion Datapath : 
/* Description: 
    All of the logic necessary to calculate the time of arrival of a photon

    1. FIR filter to filter out noise 
    2. DSP Logic for Time of Arrival Calculations 
    3. 
*/
//////////////////////////////////////////////////////////////////////////////

module acq_dtp #(
    // Parameters 
    parameter DT_W      =   16,
    parameter N_S       =    8,
    parameter T_W       =   32, // Concatenated total experimental time
    parameter DTR_RST   =   10, // Clock Cycles: 10 * (1/350e6) = Detector Reset Time
    parameter DT_LAT    =    1 // Number of Clock cycles it takes the DATA to propogate through the constant fraction discriminator
) (
    // System Inputs
    input   wire                        clk_i       ,
    input   wire                        rst_ni      ,
    // Axis Stream Signals
    input   wire      [N_S*DT_W-1:0]    vector_i    ,
    input   wire                        tvalid      ,
    // Axis Registers
    input   wire      [31:0]            qp_delay    ,
    input   wire      [31:0]            qp_frac     ,
    // Input from Interface 
    input   wire      [T_W-1:0]         start_time  ,
    input   wire      [T_W-1:0]         curr_time   ,
    // Inputs from Control
    input   wire                        start_acq   ,
    input   wire                        store_en    ,
    input   wire                        asleep      ,
    // Outputs to Control
    output  reg                         triggered   ,
    output  reg                         store_rdy   , // Calculated the value to store
    output  reg                         wake_up     ,
    // FIFO Outputs
    output reg        [31:0]            toa_dt      

);

reg [T_W-1:0] trig_time;

//////////////////////////////////////////////////////////////////////////////
// Edge Detector
//////////////////////////////////////////////////////////////////////////////
// Storing Trigger Time
always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
        trig_time <= 0;
    end
    else begin
        // Store the time that we triggered on to store for the storage stage
        if (triggered) begin
            trig_time <= curr_time;
        end
    end
end


//////////////////////////////////////////////////////////////////////////////
// Edge Detection Interpolation
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// Module 
//////////////////////////////////////////////////////////////////////////////




endmodule