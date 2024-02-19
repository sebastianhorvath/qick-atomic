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
    parameter RES       =       12,
    parameter N_S       =        8           
) (
    input   wire                      clk_i       ,
    input   wire                      reset_i     ,

    input   wire      [DT_W*N_S-1:0]  vector_i    ,
    input   wire                      t_valid     ,

    input   wire                      acq_en      ,
    input   wire                      asleep      , 

    input   wire      [RES-1:0]       threshold   ,  // adc threshold value

    output  reg                       triggered   , // Signal to the control (this is asynchronous)
    output  wire      [N_S-1:0]       edge_index  
);

wire [RES+1:0] signed_threshold = {1'b0, threshold};
wire [N_S-1:0] trig_bits;

genvar ii;
generate
    for (ii = 0; ii < N_S; ii++) begin : generate_edge_comparators
        wire [RES+1:0] result_ii;
        reg  [RES+1:0] result_reg;
        // Determine packing order from the RF Data Conversion port
        wire [RES:0] signed_sample_ii = vector_i[((ii+1)*DT_W)-(DT_W-RES-1):(ii*DT_W)];

        // DSP block (Changed so that I manually register the output.)
        // I need complete visibilty of the signal before registered to ensure the correct time is used for 
        // Interpolation and all next stage is triggered
        dsp_edge_crossing #() edge_comp (      
            .A          (signed_threshold),
            .C          (signed_sample_ii),
            .P          (result_ii)
        );

        // Bits to Calculate the trigger
        assign trig_bits[ii] = result_ii[RES+1];

        // Bits used for the edge are registered to hit critical timing
        assign edge_index[ii] = result_reg[ii];

        // Store the result only if in the  
        always_ff @(posedge clk_i, negedge rst_ni) begin
            if (!rst_ni) begin
                result_reg <= 0;
            end
            else begin
                if (acq_en) begin
                    result_reg <= result_ii; 
                end
                if (asleep) begin
                    result_reg <= 0;
                end
            end
        end

    end
endgenerate

// Reduction OR on all the bits of edge_index
// For <12 bits only needs 2 cascaded lookup table (hopefully not too much)
// Expects 1 clk cycle otherwise redundant time storage
always_comb begin
    triggered = |trig_bits;
end



endmodule
