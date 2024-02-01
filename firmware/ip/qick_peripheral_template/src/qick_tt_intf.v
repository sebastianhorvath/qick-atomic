///////////////////////////////////////////////////////////////////////////////
//  FERMI RESEARCH LAB
///////////////////////////////////////////////////////////////////////////////
//  Author         : Christian Skinker
//  Date           : 1-2024
//  Version        : 1
///////////////////////////////////////////////////////////////////////////////
//  QICK PROCESSOR :  Time Tagger Peripheral QPROC Communication 
/* Description: 
    Wrapper for handling the QPROC communication 

    Acquisiton Commands :
    Start - Give the start time 
    Stop - instantly triggers the stop 

    Read Commands :
    Pop - After the previous values have been read, pop them from fifo

    
*/
//////////////////////////////////////////////////////////////////////////////
`define ARM_CMD 1
`define DISARM_CMD 2
`define READOUT_CMD 3

module tt_qcom# (
    parameter WIDTH = 32
) (
// Tproc Clock and Reset Signal
    input wire clk_i,
    input wire rst_ni,
// QPERIPH INPUT
    input wire qp_en_i,
    input wire [4:0] qp_op_i,
    input wire [31:0] qp_dt1_i, // Add the ability to 
// Timing Inputs
    input wire [47:0] qp_time,
// Internal Outputs -> Inputs
    input wire [31:0] fifo_out, //-> registered output
    input wire [31:0] status, //-> potentially status register
    input wire fifo_empty,
// Outputs to Time Tagger Controllers
    output reg arm,
    output reg [47:0] start_time,
    output reg read_toa, //read time tagger 
// Outputs to QPROC  
    output reg qp_ready_i 
    output reg qp_vld_i,
    output wire qp_flag,
    output wire [31:0] qp_dt1_o,
    output reg [31:0] qp_dt2_o,
);

// Handshake Signal 
assign handshake = qp_ready_i & qp_en_i;

// Flag exactly not fifo_empty
assign qp_flag = ~fifo_empty;

// Clock Register
reg [47:0] tagger_time;
always @(posedge clk_i) begin
    tagger_time <= qp_time;
end 

/////////////////////////////////////////////////////////////////////////////////
// Input FSM 
/////////////////////////////////////////////////////////////////////////////////

// Output Signals
reg armed; 
reg start_t;

// State Vector 
reg input_state; 

// State Params
localparam DISARMED = 1'b0,
           ARMED = 1'b1;


// One Sequential Logic FSM (Two State Machine)
always @ (posedge clk_i or negedge rst_ni)  begin 
    // Starting State is DISARMED
    if (!rst_ni) begin 
        input_state <= DISARMED;
        ready <= 1;
        start_t <= 0;
    end
    else begin 
        case(input_state)
            DISARMED: begin
                if ((qp_op_i == `ARM_CMD) && handshake) begin 
                    armed <= 1;
                    start_t <= tagger_time;
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

assign qp_dt1_o = fifo_out; //The assignment is fine because of the valid signal sent to tproc

reg [1:0] out_state;
localparam IDLE = 2'b0,
           POP = 2'b1,
           READ = 2'b2;

always @ (posedge clk_i or negedge rst_ni ) begin
    // Don't need initial values because they are flip flops 

    if (!rst_ni) begin 
        out_state <= IDLE;
        read_toa <= 0;
        qp_vld_i <= 0;
    end
    else begin 
        case(out_state) 
            IDLE: begin
                if (qp_op_i == `READOUT_CMD && !fifo_empty) begin
                    // read_toa State Signals
                    read_toa <= 1;
                    out_state <= POP;
                end
            end
            // One clk_cycle of downtime before reading a new signal 
            POP: begin
                out_state <= READ;
                // READ State Signals
                qp_vld_i <= 1;
                read_toa <= 0;
            end
            // Programmer is responsible for not overwriting values
            // Valid Signal is Set 
            // Data is available from FIFO via fifo_out
            // Pop is not asserted in this state 
            // Either go back to the idle state
            READ: begin
                qp_vld_i <= 0;
                if (qp_op_i == `READOUT_CMD && !fifo_empty) begin
                    // POP State Signals
                    read_toa <= 1;
                    out_state <= POP;
                end 
                else begin 
                    out_state <= IDLE;
                end
            end
        endcase 
    end 
end



/////////////////////////////////////////////////////////////////////////////////



endmodule
