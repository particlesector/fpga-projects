//-----------------------------------------------------------------------------
// Module: edge_detector
//
// Description:
//   Detects rising and/or falling edges on an input signal.
//   Outputs single-cycle pulses on detected edges.
//
// Parameters:
//   DETECT_RISING  - Enable rising edge detection (default: 1)
//   DETECT_FALLING - Enable falling edge detection (default: 1)
//
// Dependencies:
//   None
//
// Author: Chris Lindsey
// Date: 2026-01-02
//-----------------------------------------------------------------------------

module edge_detector #(
    parameter bit DETECT_RISING  = 1'b1,
    parameter bit DETECT_FALLING = 1'b1
) (
    // Clock and reset
    input  logic clk,
    input  logic rst_n,

    // Input signal (should be synchronous to clk)
    input  logic sig_in,

    // Edge detection outputs
    output logic rising_edge,
    output logic falling_edge
);

    //-------------------------------------------------------------------------
    // Internal signals
    //-------------------------------------------------------------------------
    logic sig_prev;

    //-------------------------------------------------------------------------
    // Previous value register
    //-------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sig_prev <= 1'b0;
        end else begin
            sig_prev <= sig_in;
        end
    end

    //-------------------------------------------------------------------------
    // Edge detection logic
    //-------------------------------------------------------------------------
    assign rising_edge  = DETECT_RISING  ? (sig_in & ~sig_prev) : 1'b0;
    assign falling_edge = DETECT_FALLING ? (~sig_in & sig_prev) : 1'b0;

endmodule
