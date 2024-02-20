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
module qick_periph #(
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
   input  wire             qp_signal_i ,
   input  wire  [47:0]     qp_time     , 
// OUTPUTS
   output reg              qp_signal_o ,
   output reg   [31:0]     qp_vector_o ,
// DEBUG   
   output wire [31:0]      qp_do     );


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
// ASYNCHONOUS INPUT SYNCRONIZATION
///////////////////////////////////////////////////////////////////////////////

// Using Axis Stream Signals instead
// wire  qp_signal_r;
// sync_reg # (
//    .DW ( 1 )
// ) sg_sync (
//    .dt_i      ( qp_signal_i    ) ,
//    .clk_i     ( clk_i    ) ,
//    .rst_ni    ( rst_ni   ) ,
//    .dt_o      ( qp_signal_r   ) );

// wire [31:0] qp_vector_r;
// sync_reg # (
//    .DW ( 32 )
// ) vec_sync (
//    .dt_i      ( qp_vector_i    ) ,
//    .clk_i     ( clk_i    ) ,
//    .rst_ni    ( rst_ni   ) ,
//    .dt_o      ( qp_vector_r   ) );
   
///////////////////////////////////////////////////////////////////////////////
// PERIPHERAL PROCESSING
///////////////////////////////////////////////////////////////////////////////
wire xreg_QP_DT1 = AXI_DT1 ;
wire xreg_QP_DT2 = AXI_DT2 ;
wire xreg_QP_DT3 = AXI_DT3 ;
wire xreg_QP_DT4 = AXI_DT4 ;



///////////////////////////////////////////////////////////////////////////////
// INTERFACE FOR TIME TAGGER
///////////////////////////////////////////////////////////////////////////////
wire [31:0] fifo_out, status;
wire fifo_empty;
wire arm, read_toa;
wire [T_W-1:0] start_time, curr_time;       


qick_tt_intf #(
   .T_W           (T_W)
) photon_time_to_qick (
   .clk_i         (clk_i)        ,
   .rst_ni        (rst_ni)       ,

   .qp_en_i       (qp_en_i)      ,
   .qp_op_i       (qp_op_i)      ,
   .qp_dt1_i      (qp_dt1_i)     ,

   .qp_time       (qp_time)      ,

   .fifo_out      (fifo_out)     , // Input Time Tagger
   .status        (status)       , // Input Time Tagger
   .fifo_empty    (fifo_empty)   ,

   .arm           (arm)          , // Output to Time Tagger
   .start_time    (start_time)   , // Output to Time Tagger
   .curr_time     (curr_time)    , // Output to Time Tagger
   .read_toa      (read_toa)     , // Output to Time Tagger

   .qp_ready_i    (qp_rdy_o)     , 
   .qp_vld_i      (qp_vld_o)     ,
   .qp_flag       (qp_flag_o)    ,
   .qp_dt1_o      (qp_dt1_o)     
);


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

   .arm              (arm)             ,   // From Interface
   .start_time       (start_time)      ,   // From Interface
   .curr_time        (curr_time)       ,
   .read_toa         (read_toa)        ,   // From Interface

   .fifo_out         (fifo_out)        ,   // To Interface 
   .status           (status)          ,   // To Interface
   .fifo_empty       (fifo_empty)          // To Interface
);



///////////////////////////////////////////////////////////////////////////////
// OUTPUTS
///////////////////////////////////////////////////////////////////////////////

// AXI REGISTERS
assign   QP_DT1      = xreg_QP_DT1 ;
assign   QP_DT2      = xreg_QP_DT2 ;
assign   QP_DT3      = xreg_QP_DT3 ;
assign   QP_DT4      = xreg_QP_DT4 ;
assign   QP_STATUS   = 0 ;

// REGISTERES OUTs
always_ff @ (posedge clk_i, negedge rst_ni) begin
   if (!rst_ni) begin
      qp_signal_o       <= 1'b0;
   end else begin
      qp_signal_o       <= qp_signal_r;
      qp_vector_o       <= qp_vector_r;
   end
end

endmodule
