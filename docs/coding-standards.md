# SystemVerilog Coding Standards

This document defines the coding standards for all SystemVerilog modules in this repository.

---

## Module Header Template

Every module must begin with a standard header block:

```systemverilog
//-----------------------------------------------------------------------------
// Module: <module_name>
//
// Description:
//   <Brief description of what this module does>
//
// Parameters:
//   <PARAM_NAME> - <description>
//
// Dependencies:
//   <list any instantiated modules, or "None">
//
// Author: Chris Lindsey
// Date: <YYYY-MM-DD>
//-----------------------------------------------------------------------------
```

---

## Naming Conventions

### Signals

| Type | Convention | Examples |
|------|------------|----------|
| Clock | `clk` or `clk_<name>` | `clk`, `clk_pixel` |
| Reset | `rst_n` (active-low async) | `rst_n` |
| Enable | `<name>_en` | `tx_en`, `autobaud_en` |
| Valid | `<name>_valid` | `rx_valid`, `data_valid` |
| Ready | `<name>_ready` | `tx_ready`, `fifo_ready` |
| Data buses | `<name>_data` | `tx_data`, `rx_data` |
| Write strobe | `<name>_wr_en` | `fifo_wr_en` |
| Read strobe | `<name>_rd_en` | `fifo_rd_en` |
| Active-low signals | `<name>_n` | `cs_n`, `oe_n` |
| Physical pins | `<name>_pin` | `tx_pin`, `rx_pin` |

### Parameters

- Use `UPPER_CASE` with underscores
- Examples: `CLK_FREQ`, `DATA_WIDTH`, `FIFO_DEPTH`

### Modules

- Use `lower_case` with underscores
- Examples: `uart_tx_core`, `baud_generator`, `fifo_fwft`

### Files

- One module per file
- Filename matches module name: `uart_tx_core.sv`

---

## Coding Style

### Data Types

- Always use `logic` instead of `reg` or `wire`
- Use explicit widths: `logic [7:0]` not `logic [0:7]`

```systemverilog
// Good
logic [7:0] tx_data;
logic       tx_valid;

// Avoid
reg [7:0] tx_data;
wire tx_valid;
```

### Parameters and Ports

- Parameters before ports in module declaration
- Group ports by function: clocks/resets, inputs, outputs
- One port per line with aligned comments

```systemverilog
module example #(
    parameter int DATA_WIDTH = 8,
    parameter int FIFO_DEPTH = 16
) (
    // Clock and reset
    input  logic                  clk,
    input  logic                  rst_n,

    // Data input
    input  logic [DATA_WIDTH-1:0] data_in,
    input  logic                  data_valid,

    // Data output
    output logic [DATA_WIDTH-1:0] data_out,
    output logic                  data_ready
);
```

### Always Blocks

- Use `always_ff` for sequential logic
- Use `always_comb` for combinational logic
- Never use `always @*` or `always @(posedge clk)`

```systemverilog
// Sequential logic
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= '0;
    end else begin
        count <= count + 1'b1;
    end
end

// Combinational logic
always_comb begin
    next_state = current_state;
    case (current_state)
        IDLE: if (start) next_state = RUNNING;
        // ...
    endcase
end
```

### State Machines

- Use `typedef enum` for state definitions
- Place in `<module>_pkg.sv` if shared, otherwise local
- Use descriptive state names in `UPPER_CASE`

```systemverilog
typedef enum logic [1:0] {
    IDLE,
    START,
    DATA,
    STOP
} uart_state_t;

uart_state_t state, next_state;
```

### Reset Style

- Active-low asynchronous reset (`rst_n`)
- Reset to known values, typically `'0`

---

## File Organization

### Project Structure

```
project/
├── rtl/           # Synthesizable RTL
├── tb/            # Testbenches
├── constraints/   # Timing/pin constraints
└── scripts/       # Build scripts
```

### Library Structure

```
library/
├── core/          # Fundamental building blocks
├── peripherals/   # Board peripheral interfaces
└── tb/            # Library testbenches
```

---

## Instantiation Style

- Use named port connections (never positional)
- Align ports for readability

```systemverilog
uart_tx_core #(
    .DATA_BITS (8),
    .PARITY_EN (1'b0)
) u_tx_core (
    .clk      (clk),
    .rst_n    (rst_n),
    .tick     (baud_tick),
    .tx_data  (tx_fifo_data),
    .tx_valid (tx_fifo_valid),
    .tx_ready (tx_ready),
    .tx_pin   (tx_pin)
);
```

---

## Comments

- Use `//` for single-line comments
- Use `/* */` sparingly, mainly for disabling code blocks
- Comment non-obvious logic, not obvious code

```systemverilog
// Good: explains WHY
// Sample at bit center (8 ticks into 16-tick bit period)
if (tick_count == 4'd7) begin

// Bad: restates WHAT the code does
// Increment counter
count <= count + 1;
```
