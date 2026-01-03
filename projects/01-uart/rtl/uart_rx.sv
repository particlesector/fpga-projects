//-----------------------------------------------------------------------------
// Module: uart_rx
//
// Description:
//   RX path wrapper combining input synchronizer, autobaud calibrator,
//   RX core, and FWFT FIFO. Provides buffered reception with automatic
//   baud rate tracking.
//
// Parameters:
//   CLK_FREQ   - System clock frequency in Hz (default: 100_000_000)
//   FIFO_DEPTH - RX FIFO depth (default: 16)
//   DATA_BITS  - Data bits per frame, 7 or 8 (default: 8)
//   PARITY_EN  - Enable parity checking (default: 0)
//   PARITY_ODD - 0=even parity, 1=odd parity (default: 0)
//
// Dependencies:
//   sync_2ff (library/core/)
//   edge_detector (library/core/)
//   autobaud_calibrator
//   uart_rx_core
//   fifo_fwft (library/core/)
//
// Author: Chris Lindsey
// Date: 2026-01-02
//-----------------------------------------------------------------------------

module uart_rx #(
    parameter int CLK_FREQ   = 100_000_000,
    parameter int FIFO_DEPTH = 16,
    parameter int DATA_BITS  = 8,
    parameter bit PARITY_EN  = 1'b0,
    parameter bit PARITY_ODD = 1'b0
) (
    // Clock and reset
    input  logic        clk,
    input  logic        rst_n,

    // Timing
    input  logic        tick,            // 16x baud rate tick
    input  logic [15:0] nominal_bit_period,

    // Serial input (directly from pin)
    input  logic        rx_pin,          // Raw RX input

    // Read interface (from FIFO)
    output logic [7:0]  rx_rd_data,      // Received data
    input  logic        rx_rd_en,        // Read enable
    output logic        rx_data_avail,   // FIFO not empty

    // Status
    output logic        rx_fifo_full,    // FIFO full
    output logic        frame_err,       // Framing error (latched)
    output logic        parity_err,      // Parity error (latched)
    input  logic        err_clear,       // Clear error latches

    // Autobaud control and status
    input  logic        autobaud_enable,
    output logic [1:0]  calibration_quality,
    output logic [19:0] measured_baud
);

    //-------------------------------------------------------------------------
    // Internal signals
    //-------------------------------------------------------------------------
    logic        rx_sync;
    logic [7:0]  rx_data;
    logic        rx_valid;
    logic        frame_start;
    logic        frame_done;
    logic [15:0] calibrated_bit_period;
    logic [3:0]  sample_offset;

    //-------------------------------------------------------------------------
    // RX path instantiation - TODO: Implement
    //-------------------------------------------------------------------------

endmodule
