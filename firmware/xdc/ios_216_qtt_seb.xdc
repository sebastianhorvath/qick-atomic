set_property PACKAGE_PIN G15       [get_ports "PMOD0_0_LS"] ;# Bank  88 VCCO - VCC1V8   - IO_L12N_AD8N_88
set_property PACKAGE_PIN G16       [get_ports "PMOD0_1_LS"] ;# Bank  88 VCCO - VCC1V8   - IO_L12P_AD8P_88
set_property PACKAGE_PIN H14       [get_ports "PMOD0_2_LS"] ;# Bank  88 VCCO - VCC1V8   - IO_L11N_AD9N_88
set_property PACKAGE_PIN H15       [get_ports "PMOD0_3_LS"] ;# Bank  88 VCCO - VCC1V8   - IO_L11P_AD9P_88
set_property IOSTANDARD  LVCMOS18  [get_ports "PMOD0_*"]

set_property PACKAGE_PIN L17       [get_ports "PMOD1_0_LS"] ;# Bank  88 VCCO - VCC1V8   - IO_L4N_AD12N_88
set_property PACKAGE_PIN M17       [get_ports "PMOD1_1_LS"] ;# Bank  88 VCCO - VCC1V8   - IO_L4P_AD12P_88
set_property IOSTANDARD  LVCMOS18  [get_ports "PMOD1*"]
set_property PULLDOWN TRUE         [get_ports "PMOD1*"]


set_property BITSTREAM.CONFIG.UNUSEDPIN PULLUP [current_design]
set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN ENABLE [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

