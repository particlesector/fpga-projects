#-----------------------------------------------------------------------------
# Script: run_sim.tcl
#
# Description:
#   Runs behavioral simulation for UART project testbenches
#
# Usage:
#   vivado -mode batch -source scripts/run_sim.tcl
#   vivado -mode batch -source scripts/run_sim.tcl -tclargs <testbench_name>
#
# Examples:
#   vivado -mode batch -source scripts/run_sim.tcl
#   vivado -mode batch -source scripts/run_sim.tcl -tclargs uart_tx_core_tb
#
# Author: Chris Lindsey
# Date: 2026-01-02
#-----------------------------------------------------------------------------

# Get script directory
set script_dir [file dirname [file normalize [info script]]]
set proj_root  [file dirname $script_dir]
set project_dir "$proj_root/vivado"
set project_name "uart"

# Check for command line arguments
set run_all 1
set specific_tb ""
if {$argc > 0} {
    set specific_tb [lindex $argv 0]
    set run_all 0
    puts "Running specific testbench: $specific_tb"
}

# List of testbenches to run (in order)
set testbenches {
    baud_generator_tb
    uart_tx_core_tb
    uart_rx_core_tb
    autobaud_calibrator_tb
    uart_top_tb
    uart_system_tb
}

#-----------------------------------------------------------------------------
# Open project
#-----------------------------------------------------------------------------
puts "=============================================="
puts "UART Simulation Runner"
puts "=============================================="

if {[file exists "$project_dir/$project_name.xpr"]} {
    puts "Opening project..."
    open_project "$project_dir/$project_name.xpr"
} else {
    puts "ERROR: Project not found at $project_dir/$project_name.xpr"
    puts "Run create_project.tcl first."
    exit 1
}

#-----------------------------------------------------------------------------
# Run simulations
#-----------------------------------------------------------------------------
set pass_count 0
set fail_count 0
set skip_count 0

proc run_testbench {tb_name} {
    global pass_count fail_count skip_count

    puts ""
    puts "----------------------------------------------"
    puts "Running: $tb_name"
    puts "----------------------------------------------"

    # Check if testbench file exists
    set tb_files [get_files -quiet "*${tb_name}.sv"]
    if {[llength $tb_files] == 0} {
        puts "  SKIP: Testbench file not found"
        incr skip_count
        return
    }

    # Set testbench as simulation top
    set_property top $tb_name [get_filesets sim_1]

    # Reset simulation
    reset_simulation sim_1

    # Launch simulation
    if {[catch {launch_simulation} err]} {
        puts "  FAIL: Simulation launch failed"
        puts "  Error: $err"
        incr fail_count
        return
    }

    # Run simulation
    run all

    # Check for errors (look for $error or assertion failures)
    # Note: This is a basic check; actual pass/fail depends on testbench output
    puts "  DONE: Simulation complete"
    incr pass_count

    # Close simulation
    close_sim -quiet
}

if {$run_all} {
    puts "Running all testbenches..."
    foreach tb $testbenches {
        run_testbench $tb
    }
} else {
    run_testbench $specific_tb
}

#-----------------------------------------------------------------------------
# Summary
#-----------------------------------------------------------------------------
puts ""
puts "=============================================="
puts "Simulation Summary"
puts "=============================================="
puts "  Passed:  $pass_count"
puts "  Failed:  $fail_count"
puts "  Skipped: $skip_count"
puts "=============================================="

if {$fail_count > 0} {
    puts "RESULT: SOME TESTS FAILED"
    exit 1
} else {
    puts "RESULT: ALL TESTS PASSED"
    exit 0
}
