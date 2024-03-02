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
    parameter T_W       =   32, 
    parameter DTR_RST   =   10,
    parameter RES       =   12
) (
    // System Inputs
    input   wire                        clk_i       ,
    input   wire                        rst_ni      ,
    // Axis Stream Signals
    input   wire      [N_S*DT_W-1:0]    tdata       ,
    // Axis Registers
    // input   wire      [31:0]            qp_delay    ,
    // input   wire      [31:0]            qp_frac     ,
    input   wire      [RES-1:0]         qp_threshold, 
    // Inputs from Control
    input   wire                        armed       ,
    input   wire                        acq_en      ,
    input   wire                        store_en    ,
    input   wire                        asleep      ,                
    // Outputs to Control
    output  wire                        triggered   ,
    output  reg                         store_rdy   , // Calculated the value to store
    output  wire                        wake_up     ,
    // FIFO Outputs
    output  wire      [31:0]            toa_dt      
);

wire [N_S-1:0] edge_index;
wire above_thresh, below_thresh;
reg alr_trig;

/////////////////////////////////////////////////////////////////////////////
// Time Counter
/////////////////////////////////////////////////////////////////////////////
reg [T_W-1:0] tt_curr_time;

always_ff @(posedge clk_i, negedge rst_ni) begin
     if (!rst_ni) tt_curr_time <= 0;
     else begin
        if (armed) tt_curr_time <= tt_curr_time + 1'b1;
        else tt_curr_time <= 0;
     end
end
/////////////////////////////////////////////////////////////////////////////
// Storing the Trigger Time (Prevents effects from latency)
/////////////////////////////////////////////////////////////////////////////
reg [T_W-1:0] trig_time;
assign triggered = above_thresh & !alr_trig;

always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
        trig_time <= 0;
        alr_trig <= 0;
    end
    else begin
        if (triggered && acq_en) begin
            trig_time <= tt_curr_time;
            alr_trig <= 1;
        end
        // If already triggered wait until below threshold to reallow a trigger
        if (alr_trig & below_thresh) alr_trig <= 0;
    end
end

//////////////////////////////////////////////////////////////////////////////
// Dead Time counter 
//////////////////////////////////////////////////////////////////////////////
localparam int DEAD_W = $clog2(DTR_RST);
reg [DEAD_W-1:0] dead_time;
assign wake_up = (dead_time == 1);

// Counter doesn't stop until = 0
always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) dead_time <= DTR_RST;
    else begin 
        if (asleep) begin 
            dead_time <= dead_time - 1; 
            if (wake_up) dead_time <= DTR_RST;
        end
        else dead_time <= DTR_RST;
    end
end

//////////////////////////////////////////////////////////////////////////////
// Edge Detector (Can Replace with the Constant Fraction Discrimination)
//////////////////////////////////////////////////////////////////////////////
edge_detect #(
    .DT_W       (DT_W)  ,
    .N_S        (N_S)   ,
    .RES        (RES)    
) photon_arrival (
    .clk_i             (clk_i)      ,
    .rst_ni            (rst_ni)     ,
    .tdata             (tdata)      ,
    .acq_en            (acq_en)     ,
    .threshold         (qp_threshold),
    .above_thresh      (above_thresh),
    .below_thresh      (below_thresh),
    .edge_index        (edge_index) 
);

//////////////////////////////////////////////////////////////////////////////
// Edge Detection Interpolation 
//////////////////////////////////////////////////////////////////////////////
localparam int N_B = $clog2(N_S);
localparam int TOA_W = N_B+T_W;
wire [(TOA_W-1):0] part_toa_dt;
assign toa_dt = {{(32 - TOA_W){1'b0}}, part_toa_dt};

t_interpolate #(
    .T_W        (T_W)   ,
    .N_S        (N_S)   ,
    .N_B        (N_B)
) precise_time (
    .clk_i          (clk_i)         ,
    .rst_ni         (rst_ni)        ,
    .trig_time      (trig_time)     ,
    .store_en       (store_en)      ,
    .edge_index     (edge_index)    ,
    .store_rdy      (store_rdy)     ,
    .toa_dt         (part_toa_dt)        
);

endmodule