# UART Transceiver with Autobaud Calibration

A professional-grade UART implementation featuring adaptive baud rate detection, continuous calibration, and FWFT FIFOs.

**Status:** 🔲 Planned  
**Platform:** RealDigital Blackboard (Xilinx Zynq XC7Z007S)  
**Language:** SystemVerilog (with VHDL port)  
**System Clock:** 100 MHz  

---

## Features

- **Full-duplex** TX and RX with independent 16-byte FIFOs
- **Configurable framing:** 7/8 data bits, none/even/odd parity, 1/2 stop bits
- **8 baud rates:** 4800 to 460800
- **Tiered autobaud calibration:**
  - Tier 1: 0x55 sync byte detection (±0.1% accuracy)
  - Tier 2: Start bit measurement (±1% accuracy)
  - Tier 3: Static compensation fallback (±3% accuracy)
- **Continuous tracking:** Adapts to temperature drift in real-time
- **16x oversampling** with majority voting
- **Latched error flags:** Frame and parity errors, cleared on read or explicit clear

---

## Architecture

```
┌────────────────────────────────────────────────────────────────────────────┐
│                              uart_top                                      │
│                                                                            │
│  ┌─────────────────┐                                                       │
│  │  baud_generator │──── tick ──────────────────┬───────────────┐          │
│  └─────────────────┘                            │               │          │
│                                                 │               │          │
│  ┌──────────────────────────────────────────────┼───────────────┼────────┐ │
│  │                    TX PATH                   │               │        │ │
│  │                                              │               │        │ │
│  │  ┌────────────┐      ┌─────────────┐         │               │        │ │
│  │  │ fifo_fwft  │─────►│ uart_tx_core│─────────┼───────────────┼────────┼─┼──► TX
│  │  │ (library)  │      │             │         │               │        │ │
│  │  └────────────┘      └─────────────┘         │               │        │ │
│  └──────────────────────────────────────────────┼───────────────┼────────┘ │
│                                                 │               │          │
│  ┌──────────────────────────────────────────────┼───────────────┼────────┐ │
│  │                    RX PATH                   │               │        │ │
│  │                                              │               │        │ │
│  │  ┌──────────┐   ┌─────────────┐   ┌────────────┐   ┌──────────────┐   │ │
│  │  │ sync_2ff │──►│  autobaud   │──►│uart_rx_core│──►│  fifo_fwft   │   │ │
│  │  │(library) │   │ _calibrator │   │            │   │  (library)   │   │ │
│  │  └──────────┘   └─────────────┘   └────────────┘   └──────────────┘   │ │
│  │       ▲                                                               │ │
│  └───────┼───────────────────────────────────────────────────────────────┘ │
│          │                                                                 │
└──────────┼─────────────────────────────────────────────────────────────────┘
           │
        RX Pin
```

---

## Module Hierarchy

```
uart_top
├── baud_generator
│   └── baud_lut (divisor + static compensation lookup)
├── uart_tx
│   ├── fifo_fwft ────────────────► from library/core/
│   └── uart_tx_core
└── uart_rx
    ├── sync_2ff ─────────────────► from library/core/
    ├── edge_detector ────────────► from library/core/
    ├── uart_rx_core
    │   └── autobaud_calibrator
    │       ├── edge_capture
    │       ├── measurement_analyzer
    │       └── rolling_average
    └── fifo_fwft ────────────────► from library/core/
```

### Demo/Hardware Wrapper

```
uart_demo_top
├── uart_top
├── seven_seg_controller ─────────► from library/peripherals/
├── debounce ─────────────────────► from library/core/
└── baud_display
```

---

## Module Summary

### From Library (`../../library/core/`)

| Module          | Description                              | Location                        |
|-----------------|------------------------------------------|---------------------------------|
| `fifo_fwft`     | First-word-fall-through synchronous FIFO | `library/core/fifo_fwft.sv`     |
| `sync_2ff`      | 2-stage metastability synchronizer       | `library/core/sync_2ff.sv`      |
| `edge_detector` | Rising/falling edge detection            | `library/core/edge_detector.sv` |
| `debounce`      | Switch/button debouncer                  | `library/core/debounce.sv`      |

### From Library (`../../library/peripherals/`)

| Module                 | Description                        | Location                                      |
|------------------------|------------------------------------|-----------------------------------------------|
| `seven_seg_controller` | 4-digit multiplexed display driver | `library/peripherals/seven_seg_controller.sv` |

### Project-Specific (`rtl/`)

| Module                | Description                                     |
|-----------------------|-------------------------------------------------|
| `baud_generator`      | Configurable baud rate tick generator           |
| `autobaud_calibrator` | Continuous baud measurement and tracking        |
| `uart_tx_core`        | TX state machine and shift register             |
| `uart_rx_core`        | RX state machine with adaptive sampling         |
| `uart_tx`             | TX path wrapper (FIFO + core)                   |
| `uart_rx`             | RX path wrapper (sync + autobaud + core + FIFO) |
| `uart_top`            | Complete UART transceiver                       |
| `uart_demo_top`       | Hardware demo with display and controls         |
| `baud_display`        | Converts measured baud to 7-segment format      |

---

## Design Decisions

| Parameter    | Decision            | Rationale                                          | 
|--------------|---------------------|----------------------------------------------------|
| FIFO style   | FWFT                | Data available immediately, cleaner consumer logic |
| FIFO depth   | 16                  | Matches 16550 UART standard                        |
| Parity       | None, Even, Odd     | Standard options, skip archaic Mark/Space          |
| Data bits    | 7, 8                | Cover legacy (7E1) and modern (8N1)                |
| Stop bits    | 1, 2                | Standard options, skip 1.5 (archaic)               |
| Baud rates   | 4800-1500000        | 11 rates via 4-bit select                          |
| Oversampling | 16x                 | Industry standard, ±3% base tolerance              |
| Error flags  | Latched             | Clear on FIFO empty OR explicit signal             |
| Autobaud     | Tiered + continuous | Adapts to real-world timing variations             |
| Idle timeout | 100 bit periods     | Reset calibration on probable disconnection        |

---

## Baud Rate Configuration

| `baud_sel` | Baud Rate | Divisor | Actual Baud |  Error  | Sample Offset |
|------------|-----------|---------|-------------|---------|---------------|
| 4'b0000    | 4800      |    1302 |     4800.31 | +0.006% |    0 (center) |
| 4'b0001    | 9600      |     651 |     9600.61 | +0.006% |    0          |
| 4'b0010    | 19200     |     326 |    19171.78 | -0.15%  |    0          |
| 4'b0011    | 38400     |     163 |    38343.56 | -0.15%  |    0          |
| 4'b0100    | 57600     |     109 |    57339.45 | -0.45%  |    0          |
| 4'b0101    | 115200    |      54 |   115740.74 | +0.47%  |   +1 (late)   |
| 4'b0110    | 230400    |      27 |   231481.48 | +0.47%  |   +1          |
| 4'b0111    | 460800    |      14 |   446428.57 | -3.12%  |   -2 (early)  |
| 4'b1000    | 921600    |       7 |   892857.14 | -3.12%  |   -2 (early)  |
| 4'b1001    | 1000000   |       6 |  1041666.66 | +4.17%  |   +2 (late)   |
| 4'b1010    | 1500000   |       4 |  1562500.00 | +4.17%  |   +2 (late)   |

**Sample Offset:** Shifts the 3-sample majority vote window to compensate for known clock error.

---

## Autobaud Calibration System

### Tiered Accuracy

```
┌─────────────────────────────────────────────────────────────────────┐
│ TIER 1: Multi-Edge Sync (0x55 detected)                             │
│   • 9 measurable edge intervals, averaged                           │
│   • Expected accuracy: ±0.1%                                        │
│   • Weight in rolling average: 9                                    │
├─────────────────────────────────────────────────────────────────────┤
│ TIER 2: Start Bit Measurement (D0 = 1)                              │
│   • Single edge at end of start bit                                 │
│   • Expected accuracy: ±1%                                          │
│   • Weight in rolling average: 1                                    │
├─────────────────────────────────────────────────────────────────────┤
│ TIER 3: Nominal + Static Compensation (no edges available)          │
│   • Pre-calculated sample offset from known divisor error           │
│   • Baseline accuracy: ±3%                                          │
└─────────────────────────────────────────────────────────────────────┘
```

### Why 0x55?

The byte 0x55 (binary 01010101) creates alternating bit transitions:

```
     Start                                               Stop
       ↓   D0  D1  D2  D3  D4  D5  D6  D7                 ↓
IDLE───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───────────────IDLE
       │ 0 │ 1 │ 0 │ 1 │ 0 │ 1 │ 0 │ 1 │ 0 │      1
       └───┘   └───┘   └───┘   └───┘   └───┘
       ↑   ↑   ↑   ↑   ↑   ↑   ↑   ↑   ↑   ↑
       E0  E1  E2  E3  E4  E5  E6  E7  E8  E9

9 measurable intervals → averaged for high accuracy
```

The calibrator opportunistically detects 0x55 bytes—no protocol changes required.

### Continuous Tracking

Unlike one-shot autobaud, this system continuously updates:

- Every received byte contributes a measurement (if edges are available)
- Rolling exponential average smooths noise
- Tracks crystal drift from temperature changes
- Resets after 100 bit periods of idle (connection may have changed)

---

## Hardware Interface

### Demo Top Pin Mapping

| Function | Direction | Pin         | Notes                          |
|----------|-----------|-------------|--------------------------------|
| TX       | output    | Pmod JA1    | Connect to USB-UART adapter RX |
| RX       | input     | Pmod JA2    | Connect to USB-UART adapter TX |
| GND      | —         | Pmod JA GND | Common ground required         |

### Switch Mapping

| Switch  | Function                                    |
|---------|---------------------------------------------|
| SW[3:0] | Baud rate select                            |
| SW[4]   | Enable local echo                           |
| SW[5]   | Enable internal loopback (TX→RX)            |
| SW[6]   | Enable autobaud                             |
| SW[7]   | Display mode (0=last byte, 1=measured baud) |

### Button Mapping

| Button | Function          |
|--------|-------------------|
| BTN[0] | Clear error flags |
| BTN[1] | Reset calibration |
| BTN[3] | System reset      |

### LED Mapping

| LED      | Function                                        |
|----------|-------------------------------------------------|
| LED[0]   | TX busy                                         |
| LED[1]   | RX data available                               |
| LED[2]   | TX FIFO full                                    |
| LED[3]   | RX FIFO full                                    |
| LED[4]   | Frame error (latched)                           |
| LED[5]   | Parity error (latched)                          |
| LED[7:6] | Calibration quality (00=nom, 01=start, 10=sync) |

### 7-Segment Display

- **Mode 0:** Last received byte in hex (e.g., "A5")
- **Mode 1:** Measured baud rate (e.g., "115.2" for 115200)

---

## Directory Structure

```
01-uart/
├── README.md                    # This file
├── rtl/
│   ├── baud_generator.sv
│   ├── autobaud_calibrator.sv
│   ├── uart_tx_core.sv
│   ├── uart_rx_core.sv
│   ├── uart_tx.sv
│   ├── uart_rx.sv
│   ├── uart_top.sv
│   ├── baud_display.sv
│   └── uart_demo_top.sv
├── tb/
│   ├── uart_bfm.sv              # Reusable Bus Functional Model
│   ├── baud_generator_tb.sv
│   ├── uart_tx_core_tb.sv
│   ├── uart_rx_core_tb.sv
│   ├── autobaud_calibrator_tb.sv
│   ├── uart_top_tb.sv
│   └── uart_system_tb.sv        # Full integration test
├── vhdl/                        # VHDL port (later)
│   └── ...
├── constraints/
│   └── blackboard.xdc
├── scripts/
│   ├── create_project.tcl
│   └── run_sim.tcl
├── docs/
│   ├── block_diagram.svg
│   ├── state_machines.svg
│   └── autobaud_algorithm.md
└── media/
    ├── demo_video.md            # Link to YouTube
    └── hardware_setup.jpg
```

---

## Building the Project

### Prerequisites

- Vivado ML Edition 2023.x or later
- RealDigital Blackboard
- USB-UART adapter (recommended: FTDI or CH340G)

### Create Vivado Project

```bash
cd projects/01-uart
vivado -mode batch -source scripts/create_project.tcl
```

### Run Simulation

```bash
# Full regression
vivado -mode batch -source scripts/run_sim.tcl

# Or interactive
vivado -mode gui
# Then: Flow → Run Simulation → Run Behavioral Simulation
```

### Program Board

```bash
vivado -mode batch -source scripts/program_board.tcl
```

---

## Implementation Plan

### Week 1: Foundation Modules

| Day | Task |
|-----|------|
| 1-2 | `baud_generator` + testbench |
| 3-4 | `fifo_fwft` + testbench → commit to library |
| 5 | `sync_2ff`, `edge_detector` + testbenches → commit to library |

### Week 2: TX Path

| Day | Task |
|-----|------|
| 1-3 | `uart_tx_core` + testbench |
| 4-5 | `uart_tx` integration + testbench |

### Week 3: RX Path (Basic)

| Day | Task |
|-----|------|
| 1-3 | `uart_rx_core` (fixed timing) + testbench |
| 4-5 | `uart_rx` integration + loopback test |

### Week 4: Autobaud System

| Day | Task |
|-----|------|
| 1-2 | `autobaud_calibrator` + testbench |
| 3-4 | Integrate autobaud into RX path |
| 5 | `uart_top` full integration test |

### Week 5: Hardware Demo

| Day | Task |
|-----|------|
| 1-2 | `uart_demo_top` + constraints |
| 3 | Hardware bring-up, basic TX test |
| 4-5 | Full testing with USB-UART adapter |

### Week 6: Polish & VHDL

| Day | Task |
|-----|------|
| 1-3 | VHDL port of core modules |
| 4-5 | Documentation, demo video |

---

## Module Specifications

### `baud_generator`

Generates timing ticks at 16× selected baud rate.

**Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `CLK_FREQ` | int | 100_000_000 | System clock frequency in Hz |
| `OVERSAMPLE` | int | 16 | Oversampling factor |

**Ports:**
| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk` | input | 1 | System clock |
| `rst_n` | input | 1 | Active-low async reset |
| `baud_sel` | input | 4 | Baud rate selection |
| `tick` | output | 1 | Single-cycle pulse at 16× baud rate |
| `divisor_out` | output | 16 | Current divisor (debug) |

---

### `uart_tx_core`

TX state machine with shift register.

**Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `DATA_BITS` | int | 8 | Data bits per frame (7 or 8) |
| `PARITY_EN` | bit | 0 | Enable parity bit |
| `PARITY_ODD` | bit | 0 | 0=even, 1=odd parity |
| `STOP_BITS` | int | 1 | Stop bits (1 or 2) |

**Ports:**
| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk` | input | 1 | System clock |
| `rst_n` | input | 1 | Active-low async reset |
| `tick` | input | 1 | 16× baud rate tick |
| `tx_data` | input | 8 | Data byte to transmit |
| `tx_valid` | input | 1 | Data valid (FIFO not empty) |
| `tx_ready` | output | 1 | Ready for next byte |
| `tx_pin` | output | 1 | Serial output |
| `tx_busy` | output | 1 | Transmission in progress |

---

### `uart_rx_core`

RX state machine with adaptive sampling.

**Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `DATA_BITS` | int | 8 | Data bits per frame (7 or 8) |
| `PARITY_EN` | bit | 0 | Enable parity checking |
| `PARITY_ODD` | bit | 0 | 0=even, 1=odd parity |

**Ports:**
| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk` | input | 1 | System clock |
| `rst_n` | input | 1 | Active-low async reset |
| `tick` | input | 1 | 16× baud rate tick |
| `rx_sync` | input | 1 | Synchronized RX input |
| `rx_data` | output | 8 | Received byte |
| `rx_valid` | output | 1 | Byte ready (single cycle) |
| `frame_err` | output | 1 | Stop bit error (latched) |
| `parity_err` | output | 1 | Parity error (latched) |
| `err_clear` | input | 1 | Clear error latches |
| `bit_period` | input | 16 | Bit period from autobaud |
| `sample_offset` | input | 4 | Sample point adjustment |
| `frame_start` | output | 1 | Start of frame detected |
| `frame_done` | output | 1 | Frame complete |

---

### `autobaud_calibrator`

Continuous baud rate measurement system.

**Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `CLK_FREQ` | int | 100_000_000 | System clock frequency |
| `IDLE_TIMEOUT_BITS` | int | 100 | Bit periods before reset |

**Ports:**
| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk` | input | 1 | System clock |
| `rst_n` | input | 1 | Active-low async reset |
| `enable` | input | 1 | Enable calibration |
| `rx_sync` | input | 1 | Synchronized RX input |
| `frame_start` | input | 1 | Start of frame |
| `frame_done` | input | 1 | Frame complete |
| `rx_data` | input | 8 | Received byte (for 0x55 detection) |
| `rx_valid` | input | 1 | rx_data is valid |
| `nominal_bit_period` | input | 16 | Nominal bit period |
| `calibrated_bit_period` | output | 16 | Calibrated bit period |
| `calibration_active` | output | 1 | Using calibrated timing |
| `calibration_quality` | output | 2 | 0=nominal, 1=start, 2=sync |
| `measured_baud` | output | 20 | Calculated baud rate |

---

### `uart_top`

Complete UART transceiver.

**Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `CLK_FREQ` | int | 100_000_000 | System clock frequency |
| `DEFAULT_BAUD_SEL` | int | 5 | Default baud (115200) |
| `FIFO_DEPTH` | int | 16 | FIFO size |
| `DATA_BITS` | int | 8 | Data bits |
| `PARITY_EN` | bit | 0 | Enable parity |
| `PARITY_ODD` | bit | 0 | Odd parity |
| `STOP_BITS` | int | 1 | Stop bits |

**Ports:**
| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk` | input | 1 | System clock |
| `rst_n` | input | 1 | Active-low async reset |
| `baud_sel` | input | 4 | Baud rate selection |
| `tx_pin` | output | 1 | Serial TX output |
| `rx_pin` | input | 1 | Serial RX input |
| `tx_wr_en` | input | 1 | TX write strobe |
| `tx_wr_data` | input | 8 | TX data byte |
| `tx_busy` | output | 1 | TX in progress |
| `tx_fifo_full` | output | 1 | TX FIFO full |
| `tx_fifo_empty` | output | 1 | TX FIFO empty |
| `rx_rd_en` | input | 1 | RX read strobe |
| `rx_rd_data` | output | 8 | RX data byte |
| `rx_data_avail` | output | 1 | RX FIFO has data |
| `rx_fifo_full` | output | 1 | RX FIFO full |
| `frame_err` | output | 1 | Framing error |
| `parity_err` | output | 1 | Parity error |
| `err_clear` | input | 1 | Clear errors |
| `autobaud_enable` | input | 1 | Enable autobaud |
| `calibration_quality` | output | 2 | Calibration status |
| `measured_baud` | output | 20 | Measured baud rate |

---

## Testbench Strategy

### UART Bus Functional Model (BFM)

A reusable `uart_bfm` class provides:

```systemverilog
class uart_bfm;
    // Configuration
    int       baud_rate;
    int       data_bits;
    bit       parity_en;
    bit       parity_odd;
    int       stop_bits;
    real      baud_error;      // Inject timing mismatch
    
    // Transmit
    task send_byte(logic [7:0] data);
    task send_break();
    task send_sync();          // Send 0x55 for calibration
    task send_string(string s);
    
    // Receive
    task receive_byte(output logic [7:0] data);
    task receive_with_timeout(output logic [7:0] data, output bit timeout);
    
    // Error injection
    task inject_framing_error();
    task inject_parity_error();
    task set_baud_error(real percent);  // Simulate mismatch
endclass
```

### Test Cases

| Test | Description | Pass Criteria |
|------|-------------|---------------|
| `tx_single_byte` | Transmit one byte | Correct waveform timing |
| `tx_all_patterns` | Send 0x00, 0xFF, 0xAA, 0x55 | All patterns correct |
| `tx_back_to_back` | Fill FIFO, continuous TX | No gaps between bytes |
| `rx_single_byte` | Receive one byte | Correct data captured |
| `rx_loopback` | TX→RX internal | All bytes match |
| `rx_baud_mismatch` | RX at ±3% error | Still decodes correctly |
| `rx_sync_byte` | Send 0x55 first | Calibration improves |
| `rx_framing_error` | Bad stop bit | frame_err asserts |
| `rx_parity_error` | Wrong parity | parity_err asserts |
| `autobaud_track` | Vary baud during stream | Tracks within 100ms |
| `fifo_full` | Overflow TX FIFO | No data corruption |
| `idle_timeout` | Long pause | Calibration resets |

---

## Success Criteria

| Criterion | Target |
|-----------|--------|
| TX timing accuracy | Within ±0.5% of target baud |
| RX tolerance (no autobaud) | Accept ±3% mismatch |
| RX tolerance (with autobaud) | Accept ±6% mismatch |
| Autobaud 0x55 accuracy | Within ±0.1% of actual |
| FIFO integrity | Zero data loss at 100% utilization |
| Error detection | 100% of injected errors caught |
| Resource usage | < 800 LUTs, < 500 FFs |
| Timing closure | Met at 100 MHz with >1ns slack |
| Code quality | Zero Verilator lint warnings |

---

## Resources

### References

- [UART Protocol Basics](https://www.nandland.com/vhdl/tutorials/tutorial-uart-serial-port-rs232.html) — nandland tutorial
- [16550 UART Datasheet](https://www.ti.com/lit/ds/symlink/tl16c550c.pdf) — Industry standard reference
- *FPGA Prototyping by VHDL Examples* — Pong P. Chu (UART chapter)

### Hardware

- [RealDigital Blackboard](https://www.realdigital.org/hardware/blackboard) — Board documentation
- USB-UART adapters: FTDI FT232RL, CP2102, or CH340G

---

## License

MIT License — See repository root for details.
