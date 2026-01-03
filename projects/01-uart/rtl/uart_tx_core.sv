//-----------------------------------------------------------------------------
// Module: uart_tx_core
//
// Description:
//   UART transmitter state machine with shift register. Generates serial
//   output with configurable frame format (data bits, parity, stop bits).
//   Uses 16x oversampling tick for bit timing.
//
// Parameters:
//   DATA_BITS  - Data bits per frame, 7 or 8 (default: 8)
//   PARITY_EN  - Enable parity bit (default: 0)
//   PARITY_ODD - 0=even parity, 1=odd parity (default: 0)
//   STOP_BITS  - Number of stop bits, 1 or 2 (default: 1)
//
// Dependencies:
//   None
//
// Author: Chris Lindsey
// Date: 2026-01-02
//-----------------------------------------------------------------------------

module uart_tx_core #(
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

    // Data interface
    input  logic [7:0] tx_data,          // Data byte to transmit
    input  logic       tx_valid,         // Data valid (FIFO not empty)
    output logic       tx_ready,         // Ready for next byte

    // Serial output
    output logic       tx_pin,           // Serial TX output
    output logic       tx_busy           // Transmission in progress
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
    } tx_state_t;

    //-------------------------------------------------------------------------
    // Internal signals
    //-------------------------------------------------------------------------
    tx_state_t          state, next_state;
    logic [3:0]         tick_count;      // 0-15 for oversampling
    logic [2:0]         bit_count;       // 0-7 for data bits
    logic [7:0]         shift_reg;
    logic               parity_bit;

    //-------------------------------------------------------------------------
    // TX state machine - TODO: Implement
    //-------------------------------------------------------------------------

endmodule
