# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DEBUG" -parent ${Page_0}

  set DT_W [ipgui::add_param $IPINST -name "DT_W" -widget comboBox]
  set_property tooltip {DT W} ${DT_W}
  ipgui::add_param $IPINST -name "N_S" -widget comboBox
  ipgui::add_param $IPINST -name "T_W"
  ipgui::add_param $IPINST -name "FIFO_W"
  ipgui::add_param $IPINST -name "DTR_RST"

}

proc update_PARAM_VALUE.DEBUG { PARAM_VALUE.DEBUG } {
	# Procedure called to update DEBUG when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEBUG { PARAM_VALUE.DEBUG } {
	# Procedure called to validate DEBUG
	return true
}

proc update_PARAM_VALUE.DTR_RST { PARAM_VALUE.DTR_RST } {
	# Procedure called to update DTR_RST when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DTR_RST { PARAM_VALUE.DTR_RST } {
	# Procedure called to validate DTR_RST
	return true
}

proc update_PARAM_VALUE.DT_W { PARAM_VALUE.DT_W } {
	# Procedure called to update DT_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DT_W { PARAM_VALUE.DT_W } {
	# Procedure called to validate DT_W
	return true
}

proc update_PARAM_VALUE.FIFO_W { PARAM_VALUE.FIFO_W } {
	# Procedure called to update FIFO_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FIFO_W { PARAM_VALUE.FIFO_W } {
	# Procedure called to validate FIFO_W
	return true
}

proc update_PARAM_VALUE.N_S { PARAM_VALUE.N_S } {
	# Procedure called to update N_S when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.N_S { PARAM_VALUE.N_S } {
	# Procedure called to validate N_S
	return true
}

proc update_PARAM_VALUE.T_W { PARAM_VALUE.T_W } {
	# Procedure called to update T_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.T_W { PARAM_VALUE.T_W } {
	# Procedure called to validate T_W
	return true
}


proc update_MODELPARAM_VALUE.DEBUG { MODELPARAM_VALUE.DEBUG PARAM_VALUE.DEBUG } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEBUG}] ${MODELPARAM_VALUE.DEBUG}
}

proc update_MODELPARAM_VALUE.DT_W { MODELPARAM_VALUE.DT_W PARAM_VALUE.DT_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DT_W}] ${MODELPARAM_VALUE.DT_W}
}

proc update_MODELPARAM_VALUE.N_S { MODELPARAM_VALUE.N_S PARAM_VALUE.N_S } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.N_S}] ${MODELPARAM_VALUE.N_S}
}

proc update_MODELPARAM_VALUE.T_W { MODELPARAM_VALUE.T_W PARAM_VALUE.T_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.T_W}] ${MODELPARAM_VALUE.T_W}
}

proc update_MODELPARAM_VALUE.FIFO_W { MODELPARAM_VALUE.FIFO_W PARAM_VALUE.FIFO_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FIFO_W}] ${MODELPARAM_VALUE.FIFO_W}
}

proc update_MODELPARAM_VALUE.DTR_RST { MODELPARAM_VALUE.DTR_RST PARAM_VALUE.DTR_RST } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DTR_RST}] ${MODELPARAM_VALUE.DTR_RST}
}

