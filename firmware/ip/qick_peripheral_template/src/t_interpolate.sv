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

    input   wire    [T_W-1:0]       start_time      ,
    input   wire    [T_W-1:0]       trig_time       ,  

    input   wire                    store_en        ,
    input   wire    [N_S-1:0]       edge_index      ,

    output  reg                     store_rdy       ,
    output  reg     [(N_B+T_W-1):0] edge_time              
);

localparam int CALC_TIME = 2;
localparam int TIMER_W = $clog2(CALC_TIME);
// Use a timer to tell the control unit when to switch
reg [TIMER_W-1:0] calc_timer;

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


// Decoder for the Edge index
always_comb begin
    trig_samp =  0;
    store_rdy = 0; 
    for (int i=0; i < N_S; i++) begin
        if (edge_index[i] == 1) begin
            trig_samp = i;
        end
    end

    if (calc_timer == 0) begin
        store_rdy = 1;
    end
end


// Takes an entire cycle to perform the subtraction 
always_ff @ (posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
        diff <= 0;
        calc_timer <= CALC_TIME;
    end
    else begin
        if (store_en) begin
            diff <= unsig_ct - unsig_st;
            calc_timer <= calc_timer - 1;
            edge_time <= (t_diff << N_B) + trig_samp; 
            if (calc_timer == 0) begin
                calc_timer <= CALC_TIME;
            end
        end
        
    end
end



endmodule
