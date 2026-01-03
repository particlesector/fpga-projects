##-----------------------------------------------------------------------------
## Constraints: blackboard.xdc
##
## Description:
##   Pin constraints for RealDigital Blackboard (Xilinx Zynq XC7Z007S-1CLG400C)
##   Target module: uart_demo_top
##
## Author: Chris Lindsey
## Date: 2026-01-02
##-----------------------------------------------------------------------------

##-----------------------------------------------------------------------------
## Clock
##-----------------------------------------------------------------------------
## 100 MHz system clock
## Note: Blackboard Zynq PS can be configured to output 100 MHz via block design
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} [get_ports clk]

##-----------------------------------------------------------------------------
## Reset
##-----------------------------------------------------------------------------
## BTN3 directly active-high from board; active-low logic in design handles inversion
## rst_n is generated internally from btn[3]

##-----------------------------------------------------------------------------
## UART Pins - Pmod JA
##-----------------------------------------------------------------------------
## Pmod JA Pin 1 (top row, pin 1) - TX output
set_property -dict {PACKAGE_PIN Y18 IOSTANDARD LVCMOS33} [get_ports tx_pin]

## Pmod JA Pin 2 (top row, pin 2) - RX input
set_property -dict {PACKAGE_PIN Y19 IOSTANDARD LVCMOS33} [get_ports rx_pin]

##-----------------------------------------------------------------------------
## Switches
##-----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33} [get_ports {sw[0]}]
set_property -dict {PACKAGE_PIN Y17 IOSTANDARD LVCMOS33} [get_ports {sw[1]}]
set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33} [get_ports {sw[2]}]
set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS33} [get_ports {sw[3]}]
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports {sw[4]}]
set_property -dict {PACKAGE_PIN U13 IOSTANDARD LVCMOS33} [get_ports {sw[5]}]
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports {sw[6]}]
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports {sw[7]}]

##-----------------------------------------------------------------------------
## Buttons (directly active high from board)
##-----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN Y13 IOSTANDARD LVCMOS33} [get_ports {btn[0]}]
set_property -dict {PACKAGE_PIN W12 IOSTANDARD LVCMOS33} [get_ports {btn[1]}]
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS33} [get_ports {btn[2]}]
set_property -dict {PACKAGE_PIN Y14 IOSTANDARD LVCMOS33} [get_ports {btn[3]}]

##-----------------------------------------------------------------------------
## LEDs
##-----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN N20 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN P20 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN R19 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN T20 IOSTANDARD LVCMOS33} [get_ports {led[3]}]
set_property -dict {PACKAGE_PIN T19 IOSTANDARD LVCMOS33} [get_ports {led[4]}]
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports {led[5]}]
set_property -dict {PACKAGE_PIN W20 IOSTANDARD LVCMOS33} [get_ports {led[6]}]
set_property -dict {PACKAGE_PIN V20 IOSTANDARD LVCMOS33} [get_ports {led[7]}]

##-----------------------------------------------------------------------------
## 7-Segment Display - Segments (accent active-low)
##-----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN K19 IOSTANDARD LVCMOS33} [get_ports {seg[0]}]
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {seg[1]}]
set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports {seg[2]}]
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports {seg[3]}]
set_property -dict {PACKAGE_PIN L17 IOSTANDARD LVCMOS33} [get_ports {seg[4]}]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports {seg[5]}]
set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports {seg[6]}]

## Decimal point
set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS33} [get_ports dp]

##-----------------------------------------------------------------------------
## 7-Segment Display - Digit Anodes (active-low)
##-----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN L19 IOSTANDARD LVCMOS33} [get_ports {an[0]}]
set_property -dict {PACKAGE_PIN L20 IOSTANDARD LVCMOS33} [get_ports {an[1]}]
set_property -dict {PACKAGE_PIN M20 IOSTANDARD LVCMOS33} [get_ports {an[2]}]
set_property -dict {PACKAGE_PIN N19 IOSTANDARD LVCMOS33} [get_ports {an[3]}]

##-----------------------------------------------------------------------------
## Configuration
##-----------------------------------------------------------------------------
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

##-----------------------------------------------------------------------------
## Timing Constraints
##-----------------------------------------------------------------------------
## Input delays for asynchronous inputs (switches, buttons, RX)
set_input_delay -clock sys_clk_pin -max 2.0 [get_ports {sw[*]}]
set_input_delay -clock sys_clk_pin -max 2.0 [get_ports {btn[*]}]
set_input_delay -clock sys_clk_pin -max 2.0 [get_ports rx_pin]

## Output delays
set_output_delay -clock sys_clk_pin -max 2.0 [get_ports tx_pin]
set_output_delay -clock sys_clk_pin -max 2.0 [get_ports {led[*]}]
set_output_delay -clock sys_clk_pin -max 2.0 [get_ports {seg[*]}]
set_output_delay -clock sys_clk_pin -max 2.0 [get_ports dp]
set_output_delay -clock sys_clk_pin -max 2.0 [get_ports {an[*]}]

## False path for asynchronous inputs (they go through synchronizers)
set_false_path -from [get_ports {sw[*]}]
set_false_path -from [get_ports {btn[*]}]
set_false_path -from [get_ports rx_pin]
