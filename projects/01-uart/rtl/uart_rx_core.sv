//-----------------------------------------------------------------------------
// Module: uart_rx_core
//
// Description:
//   UART receiver state machine with adaptive sampling. Uses 16x
//   oversampling with 3-sample majority voting. Supports configurable
//   frame format and reports framing/parity errors.
//
// Parameters:
//   DATA_BITS  - Data bits per frame, 7 or 8 (default: 8)
//   PARITY_EN  - Enable parity checking (default: 0)
//   PARITY_ODD - 0=even parity, 1=odd parity (default: 0)
//
// Dependencies:
//   None
//
// Author: Chris Lindsey
// Date: 2026-01-02
//-----------------------------------------------------------------------------

module uart_rx_core #(
    parameter int DATA_BITS  = 8,
    parameter bit PARITY_EN  = 1'b0,
    parameter bit PARITY_ODD = 1'b0
) (
    // Clock and reset
    input  logic        clk,
    input  logic        rst_n,

    // Timing
    input  logic        tick,            // 16x baud rate tick

    // Serial input (synchronized)
    input  logic        rx_sync,         // Synchronized RX input

    // Data output
    output logic [7:0]  rx_data,         // Received byte
    output logic        rx_valid,        // Byte ready (single cycle)

    // Error flags (latched until cleared)
    output logic        frame_err,       // Stop bit error
    output logic        parity_err,      // Parity error
    input  logic        err_clear,       // Clear error latches

    // Autobaud interface
    input  logic [15:0] bit_period,      // Bit period from autobaud
    input  logic [3:0]  sample_offset,   // Sample point adjustment
    output logic        frame_start,     // Start of frame detected
    output logic        frame_done       // Frame complete
);

    //-------------------------------------------------------------------------
    // State machine states
    //-------------------------------------------------------------------------
    typedef enum logic [2:0] {
        IDLE,
        START,
        DATA,
        PARITY,
        STOP
    } rx_state_t;

    //-------------------------------------------------------------------------
    // Internal signals
    //-------------------------------------------------------------------------
    rx_state_t          state, next_state;
    logic [3:0]         tick_count;      // 0-15 for oversampling
    logic [2:0]         bit_count;       // 0-7 for data bits
    logic [7:0]         shift_reg;
    logic [2:0]         sample_buffer;   // For majority voting

    //-------------------------------------------------------------------------
    // RX state machine - TODO: Implement
    //-------------------------------------------------------------------------

endmodule
