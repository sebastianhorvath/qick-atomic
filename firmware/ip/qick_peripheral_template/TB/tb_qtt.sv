`timescale 1ns/10ps

`include "./tb_macros.svh"
`include "../headers/cmd_err.svh"

module qtt_dut();

reg c_clk, ps_clk, t_clk;
reg rst_ni;
reg sync; // Don't know if necessary 
// CLK Generation 
initial begin
    ps_clk = 0; 
    forever # (`T_PS_CLK) ps_clk = ~ps_clk;
end
initial begin
    c_clk = 0;
    forever # (`T_C_CLK) c_clk = ~c_clk;
end
initial begin
    t_clk = 0;
    forever # (`T_C_CLK) t_clk = ~t_clk;
end

// Parameters and Constants
///////////////////////////////////////////////////////////////////////

parameter integer FIFO_DEPTH = 32;
parameter integer TIME_WIDTH = 28;
parameter integer NUM_SAMPLES = 8;
parameter integer DATA_WIDTH = 16;
parameter integer RESOLUTION = 12;
parameter integer DETECTOR_RESET = 20;

reg [31:0] threshold = 1024;

// Control Signals / Outputs
///////////////////////////////////////////////////////////////////////
reg arm, read_toa;
reg [31:0] fifo_out, status;
reg fifo_empty;

reg [NUM_SAMPLES*DATA_WIDTH-1:0] adc_dt;

// Time Tagger Module
///////////////////////////////////////////////////////////////////////
time_tagger #(
    .FIFO_DEP       (FIFO_DEPTH),
    .T_W            (TIME_WIDTH),
    .N_S            (NUM_SAMPLES),
    .DT_W           (DATA_WIDTH),
    .RES            (RESOLUTION),
    .DTR_RST        (DETECTOR_RESET)
) dut_qtt (
    .clk_i          (c_clk),
    .rst_ni         (rst_ni),
    .tdata          (adc_dt),
    .threshold      (threshold),
    .arm            (arm),
    .read_toa       (read_toa),
    .fifo_out       (fifo_out),
    .status         (status),
    .fifo_empty     (fifo_empty)
);

parameter int WAV_SIZE = 992;
reg [DATA_WIDTH-1:0] adc_memory [0:1023];

// Tasks for Simulation 
////////////////////////////////////////////////////////////////////////
task START_SIMULATION (); begin
   $display("START SIMULATION");
   if (test_case == 1) begin
        $readmemb("../firmware/ip/qick_peripheral_template/TB/Mem_dt/nanowire1.txt", adc_memory);
   end
   else if (test_case == 2) begin
        $readmemb("../firmware/ip/qick_peripheral_template/TB/Mem_dt/doublepeak1.txt", adc_memory);
   end
// Reset
   rst_ni    = 1'b0;
   arm    = 1'b0;
   read_toa = 1'b0;
   adc_dt = '0;
   @ (posedge ps_clk); #0.1;
   rst_ni   = 1'b1;
end
endtask 

// Generating Different Types of ADC Samples
//////////////////////////////////////////////////////////////////////////

// Typical Photon Signal //
// Nanowire1.txt sample past threshold is 206
parameter integer thresh_time = 214;

int t;
reg [DATA_WIDTH-1:0] s0, s1, s2, s3, s4, s5, s6, s7;
int photon_length = WAV_SIZE / 8;

task PHOTON_ADC_SAMPLES(); begin
    $display("Starting Photon samples");
    for (t=0; t<photon_length; t=t+1) begin
        @ (posedge t_clk); #0.1;

        s0 = adc_memory[(t*8)];
        s1 = adc_memory[(t*8)+1];
        s2 = adc_memory[(t*8)+2];
        s3 = adc_memory[(t*8)+3];
        s4 = adc_memory[(t*8)+4];
        s5 = adc_memory[(t*8)+5];
        s6 = adc_memory[(t*8)+6];
        s7 = adc_memory[(t*8)+7];

        adc_dt = {s7, s6, s5, s4, s3, s2, s1, s0};
    end
    adc_dt = '0;
end
endtask

int double_length = 12;
// Edge Case Two Peaks During Sleep Time //
task DOUBLE_ADC_SAMPLES(); begin
    $display("Starting Double Peak samples");
    for (t=0; t<double_length; t=t+1) begin
        @ (posedge t_clk); #0.1;

        s0 = adc_memory[(t*8)];
        s1 = adc_memory[(t*8)+1];
        s2 = adc_memory[(t*8)+2];
        s3 = adc_memory[(t*8)+3];
        s4 = adc_memory[(t*8)+4];
        s5 = adc_memory[(t*8)+5];
        s6 = adc_memory[(t*8)+6];
        s7 = adc_memory[(t*8)+7];

        adc_dt = {s7, s6, s5, s4, s3, s2, s1, s0};
    end
    adc_dt = '0;
end
endtask

// Different Test Cases
//////////////////////////////////////////////////////////////////////////

// Passed
task EDGE_DETECT_TEST(); begin
    arm = 1; 
    # (`T_C_CLK * 2 * (WAV_SIZE/8)); // Wait until all samples have passed
    arm = 0;
    read_toa = 1;
    @ (posedge c_clk); #0.1;
    read_toa = 0;
    `ASSERT_EQ(fifo_out, thresh_time, "Wrong threshold time calculated")
    @ (posedge c_clk); #0.1;
end
endtask

// Passed 
task TWO_EDGE_TEST(); begin
    arm = 1;
    # (2 * `T_C_CLK * 2 * (WAV_SIZE/8)); // Wait until all samples have passed Twice
    read_toa = 1;
    arm = 0;
    @ (posedge c_clk); #0.1;
    read_toa = 0;
    @ (posedge c_clk); #0.1;
    @ (posedge c_clk); #0.1;
    @ (posedge c_clk); #0.1;
    read_toa = 1;
    @ (posedge c_clk); #0.1;
    read_toa = 0;
    @ (posedge c_clk); #0.1;
end
endtask

// Passed 
task READ_WHILE_ASLEEP(); begin
    arm = 1;
    wait (fifo_empty == 0);
    read_toa = 1;
    @ (posedge c_clk); #0.1;
    read_toa = 0;
    wait (t == 120);
    arm = 0;
    @ (posedge c_clk); #0.1;
end
endtask

task DOUBLE_PEAK(); begin
    arm = 1;
    # (2 * `T_C_CLK * (double_length));
    read_toa = 1; 
    arm = 0;
    @ (posedge c_clk); #0.1;
    read_toa = 0;
    @ (posedge c_clk); #0.1;
end
endtask

int sim_en = 1;
reg activate;
initial begin
    while (sim_en == 1) begin
        wait (arm == 1);
        if (test_case == 1) PHOTON_ADC_SAMPLES();
        else if (test_case == 2) DOUBLE_ADC_SAMPLES();
    end
end

int test_case = 2;
// Test Cases 
initial begin

    START_SIMULATION();

    // Check that the time tagger marks the right time
    @ (posedge c_clk); #0.1;

    // New Test (Now Two Cycles of Peaks) Test FIFO
    DOUBLE_PEAK();

    sim_en = 0;
end

endmodule