//-----------------------------------------------------------------------------
// Module: uart_tx
//
// Description:
//   TX path wrapper combining FWFT FIFO with TX core. Provides buffered
//   transmission with flow control.
//
// Parameters:
//   FIFO_DEPTH - TX FIFO depth (default: 16)
//   DATA_BITS  - Data bits per frame, 7 or 8 (default: 8)
//   PARITY_EN  - Enable parity bit (default: 0)
//   PARITY_ODD - 0=even parity, 1=odd parity (default: 0)
//   STOP_BITS  - Number of stop bits, 1 or 2 (default: 1)
//
// Dependencies:
//   fifo_fwft (library/core/)
//   uart_tx_core
//
// Author: Chris Lindsey
// Date: 2026-01-02
//-----------------------------------------------------------------------------

module uart_tx #(
    parameter int FIFO_DEPTH = 16,
    parameter int DATA_BITS  = 8,
    parameter bit PARITY_EN  = 1'b0,
    parameter bit PARITY_ODD = 1'b0,
    parameter int STOP_BITS  = 1
) (
    // Clock and reset
    input  logic       clk,
    input  logic       rst_n,

    // Timing
    input  logic       tick,             // 16x baud rate tick

    // Write interface (to FIFO)
    input  logic [7:0] tx_wr_data,       // Data to transmit
    input  logic       tx_wr_en,         // Write enable

    // Status
    output logic       tx_fifo_full,     // FIFO full
    output logic       tx_fifo_empty,    // FIFO empty
    output logic       tx_busy,          // Transmission in progress

    // Serial output
    output logic       tx_pin            // Serial TX output
);

    //-------------------------------------------------------------------------
    // Internal signals
    //-------------------------------------------------------------------------
    logic [7:0] fifo_rd_data;
    logic       fifo_rd_en;
    logic       fifo_empty;
    logic       tx_ready;

    //-------------------------------------------------------------------------
    // FIFO and TX core instantiation - TODO: Implement
    //-------------------------------------------------------------------------

endmodule
