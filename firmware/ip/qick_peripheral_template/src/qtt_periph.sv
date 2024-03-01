///////////////////////////////////////////////////////////////////////////////
//  FERMI RESEARCH LAB
///////////////////////////////////////////////////////////////////////////////
//  Author         : Martin Di Federico
//  Date           : 1-2024
//  Version        : 1
///////////////////////////////////////////////////////////////////////////////
//  QICK PROCESSOR :  Custom Peripheral Template
/* Description: 
    Core processing unit: implement here the peripheral.
    Eventually name this time tagger top 
*/
//////////////////////////////////////////////////////////////////////////////

`define ARM_CMD 1
`define DISARM_CMD 2
`define READ_CMD 3

module qtt_periph #(
   parameter DT_W       =  16 ,
   parameter FIFO_DEP   = 128 ,
   parameter T_W        =  32 ,   // Length of the photon detection cd experiment = 2^32
   parameter N_S        =   8 ,
   parameter DTR_RST    =  10     //Clock Cycles    
) (
// Core CLK & RST
   input  wire          clk_i          ,
   input  wire          rst_ni         ,
// QPERIPH INTERFACE
   input  wire             qp_en_i     , //
   input  wire  [ 4:0]     qp_op_i     , //
   input  wire  [31:0]     qp_dt1_i    , //
   input  wire  [31:0]     qp_dt2_i    , // 
   input  wire  [31:0]     qp_dt3_i    , // 
   input  wire  [31:0]     qp_dt4_i    , // 
   output reg              qp_rdy_o    , // 
   output reg   [31:0]     qp_dt1_o    , // 
   output reg   [31:0]     qp_dt2_o    , // 
   output reg              qp_vld_o    , // 
   output reg              qp_flag_o   , // 
// Axis Stream Signals
   input  wire  [N_S*DT_W-1:0] qp_vector_i ,
   output wire             qp_tready   ,
   input  wire             qp_tvalid   ,
// AXI REG
   input  wire  [ 7:0]     QP_CTRL     ,
   input  wire  [ 7:0]     QP_CFG      ,
   input  wire  [31:0]     QP_DELAY    ,
   input  wire  [31:0]     QP_FRAC     ,
   input  wire  [31:0]     QP_THRES    ,
   input  wire  [31:0]     AXI_DT1     ,
   input  wire  [31:0]     AXI_DT2     ,
   input  wire  [31:0]     AXI_DT3     ,
   input  wire  [31:0]     AXI_DT4     ,
   output reg   [31:0]     QP_DT1      ,
   output reg   [31:0]     QP_DT2      ,
   output reg   [31:0]     QP_DT3      ,
   output reg   [31:0]     QP_DT4      ,
   output reg   [31:0]     QP_STATUS   ,
   output reg   [31:0]     QP_DEBUG    ,
// INPUTS 
   input  wire  [47:0]     qp_time     , 
// DEBUG   
   output wire [31:0]      qp_do     );

wire [T_W-1:0] curr_time;

//Axi Stream Handling
assign qp_tready = 1;
wire [DT_W*N_S-1:0] tdata = qp_tvalid ? qp_vector_i : '0;

///////////////////////////////////////////////////////////////////////////////
// Python Command SYNCRONIZATION
///////////////////////////////////////////////////////////////////////////////
// Control Signal SYNC 
wire [ 5:0] axi_ctrl ;
sync_reg # (
   .DW ( 6 )
)cmd_sync (
   .dt_i      ( QP_CTRL[5:0]    ) ,
   .clk_i     ( clk_i    ) ,
   .rst_ni    ( rst_ni   ) ,
   .dt_o      ( axi_ctrl   ) );

wire p_cmd_in     =  axi_ctrl[0] ; 

reg [ 7:0] p_cmd_in_r ;

always_ff @ (posedge clk_i, negedge rst_ni) begin
   if   (!rst_ni) p_cmd_in_r <= 1'b0; 
   else           p_cmd_in_r <= p_cmd_in;
end
//Single Pulse Control Signal
wire p_cmd_in_t01 =  !p_cmd_in_r & p_cmd_in;


///////////////////////////////////////////////////////////////////////////////
// Input Command and Data 
///////////////////////////////////////////////////////////////////////////////
reg  [ 4:0] c_op_r ;
reg  [31:0] c_dt1_r, c_dt2_r ;

// REGISTERES INs
always_ff @ (posedge clk_i, negedge rst_ni) begin
   if (!rst_ni) begin
      c_op_r      <= 1'b0;
      c_dt1_r     <= '{default:'0} ;
      c_dt2_r     <= '{default:'0} ;
   end else if (p_cmd_in_t01) begin
   // Command from Python Interface    
      c_op_r      <= axi_ctrl[5:1];
      c_dt1_r     <= AXI_DT1;
      c_dt2_r     <= AXI_DT2;
   end else if (qp_en_i) begin
   // Command from QPROC Interface    
      c_op_r      <= qp_op_i[4:0];
      c_dt1_r     <= qp_dt1_i;
      c_dt2_r     <= qp_dt1_i;
   end
end
   
///////////////////////////////////////////////////////////////////////////////
// Communication for ZYNQ (AXI)
///////////////////////////////////////////////////////////////////////////////
wire xreg_QP_DT1 = AXI_DT1 ;
wire xreg_QP_DT2 = AXI_DT2 ;
wire xreg_QP_DT3 = AXI_DT3 ;
wire xreg_QP_DT4 = AXI_DT4 ;

reg axi_arm;
wire axi_fifo_empty, axi_read_toa;
wire [31:0] axi_toa_dt, axi_tt_status;
reg [T_W-1:0] axi_start_time; // Start time for the data acquistion 

always_ff @ (posedge clk_i, negedge rst_ni) begin
   if (!rst_ni) begin
      axi_arm <= 0;
   end 
   else begin
      if ((axi_arm == 1) & (axi_start_time == curr_time)) begin
         axi_arm <= 0;
      end
      else begin
         case (c_op_r)
            `ARM_CMD: begin
               axi_arm <= 1;
               axi_start_time <= qp_time;
            end
            `DISARM_CMD: begin
               axi_arm <= 0;
            end
            `READ_CMD: begin
               // Handle Error Message inside the Time Tagger Module
               axi_read_toa <= 1;
            end
         endcase
      end
   end
end



///////////////////////////////////////////////////////////////////////////////
// INTERFACE FOR Tproc Communication (QP)
///////////////////////////////////////////////////////////////////////////////
wire qp_fifo_empty;
wire qp_arm, qp_read_toa;
wire [T_W-1:0] qp_start_time; 
wire [31:0] qp_fifo_in, qp_tt_status;    


tt_qcom #(
   .T_W           (T_W)
) photon_time_to_qick (
   .clk_i         (clk_i)        ,
   .rst_ni        (rst_ni)       ,

   .qp_en_i       (qp_en_i)      ,
   .qp_op_i       (qp_op_i)      ,
   .qp_dt1_i      (qp_dt1_i)     ,

   .fifo_in       (qp_fifo_in)   , // Input Time Tagger
   .status        (qp_tt_status) , // Input Time Tagger
   .fifo_empty    (qp_fifo_empty),

   .armed         (qp_arm)        , // Output to Time Tagger
   .read_toa      (qp_read_toa)   , // Output to Time Tagger

   .qp_ready_i    (qp_rdy_o)     , 
   .qp_vld_i      (qp_vld_o)     ,
   .qp_flag       (qp_flag_o)    ,
   .qp_dt1_o      (qp_dt1_o)     
);

///////////////////////////////////////////////////////////////////////////////
// Muxing / Demuxing between ZYNQ and Trpoc
///////////////////////////////////////////////////////////////////////////////
wire [31:0] tt_fifo_out, tt_status;
wire tt_fifo_empty;

// Arming and Start Time determined by if AXI or not
wire tt_arm = QP_CFG[7] ? axi_arm : qp_arm;
wire [T_W-1:0] tt_start_time = QP_CFG[7] ? axi_start : qp_start_time; 

wire [31:0] toa_dt;
wire tt_read_toa = QP_CFG[7] ? axi_read_toa : qp_read_toa;

// Tproc Multiplexing
assign qp_fifo_in = ( !QP_CFG[7] ) ? tt_fifo_out : '0;
assign qp_tt_status = ( !QP_CFG[7] ) ? tt_status : '0; 
assign qp_fifo_empty = ( !QP_CFG[7] ) ? tt_fifo_empty : 1'b1;

// Axi Multiplexing
assign axi_toa_dt = QP_CFG[7] ? tt_fifo_out : '0;
assign axi_tt_status = QP_CFG[7] ? tt_status : '0;
assign axi_fifo_empty = QP_CFG[7] ? tt_fifo_empty : 1'b1;

///////////////////////////////////////////////////////////////////////////////
// TAGGER
///////////////////////////////////////////////////////////////////////////////

time_tagger #(
   .FIFO_DEP         (FIFO_DEP)        ,
   .T_W              (T_W)             ,
   .DT_W             (DT_W)            ,
   .N_S              (N_S)             ,
   .DTR_RST          (DTR_RST)      
) photon_time (
   .clk_i            (clk_i)           ,
   .rst_ni           (rst_ni)          ,
   .tdata            (tdata)           ,
   .threshold        (QP_THRES)        ,   // Add this to the AXI Register Addressing
   .arm              (tt_arm)          ,   // From Interface
   .read_toa         (tt_read_toa)     ,
   .fifo_out         (tt_fifo_out)     ,   // From Interface
   .status           (tt_status)       ,   // To Interface
   .fifo_empty       (tt_fifo_empty)          // To Interface
);

///////////////////////////////////////////////////////////////////////////////
// OUTPUTS
///////////////////////////////////////////////////////////////////////////////

// AXI REGISTERS
assign   QP_DT1      = axi_toa_dt ;
assign   QP_DT2      = 0 ;
assign   QP_DT3      = xreg_QP_DT3 ;
assign   QP_DT4      = xreg_QP_DT4 ;
assign   QP_STATUS   = axi_tt_status ;

endmodule
