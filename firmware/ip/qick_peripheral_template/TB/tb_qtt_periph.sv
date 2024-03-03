`timescale 1ns/10ps

`include "./tb_macros.svh"
`include "../headers/cmd_err.svh"

module tb_qtt_periph();
reg c_clk, ps_clk, t_clk;
reg rst_ni;

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

// Waveform Setup 
///////////////////////////////////////////////////////////////////////

int WAV_SIZE = 992;
reg [DATA_WIDTH-1:0] s0, s1, s2, s3, s4, s5, s6, s7;
int photon_length = WAV_SIZE / 8;

// Control Signals and Output Signals
////////////////////////////////////////////////////////////////////////

reg qp_en_i, qp_rdy_o, qp_vld_o, qp_flag_o; //Flags Interface signals
reg [ 4:0] qp_op_i;
reg qp_tready, qp_tvalid; // Stream signals
reg [DATA_WIDTH*NUM_SAMPLES-1:0] adc_dt; // Data Stream

reg [31:0] qp_dt1_o, qp_dt2_o; // Peripheral Outputs

reg [ 7:0] r_qp_ctrl, r_qp_cfg;
reg [31:0] r_qp_threshold;
reg [31:0] r_qp_dt1, r_qp_dt2, r_qp_dt3, r_qp_dt4, r_qp_status;

reg [DATA_WIDTH-1:0] adc_memory [0:1023];

qtt_periph #(
    .DT_W           (DATA_WIDTH),
    .FIFO_DEP       (FIFO_DEPTH),
    .T_W            (TIME_WIDTH),
    .N_S            (NUM_SAMPLES),
    .DTR_RST        (DETECTOR_RESET)
) tt_periph_dut (
   .clk_i      ( c_clk     ) ,
   .rst_ni     ( rst_ni    ) ,
   .qp_en_i     ( qp_en_i     ) ,
   .qp_op_i     ( qp_op_i     ) ,
   .qp_rdy_o    ( qp_rdy_o    ) , 
   .qp_dt1_o    ( qp_dt1_o    ) , 
   .qp_dt2_o    ( qp_dt2_o    ) , 
   .qp_vld_o    ( qp_vld_o    ) , 
   .qp_flag_o   ( qp_flag_o   ) , 
   .qp_vector_i ( adc_dt      ) ,
   .qp_tready   ( qp_tready   ) ,
   .qp_tvalid   ( qp_tvalid   ) ,
   .QP_CTRL     ( r_qp_ctrl     ) ,
   .QP_CFG      ( r_qp_cfg      ) ,
   .QP_DELAY    ( ) ,
   .QP_FRAC     ( ) ,
   .QP_THRES    ( r_qp_threshold) ,
   .AXI_DT1     ( ) ,
   .AXI_DT2     ( ) ,
   .AXI_DT3     ( ) ,
   .AXI_DT4     ( ) ,
   .QP_DT1      ( r_qp_dt1      ) ,
   .QP_DT2      ( r_qp_dt2      ) ,
   .QP_DT3      ( r_qp_dt3      ) ,
   .QP_DT4      ( r_qp_dt4      ) ,
   .QP_STATUS   ( r_qp_status   ) ,
   .QP_DEBUG    ( ) ,
   .qp_time     ( qp_time       ) , 
   .qp_do       ( qp_do_s       ) );


int cycles;
task START_SIMULATION(); begin
    $display("START SIMULATION");
    $readmemb("../firmware/ip/qick_peripheral_template/TB/Mem_dt/nanowire1.txt", adc_memory);
    rst_ni = 0;
    cycles = 0;
    qp_en_i = 0;
    qp_op_i = 0;
    adc_dt = '0;
    qp_tvalid = 1;
    r_qp_ctrl = 0;
    r_qp_cfg = 0;
    r_qp_threshold = 1024; 
    @ (posedge c_clk); #0.1;
    rst_ni = 1;
end
endtask

int t;
task PHOTON_ADC_SAMPLES(); begin
    $display("Starting Photon samples");
    for (t=0; t<photon_length; t=t+1) begin
        s0 = adc_memory[(t*8)];
        s1 = adc_memory[(t*8)+1];
        s2 = adc_memory[(t*8)+2];
        s3 = adc_memory[(t*8)+3];
        s4 = adc_memory[(t*8)+4];
        s5 = adc_memory[(t*8)+5];
        s6 = adc_memory[(t*8)+6];
        s7 = adc_memory[(t*8)+7];

        adc_dt = {s7, s6, s5, s4, s3, s2, s1, s0};

        @ (posedge t_clk); #0.1; 
    end

    adc_dt = '0;
end
endtask

// Receiving Commands from the Tproc // 
task SWITCH_TO_QP_OP(); begin
    @ (posedge ps_clk); #0.1;
    r_qp_cfg[7] = 1'b0;
    @ (posedge ps_clk); 
    @ (posedge c_clk); #0.1;
end
endtask

task QP_ARM_CMD(); begin
    $display("Arming Time Tagger");
    qp_op_i = `ARM_CMD;
    qp_en_i = 1;
    wait (qp_rdy_o);
    @ (posedge c_clk); #0.1; 
    qp_en_i = 0;
    qp_op_i = 0;
    `ASSERT_EQ(tt_periph_dut.photon_time.arm, 1, "Time Tagger Not Entering Armed State")
    @(posedge c_clk); #0.1;
end
endtask

task QP_DISARM_CMD(); begin
    $display("Disarming Time Tagger");
    qp_op_i = `DISARM_CMD;
    qp_en_i = 1;
    wait (qp_rdy_o);
    @ (posedge c_clk); #0.1; 
    qp_en_i = 0;
    qp_op_i = 0;
    `ASSERT_EQ(tt_periph_dut.photon_time.arm, 0, "Time Tagger Not Entering Disarmed state")
    @(posedge c_clk); #0.1;
end
endtask

task QP_READOUT_CMD(integer exp_time, exp_status); begin
    $display("Reading Value from Time Tagger");
    qp_op_i = `READOUT_CMD;
    qp_en_i = 1'b1;
    wait(qp_rdy_o);
    @ (posedge c_clk); #0.1;
    qp_op_i = 7'd0;
    qp_en_i = 1'b0;
    @ (posedge c_clk); #0.1;
    `ASSERT_EQ(qp_dt1_o, exp_time, "Incorrect Time Recorded from Tproc Read");
    `ASSERT_EQ(qp_dt2_o, exp_status, "Incorrect Status Recorded");
    `ASSERT_EQ(qp_vld_o, 1, "Data should be valid");

end
endtask

// Recieving Commands from Python AXI // 
task SWITCH_TO_AXI_OP(); begin
    @ (posedge ps_clk); #0.1;
    r_qp_cfg[7] = 1'b1;
    @ (posedge ps_clk); #0.1; // Only need one cycle to configure
end
endtask

task AXI_ARM_CMD(); begin
    $display("Arming Time Tagger");
    @ (posedge ps_clk); #0.1;
    r_qp_ctrl[0] = 1;
    r_qp_ctrl[5:1] = `ARM_CMD;
    @ (posedge c_clk); #(`T_C_CLK * 3 * 2 + 0.1 ); // Three Cycles Guaranteed Synced Signal
    `ASSERT_EQ(tt_periph_dut.c_op_r, 0, "AXI not pulsing command")
    @ (posedge ps_clk); #0.1;
    `ASSERT_EQ(tt_periph_dut.photon_time.arm, 1, "Time Tagger Not Entering Armed State")
    r_qp_ctrl = '0;
    @(posedge c_clk); #0.1;
end
endtask

task AXI_DISARM_CMD(); begin
    $display("Disarming Time Tagger");
    @ (posedge ps_clk); #0.1;
    r_qp_ctrl[0] = 1;
    r_qp_ctrl[5:1] = `DISARM_CMD;
     @ (posedge c_clk); # (`T_C_CLK * 3 *2 + 0.1); // Three Cycles Guaranteed Synced Signal
    `ASSERT_EQ(tt_periph_dut.c_op_r, 0, "AXI not pulsing command")
    @ (posedge c_clk); #0.1;
    `ASSERT_EQ(tt_periph_dut.photon_time.arm, 0, "Time Tagger Not Disarming")
    @ (posedge ps_clk); #0.1;
    r_qp_ctrl = '0;
    @(posedge c_clk); #0.1;
end
endtask

task AXI_READOUT_CMD(integer exp_time, exp_status ); begin
    $display("Reading Data Time Tagger");
    @ (posedge ps_clk); #0.1;
    r_qp_ctrl[0] = 1;
    r_qp_ctrl[5:1] = `READOUT_CMD;
    @ (posedge c_clk); # (`T_C_CLK * 3 *2 + 0.1); // Three Cycles Guaranteed Synced Signal
    `ASSERT_EQ(tt_periph_dut.c_op_r, 0, "AXI not pulsing command")
    @ (posedge c_clk); #0.1;
    `ASSERT_EQ(r_qp_dt1, exp_time, "Incorrect Time Recorded from Tproc Read")
    `ASSERT_EQ(r_qp_status , exp_status, "Incorrect Status Recorded")
    @ (posedge ps_clk); #0.1 
    r_qp_ctrl = '0;
    @(posedge c_clk); #0.1;
end
endtask

int sim_en = 1;
initial begin
    while (sim_en) begin
        wait ( (tt_periph_dut.tt_arm) );
        if (tt_periph_dut.axi_arm) #(`T_C_CLK * 2* 3);
        PHOTON_ADC_SAMPLES();
        cycles = cycles+1;
    end
end

int test_case = 0;
initial begin
    START_SIMULATION();

    // First Test the interface with Tproc // 
    test_case = 1; // Passed 
    cycles = 0;
    SWITCH_TO_QP_OP();

    QP_ARM_CMD();

    wait (t == (photon_length-2));

    QP_DISARM_CMD();

    QP_READOUT_CMD(206, 0);

    @ (posedge c_clk); 
    @ (posedge c_clk);

    // Test AXI Configuration // 
    test_case = 2; // Passed 
    cycles = 0;
    SWITCH_TO_AXI_OP();

    AXI_ARM_CMD();

    wait (t == (photon_length-5));

    AXI_DISARM_CMD();

    AXI_READOUT_CMD(222, 0);

    @ (posedge c_clk); 
    @ (posedge c_clk);

    // Test Status Register for Two Samples
    test_case = 3; // Passed 
    cycles = 0;
    SWITCH_TO_QP_OP();

    QP_ARM_CMD();

    wait (t == (photon_length-2) && ( cycles == 1));

    QP_DISARM_CMD();

    QP_READOUT_CMD(206, 1);

    QP_READOUT_CMD((206+992), 0);

    // Test Multple Edges from AXI control // 
    test_case = 4;
    cycles = 0;

    SWITCH_TO_AXI_OP();

    AXI_ARM_CMD();

    wait (t == (photon_length-5) && ( cycles == 3))

    AXI_DISARM_CMD();

    AXI_READOUT_CMD(222, 3);

    @ (posedge c_clk); 

    AXI_READOUT_CMD(222+992, 2);

    @ (posedge c_clk); 

    AXI_READOUT_CMD(222+992*2, 1);

    @ (posedge c_clk); 

    AXI_READOUT_CMD(222+992*3, 0);

    @ (posedge c_clk); 

    sim_en = 0;

end

endmodule 