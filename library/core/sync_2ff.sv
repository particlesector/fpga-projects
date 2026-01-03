//-----------------------------------------------------------------------------
// Module: sync_2ff
//
// Description:
//   2-stage flip-flop synchronizer for crossing clock domains or
//   synchronizing asynchronous inputs. Reduces metastability risk.
//
// Parameters:
//   WIDTH - Bit width of the synchronized signal (default: 1)
//
// Dependencies:
//   None
//
// Author: Chris Lindsey
// Date: 2026-01-02
//-----------------------------------------------------------------------------

module sync_2ff #(
    parameter int WIDTH = 1
) (
    // Clock and reset
    input  logic             clk,
    input  logic             rst_n,

    // Asynchronous input
    input  logic [WIDTH-1:0] async_in,

    // Synchronized output
    output logic [WIDTH-1:0] sync_out
);

    //-------------------------------------------------------------------------
    // Internal signals
    //-------------------------------------------------------------------------
    logic [WIDTH-1:0] meta_ff;
    logic [WIDTH-1:0] sync_ff;

    //-------------------------------------------------------------------------
    // Synchronizer flip-flops
    //-------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            meta_ff <= '0;
            sync_ff <= '0;
        end else begin
            meta_ff <= async_in;
            sync_ff <= meta_ff;
        end
    end

    assign sync_out = sync_ff;

endmodule
