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


    Need's a write enable signal that's dependent on if the signal is stored
*/
/////////////////////////////////////////////////////////////////////////////// 


module t_interpolate #(
    parameter N_S       =        8  ,
    parameter N_B       =        3  ,       // Bits required to represent the interpolated time
    parameter T_W       =       32  
) (
    input   wire                    clk_i           ,
    input   wire                    rst_ni          ,

    input   wire    [T_W-1:0]       trig_time       ,  

    input   wire                    store_en        ,
    input   wire    [N_S-1:0]       edge_index      ,

    output  reg                     store_rdy       ,
    output  reg     [(N_B+T_W-1):0] toa_dt                        
);
wire [T_W-1:0] t_diff;
reg [N_B-1:0] trig_samp;
reg one_valid;

// Priority Decoder
always_comb begin
    trig_samp =  0;
    one_valid = 0;
    for (int i=0; i < N_S; i++) begin
        if (one_valid != 1 &&  edge_index[i] == 1) begin
            one_valid = 1;
            trig_samp = i;
        end
    end
end

always_ff @ (posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
        toa_dt <= 1'b0;
        store_rdy <= 1'b0;
    end
    else begin
        if (store_en) begin
            toa_dt <= (trig_time << N_B) + trig_samp; 
            store_rdy <= 1'b1;
        end
        else store_rdy <= 0;
        
    end
end



endmodule
