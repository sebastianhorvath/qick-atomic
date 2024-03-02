`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////
//  FERMI RESEARCH LAB
///////////////////////////////////////////////////////////////////////////////
//  Author         : Christian Skinker
//  Date           : 1-2024
//  Version        : 1
///////////////////////////////////////////////////////////////////////////////
// Edge Detection RTL
/* Description: 

*/
/////////////////////////////////////////////////////////////////////////////// 


module edge_detect #(
    parameter DT_W      =       16,
    parameter N_S       =        8,   
    parameter RES       =       12        
) (
    input   wire                      clk_i       ,
    input   wire                      rst_ni      ,
    input   wire      [DT_W*N_S-1:0]  tdata       ,
    input   wire                      acq_en      , 
    input   wire      [RES-1:0]       threshold   ,  // adc threshold value
    output  reg                       above_thresh, // Signal to the control (this is asynchronous)
    output  reg                       below_thresh, 
    output  wire      [N_S-1:0]       edge_index  
);

wire [RES:0] signed_threshold = {{1'b0}, threshold};
wire [N_S-1:0] trig_bits;

genvar ii;
generate
    for (ii = 0; ii < N_S; ii++) begin : generate_edge_comparators
        wire [RES+1:0] result_ii;
        reg  [RES+1:0] result_reg;
        
        // Take the first signed bit of the adc samples
        wire [RES:0] signed_sample_ii = tdata[((ii*DT_W) + RES) :(ii*DT_W)];

        dsp_edge_crossing #() edge_comp (      
            .A          (signed_threshold),
            .C          (signed_sample_ii),
            .P          (result_ii)
        );
        // Bits to Calculate the trigger
        assign trig_bits[ii] = result_ii[RES+1];
        // Bits used for the edge are registered to hit critical timing
        assign edge_index[ii] = result_reg[RES+1];
        // Store the result only if in the  
        always_ff @(posedge clk_i, negedge rst_ni) begin
            if (!rst_ni) result_reg <= 0;
            else begin
                if (acq_en) result_reg <= result_ii; 
            end
        end
    end
endgenerate

always_comb begin
    above_thresh = |trig_bits;
    below_thresh = &(~trig_bits);
end

endmodule
