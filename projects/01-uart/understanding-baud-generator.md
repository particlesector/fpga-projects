# Understanding the Baud Generator

A visual guide to clock division for UART timing.

---

## What Problem Are We Solving?

Your FPGA has a 100 MHz clock. UART needs precise timing at much slower rates (e.g., 115200 baud). The baud generator bridges this gap.

```
FPGA Clock (100 MHz)                    UART Bit Rate (115200 baud)
        │                                         │
        │  100,000,000 cycles/second              │  115,200 bits/second
        │                                         │
        │         WAY TOO FAST!                   │
        │                                         │
        └──────────────┬──────────────────────────┘
                       │
                       ▼
               ┌───────────────┐
               │ Baud Generator│
               │   (Divider)   │
               └───────────────┘
                       │
                       ▼
              Tick at exactly the
              right rate for UART
```

---

## The Core Concept: Clock Division

A clock divider counts input clock cycles and outputs a pulse every N cycles.

### Simple Example: Divide by 4

```
Input Clock:    ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌
                ┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘

Counter:        0   1   2   3   0   1   2   3   0   1   2   3   0
                ↑               ↑               ↑               ↑
                WRAP!           WRAP!           WRAP!           WRAP!

Output Tick:    ┌───┐           ┌───┐           ┌───┐           ┌───┐
                ┘   └───────────┘   └───────────┘   └───────────┘   └
                ↑               ↑               ↑               ↑
           Single-cycle    Single-cycle    Single-cycle    Single-cycle
                pulse           pulse           pulse           pulse
```

**The pattern:**
1. Counter counts 0, 1, 2, 3
2. When counter reaches 4, output a tick pulse
3. Reset counter to 0
4. Repeat forever

---

## Why 16x Oversampling?

We don't generate ticks at the baud rate directly. We generate ticks at **16× the baud rate**.

### Why?

For receiving, we need to sample the RX line multiple times per bit to:
1. Find the middle of each bit (not the edges)
2. Take multiple samples for noise rejection

```
                 One UART Bit Period
                ├───────────────────────────────────────────────┤

RX Line:        ┌───────────────────────────────────────────────┐
(could be       │                                               │
0 or 1)         │              STABLE DATA HERE                 │
                │                                               │
────────────────┘                                               └────

16x Ticks:      ↑  ↑  ↑  ↑  ↑  ↑  ↑  ↑  ↑  ↑  ↑  ↑  ↑  ↑  ↑  ↑  ↑
Tick #:         0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 0
                                     ↑  ↑  ↑
                                   Sample Zone
                                  (ticks 7,8,9)
                              
We sample at tick 7, 8, and 9 (the middle), then majority vote.
This avoids the noisy edges and rejects glitches.
```

---

## The Math

### Target: 115200 Baud with 16x Oversampling

```
Step 1: What tick frequency do we need?

    tick_frequency = baud_rate × 16
                   = 115,200 × 16
                   = 1,843,200 Hz

Step 2: How many clock cycles between ticks?

    divisor = clock_frequency / tick_frequency
            = 100,000,000 / 1,843,200
            = 54.25...
            
Step 3: Round to integer (we can't have fractional counters!)

    divisor = 54

Step 4: What's our actual tick frequency?

    actual_tick = 100,000,000 / 54
                = 1,851,851.85 Hz
                
Step 5: What's our actual baud rate?

    actual_baud = actual_tick / 16
                = 1,851,851.85 / 16
                = 115,740.74 baud
                
Step 6: What's the error?

    error = (115,740.74 - 115,200) / 115,200
          = +0.47%  ✓ (within ±3% tolerance)
```

---

## Timing Diagram: 115200 Baud

```
Clock Period:     10 ns (100 MHz)
Tick Period:      54 × 10 ns = 540 ns
Bit Period:       16 × 540 ns = 8,640 ns = 8.64 µs
Actual Baud:      1 / 8.64 µs = 115,740 baud


System Clock (100 MHz):
   ─┐    ┌────┐    ┌────┐    ┌────┐    ┌────┐    ┌─...
    └────┘    └────┘    └────┘    └────┘    └────┘    
         │← 10ns  →│
    
    
Counter (0 to 53, then wrap):
    ┌──┬──┬──┬──┬──┬──┬────────────────────────────────┬──┬──┐
    │0 │1 │2 │3 │4 │5 │ ...                        ... │53│0 │...
    └──┴──┴──┴──┴──┴──┴────────────────────────────────┴──┴──┘
                                                          ↑
                                                      Counter = 54
                                                     (reset to 0)
                                                      
Tick Output:
    ┐                                                     ┌┐
    └─────────────────────────────────────────────────────┘└─                     
                                                         Single cycle
                                                         pulse (10ns)
    │←──────────────── 54 clock cycles ──────────────────→│
    │←──────────────────── 540 ns ───────────────────────→│
```

---

## One Complete UART Bit

```
16 ticks = 1 bit period = 8.64 µs at 115200 baud

Tick:   0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15    0
        │    │    │    │    │    │    │    │    │    │    │    │    │    │    |    │    │
        ▼    ▼    ▼    ▼    ▼    ▼    ▼    ▼    ▼    ▼    ▼    ▼    ▼    ▼    ▼    ▼    ▼
Tick:   ┌┐   ┌┐   ┌┐   ┌┐   ┌┐   ┌┐   ┌┐   ┌┐   ┌┐   ┌┐   ┌┐   ┌┐   ┌┐   ┌┐   ┌┐   ┌┐   ┌┐
Pulse:  ││   ││   ││   ││   ││   ││   ││   ││   ││   ││   ││   ││   ││   ││   ││   ││   ││
     ───┘└───┘└───┘└───┘└───┘└───┘└───┘└───┘└───┘└───┘└───┘└───┘└───┘└───┘└───┘└───┘└───┘└───
        
                                           ↑    ↑    ↑
                                          Sample points
                                         (ticks 7, 8, 9)

RX Data:┌───────────────────────────────────────────────────────────────────────────────┐
(bit=1) │                                     ONE BIT                                   │
        │                                                                               │
────────┘                                                                               └──

        │←──────────────────────────── 16 ticks = 1 bit period ────────────────────────→│
```

---

## Complete UART Frame Timing

```
8N1 Frame at 115200 baud: 10 bits × 8.64 µs = 86.4 µs

          START    D0      D1      D2      D3      D4      D5      D6      D7     STOP
            ↓       ↓       ↓       ↓       ↓       ↓       ↓       ↓       ↓       ↓
        ┌───────┬───────┬───────┬───────┬───────┬───────┬───────┬───────┬───────┬───────┐
        │   0   │ bit 0 │ bit 1 │ bit 2 │ bit 3 │ bit 4 │ bit 5 │ bit 6 │ bit 7 │   1   │
        └───────┴───────┴───────┴───────┴───────┴───────┴───────┴───────┴───────┴───────┘
        
        │←─16──→│←─16──→│←─16──→│←─16──→│←─16──→│←─16──→│←─16──→│←─16──→│←─16──→│←─16──→│
          ticks  ticks   ticks   ticks   ticks   ticks   ticks   ticks   ticks   ticks

Total: 10 bits × 16 ticks/bit = 160 ticks per frame
Total time: 160 × 540 ns = 86,400 ns = 86.4 µs
```

---

## The Counter Logic (What You'll Implement)

### Concept

```
                    ┌─────────────────────────────┐
                    │        baud_generator       │
                    │                             │
     clk ──────────►│  ┌───────────────────────┐  │
                    │  │        Counter        │  │
     rst_n ────────►│  │        (16-bit)       │  │
                    │  └───────────┬───────────┘  │
                    │              │              │
     baud_sel[3:0]─►│  ┌───────────▼───────────┐  │
                    │  │       Comparator      │  │
                    │  │ count >= divisor - 1  │─►│───► tick
                    │  └───────────┬───────────┘  │
                    │              │              │
                    │  ┌───────────▼───────────┐  │
                    │  │      Divisor LUT      │  │───► divisor_out[15:0]
                    │  │     (11 entries)      │  │     (for debug)
                    │  └───────────────────────┘  │ 
                    └─────────────────────────────┘

Inputs:
  - clk:       100 MHz system clock
  - rst_n:     Active-low async reset (0 = reset, 1 = run)
  - baud_sel:  4-bit selection of baud rate (0-7 valid, 8-15 reserved)

Outputs:
  - tick:      Single-cycle pulse at 16× baud rate
  - divisor_out: Current divisor value (for debugging/display)

```

### Pseudocode

```
On every rising edge of clk:
    if (rst_n == 0):           // Reset
        counter = 0
        tick = 0
    else
        if (counter >= divisor - 1):    // Time to output tick
            counter = 0                 // Reset counter
            tick = 1                    // Output pulse
        else
            counter = counter + 1       // Add one to the counter
            tick = 0                    // Reset the tick

```

---

## The Divisor Lookup Table

```
baud_sel    Baud Rate    Calculation                    Divisor
────────    ─────────    ───────────────────────────    ───────
  0000        4800       100,000,000 / (4800 × 16)       1302
  0001        9600       100,000,000 / (9600 × 16)        651
  0010       19200       100,000,000 / (19200 × 16)       326
  0011       38400       100,000,000 / (38400 × 16)       163
  0100       57600       100,000,000 / (57600 × 16)       109
  0101      115200       100,000,000 / (115200 × 16)       54
  0110      230400       100,000,000 / (230400 × 16)       27
  0111      460800       100,000,000 / (460800 × 16)       14
  1000      921600       100,000,000 / (921600 × 16)        7
  1001     1000000       100,000,000 / (1000000 × 16)       6
  1010     1500000       100,000,000 / (1500000 × 16)       4
```

### As a Combinational Lookup

```
        baud_sel
            │
            ▼
    ┌───────────────┐
    │  case/switch  │
    │               │
    │ 0000 → 1302   │
    │ 0001 →  651   │
    │ 0010 →  326   │
    │ 0011 →  163   │
    │ 0100 →  109   │
    │ 0101 →   54   │
    │ 0110 →   27   │
    │ 0111 →   14   │
    │ 1000 →    7   │
    │ 1001 →    6   │
    │ 1010 →    4   │
    │ else →  651   │ (default to 9600)
    └───────┬───────┘
            │
            ▼
         divisor
```

---