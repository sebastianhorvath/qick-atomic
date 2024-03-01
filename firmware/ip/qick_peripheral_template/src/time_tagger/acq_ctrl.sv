///////////////////////////////////////////////////////////////////////////////
//  FERMI RESEARCH LAB
///////////////////////////////////////////////////////////////////////////////
//  Author         : Christian Skinker
//  Date           : 1-2024
//  Version        : 1
///////////////////////////////////////////////////////////////////////////////
// Photon Acquisition Control: 
/* Description: 
*/
/////////////////////////////////////////////////////////////////////////////// 


// At Some point add an end function in case the experiment goes over time

module acq_ctrl # (
) (
    // System Inputs
    input wire          clk_i           ,
    input wire          rst_ni          ,
    // Interface Input
    input wire          armed           ,
    // Acq Datapath Inputs
    input wire          triggered       ,
    input wire          store_rdy       ,
    input wire          wake_up         , 
    // Acq Datapath Outputs
    output reg          acq_en          ,
    output reg          store_en        ,
    output reg          asleep
);

typedef enum {  IDLE_ST         ,
                EVENT_WAIT_ST   ,
                EVENT_STORE_ST  ,
                SLEEP_TIME_ST                  
} state_t;  

// State register
state_t acq_state;
// State Outputs and Control Signals 
always_comb begin 
    acq_en = 1'b0;
    store_en = 1'b0;
    asleep = 1'b0;
    case (acq_state)
        IDLE_ST: begin
        end
        EVENT_WAIT_ST: begin 
            acq_en = 1'b1;
        end
        EVENT_STORE_ST: begin
            store_en = 1'b1;
        end
        SLEEP_TIME_ST: begin 
            asleep = 1'b1;
        end
    endcase 
end

// State Transition Logic
always_ff @(posedge clk_i, negedge rst_ni) begin 
    if(!rst_ni) acq_state <= IDLE_ST;
    else begin 
        case (acq_state)
            IDLE_ST: begin 
                if (armed) acq_state <= EVENT_WAIT_ST;
            end
            EVENT_WAIT_ST: begin 
                if(!armed) acq_state <= IDLE_ST;
                else if (triggered) acq_state <= EVENT_STORE_ST;
            end
            EVENT_STORE_ST: begin
                if (store_rdy) acq_state <= SLEEP_TIME_ST;
            end
            // Keep in asleep state (eliminates the need for a dead signal)
            SLEEP_TIME_ST: begin 
                if (wake_up) begin
                    if (armed) acq_state <= EVENT_WAIT_ST;
                    else acq_state <= IDLE_ST;
                end
            end
        endcase
    end
end 
endmodule