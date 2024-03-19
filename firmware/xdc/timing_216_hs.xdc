set clk_axi  [get_clocks -of_objects [get_nets -of_objects [get_pins d_1_i/qick_processor_0/ps_clk_i] ] ]
set c_clk    [get_clocks -of_objects [get_nets -of_objects [get_pins d_1_i/qick_processor_0/c_clk_i] ] ]
set t_clk    [get_clocks -of_objects [get_nets -of_objects [get_pins d_1_i/qick_processor_0/t_clk_i] ] ]

# ADC/DAC
set clk_adc2  [get_clocks -of_objects [get_nets -of_objects [get_pins d_1_i/usp_rf_data_converter_0/clk_adc2]]]
#set clk_dac0 [get_clocks -of_objects [get_nets -of_objects [get_pins d_1_i/usp_rf_data_converter_0/clk_dac0]]]
#set clk_dac1 [get_clocks -of_objects [get_nets -of_objects [get_pins d_1_i/usp_rf_data_converter_0/clk_dac1]]]
set clk_dac2 [get_clocks -of_objects [get_nets -of_objects [get_pins d_1_i/usp_rf_data_converter_0/clk_dac2]]]
set clk_dac3 [get_clocks -of_objects [get_nets -of_objects [get_pins d_1_i/usp_rf_data_converter_0/clk_dac3]]]
    
set_clock_group -name clk_async -asynchronous \
    -group [get_clocks $clk_axi ] \
    -group [get_clocks $clk_dac2] \
    -group [get_clocks $clk_dac3] \
    -group [get_clocks $clk_adc2] \
    -group [get_clocks $t_clk   ] \
    -group [get_clocks $c_clk   ]
    
