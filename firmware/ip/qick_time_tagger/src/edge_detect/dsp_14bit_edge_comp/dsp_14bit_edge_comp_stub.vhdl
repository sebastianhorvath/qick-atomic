-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
-- Date        : Wed Apr  3 13:24:09 2024
-- Host        : QuantumEnabler running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               c:/Users/schsd/Documents/Princeton/Classes/Senior_Year/ECE_497/thesis_project_files/qick_atomic/firmware/ip/qick_time_tagger/src/edge_detect/dsp_14bit_edge_comp/dsp_14bit_edge_comp_stub.vhdl
-- Design      : dsp_14bit_edge_comp
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xczu49dr-ffvf1760-2-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dsp_14bit_edge_comp is
  Port ( 
    A : in STD_LOGIC_VECTOR ( 13 downto 0 );
    C : in STD_LOGIC_VECTOR ( 13 downto 0 );
    P : out STD_LOGIC_VECTOR ( 14 downto 0 )
  );

end dsp_14bit_edge_comp;

architecture stub of dsp_14bit_edge_comp is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "A[13:0],C[13:0],P[14:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "dsp_macro_v1_0_2,Vivado 2022.1";
begin
end;
