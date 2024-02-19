///////////////////////////////////////////////////////////////////////////////
//  FERMI RESEARCH LAB
///////////////////////////////////////////////////////////////////////////////
//  Author         : Christian Skinker
//  Date           : 1-2024
//  Version        : 1
///////////////////////////////////////////////////////////////////////////////
// Photon Acquisition Control: 
/* Description: 
    Control the Behavior of the Acquisition Module 

    3 States: 
        1. Idle
        2. Wait for Event
        3. Store Event 
        4. Detector Reset (Dead Time)


    Inputs: 
        1. clk_i
        2. rst_ni
        3. armed (Enable the logic to acquire signals)
        4. triggered (switch to state to store event)
        5. event_stored (Could be inherent property of a state)
        6. dead_time > time_elapsed (wake_up)

    Outputs 
        1. start_acq (signal to turn off any registers that might require writes)
        2. store_en (essentially a write enable)
        3. asleep (conserve power and turn off subtraction might not be included
*/
/////////////////////////////////////////////////////////////////////////////// 


// At Some point add an end function in case the experiment goes over time

module acq_ctrl # (
    // Parameters
    parameter TEST  = 0 
) (
    // System Inputs
    input wire clk_i,
    input wire rst_ni,
    // Interface Input
    input wire armed,
    // Acq Datapath Inputs
    input wire triggered,
    input wire store_rdy,
    input wire wake_up, 
    // Acq Datapath Outputs
    output reg start_acq,
    output reg store_en,
    output reg asleep
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
    start_acq = 0;
    store_en = 0;
    asleep = 0;
    if (!rst_ni) begin
        start_acq = 0;
        store_en = 0;
        asleep = 0;
    end
    else begin
        case (acq_state)
            IDLE_ST: begin 
                start_acq = 0;
                store_en = 0;
                asleep = 0;
            end
            EVENT_WAIT_ST: begin 
                start_acq = 1;
                store_en = 0;
                asleep = 0;
            end
            EVENT_STORE_ST: begin
                store_en = 1;
                start_acq = 0;
                asleep = 0;
            end
            SLEEP_TIME_ST: begin 
                store_en = 0;
                start_acq = 0;
                asleep = 1;
            end
        endcase 
    end
end

// State Transition Logic
always_ff @(posedge clk_i, negedge rst_ni) begin 
    if(!rst_ni) begin
        acq_state <= IDLE_ST;
    end 
    else begin 
        case (acq_state)
            IDLE_ST: begin 
                if (armed) begin
                    acq_state <= EVENT_WAIT_ST;
                end
            end
            EVENT_WAIT_ST: begin 
                if(!armed) begin 
                    acq_state <= IDLE_ST;
                end
                else if (triggered) begin
                    acq_state <= EVENT_STORE_ST;
                end
            end
            EVENT_STORE_ST: begin
                if (store_rdy) begin
                    acq_state <= SLEEP_TIME_ST;
                end
            end
            SLEEP_TIME_ST: begin 
                if (!armed) begin 
                    acq_state <= IDLE_ST;
                end
                else if (wake_up) begin 
                    acq_state <= EVENT_WAIT_ST;
                end
            end
        endcase
    end
end 


endmodule;