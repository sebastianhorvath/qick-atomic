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
    parameter RES       =   12,
    parameter T_W       =   32, // Concatenated total experimental time
    parameter DTR_RST   =   10, // Clock Cycles: 10 * (1/350e6) = Detector Reset Time
)
    // System Inputs
    input   wire                        clk_i       ,
    input   wire                        rst_ni      ,
    // Axis Stream Signals
    input   wire      [N_S*DT_W-1:0]    data_v      ,
    // Axis Registers
    // input   wire      [31:0]            qp_delay    ,
    // input   wire      [31:0]            qp_frac     ,
    // Input from Interface 
    input   wire      [T_W-1:0]         start_time  ,
    input   wire      [T_W-1:0]         curr_time   ,
    // Inputs from Control
    input   wire                        acq_en      ,
    input   wire                        store_en    ,
    input   wire                        asleep      ,
    input   wire      [RES-1:0]         threshold   ,                 
    // Outputs to Control
    output  reg                         triggered   ,
    output  reg                         store_rdy   , // Calculated the value to store
    output  wire                        wake_up     ,
    // FIFO Outputs
    output  reg        [T_W-1:0]        toa_dt      
);

localparam int N_B = $clog2(N_S);

wire [N_S-1:0] edge_index;

/////////////////////////////////////////////////////////////////////////////
// Storing the Trigger Time (Prevents effects from latency)
/////////////////////////////////////////////////////////////////////////////

reg [T_W-1:0] trig_time;

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
// Dead Time counter 
//////////////////////////////////////////////////////////////////////////////
localparam int DEAD_W = $clog2(DTR_RST);

reg [DEAD_W-1:0] dead_time;

assign wake_up = (dead_time == 0);

always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
        dead_time <= DTR_RST;
    end 
    else begin 
        if (asleep) begin
            dead_time <= dead_time - 1; 
        end 
        else begin
            dead_time <= DTR_RST;
        end
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

    .data_v            (data_v)     ,
    
    .acq_en            (acq_en)     ,
    .threshold         (threshold)  ,

    .triggered         (triggered)  ,
    .edge_index        (edge_index) ,
);

//////////////////////////////////////////////////////////////////////////////
// Edge Detection Interpolation 
//////////////////////////////////////////////////////////////////////////////


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
    .edge_time      (toa_dt)        ,
);



endmodule