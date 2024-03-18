`timescale 1ns/10ps 

`include "../headers/cmd_err.svh"
`include "./tb_macros.svh"

module qtt_intf();

reg c_clk, ps_clk;
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

// Inputs to tt_qcom 
reg qp_en_i;
reg [4:0] qp_op_i;
reg [31:0] qp_dt1_i;
reg [31:0] fifo_in, status;
reg fifo_empty;

// Outputs from tt_qcom 
reg armed, read_toa; 
reg next_op;

reg qp_ready_i, qp_vld_o, qp_flag;
reg [31:0] qp_dt1_o, qp_dt2_o;

// tt_qcom
////////////////////////////////////////////////////////////////////////////////
tt_qcom #(
    .T_W            (32)
) dut_tt_qcom (
    .clk_i          (c_clk),
    .rst_ni         (rst_ni),
    .qp_en_i        (qp_en_i),
    .qp_op_i        (qp_op_i),
    .qp_dt1_i       (qp_dt1_i),
    .fifo_in        (fifo_in),
    .status         (status),
    .fifo_empty     (fifo_empty),
    .armed          (armed),
    .read_toa       (read_toa),
    .qp_ready_i     (qp_ready_i),
    .qp_vld_o       (qp_vld_o),
    .qp_flag        (qp_flag),
    .qp_dt1_o       (qp_dt1_o),
    .qp_dt2_o       (qp_dt2_o)
);

// FIFO Module for Tests
////////////////////////////////////////////////////////////////////////////////////
reg wr_en;
reg [31:0] din;
reg [2:0] val_count;

tt_fifo #(
    .B      (32),
    .N      (8),
    .N_W    (3)
) test_tt_fifo (
    .clk            (c_clk),
    .rstn           (rst_ni),
    .wr_en          (wr_en),
    .din            (din),
    .rd_en          (read_toa),
    .dout           (fifo_in),
    .d_count        (val_count),
    .full           (),
    .empty          (fifo_empty)
);

// Testbench for the Interface
////////////////////////////////////////////////////////////////////////////////////
task LOAD_FIFO(integer data); begin
        @ (posedge c_clk); #0.1;
        din = data;
        wr_en = 1'b1;
        @ (posedge c_clk); #0.1;
        wr_en = 1'b0;
        din = 0;
    end
endtask

task START_SIMULATION (); begin
    $display("Starting Simulation");
    rst_ni = 1'b0;

    qp_en_i = 1'b0;  
    qp_op_i = 0;
    qp_dt1_i = 0;
    din = 0;
    wr_en = 1'b0;

    @ (posedge c_clk); #0.1;
    rst_ni = 1'b1;

    end
endtask

task ARM (); begin
    $display("Arming Time Tagger");
    qp_op_i = `ARM_CMD;
    qp_en_i = 1'b1;
    next_op = qp_ready_i;
    @ (posedge c_clk); #0.1;
    if (!next_op) begin
        @ (posedge c_clk);
        @ (posedge c_clk);
    end
    qp_op_i = 0;
    qp_en_i = 0;
    next_op = 0;
    end
endtask 

task DISARM (); begin
    $display("Disarming Time Tagger");
    qp_op_i = `DISARM_CMD;
    qp_en_i = 1'b1;
    next_op = qp_ready_i;
    @ (posedge c_clk); #0.1;
    if (!next_op) begin
        @ (posedge c_clk);
        @ (posedge c_clk);
    end
    qp_op_i = 0;
    qp_en_i = 0;
    next_op = 0;
end
endtask 

task READOUT (); begin
    $display(" Reading out Values ");
    qp_op_i = `READOUT_CMD;
    qp_en_i = 1;
    next_op = qp_ready_i;
    @ (posedge c_clk); #0.1;
    if (!next_op) begin
        @ (posedge c_clk);
        @ (posedge c_clk);
    end
    qp_op_i = 0;
    qp_en_i = 0;
    next_op = 0;
end
endtask

// Different Test Cases 
////////////////////////////////////////////////////////////////////////////////////

initial begin
    START_SIMULATION();
    LOAD_FIFO(20);
    LOAD_FIFO(5);
    LOAD_FIFO(256);
    LOAD_FIFO(1);

    `ASSERT_EQ(val_count, 2, "Fifo Counter not Correct")
    // Begin Test cases 
    `ASSERT_EQ(qp_ready_i, 1'b1, "Time Tagger not ready to Recieve")

    // ARM and DISARM Base Test
    @ (posedge c_clk); #0.1;
    ARM (); // ARM, DISARM, READOUT require an @posedge c_clk before they are called

    `ASSERT_EQ(armed, 1'b1, "Err: Time Tagger Failed to ARM")

    # (10 * `T_C_CLK);

    @ (posedge c_clk); #0.1;
    DISARM ();

    `ASSERT_EQ(armed, 1'b0, "Err: Time Tagger Failed to DISARM")
    
    // Test the Readout while disarmed
    @ (posedge c_clk); #0.1;
    READOUT ();
    @ (posedge c_clk); // Takes two clock cycles
    `ASSERT_EQ(read_toa, 1'b1, "Err: Time Tagger not sending read")
    `ASSERT_EQ(qp_vld_o, 1'b1, "Time Tagger not sending a valid value")
    `ASSERT_EQ(qp_dt1_o, 20, "Time Tagger Read Wrong Value from FIFO")

    // Test the Readout while Armed 
    @ (posedge c_clk); #0.1;
    ARM ();
    READOUT ();
    `ASSERT_EQ(read_toa, 1'b1, "Err: Time Tagger not sending read")
    @ (posedge c_clk); #0.1; // Two Clock Cycles
    `ASSERT_EQ(qp_vld_o, 1'b1, "Time Tagger not sending a valid value")
    `ASSERT_EQ(qp_dt1_o, 5, "Time Tagger Read Wrong Value from FIFO")
    
    # (10 * `T_C_CLK);

    @ (posedge c_clk); #0.1;
    DISARM ();

    // Test Readout while Reading

    READOUT ();
    `ASSERT_EQ(read_toa, 1'b1, "Err: Time Tagger not sending read")
    READOUT ();
    `ASSERT_EQ(qp_dt1_o, 256, "Wrong value from FIFO")
    `ASSERT_EQ(qp_vld_o, 1'b1, "Time Tagger not sending a valid value")
    `ASSERT_EQ(read_toa, 1'b1, "Err: Time Tagger not sending read")
    @ (posedge c_clk); #0.1; // Two Clock Cycles
    `ASSERT_EQ(qp_vld_o, 1'b1, "Time Tagger not sending a valid value")
    `ASSERT_EQ(qp_dt1_o, 256, "Wrong value from FIFO")
    
    @ (posedge c_clk); #0.1; // Two Clock Cycles
end

endmodule