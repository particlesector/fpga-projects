#-----------------------------------------------------------------------------
# Script: create_project.tcl
#
# Description:
#   Creates Vivado project for UART Transceiver on RealDigital Blackboard
#
# Usage:
#   vivado -mode batch -source scripts/create_project.tcl
#   vivado -mode gui -source scripts/create_project.tcl
#
# Author: Chris Lindsey
# Date: 2026-01-02
#-----------------------------------------------------------------------------

# Project settings
set project_name "uart"
set project_dir  "./vivado"
set part         "xc7z007sclg400-1"
set top_module   "uart_demo_top"

# Get script directory (project root)
set script_dir [file dirname [file normalize [info script]]]
set proj_root  [file dirname $script_dir]
set repo_root  [file dirname [file dirname $proj_root]]

puts "=============================================="
puts "Creating UART Project"
puts "=============================================="
puts "Project root: $proj_root"
puts "Repository root: $repo_root"
puts "Part: $part"
puts "Top module: $top_module"
puts "=============================================="

# Create project
create_project $project_name $proj_root/$project_dir -part $part -force

# Set project properties
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]

#-----------------------------------------------------------------------------
# Add RTL sources
#-----------------------------------------------------------------------------
puts "Adding RTL sources..."

# Project RTL files
set rtl_files [glob -nocomplain $proj_root/rtl/*.sv]
if {[llength $rtl_files] > 0} {
    add_files -norecurse $rtl_files
    puts "  Added [llength $rtl_files] project RTL files"
}

# Library core files
set lib_core_files [glob -nocomplain $repo_root/library/core/*.sv]
if {[llength $lib_core_files] > 0} {
    add_files -norecurse $lib_core_files
    puts "  Added [llength $lib_core_files] library core files"
}

# Library peripheral files
set lib_periph_files [glob -nocomplain $repo_root/library/peripherals/*.sv]
if {[llength $lib_periph_files] > 0} {
    add_files -norecurse $lib_periph_files
    puts "  Added [llength $lib_periph_files] library peripheral files"
}

#-----------------------------------------------------------------------------
# Add constraints
#-----------------------------------------------------------------------------
puts "Adding constraints..."

set xdc_files [glob -nocomplain $proj_root/constraints/*.xdc]
if {[llength $xdc_files] > 0} {
    add_files -fileset constrs_1 -norecurse $xdc_files
    puts "  Added [llength $xdc_files] constraint files"
}

#-----------------------------------------------------------------------------
# Add testbench sources
#-----------------------------------------------------------------------------
puts "Adding testbench sources..."

set tb_files [glob -nocomplain $proj_root/tb/*.sv]
if {[llength $tb_files] > 0} {
    add_files -fileset sim_1 -norecurse $tb_files
    puts "  Added [llength $tb_files] testbench files"
}

# Library testbench files
set lib_tb_files [glob -nocomplain $repo_root/library/tb/*.sv]
if {[llength $lib_tb_files] > 0} {
    add_files -fileset sim_1 -norecurse $lib_tb_files
    puts "  Added [llength $lib_tb_files] library testbench files"
}

#-----------------------------------------------------------------------------
# Set top module
#-----------------------------------------------------------------------------
puts "Setting top module to $top_module..."
set_property top $top_module [current_fileset]

#-----------------------------------------------------------------------------
# Configure simulation
#-----------------------------------------------------------------------------
puts "Configuring simulation settings..."
set_property top uart_top_tb [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {1000us} -objects [get_filesets sim_1]

#-----------------------------------------------------------------------------
# Update compile order
#-----------------------------------------------------------------------------
puts "Updating compile order..."
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

#-----------------------------------------------------------------------------
# Done
#-----------------------------------------------------------------------------
puts "=============================================="
puts "Project created successfully!"
puts "Project location: $proj_root/$project_dir"
puts "=============================================="
puts ""
puts "Next steps:"
puts "  1. Run synthesis: launch_runs synth_1"
puts "  2. Run implementation: launch_runs impl_1"
puts "  3. Generate bitstream: write_bitstream"
puts "  4. Run simulation: launch_simulation"
puts ""
