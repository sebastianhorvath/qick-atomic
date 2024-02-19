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
    parameter N_S       =        8  ,
    parameter N_B       =        3  ,       // Bits required to represent the interpolated time
    parameter T_W       =       32  
) (
    input   wire                    clk_i           ,
    input   wire                    rst_ni          ,

    input   wire    [T_W-1:0]       start_time      ,
    input   wire    [T_W-1:0]       trig_time       ,  
    input   wire    [N_S-1:0]       edge_index      ,

    output  reg     [(N_B+T_W-1):0] edge_time              
);

wire [T_W-1:0] t_diff;
reg [N_B-1:0] trig_samp;

// DSP block interprets inputs as signed so make all inputs unsigned
wire signed [T_W:0] unsig_st = {1'b0, start_time}; 
wire signed [T_W:0] unsig_ct = {1'b0, trig_time};
//reg signed [T_W:0] diff = unsig_ct - unsig_st; 
wire [T_W-1:0] wrap_diff = ~diff[T_W-1:0] + 1;

reg signed [T_W:0] diff;

assign t_diff = diff[T_W] ? {{N_B{1'b0}} , wrap_diff} 
                : {{N_B{1'b0}} , diff[T_W-1:0]};


// Decode the edge_index
always_comb begin
    trig_samp =  0;
    for (int i=0; i < N_S; i++) begin
        if (edge_index[i] == 1) begin
            trig_samp = i;
        end
    end
end


// Takes an entire cycle to perform the subtraction (Then perform the shift )
always_ff @ (posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
        diff <= 0;
    end
    else begin
        diff <= unsig_ct - unsig_st;
        // Convert to the wrap around value if start_time is larger than trig_time
        edge_time <= (t_diff << N_B) + trig_samp; 
    end
end



endmodule
