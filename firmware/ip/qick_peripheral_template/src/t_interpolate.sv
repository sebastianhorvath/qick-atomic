`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////
//  FERMI RESEARCH LAB
///////////////////////////////////////////////////////////////////////////////
//  Author         : Christian Skinker
//  Date           : 1-2024
//  Version        : 1
///////////////////////////////////////////////////////////////////////////////
// Time Interpolator: 
/* Description: 
   Takes in the multiwire signal from the edge detector and shifts the subtracted time 
   over by the amount of bits required to represent the samples width. 

*/
/////////////////////////////////////////////////////////////////////////////// 


module t_interpolate #(
    parameter N_S   =        8  ,
    parameter T_W   =       32  
) (
    input   wire                    clk_i           ,
    input   wire                    rst_ni          ,

    input   wire    [T_W-1:0]       start_time      ,
    input   wire    [T_W-1:0]       curr_time       ,    
);

localparam int NUM_BITS = $clog2()

endmodule
