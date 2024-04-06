// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
// Date        : Wed Apr  3 13:24:09 2024
// Host        : QuantumEnabler running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               c:/Users/schsd/Documents/Princeton/Classes/Senior_Year/ECE_497/thesis_project_files/qick_atomic/firmware/ip/qick_time_tagger/src/edge_detect/dsp_14bit_edge_comp/dsp_14bit_edge_comp_sim_netlist.v
// Design      : dsp_14bit_edge_comp
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu49dr-ffvf1760-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "dsp_14bit_edge_comp,dsp_macro_v1_0_2,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "dsp_macro_v1_0_2,Vivado 2022.1" *) 
(* NotValidForBitStream *)
module dsp_14bit_edge_comp
   (A,
    C,
    P);
  (* x_interface_info = "xilinx.com:signal:data:1.0 a_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME a_intf, LAYERED_METADATA undef" *) input [13:0]A;
  (* x_interface_info = "xilinx.com:signal:data:1.0 c_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME c_intf, LAYERED_METADATA undef" *) input [13:0]C;
  (* x_interface_info = "xilinx.com:signal:data:1.0 p_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME p_intf, LAYERED_METADATA undef" *) output [14:0]P;

  wire [13:0]A;
  wire [13:0]C;
  wire [14:0]P;
  wire NLW_U0_CARRYCASCOUT_UNCONNECTED;
  wire NLW_U0_CARRYOUT_UNCONNECTED;
  wire [29:0]NLW_U0_ACOUT_UNCONNECTED;
  wire [17:0]NLW_U0_BCOUT_UNCONNECTED;
  wire [47:0]NLW_U0_PCOUT_UNCONNECTED;

  (* C_A_WIDTH = "14" *) 
  (* C_B_WIDTH = "18" *) 
  (* C_CONCAT_WIDTH = "48" *) 
  (* C_CONSTANT_1 = "1" *) 
  (* C_C_WIDTH = "14" *) 
  (* C_D_WIDTH = "18" *) 
  (* C_HAS_A = "1" *) 
  (* C_HAS_ACIN = "0" *) 
  (* C_HAS_ACOUT = "0" *) 
  (* C_HAS_B = "0" *) 
  (* C_HAS_BCIN = "0" *) 
  (* C_HAS_BCOUT = "0" *) 
  (* C_HAS_C = "1" *) 
  (* C_HAS_CARRYCASCIN = "0" *) 
  (* C_HAS_CARRYCASCOUT = "0" *) 
  (* C_HAS_CARRYIN = "0" *) 
  (* C_HAS_CARRYOUT = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_CEA = "0" *) 
  (* C_HAS_CEB = "0" *) 
  (* C_HAS_CEC = "0" *) 
  (* C_HAS_CECONCAT = "0" *) 
  (* C_HAS_CED = "0" *) 
  (* C_HAS_CEM = "0" *) 
  (* C_HAS_CEP = "0" *) 
  (* C_HAS_CESEL = "0" *) 
  (* C_HAS_CONCAT = "0" *) 
  (* C_HAS_D = "0" *) 
  (* C_HAS_INDEP_CE = "0" *) 
  (* C_HAS_INDEP_SCLR = "0" *) 
  (* C_HAS_PCIN = "0" *) 
  (* C_HAS_PCOUT = "0" *) 
  (* C_HAS_SCLR = "0" *) 
  (* C_HAS_SCLRA = "0" *) 
  (* C_HAS_SCLRB = "0" *) 
  (* C_HAS_SCLRC = "0" *) 
  (* C_HAS_SCLRCONCAT = "0" *) 
  (* C_HAS_SCLRD = "0" *) 
  (* C_HAS_SCLRM = "0" *) 
  (* C_HAS_SCLRP = "0" *) 
  (* C_HAS_SCLRSEL = "0" *) 
  (* C_LATENCY = "64" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_OPMODES = "000100100011010100000001" *) 
  (* C_P_LSB = "0" *) 
  (* C_P_MSB = "14" *) 
  (* C_REG_CONFIG = "00000000000000000000000000000000" *) 
  (* C_SEL_WIDTH = "0" *) 
  (* C_SQUARE_FCN = "0" *) 
  (* C_TEST_CORE = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "zynquplus" *) 
  (* KEEP_HIERARCHY = "soft" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  dsp_14bit_edge_comp_dsp_macro_v1_0_2 U0
       (.A(A),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_U0_ACOUT_UNCONNECTED[29:0]),
        .B({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_U0_BCOUT_UNCONNECTED[17:0]),
        .C(C),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_U0_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYOUT(NLW_U0_CARRYOUT_UNCONNECTED),
        .CE(1'b1),
        .CEA(1'b1),
        .CEA1(1'b1),
        .CEA2(1'b1),
        .CEA3(1'b1),
        .CEA4(1'b1),
        .CEB(1'b1),
        .CEB1(1'b1),
        .CEB2(1'b1),
        .CEB3(1'b1),
        .CEB4(1'b1),
        .CEC(1'b1),
        .CEC1(1'b1),
        .CEC2(1'b1),
        .CEC3(1'b1),
        .CEC4(1'b1),
        .CEC5(1'b1),
        .CECONCAT(1'b1),
        .CECONCAT3(1'b1),
        .CECONCAT4(1'b1),
        .CECONCAT5(1'b1),
        .CED(1'b1),
        .CED1(1'b1),
        .CED2(1'b1),
        .CED3(1'b1),
        .CEM(1'b1),
        .CEP(1'b1),
        .CESEL(1'b1),
        .CESEL1(1'b1),
        .CESEL2(1'b1),
        .CESEL3(1'b1),
        .CESEL4(1'b1),
        .CESEL5(1'b1),
        .CLK(1'b1),
        .CONCAT({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .P(P),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_U0_PCOUT_UNCONNECTED[47:0]),
        .SCLR(1'b0),
        .SCLRA(1'b0),
        .SCLRB(1'b0),
        .SCLRC(1'b0),
        .SCLRCONCAT(1'b0),
        .SCLRD(1'b0),
        .SCLRM(1'b0),
        .SCLRP(1'b0),
        .SCLRSEL(1'b0),
        .SEL(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2022.1"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
hpQi2e575oxFDL0FfhJYpDn2Z7sr/nCnfofAXr4j6Wi2vcOZfA2l2OkTdSKknlCSp6IMPD0eHZFM
aqMcygijtcMSA03ISV3kqHHp6+6oDzDybrWzXpDWrpQKeOX5VzAspaQybgWvz7dCX6vIokYXlC1k
HUUc+Du4UI3rcjanmTM=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
l5Q7g8QwNFxeXCSTeheUamCwYPHM4YRouugZB2FHLf01oaJDP5uN23NV6E3v4oxWaqnwKPUJb6ww
S6HJw8IgqJ5bVE1Xxl9jan3gyYu6tvE3H7alei7rN4gPadbFjLwAOlT6rszsd8JmjY+RD4h43dTR
Zp7/llkBHrde+C2qQdNOUEnkeT14NQClMpKoSNITi5yQOix+5cI3q+T7Bqn65O7aGCfBgvuREshq
6Gfo74CtoCbwTuSUjdbmLYwI/MFnWOS6en7x+ia+WKqWj9YrWjfUCy8txj8hZjb4sCPQKFzN8UwT
nLeLrDWqea92fbJoN/EDhnmuuPBTW/1cBNBBlA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
YLmdwWwVwjwR7xxsZJO6nTeZvEpSyl5/kFiTBVICsMw7Wyk8IZioDZLx2d1A/HiRyrVNhlIRXScN
VrWPhFB2yYVCoJPXf0KqD1f50Y9dNOdsiZSkX+V5kuGZyPAquml/+eRBcgSZigDcNqhOBDVIVKUg
5MJsRWevOd9XaTlKW+U=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
cHrHwj/OHXOSxE2scD822kVW7wJExChuOsnxBy9RNdjkQgteHHV6YsvR0emQtlJ0GIZNiz11himX
S/ittbr8jl+aDkB03CHSCLjzLJk7xBdvkwTjogb4CJ9cZd5DvBCIIdqtba9zEzZfLzyhkLQySHma
JrNGvEFKiEPTG629+wy8W7rsXcMA0L8tC+NomPSJYkWzdCeAqRfAd/DyYStpNndscgPmfn2gc7q/
Fj2twMI6DAlvyACIArrTd0F5q4RwkwFHHeQ6aJPNrcj5o09ZDDyo+QRssr0nboYYK6iIjNKX4pQr
ejdysDKPOiVLgegrye5keqnwenqRzl3uJpV/6w==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
nnbbI+BwyID4XoMrizSDP+jbZllz3yV1mmv6KNslMVw0sxrXKbrk408TmRsjvNSSuvhV51xndPA2
FU/wKzy7/AMDxbCMLjCG3u6MmyP2CX0pkDA3BTOIP1RCGzoDoEb83gFGy4nFfeR1pJFfhq9ds51u
juJObeDYjLjaaSktbcxa2wjR8foiPfeQsrERLidvnNNkPysqj7W5ZcFAw0ZPMd/v13jyfN/jqn1i
QmYQT4M7dy8otwubi6E5mHTAgo3FK9AXEahtK94r4/ZYi/nn0T6yS29la85vqokrwRum3oLIDWW4
RrHLa8e7Pot3ZVGSSDWbMhExi6pkElaBXKnLsQ==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2021_07", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
DAVdpP5vGcRTzrsFkjJ/uBmxnMYLnU6Yd1VGi3fICAEptToeKbjoM56Fqf/3+Cfd8mfBpvgkqcJO
pfY+YpKNjL2yDpjlxxyMkEha+w2YGizKz0pAEtp70R41DcKB7TvEJA7tJYxqftSlwsGGvwPUrYMC
nbXyJjNoHZ2Ll4Ozu3UZTmP03QzndDIDfmdippWBWBHYOjJtPviLjF1/hizxHax1JTVRawer9Qjr
HVuUQeDxcxrsc02s9iZ/r6iZWZQDgBP5bsxT8EeY4hH3/P58fA9+6lZu6oVDvJeudszCZD1TgyY2
KuYShAnut6vR6Ik+oRDL3Hrp5SQoaOCW524EgA==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
cKq1TGNuFnDKKcBOyi8e1K8ly+eMeHwVdchpbd+bxxXMpqSnkHpq5kg4iZw9cOYtpKuvS93u2hah
ZNVZf+4AH7FVHFnFtRlIXfTsZnd5cE411yuLelJz1nvpouBPk7pt4Z/iOqTD48yppmHZkkqCOu29
ESLnvCcvKtfqQCX0+hx8dGU2iXc8AovJo7YCt39ZO+Xjc1N6WfC6UJyy/KkYF1qcgNkPu0nKcBwg
JCpUlwfdmeO4oAb0dJxEVi3AyWCWb1zGThxsmDj0x6jY/ymMeDRNma0QdAWnClawUQy80EPah4x3
J4u57yx6daysrYXraEuhL1xsZb4XFB+14K6Njw==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
Re5fDPZ8EQVPdNEo11DCLuZaBRdc/VJLcPQkEfqHqXr8o7UCTkVHRnYup0/sMrR05rUbcVrX+y26
Zm7KX2M2vi9JNxUdyt8DzqkHtoWjd8ox70Md9MGyYeK44bwvM8my4DW2Wm9Lk9226xF4Qa0n3IIl
lQZWxrNI6H9XjV/BNrqFj+kBeNadHP5ihUPb2EmxXSwdgLkT1zMcUhQaMDxOBzIuAbkRYta/q8za
AzYQt1W3dqFUaiUUjlCj9fYcR8ZBMFpbp3Apje8nX5mVtAmk75DBgu5i8CjYvqpT/iziDeqqtahB
/arsycohVQ1PiCF7Z8siPzsiQym0WVpsiwGZmrCyuy8bykKzLnvUGHATPxXLzSpbh8sZvrGIu0b+
hmoM0a1pF7D2SjJJWLZnJJbzkOramPWLCkoXbMc+KgHQ6OpD1ow3bhmMLg8ZbTRMgJGpfxDNkXyK
+Skb1VkCste5U4nHFrKo7krNZZ2/wytN2CSUdkzF1wfY+K/4CzgnUCs2

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
XVWUvZ/UpZ29GMy3XnymX67etmlfLX1Nc5lDCe3Fkh1pzSH0ihbTk0WE9uNfxhCf8deTSeul9LJH
AFPTiQiwkrIU9UQwnfo2xygbWbM3s3AF164xHmX2eegveVO7/ody+W2VwPqhx0nJzF7H2mOI+gFd
H9ZbDirzJXmOb6XX4H4UPFI2jCKk0g8k6n9hkO9ubyQWCValHZ4jd5SyFcQBUKMRosgR3zEL/FrT
9GeJty67V/+tdnWLZB42pnIHq13SObBDE6IhE6u0tLa6y0E5k3ZGicrRPFS2UKq7MQhtPlqMAqv/
4JCNyt5Ii3Brz3T2/Q78DbSBTS/xrLj8akB0xA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
hl9IpEpNj7GCo6ONB/Kmnwlqa+ihW4dk3aY5YbydcinEBEl9SSeogKVbaIaRfaZFXEg+ahFqJxDt
FcQ5MT4QLqrvNry26XQH5FBN2yurGIvRDtidrer6FShywraD9hPcv9HC40cs35AmCH/GOGB3Zpmf
M3X+v0M1YrcCtdpS1awoFQTFpESHClSXvMsQNqikzcHKkdt9dYeTKlyopZqAvfGl30Y/Ge5ZgpOX
Cilz/KzfsmAUVoHvGfNL4SJh5WuQiLcTBUWDxG9i4dGfwsRZDCzoJWNN1yYlPDI2B01QpGaM0qpP
Ocm9nMmqENuVRIZCSYJ5QOW6HhrWA2mrrJC3nw==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
cyUNNB5YPYI9oXktxxe0VgBEiJn72xRiMYRNOCbjFnxsIpQZEWLTw8vfTuQBc2lJ98owckDXEKIC
E7NctbokE5FFMXou5fUboX9KRj7yKOR+uNU0kPYRYtgWpODvFfaZ+ZET0p15+4ZlXVU0z4aXwIeG
Qmr+U18gWJKYAbzUBuitcuK+1KvH+3DnttVZZQyXCrO1WvtD39MtAmOomH5Q9ib7I5gjzsy6yZ7z
Te568/WmRYSg6JVWHb5G35HRFw8kXQpZSbBtVz6fcMF/KTSyDNMe3epJW+WfJJU6RTrXA/KLLLkL
585EIJmsZzsR3XE3j9b04L1EmgElv5x1meo0PA==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 28000)
`pragma protect data_block
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
kxv6YN0RG2s/qrY4dOllcJvF4qmkPMOwkruj5ftWbFozgmkpv/ojfa4QaKKvSXefjpc2Mw9HBDpw
V+VsJjnP+Rl8SVjaMp/skhLhKWhumzFJRKG2jrtz2xAJwqp8nWdhjAyqM/anhbj3X38Mr0mg3Ifv
pnjFj6L5OWH8Yy0X//yARgFqVrDRTJVjE3zZZka6qXOc6WWnGmBO6s5+Fi0x6KfDiwLwpKEFZpFH
zzwd4HQvvtP0Ulz2IhDQYjJsXTv3Im4lcfhYTx7R+KaX9lXSl7r0zDMkXn1LJN/l1c1v1hzX+VDK
ej5GGkYSJ3fy0sbGTn+KNrlhIqFSVSCq/qb90EuRjTYiJE+VA0xLClSE0PDnuo55m7MWrLxlVAI8
lIWkjC9aRAkel3eSCYodE5zrU00KRH9YcnmCFhw4G8diNLJnh6YEvAS7Jm3bZM2/bOc1R+NiQiY1
8BWdTyL+wQ8khVZCO/h+GLPLa7l+a/zmLKodTR4AhdZaLYW+2I0nVjpRgDsoCylmW/hM36iqcJRr
CRhLzdQqLvw+5r2R82AvHGy5tNnJApCfRjloS5wKEu90gjD42NrbUyQ6SJOsPueDa7E98fUshnYv
onO1KDw7rqe+hwECmBYR3wbSJvFwiYmqTAnhnyGTDluNMFtnDyc+E81uhUPqp9PDYTG0e87OdTQl
PWVJ36aubua1sjIIpPdbNQcu/Oh+YEJYldWRq0ysqUqCBwm+XHqsRSUwdL0YAoPucc4y6oNl7OcC
43gV+swwDOHra1ZgGzEQHVPMAn7p2Qpolds9ExIiNTMrmq6laUsZ8J4XUkg39Do3kAJ3T7L9OCVZ
UCos+bXqTUZ4rvn5tLBocH/Wct2fUefPXU7bWpjSnomOuJ4pLnG388dviU5FtbKO/TxgokDMqKqU
KLoMj+AtDcpnzXi4Wz/dNdS7uQ7hvuRpu38sh4+GVx9y5EHAjl0U9rITYfjE2V4pbOomuOv/oswF
Nv8tR5cMHpE7U9YigMqkHWvh5MeqXY5gbIHfVIv0XbOIwVIn7ffhlnlIxog0HTET6JzFTJy6/VV5
0KUhdE4s9Kiz9LDwULpDG5zO+2kk3VLhj8C7osZ/D3MbzA9xAoI9y5eOJX5qti0qeuYk0Fpnzsvd
WyXKW+pMqbomU2YWTCw4FHZis9qIQxahD6Xrm3ie3rS/S43hizLWUTE7PokEQHOCGCIr3+lgjAk/
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
3rFWW0SRG//eWfRXsg==
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
