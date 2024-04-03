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

// ADC are MSB aligned not LSB so bottom two bits don't matter 
wire [RES-1:0] signed_threshold = threshold;
wire [N_S-1:0] trig_bits;

genvar ii;
generate
    for (ii = 0; ii < N_S; ii++) begin : generate_edge_comparators
        // Result register length RES+1
        wire [RES:0] result_ii;
        reg  [RES:0] result_reg;
        
        // Take the upper RES-1 bits of 16 bit stream (MSB aligned and already signed)
        wire [RES-1:0] signed_sample_ii = tdata[((ii+1)*DT_W - 1):(ii*DT_W) + (DT_W-RES)];
        
        // DSP gen_12bit_edge_comparator has two 12 bit inputs and 13 bit output
        if ( RES == 12 ) begin : gen_12bit_edge_comparator
            dsp_12bit_edge_comp #() edge_comp (      
                .A          (signed_threshold),
                .C          (signed_sample_ii),
                .P          (result_ii)
            ); 
        end 
        // DSP gen_14bit_edge_detector has two 14 bit inputs and 15 bit output
        else if ( RES == 14 ) begin : gen_14bit_edge_comparator
            dsp_14bit_edge_comp #() edge_comp (      
                .A          (signed_threshold),
                .C          (signed_sample_ii),
                .P          (result_ii)
            );
        end
        // Bits to Calculate the trigger
        assign trig_bits[ii] = result_ii[RES];
        
        // Bits used for the edge are registered to hit critical timing
        assign edge_index[ii] = result_reg[RES];

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
