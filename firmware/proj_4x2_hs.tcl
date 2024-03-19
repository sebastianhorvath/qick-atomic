###############################################################################
## FERMI RESEARCH LAB
###############################################################################
## Vivado Project Creation Script



## Customizable Parameters
###############################################################################

### Project Name 
set _xil_proj_name_ "top_4x2_hs"

### Constraints
set timing_const timing_4x2_hs.xdc
set ios_const ios_4x2_hs.xdc

### Source Block Design.
set bd_file bd_4x2_hs_2022-1.tcl


## Script
###############################################################################

# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
  set origin_dir $::origin_dir_loc
}


# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir/"]"

# Create project
create_project ${_xil_proj_name_} ./${_xil_proj_name_} -part xczu48dr-ffvg1517-2-e

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [current_project]
set_property -name "board_part_repo_paths" -value "[file normalize "$origin_dir/board_files"]" -objects $obj
set_property -name "board_part" -value "realdigital.org:rfsoc4x2:part0:1.0" -objects $obj
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
set_property -name "enable_vhdl_2008" -value "1" -objects $obj
set_property -name "ip_cache_permissions" -value "read write" -objects $obj
set_property -name "ip_output_repo" -value "$proj_dir/${_xil_proj_name_}.cache/ip" -objects $obj
set_property -name "mem.enable_memory_map_generation" -value "1" -objects $obj
set_property -name "platform.board_id" -value "rfsoc4x2" -objects $obj
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

set const_files [list \
	[ file normalize "$origin_dir/xdc/$timing_const"] 	\
	[ file normalize "$origin_dir/xdc/$ios_const"] 	\
]

add_files -fileset $obj $const_files

# Source Block Design.
#set file "[file normalize "$origin_dir/bd/bd_216_qt_2022-1.tcl"]"

source [file normalize "$origin_dir/bd/$bd_file"]

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

# Add Runs
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
#create_run Timing -parent_run Performance -flow {Vivado Implementation 2022} -strategy Performance_ExtraTimingOpt
#set INC_DIR_Timing [get_property directory [current_project]]/${_xil_proj_name_}.srcs/utils_1/imports/Timing
#set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY $INC_DIR_Timing [get_runs Net_Delay]
#set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs Timing]
#set_property incremental_checkpoint.directive TimingClosure [get_runs Timing]

## Create Implementation Refine Placement
#create_run Refine_Place -parent_run Performance -flow {Vivado Implementation 2022} -strategy Performance_RefinePlacement
#set INC_DIR_Refine [get_property directory [current_project]]/${_xil_proj_name_}.srcs/utils_1/imports/Refine
#set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY $INC_DIR_Refine [get_runs Refine_Place]
#set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs Refine_Place]

current_run [get_runs Performance]
#launch_runs Performance Net_Delay Timing Refine_Place -jobs 5