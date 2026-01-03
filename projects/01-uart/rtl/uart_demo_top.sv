//-----------------------------------------------------------------------------
// Module: uart_demo_top
//
// Description:
//   Hardware demo wrapper for UART transceiver. Interfaces with
//   RealDigital Blackboard switches, buttons, LEDs, and 7-segment
//   display. Supports local echo, internal loopback, and baud rate
//   display modes.
//
// Parameters:
//   CLK_FREQ - System clock frequency in Hz (default: 100_000_000)
//
// Dependencies:
//   uart_top
//   seven_seg_controller (library/peripherals/)
//   debounce (library/core/)
//   baud_display
//
// Author: Chris Lindsey
// Date: 2026-01-02
//-----------------------------------------------------------------------------

module uart_demo_top #(
    parameter int CLK_FREQ = 100_000_000
) (
    // Clock and reset
    input  logic        clk,
    input  logic        rst_n,

    // Serial pins (directly to Pmod connector)
    output logic        tx_pin,          // Pmod JA1
    input  logic        rx_pin,          // Pmod JA2

    // Switches
    input  logic [7:0]  sw,
    // sw[3:0] - Baud rate select
    // sw[4]   - Enable local echo
    // sw[5]   - Enable internal loopback (TX→RX)
    // sw[6]   - Enable autobaud
    // sw[7]   - Display mode (0=last byte, 1=measured baud)

    // Buttons (directly from pins, active high)
    input  logic [3:0]  btn,
    // btn[0] - Clear error flags
    // btn[1] - Reset calibration
    // btn[3] - System reset

    // LEDs
    output logic [7:0]  led,
    // led[0]   - TX busy
    // led[1]   - RX data available
    // led[2]   - TX FIFO full
    // led[3]   - RX FIFO full
    // led[4]   - Frame error (latched)
    // led[5]   - Parity error (latched)
    // led[7:6] - Calibration quality

    // 7-segment display
    output logic [6:0]  seg,             // Segment outputs
    output logic        dp,              // Decimal point
    output logic [3:0]  an               // Digit anodes
);

    //-------------------------------------------------------------------------
    // Internal signals
    //-------------------------------------------------------------------------
    logic [3:0]  baud_sel;
    logic        echo_en;
    logic        loopback_en;
    logic        autobaud_en;
    logic        display_mode;

    logic        btn_clear_debounced;
    logic        btn_reset_cal_debounced;

    logic [7:0]  last_rx_byte;
    logic [3:0]  display_digit [0:3];

    //-------------------------------------------------------------------------
    // Demo logic - TODO: Implement
    //-------------------------------------------------------------------------

endmodule
