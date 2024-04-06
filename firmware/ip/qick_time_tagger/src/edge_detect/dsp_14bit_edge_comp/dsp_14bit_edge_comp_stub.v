// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
// Date        : Wed Apr  3 13:24:09 2024
// Host        : QuantumEnabler running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/schsd/Documents/Princeton/Classes/Senior_Year/ECE_497/thesis_project_files/qick_atomic/firmware/ip/qick_time_tagger/src/edge_detect/dsp_14bit_edge_comp/dsp_14bit_edge_comp_stub.v
// Design      : dsp_14bit_edge_comp
// Purpose     : Stub declaration of top-level module interface
// Device      : xczu49dr-ffvf1760-2-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "dsp_macro_v1_0_2,Vivado 2022.1" *)
module dsp_14bit_edge_comp(A, C, P)
/* synthesis syn_black_box black_box_pad_pin="A[13:0],C[13:0],P[14:0]" */;
  input [13:0]A;
  input [13:0]C;
  output [14:0]P;
endmodule
