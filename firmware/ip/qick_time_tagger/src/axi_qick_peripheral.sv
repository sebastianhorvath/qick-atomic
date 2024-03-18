///////////////////////////////////////////////////////////////////////////////
//  FERMI RESEARCH LAB
///////////////////////////////////////////////////////////////////////////////
//  Author         : Martin Di Federico
//  Date           : 1-2024
//  Version        : 1
///////////////////////////////////////////////////////////////////////////////
//  QICK PROCESSOR :  Custom Peripheral Template
/* Description: 
    Top Level of the Peripheral Template. It includes two modules
    1) The axi_qick_peripheral core processing unit
    2) The Axi Register, used to read and write from Python.
*/
//////////////////////////////////////////////////////////////////////////////

module axi_qick_peripheral # (
   parameter DT_W      = 16,
   parameter N_S       =  8,
   parameter T_W       = 32,
   parameter FIFO_W    =  7,
   parameter DTR_RST   = 10,
   parameter DEBUG     = 0
) (
// Core and AXI CLK & RST
   input  wire             c_clk          , // Right now c_clk and t_clk are the same
   input  wire             c_aresetn      ,
   input  wire             ps_clk         ,
   input  wire             ps_aresetn     ,
// QPERIPH INTERFACE
   input  wire             qp_en_i        , //
   input  wire  [ 4:0]     qp_op_i        , //
   input  wire  [31:0]     qp_dt1_i       , //
   // input  wire  [31:0]     qp_dt2_i       , // 
   // input  wire  [31:0]     qp_dt3_i       , // 
   // input  wire  [31:0]     qp_dt4_i       , // 
   output reg              qp_rdy_o       , // 
   output reg   [31:0]     qp_dt1_o       , // 
   output reg   [31:0]     qp_dt2_o       , // 
   output reg              qp_vld_o       , // 
   output reg              qp_flag_o      , // 
// INPUTS 
   input  wire  [47:0]     qp_time        ,
// AXIS Signals
   input  wire  [N_S*DT_W-1:0] s_axis_tdata ,
   input  wire             s_axis_tvalid  ,
   output reg              s_axis_tready  ,
// AXI-Lite DATA Slave I/F.   
   input  wire [5:0]       s_axi_awaddr   ,
   input  wire [2:0]       s_axi_awprot   ,
   input  wire             s_axi_awvalid  ,
   output wire             s_axi_awready  ,
   input  wire [31:0]      s_axi_wdata    ,
   input  wire [ 3:0]      s_axi_wstrb    ,
   input  wire             s_axi_wvalid   ,
   output wire             s_axi_wready   ,
   output wire [ 1:0]      s_axi_bresp    ,
   output wire             s_axi_bvalid   ,
   input  wire             s_axi_bready   ,
   input  wire [ 5:0]      s_axi_araddr   ,
   input  wire [ 2:0]      s_axi_arprot   ,
   input  wire             s_axi_arvalid  ,
   output wire             s_axi_arready  ,
   output wire [31:0]      s_axi_rdata    ,
   output wire [ 1:0]      s_axi_rresp    ,
   output wire             s_axi_rvalid   ,
   input  wire             s_axi_rready   ,
///// DEBUG   
   output wire [31:0]      qp_do        
   );


///////////////////////////////////////////////////////////////////////////////
// AXI Register.
wire [ 7:0] r_qp_ctrl;
wire [ 7:0] r_qp_cfg;
wire [31:0] r_qp_threshold, r_qp_delay, r_qp_frac;
wire [31:0] r_axi_dt1, r_axi_dt2, r_axi_dt3, r_axi_dt4;
wire [31:0] r_qp_dt1, r_qp_dt2, r_qp_dt3, r_qp_dt4;
reg  [31:0] r_qp_status, r_qp_debug;

axi_slv_qp # (
) AXI_REG (
   .aclk       ( ps_clk             ) , 
   .aresetn    ( ps_aresetn         ) , 
   .awaddr     ( s_axi_awaddr[5:0]  ) , 
   .awprot     ( s_axi_awprot       ) , 
   .awvalid    ( s_axi_awvalid      ) , 
   .awready    ( s_axi_awready      ) , 
   .wdata      ( s_axi_wdata        ) , 
   .wstrb      ( s_axi_wstrb        ) , 
   .wvalid     ( s_axi_wvalid       ) , 
   .wready     ( s_axi_wready       ) , 
   .bresp      ( s_axi_bresp        ) , 
   .bvalid     ( s_axi_bvalid       ) , 
   .bready     ( s_axi_bready       ) , 
   .araddr     ( s_axi_araddr       ) , 
   .arprot     ( s_axi_arprot       ) , 
   .arvalid    ( s_axi_arvalid      ) , 
   .arready    ( s_axi_arready      ) , 
   .rdata      ( s_axi_rdata        ) , 
   .rresp      ( s_axi_rresp        ) , 
   .rvalid     ( s_axi_rvalid       ) , 
   .rready     ( s_axi_rready       ) , 
// Registers
   .QP_CTRL    ( r_qp_ctrl          ) ,
   .QP_CFG     ( r_qp_cfg           ) ,
   .QP_DELAY   ( r_qp_delay         ) ,
   .QP_FRAC    ( r_qp_frac          ) ,
   .QP_THRES   ( r_qp_threshold     ) ,
   .AXI_DT1    ( r_axi_dt1          ) ,
   .AXI_DT2    ( r_axi_dt2          ) ,
   .AXI_DT3    ( r_axi_dt3          ) ,
   .AXI_DT4    ( r_axi_dt4          ) ,
   .QP_DT1     ( r_qp_dt1           ) ,
   .QP_DT2     ( r_qp_dt2           ) ,
   .QP_DT3     ( r_qp_dt3           ) ,
   .QP_DT4     ( r_qp_dt4           ) ,
   .QP_STATUS  ( r_qp_status        ) ,
   .QP_DEBUG   ( r_qp_debug         ) );

wire [31:0] qp_do_s;
qtt_periph  # (
   .DT_W             (DT_W) ,
   .N_S              (N_S) ,
   .T_W              (T_W) ,
   .FIFO_W           (FIFO_W) ,
   .DTR_RST          (DTR_RST) 
) qtt (
   .clk_i      ( c_clk     ) ,
   .rst_ni     ( c_aresetn    ) ,
   .qp_en_i     ( qp_en_i     ) ,
   .qp_op_i     ( qp_op_i     ) ,
   //.qp_dt1_i    ( qp_dt1_i    ) ,
   // .qp_dt2_i    ( qp_dt2_i    ) , 
   // .qp_dt3_i    ( qp_dt3_i    ) , 
   // .qp_dt4_i    ( qp_dt4_i    ) , 
   .qp_rdy_o    ( qp_rdy_o    ) , 
   .qp_dt1_o    ( qp_dt1_o    ) , 
   .qp_dt2_o    ( qp_dt2_o    ) , 
   .qp_vld_o    ( qp_vld_o    ) , 
   .qp_flag_o   ( qp_flag_o   ) , 
   .qp_vector_i ( s_axis_tdata )  ,
   .qp_tvalid   ( s_axis_tvalid ) , 
   .qp_tready   ( s_axis_tready ) ,
   .QP_CTRL     ( r_qp_ctrl     ) ,
   .QP_CFG      ( r_qp_cfg      ) ,
   .QP_DELAY    ( r_qp_delay    ) ,
   .QP_FRAC     ( r_qp_frac     ) ,
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
   .QP_DEBUG    ( r_qp_debug    ) ,
   .qp_time     ( qp_time       ) , 
   .qp_do       ( qp_do_s       ) );


///////////////////////////////////////////////////////////////////////////////
// DEBUG
///////////////////////////////////////////////////////////////////////////////
wire [31:0] qp_debug_s ;
// Assign AXI Debug Signbals
assign qp_debug_s[31:16] = r_axi_dt3[15:0] ;
assign qp_debug_s[15: 0] = r_axi_dt4[15:0] ;

generate
   if             (DEBUG == 0 )  begin: DEBUG_NO
      assign r_qp_debug   = 0;
      assign qp_do      = 0;
   end else if    (DEBUG == 1)   begin: DEBUG_REG
      assign r_qp_debug = qp_debug_s;
      assign qp_do      = 0;
   end else                      begin: DEBUG_OUT
      assign r_qp_debug = qp_debug_s;
      assign qp_do      = qp_do_s;
   end
endgenerate

endmodule
