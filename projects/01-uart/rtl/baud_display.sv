//-----------------------------------------------------------------------------
// Module: baud_display
//
// Description:
//   Converts measured baud rate to 7-segment display format. Displays
//   baud rate in abbreviated form (e.g., "115.2" for 115200).
//
// Parameters:
//   None
//
// Dependencies:
//   None
//
// Author: Chris Lindsey
// Date: 2026-01-02
//-----------------------------------------------------------------------------

module baud_display (
    // Clock and reset
    input  logic        clk,
    input  logic        rst_n,

    // Baud rate input
    input  logic [19:0] measured_baud,   // Baud rate value

    // 7-segment outputs (BCD digits)
    output logic [3:0]  digit0,          // Rightmost digit
    output logic [3:0]  digit1,
    output logic [3:0]  digit2,
    output logic [3:0]  digit3,          // Leftmost digit
    output logic [3:0]  dp_position      // Decimal point position
);

    //-------------------------------------------------------------------------
    // Internal signals
    //-------------------------------------------------------------------------
    logic [19:0] baud_scaled;
    logic [15:0] bcd_value;

    //-------------------------------------------------------------------------
    // Baud to display conversion - TODO: Implement
    //-------------------------------------------------------------------------

endmodule
