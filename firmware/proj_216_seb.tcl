# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
  set origin_dir $::origin_dir_loc
}

# Set the project name
set _xil_proj_name_ "top_216_seb"

# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir/"]"

# Create project
create_project ${_xil_proj_name_} ./${_xil_proj_name_} -part xczu49dr-ffvf1760-2-e

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [current_project]
set_property -name "board_part" -value "xilinx.com:zcu216:part0:2.0" -objects $obj
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
set_property -name "enable_vhdl_2008" -value "1" -objects $obj
set_property -name "ip_cache_permissions" -value "read write" -objects $obj
set_property -name "ip_output_repo" -value "$proj_dir/${_xil_proj_name_}.cache/ip" -objects $obj
set_property -name "mem.enable_memory_map_generation" -value "1" -objects $obj
set_property -name "platform.board_id" -value "zcu216" -objects $obj
set_property -name "sim.central_dir" -value "$proj_dir/${_xil_proj_name_}.ip_user_files" -objects $obj
set_property -name "sim.ip.auto_export_scripts" -value "1" -objects $obj
set_property -name "simulator_language" -value "Mixed" -objects $obj

# Set IP repository paths
set obj [get_filesets sources_1]
set_property "ip_repo_paths" "[file normalize "$origin_dir/ip"]" $obj

# Rebuild user ip_repo's index before adding any source files
update_ip_catalog -rebuild

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

# Add/Import constrs file and set constrs file properties
set files [list \
	[ file normalize "$origin_dir/xdc/timing_216_seb.xdc"] 	\
	[ file normalize "$origin_dir/xdc/ios_216_seb.xdc"] 	\
]
add_files -fileset $obj $files

# Source Block Design.
set file "[file normalize "$origin_dir/bd/bd_216_seb_2022-1.tcl"]"
source $file

# Update compile order.
#update_compile_order -fileset sources_1

# Set sources_1 fileset object
set obj [get_filesets sources_1]

# Create HDL Wrapper.
make_wrapper -files [get_files d_1.bd] -top

# Add files to sources_1 fileset
set files [list \
  [file normalize "${origin_dir}/${_xil_proj_name_}/${_xil_proj_name_}.srcs/sources_1/bd/d_1/hdl/d_1_wrapper.v" ]\
]
add_files -fileset $obj $files

## Modifie Current Synthesis
set_property strategy Flow_RuntimeOptimized [get_runs synth_1]

## Create Synthesis
create_run Performance -flow {Vivado Synthesis 2022} -strategy Flow_PerfOptimized_high

## Create Implementation NET DELAY
create_run Net_Delay -parent_run Performance -flow {Vivado Implementation 2022} -strategy Performance_NetDelay_high
set INC_DIR_Net_Delay [get_property directory [current_project]]/${_xil_proj_name_}.srcs/utils_1/imports/Net_Delay
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs Net_Delay]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY $INC_DIR_Net_Delay [get_runs Net_Delay]

## Create Implementation Extra Timing Opt
create_run Timing -parent_run Performance -flow {Vivado Implementation 2022} -strategy Performance_ExtraTimingOpt
set INC_DIR_Timing [get_property directory [current_project]]/${_xil_proj_name_}.srcs/utils_1/imports/Timing
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY $INC_DIR_Timing [get_runs Net_Delay]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs Timing]
set_property incremental_checkpoint.directive TimingClosure [get_runs Timing]

current_run [get_runs Performance]
#launch_runs Performance Net_Delay Timing -jobs 5

