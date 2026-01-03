//-----------------------------------------------------------------------------
// Module: fifo_fwft
//
// Description:
//   First-Word-Fall-Through synchronous FIFO. Data appears on rd_data
//   immediately when available (no read latency). Uses standard
//   valid/ready handshaking.
//
// Parameters:
//   DATA_WIDTH - Width of data bus (default: 8)
//   DEPTH      - Number of entries, must be power of 2 (default: 16)
//
// Dependencies:
//   None
//
// Author: Chris Lindsey
// Date: 2026-01-02
//-----------------------------------------------------------------------------

module fifo_fwft #(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH      = 16
) (
    // Clock and reset
    input  logic                   clk,
    input  logic                   rst_n,

    // Write interface
    input  logic [DATA_WIDTH-1:0]  wr_data,
    input  logic                   wr_en,
    output logic                   full,

    // Read interface (FWFT: data valid when !empty)
    output logic [DATA_WIDTH-1:0]  rd_data,
    input  logic                   rd_en,
    output logic                   empty,

    // Status
    output logic [$clog2(DEPTH):0] count
);

    //-------------------------------------------------------------------------
    // Local parameters
    //-------------------------------------------------------------------------
    localparam int ADDR_WIDTH = $clog2(DEPTH);

    //-------------------------------------------------------------------------
    // Internal signals
    //-------------------------------------------------------------------------
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    logic [ADDR_WIDTH:0]   wr_ptr;
    logic [ADDR_WIDTH:0]   rd_ptr;

    //-------------------------------------------------------------------------
    // FIFO logic - TODO: Implement
    //-------------------------------------------------------------------------

endmodule
