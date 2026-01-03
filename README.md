# FPGA Engineering Portfolio

A comprehensive collection of FPGA projects demonstrating digital design, signal processing, and communication systems—from foundational protocols to a complete satellite image decoder.

**Target:** FPGA/Embedded Systems Career in Christchurch, New Zealand (2028)  
**Timeline:** 24 months (January 2026 – December 2027)  
**Primary Platform:** RealDigital Blackboard (Xilinx Zynq-7000)  

---

## Projects

| # | Project | Description | Status | Platform | Language |
|:-:|---------|-------------|:------:|----------|----------|
| 1 | [UART Transceiver](projects/01-uart/) | Full-duplex serial with FIFO, autobaud calibration, and adaptive sampling | 🔲 | Blackboard | SystemVerilog |
| 2 | [SPI Sensor Controller](projects/02-spi-sensors/) | Multi-sensor interface with configurable modes | 🔲 | Blackboard | SystemVerilog |
| 3 | [Logic Analyzer](projects/03-logic-analyzer/) | 8-channel, 100MHz, sigrok-compatible with custom PCB | 🔲 | Tang Nano 20K | SystemVerilog |
| 4 | [GPS Disciplined Oscillator](projects/04-gpsdo/) | Precision timing with TDC and digital PLL | 🔲 | Blackboard | VHDL |
| 5 | [ADS-B Aircraft Decoder](projects/05-adsb-decoder/) | Real-time 1090MHz aircraft tracking | 🔲 | Blackboard | VHDL |
| 6 | [Meteor M2 Satellite Decoder](projects/06-meteor-decoder/) | QPSK demodulation, FEC, and weather image reconstruction | 🔲 | Blackboard | VHDL |

**Status:** 🔲 Planned · 🔨 In Progress · ✅ Complete

---

## Skills Demonstrated

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           SKILLS PROGRESSION                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Phase 1 (Projects 1-2)          Phase 2 (Projects 3-4)                    │
│  ─────────────────────           ──────────────────────                    │
│  • HDL fundamentals              • Memory controllers (SDRAM)              │
│  • State machines                • Precision timing (TDC, PLL)             │
│  • Protocol implementation       • PCB design integration                  │
│  • FIFO design                   • VHDL proficiency                        │
│  • Metastability handling        • Zynq PS-PL integration                  │
│                                                                             │
│  Phase 3 (Project 5)             Phase 4 (Project 6)                       │
│  ───────────────────             ───────────────────                       │
│  • SDR fundamentals              • QPSK demodulation                       │
│  • Digital demodulation          • Carrier & timing recovery               │
│  • Real-time processing          • Forward error correction                │
│  • RF signal chain               • Complete communications system          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Technical Competencies

| Category | Skills |
|----------|--------|
| **HDL Languages** | SystemVerilog, VHDL, Verilog |
| **Protocols** | UART, SPI, I2C, AXI, SUMP |
| **DSP** | FIR filters, NCO, AGC, matched filters |
| **Communications** | QPSK, carrier recovery, Viterbi decoding, Reed-Solomon |
| **Tools** | Vivado, Gowin IDE, Verilator, GTKWave, sigrok |
| **Hardware** | Xilinx Zynq, Gowin GW2A, RTL-SDR, KiCad |

---

## Repository Structure

```
fpga-projects/
│
├── library/                      # Reusable module library
│   ├── core/                     # Fundamental building blocks
│   │   ├── sync_2ff.sv           # Metastability synchronizer
│   │   ├── edge_detector.sv      # Rising/falling edge detection
│   │   ├── fifo_fwft.sv          # First-word-fall-through FIFO
│   │   ├── debounce.sv           # Button/switch debouncer
│   │   └── clock_divider.sv      # Parameterized clock divider
│   │
│   ├── peripherals/              # Board peripheral interfaces
│   │   └── seven_seg_controller.sv
│   │
│   └── tb/                       # Library testbenches
│
├── projects/
│   ├── 01-uart/                  # UART Transceiver
│   ├── 02-spi-sensors/           # SPI Sensor Controller
│   ├── 03-logic-analyzer/        # FPGA Logic Analyzer
│   ├── 04-gpsdo/                 # GPS Disciplined Oscillator
│   ├── 05-adsb-decoder/          # ADS-B Aircraft Decoder
│   └── 06-meteor-decoder/        # Meteor M2 Satellite Decoder
│
├── tools/                        # Shared build scripts
│   ├── vivado_project.tcl        # Vivado project generator
│   └── common.mk                 # Shared Makefile rules
│
└── docs/                         # Portfolio-wide documentation
    ├── roadmap.md                # Learning roadmap
    └── skills-matrix.md          # Skills tracking
```

---

## Reusable Library

The `library/` directory contains tested, parameterized modules designed for reuse across projects:

### Core Modules

| Module | Description | Used In |
|--------|-------------|---------|
| `sync_2ff` | 2-stage metastability synchronizer | All projects |
| `edge_detector` | Rising/falling edge detection | All projects |
| `fifo_fwft` | First-word-fall-through synchronous FIFO | UART, Logic Analyzer, ADS-B, Meteor |
| `debounce` | Switch/button debouncer with parameterized delay | All demos |
| `clock_divider` | Parameterized clock divider | Multiple projects |

### Design Philosophy

- **Parameterized:** All modules use parameters for width, depth, timing
- **Consistent interfaces:** Standard naming conventions (`clk`, `rst_n`, `*_valid`, `*_ready`)
- **Self-documenting:** Comprehensive headers with usage examples
- **Fully tested:** Each module has an accompanying testbench

---

## Hardware Platforms

### Primary: RealDigital Blackboard

| Feature | Specification |
|---------|---------------|
| FPGA | Xilinx Zynq XC7Z007S |
| Processor | Dual ARM Cortex-A9 |
| Logic | ~23,000 LUT6 equivalent |
| Clock | 100 MHz |
| Memory | 512MB DDR3 |
| I/O | HDMI, USB, WiFi, Bluetooth, Pmods |
| Sensors | Accelerometer, gyroscope, compass |

### Secondary: Tang Nano 20K

| Feature | Specification |
|---------|---------------|
| FPGA | Gowin GW2A-18C |
| Logic | 20,736 LUT4 |
| Memory | 64Mbit SDRAM |
| USB | BL616 RISC-V MCU |

*Used for Logic Analyzer project (dedicated hardware build)*

---

## Getting Started

### Prerequisites

- **Vivado ML Edition** (free for Zynq-7000) — [Download](https://www.xilinx.com/support/download.html)
- **Gowin IDE** (free) — [Download](https://www.gowinsemi.com/en/support/download_eda/)
- **Git** with LFS support
- **Python 3.8+** (for testbench utilities)

### Clone Repository

```bash
git clone https://github.com/particlesector/fpga-projects.git
cd fpga-projects
```

### Build a Project

Each project includes TCL scripts for reproducible builds. **Recommended: Use Vivado Tcl Shell** (ensures environment is properly configured).

**Option 1: Vivado Tcl Shell (Recommended)**

Open "Vivado 2025.2 Tcl Shell" from Start Menu, then:
```tcl
cd C:/progs/fpga-projects/projects/01-uart
source scripts/create_project.tcl
start_gui   ;# Optional: open GUI after project creation
```

**Option 2: Command Line** (requires Vivado in PATH)
```bash
cd projects/01-uart
vivado -mode gui -source scripts/create_project.tcl
```

### Run Simulations

**Option 1: Vivado Tcl Shell**
```tcl
cd C:/progs/fpga-projects/projects/01-uart
source scripts/run_sim.tcl
```

**Option 2: Command Line**
```bash
cd projects/01-uart
vivado -mode batch -source scripts/run_sim.tcl
```

**Option 3: Verilator** (faster, for quick iterations)
```bash
make sim
```

---

## Project Highlights

### UART Transceiver (Project 1)

*Not your average UART implementation.*

- **Tiered autobaud calibration:** Automatically measures transmitter timing
- **0x55 sync detection:** 9-edge averaging for ±0.1% accuracy
- **Continuous tracking:** Adapts to temperature drift in real-time
- **FWFT FIFOs:** Professional buffering with proper flow control

### Logic Analyzer (Project 3)

*A real debugging tool, not just an exercise.*

- **Custom PCB** with 5V-tolerant inputs
- **8MB capture depth** using SDRAM
- **sigrok/PulseView compatible** via SUMP protocol
- **3D printed enclosure** for permanent bench use

### Meteor M2 Decoder (Project 6)

*Receiving images from space.*

- **Complete ground station:** Antenna → decoded image
- **QPSK demodulation** with Costas loop carrier recovery
- **Viterbi decoder** for convolutional FEC
- **Real-time processing** of 80 ksps symbol stream

---

## Background

I bring a unique combination of skills to FPGA engineering:

- **Avionics & Communications degree** — RF fundamentals, signal processing theory
- **Game Development degree** — Real-time systems, C++ optimization, state machine design
- **RTK GPS experience** — Built a 3-receiver survey system with tilt compensation

This portfolio bridges that background with dedicated FPGA development, targeting New Zealand's aerospace and communications sectors.

---

## Target Companies (Christchurch, NZ)

| Company | Focus | Relevant Projects |
|---------|-------|-------------------|
| Tait Communications | Mission-critical radio | UART, GPSDO, ADS-B, Meteor |
| Enphase Energy | Solar microinverters | Logic Analyzer, SPI |
| Kea Aerospace | Stratospheric aircraft | ADS-B, Meteor |
| Dawn Aerospace | Space vehicles | GPSDO, Meteor |

---

## License

This portfolio is provided for educational and demonstration purposes.

- **Library modules** (`library/`): MIT License — free to use in your projects
- **Project code** (`projects/`): MIT License
- **Documentation**: CC BY 4.0

See individual project directories for specific licensing details.

---

## Contact

- **GitHub:** [particlesector](https://github.com/particlesector)
- **Portfolio Site:** [fpga.particlesector.com](https://fpga.particlesector.com)

---

<p align="center">
  <i>Building towards New Zealand's FPGA industry, one project at a time.</i>
</p>
