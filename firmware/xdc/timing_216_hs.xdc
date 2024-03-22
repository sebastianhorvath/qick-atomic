
# ADC/DAC
#set clk_dac0 [get_clocks -of_objects [get_nets -of_objects [get_pins d_1_i/usp_rf_data_converter_0/clk_dac0]]]
#set clk_dac1 [get_clocks -of_objects [get_nets -of_objects [get_pins d_1_i/usp_rf_data_converter_0/clk_dac1]]]

set_clock_groups -name clk_async -asynchronous -group [get_clocks [get_clocks -of_objects [get_nets -of_objects [get_pins d_1_i/qick_processor_0/ps_clk_i]]]] -group [get_clocks [get_clocks -of_objects [get_nets -of_objects [get_pins d_1_i/usp_rf_data_converter_0/clk_dac2]]]] -group [get_clocks [get_clocks -of_objects [get_nets -of_objects [get_pins d_1_i/usp_rf_data_converter_0/clk_dac3]]]] -group [get_clocks [get_clocks -of_objects [get_nets -of_objects [get_pins d_1_i/usp_rf_data_converter_0/clk_adc2]]]] -group [get_clocks [get_clocks -of_objects [get_nets -of_objects [get_pins d_1_i/qick_processor_0/t_clk_i]]]] -group [get_clocks [get_clocks -of_objects [get_nets -of_objects [get_pins d_1_i/qick_processor_0/c_clk_i]]]]


