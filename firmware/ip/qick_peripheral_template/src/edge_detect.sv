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

    input   wire      [RES-1:0]       threshold   ,  // adc threshold value
    
    output  reg       [N_S-1:0]       edge_index  
);

wire [RES+1:0] signed_threshold = {1'b0, threshold};

genvar ii;
generate
    for (ii = 0; ii < N_S; ii++) begin : generate_edge_comparators
        wire [RES+2:0] result_ii;
        // Determine packing order from the RF Data Conversion port
        wire [RES+1:0] signed_sample_ii = vector_i[((ii+1)*DT_W)-(DT_W-RES-1):(ii*DT_W)];

        // DSP block configured to have output registered
        dsp_macro_0 #() edge_comp (
            .CLK        (clk_i)       ,
            .A          (signed_threshold),
            .C          (signed_sample_ii),
            .P          (result_ii)
        );

        assign edge_index[ii] = result[RES+2];
    
    end
endgenerate


endmodule
