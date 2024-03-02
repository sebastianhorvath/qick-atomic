///////////////////////////////////////////////////////////////////////////////
//  FERMI RESEARCH LAB
///////////////////////////////////////////////////////////////////////////////
//  Author         : Christian Skinker
//  Date           : 1-2024
//  Version        : 1
///////////////////////////////////////////////////////////////////////////////
//  QICK PROCESSOR :  Time Tagger Peripheral QPROC Communication 
/*
    
*/
//////////////////////////////////////////////////////////////////////////////
`include "../headers/cmd_err.svh"

module tt_qcom #(
    parameter T_W = 32
) (
// Tproc Clock and Reset Signal
    input wire              clk_i         ,
    input wire              rst_ni        ,
// QPERIPH INPUT
    input wire              qp_en_i       ,
    input wire [4:0]        qp_op_i       ,
// Internal Outputs -> Inputs
    input wire [31:0]       fifo_in       , //-> registered output
    input wire [31:0]       status        , //-> potentially status register
    input wire              fifo_empty    ,
// Outputs to Time Tagger Controllers
    output reg              armed         ,
    output reg              read_toa      , //read time tagger 
// Outputs to QPROC  
    output reg              qp_ready_i    , 
    output reg              qp_vld_o      ,
    output wire             qp_flag       ,
    output wire [31:0]      qp_dt1_o      ,
    output wire [31:0]      qp_dt2_o
);

// Handshake Signal 
wire handshake = qp_ready_i & qp_en_i;

// Flag exactly not fifo_empty
assign qp_flag = ~fifo_empty;

/////////////////////////////////////////////////////////////////////////////////
// Input FSM 
/////////////////////////////////////////////////////////////////////////////////
localparam DISARMED = 1'b0,
           ARMED = 1'b1;

reg input_state; 

// One Sequential Logic FSM (Two State Machine)
always @ (posedge clk_i or negedge rst_ni)  begin 
    // Starting State is DISARMED
    if (!rst_ni) input_state <= DISARMED;
    else begin 
        case(input_state)
            DISARMED: begin
                if ((qp_op_i == `ARM_CMD) && handshake) begin 
                    armed <= 1;
                    input_state <= ARMED;
                end
            end
            ARMED: begin 
                if ((qp_op_i == `DISARM_CMD) && handshake) begin 
                    armed <= 0;
                    input_state <= DISARMED;
                end
            end 
        endcase 
    end
end

/////////////////////////////////////////////////////////////////////////////////
// Output FSM 
/////////////////////////////////////////////////////////////////////////////////

assign qp_dt1_o = fifo_in; //The assignment is fine because of the valid signal sent to tproc
assign qp_dt2_o = status;

localparam IDLE = 2'b0, POP  = 2'b1, READ = 2'b10;

reg [1:0] out_state;

always @ (posedge clk_i or negedge rst_ni ) begin
    // Don't need initial values because they are flip flops 
    if (!rst_ni) begin 
        out_state <= IDLE;
        read_toa <= 0;
        qp_ready_i <= 1;
        qp_vld_o <= 0;
    end
    else begin 
        case(out_state) 
            IDLE: begin
                if (qp_op_i == `READOUT_CMD && !fifo_empty) begin
                    // read_toa State Signals
                    read_toa <= 1;
                    out_state <= POP;
                    qp_ready_i <= 0;
                end
            end
            // Change Design after confirmed working
            // Needs to arm even if in POP state
            POP: begin
                out_state <= READ;
                qp_vld_o <= 1;
                qp_ready_i <= 1;
                read_toa <= 0;
            end
            READ: begin
                qp_vld_o <= 0;
                if (qp_op_i == `READOUT_CMD && !fifo_empty) begin
                    read_toa <= 1;
                    out_state <= POP;
                    qp_ready_i <= 0;
                end 
                else out_state <= IDLE;
            end
        endcase 
    end 
end

endmodule
