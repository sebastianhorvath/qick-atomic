`timescale 1ns/10ps

import axi_vip_pkg::*;
import axi_mst_0_pkg::*;

`include "./tb_macros.svh"
`include "../headers/cmd_err.svh"


module tb_qtt_axi();

axi_mst_0_mst_t        axi_mst_0_agent;
xil_axi_prot_t  prot        = 0;
xil_axi_resp_t  resp, rresp;

reg c_clk, ps_clk, t_clk;
reg rst_ni;

//AXI-LITE
wire [7:0]             s_axi_awaddr  ;
wire [2:0]             s_axi_awprot  ;
wire                   s_axi_awvalid ;
wire                   s_axi_awready ;
wire [31:0]            s_axi_wdata   ;
wire [3:0]             s_axi_wstrb   ;
wire                   s_axi_wvalid  ;
wire                   s_axi_wready  ;
wire  [1:0]            s_axi_bresp   ;
wire                   s_axi_bvalid  ;
wire                   s_axi_bready  ;
wire [7:0]             s_axi_araddr  ;
wire [2:0]             s_axi_arprot  ;
wire                   s_axi_arvalid ;
wire                   s_axi_arready ;
wire  [31:0]           s_axi_rdata   ;
wire  [1:0]            s_axi_rresp   ;
wire                   s_axi_rvalid  ;
wire                   s_axi_rready  ;

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

// Register ADDRESS
parameter QP_CTRL     = 0 * 4 ;
parameter QP_CFG      = 1 * 4 ;
parameter AXI_DT1     = 2 * 4 ;
parameter AXI_DT2     = 3 * 4 ;
parameter AXI_DT3     = 4 * 4 ;
parameter AXI_DT4     = 5 * 4 ;
parameter QP_DT1      = 7 * 4 ;
parameter QP_DT2      = 8 * 4 ;
parameter QP_DT3      = 9 * 4 ;
parameter QP_DT4      = 10 * 4 ;
parameter QP_DELAY    = 11 * 4 ;
parameter QP_FRAC     = 12 * 4 ;
parameter QP_THRES    = 13 * 4 ;
parameter QP_STATUS   = 14 * 4 ;
parameter QP_DEBUG    = 15 * 4 ;

// Parameters for Time Tagger 

parameter integer FIFO_WIDTH = 7;
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

reg [DATA_WIDTH*NUM_SAMPLES-1:0] s_axis_tdata; 
reg [DATA_WIDTH-1:0] adc_memory [0:1023];

// Other Connections
///////////////////////////////////////////////////////////////////////
reg s_axis_tvalid, s_axis_tready;
reg begin_time;
reg [47:0] qp_time;

///////////////////////////////////////////////////////////////////////
// AXI AGENT
axi_mst_0 axi_mst_0_i (
   .aclk			(ps_clk		   ),
   .aresetn		    (rst_ni	       ),
   .m_axi_araddr	(s_axi_araddr	),
   .m_axi_arprot	(s_axi_arprot	),
   .m_axi_arready	(s_axi_arready	),
   .m_axi_arvalid	(s_axi_arvalid	),
   .m_axi_awaddr	(s_axi_awaddr	),
   .m_axi_awprot	(s_axi_awprot	),
   .m_axi_awready	(s_axi_awready	),
   .m_axi_awvalid	(s_axi_awvalid	),
   .m_axi_bready	(s_axi_bready	),
   .m_axi_bresp	    (s_axi_bresp	),
   .m_axi_bvalid	(s_axi_bvalid	),
   .m_axi_rdata	    (s_axi_rdata	),
   .m_axi_rready	(s_axi_rready	),
   .m_axi_rresp	    (s_axi_rresp	),
   .m_axi_rvalid	(s_axi_rvalid	),
   .m_axi_wdata	    (s_axi_wdata	),
   .m_axi_wready	(s_axi_wready	),
   .m_axi_wstrb	    (s_axi_wstrb	),
   .m_axi_wvalid	(s_axi_wvalid	)
);

axi_qick_peripheral #(
    .DT_W               (DATA_WIDTH),
    .N_S                (NUM_SAMPLES),
    .T_W                (TIME_WIDTH), 
    .FIFO_W             (FIFO_WIDTH),
    .DTR_RST            (DETECTOR_RESET)
) qtt_periph_axi (
    .c_clk                  (  c_clk  ) ,
    .c_aresetn              (  rst_ni ) ,
    .ps_clk                 (  ps_clk ) ,
    .ps_aresetn             (  rst_ni ) ,
    .qp_en_i                (  )        ,
    .qp_op_i                (  )        ,
    .qp_rdy_o               (  )        ,
    .qp_dt1_o               (  )        ,
    .qp_dt2_o               (  )        ,
    .qp_vld_o               (  )        ,
    .qp_flag_o              (  )        ,
    .qp_time                ( qp_time )        ,
    // AXI Stream
    .s_axis_tdata           ( s_axis_tdata  )        ,
    .s_axis_tvalid          ( s_axis_tvalid )        ,
    .s_axis_tready          ( s_axis_tready )        ,
    // AXI Lite 
    .s_axi_awaddr           ( s_axi_awaddr  )        ,
    .s_axi_awprot           ( s_axi_awprot  )        ,
    .s_axi_awvalid          ( s_axi_awvalid )        ,
    .s_axi_awready          ( s_axi_awready )        ,
    .s_axi_wdata            ( s_axi_wdata   )        ,
    .s_axi_wstrb            ( s_axi_wstrb   )        ,
    .s_axi_wvalid           ( s_axi_wvalid  )        ,
    .s_axi_wready           ( s_axi_wready  )        ,
    .s_axi_bresp            ( s_axi_bresp   )        ,
    .s_axi_bvalid           ( s_axi_bvalid  )        ,
    .s_axi_bready           ( s_axi_bready  )        ,
    .s_axi_araddr           ( s_axi_araddr  )        ,
    .s_axi_arprot           ( s_axi_arprot  )        ,
    .s_axi_arvalid          ( s_axi_arvalid )        ,
    .s_axi_arready          ( s_axi_arready )        ,
    .s_axi_rdata            ( s_axi_rdata )        ,
    .s_axi_rresp            ( s_axi_rresp )        ,
    .s_axi_rvalid           ( s_axi_rvalid )        ,
    .s_axi_rready           ( s_axi_rready )        ,
    .qp_do                  ( )
);


task START_SIMULATION (); begin
    $display("Start Simulation");
    $readmemb("../firmware/ip/qick_peripheral_template/TB/Mem_dt/nanowire1.txt", adc_memory);
    // Create Agents
    axi_mst_0_agent  = new("axi_mst_0 VIP Agent", tb_qtt_axi.axi_mst_0_i.inst.IF);

    axi_mst_0_agent.set_agent_tag("axi_mst_0 VIP");
    axi_mst_0_agent.start_master();

    begin_time = 1;
    qp_time = 0;
    rst_ni = 0;
    s_axis_tdata = '0;
    s_axis_tvalid = 1;

    @ (posedge ps_clk); #0.1;
    rst_ni = 1; 

end
endtask

// Generating Waveform Task 

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

        s_axis_tdata = {s7, s6, s5, s4, s3, s2, s1, s0};

        @ (posedge t_clk); #0.1; 
    end

    s_axis_tdata = '0;
end
endtask

// AXI MASTER TASKS 
task WRITE_AXI(integer PORT_AXI, DATA_AXI); begin
   @ (posedge ps_clk); #0.1;
   axi_mst_0_agent.AXI4LITE_WRITE_BURST(PORT_AXI, prot, DATA_AXI, resp);
   end
endtask

task READ_AXI(input int R_PORT_AXI, output int R_DATA_AXI); begin
    @ (posedge ps_clk); #0.1;
    axi_mst_0_agent.AXI4LITE_READ_BURST(R_PORT_AXI, prot, R_DATA_AXI, rresp);
end
endtask

// Simulation Test Tasks
task SWITCH_TO_AXI_OP(); begin
    $display("Switching to AXI CMDS");
    WRITE_AXI(QP_CFG, 128); // This sets the top bit of QP_CFG 
    @ (posedge ps_clk); @ (posedge ps_clk); #0.1;
end
endtask

task SET_THRESHOLD(input int THRESHOLD); begin
    $display("Setting threshold to %d", THRESHOLD);
    WRITE_AXI(QP_THRES, THRESHOLD);
    @ (posedge ps_clk); @ (posedge ps_clk); #0.1;
end
endtask

task AXI_ARM_CMD(); begin
    $display("Arming Time Tagger");
    WRITE_AXI(QP_CTRL, ((`ARM_CMD << 1) + 1 )); // Arm the AXI Interface
    @ (posedge ps_clk); @ (posedge ps_clk); #0.1;
    WRITE_AXI(QP_CTRL, 0); // Turn off the command
    @ (posedge ps_clk); #0.1;
end
endtask

task AXI_DISARM_CMD(); begin
    $display("Disarming Time Tagger");
    WRITE_AXI(QP_CTRL, ((`DISARM_CMD << 1) + 1 )); // Disarm the AXI Interface
    @ (posedge ps_clk); @ (posedge ps_clk); #0.1;
    WRITE_AXI(QP_CTRL, 0); // Turn off the command
    @ (posedge ps_clk); #0.1;
end
endtask

task AXI_READOUT_CMD(); begin
    $display("Reading Data Time Tagger");
    WRITE_AXI(QP_CTRL, ((`READOUT_CMD << 1) + 1 ));
    @ (posedge ps_clk); #0.1; @ (posedge ps_clk); #0.1;
    WRITE_AXI(QP_CTRL, 0); // Turn off the command
    @ (posedge ps_clk); #0.1;
end
endtask

// Check the Result
task AXI_READ_DATA(input int DATA_REG, output int toa); begin
    $display("Reading Detection Times from AXI Reg QP_DT%d", DATA_REG);
    READ_AXI(QP_DT1 + (4*(DATA_REG-1)), toa);
    @ (posedge ps_clk); #0.1;
    $display("At simulation time: %d, value in AXI Reg QP_DT%d was %d", $time, DATA_REG, toa);
end
endtask

// QP Time
initial begin
    while (begin_time) begin
        qp_time = qp_time + 1;
    end
end

// Generate Data
int sim_en = 1;
initial begin
    while (sim_en) begin
        wait ( (qtt_periph_axi.qtt.axi_arm ));
        PHOTON_ADC_SAMPLES();
    end
end

int toa;
initial begin 

    START_SIMULATION();

    @ (posedge ps_clk);    
    SWITCH_TO_AXI_OP();

    SET_THRESHOLD(1024);

    AXI_ARM_CMD();

    wait ( t == (photon_length - 5));

    AXI_DISARM_CMD();

    AXI_READOUT_CMD();

    AXI_READ_DATA(1, toa);

    sim_en = 0;

end 

endmodule 