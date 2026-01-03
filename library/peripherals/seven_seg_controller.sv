//-----------------------------------------------------------------------------
// Module: seven_seg_controller
//
// Description:
//   4-digit multiplexed 7-segment display driver. Accepts 4 BCD or hex
//   digits and drives common-cathode or common-anode displays with
//   configurable refresh rate.
//
// Parameters:
//   CLK_FREQ     - System clock frequency in Hz (default: 100_000_000)
//   REFRESH_HZ   - Display refresh rate per digit (default: 1000)
//   COMMON_ANODE - Set to 1 for common anode displays (default: 0)
//
// Dependencies:
//   None
//
// Author: Chris Lindsey
// Date: 2026-01-02
//-----------------------------------------------------------------------------

module seven_seg_controller #(
    parameter int CLK_FREQ     = 100_000_000,
    parameter int REFRESH_HZ   = 1000,
    parameter bit COMMON_ANODE = 1'b0
) (
    // Clock and reset
    input  logic        clk,
    input  logic        rst_n,

    // Digit inputs (active display values)
    input  logic [3:0]  digit0,          // Rightmost digit
    input  logic [3:0]  digit1,
    input  logic [3:0]  digit2,
    input  logic [3:0]  digit3,          // Leftmost digit

    // Decimal point control (active high)
    input  logic [3:0]  dp_in,

    // Digit enable (active high, allows blanking)
    input  logic [3:0]  digit_en,

    // Display outputs
    output logic [6:0]  seg,             // Segment outputs (active per COMMON_ANODE)
    output logic        dp,              // Decimal point
    output logic [3:0]  an               // Digit anodes/cathodes
);

    //-------------------------------------------------------------------------
    // Local parameters
    //-------------------------------------------------------------------------
    localparam int REFRESH_CYCLES = CLK_FREQ / (REFRESH_HZ * 4);
    localparam int COUNTER_WIDTH  = $clog2(REFRESH_CYCLES);

    //-------------------------------------------------------------------------
    // Internal signals
    //-------------------------------------------------------------------------
    logic [COUNTER_WIDTH-1:0] refresh_counter;
    logic [1:0]               digit_select;
    logic [3:0]               current_digit;
    logic [6:0]               seg_pattern;

    //-------------------------------------------------------------------------
    // 7-segment decoder and multiplexing - TODO: Implement
    //-------------------------------------------------------------------------

endmodule
