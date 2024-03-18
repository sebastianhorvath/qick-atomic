`timescale 1ns/10ps 

`include "../headers/cmd_err.svh"
`include "./tb_macros.svh"

module qtt_acq_ctrl;

reg c_clk, ps_clk;
reg rst_ni;

// CLK Generation 
initial begin
    ps_clk = 0; 
    forever # (`T_PS_CLK) ps_clk = ~ps_clk;
end
initial begin
    c_clk = 0;
    forever # (`T_C_CLK) c_clk = ~c_clk;
end

// Inputs
reg armed, triggered, store_rdy, wake_up, dead;
// Ouptuts
reg acq_en, store_en, asleep;

acq_ctrl #(

) dut_qtt_acq_ctrl (
    .clk_i      (c_clk),
    .rst_ni     (rst_ni),
    .armed      (armed),
    .triggered  (triggered),
    .store_rdy  (store_rdy),
    .dead       (dead),
    .wake_up    (wake_up),
    .acq_en     (acq_en),
    .store_en   (store_en),
    .asleep     (asleep)
);

task START_SIMULATION (); begin
    $display("Starting Simulation");
    rst_ni = 1'b0;

    armed = 1'b0;  
    triggered = 0;
    store_rdy = 0;
    dead = 0;
    wake_up = 0;

    @ (posedge c_clk); #0.1;
    rst_ni = 1'b1;

    end
endtask

initial begin
    START_SIMULATION();

    @ (posedge c_clk); #0.1;
    armed = 1; 

    @ (posedge c_clk); #0.1;
    `ASSERT_EQ(acq_en, 1, "Now Entering in acquistion")

    triggered = 1;

    @ (posedge c_clk); #0.1;
    `ASSERT_EQ(store_en, 1, "Not entering into storage state")

    armed = 0; 

    @ (posedge c_clk); #0.1;
    `ASSERT_EQ(store_en, 1, "Should still be in storage state")

    armed = 1;
    store_rdy = 1;

     @ (posedge c_clk); #0.1;
    `ASSERT_EQ(asleep, 1, "After Storage should enter sleep state")

    armed = 0;

    @ (posedge c_clk); #0.1;
    `ASSERT_EQ(acq_en, 0, "Should enter into idle state")

    dead = 1;
    armed = 1;

    @ (posedge c_clk); #0.1;
    `ASSERT_EQ(acq_en, 0, "Should remain in idle state if detector still dead")

    # (4 * `T_C_CLK);

    wake_up = 1;
     @ (posedge c_clk); #0.1;
    `ASSERT_EQ(acq_en, 1, "Should now enter into acquistion after wake up")
    
    # (4 * `T_C_CLK);

    armed = 0;

    @ (posedge c_clk); #0.1;
    `ASSERT_EQ(acq_en, 0, "Exit the acquistion state")

    @ (posedge c_clk); #0.1;

end


endmodule 