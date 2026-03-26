8-Tap Serial FIR Filter in VHDL

A resource-efficient, serial (folded) Finite Impulse Response (FIR) filter implementation in VHDL. This design utilizes a single Multiply-Accumulate (MAC) unit, a RAM for sample storage, and a ROM for filter coefficients.
## Overview

Unlike a parallel FIR filter that uses 8 multipliers, this architecture uses a time-multiplexed approach. It processes one tap per clock cycle, making it ideal for applications where FPGA area (logic gates) is limited and the sampling rate allows for multiple clock cycles per sample.
Key Features

    8-Tap Filter: Processes eight coefficients.

    Resource Efficient: Uses only one MAC unit.

    Modular Design: Separated into Control Unit, RAM, ROM, and MAC components.

    Standard Interfaces: Uses std_logic_1164 and numeric_std.

## Architecture

The system is composed of four main internal modules:

    Control Unit: Manages the addressing logic for RAM/ROM and synchronizes the MAC unit start/stop signals.

    MLAB RAM: Acts as the circular buffer, storing the 8 most recent input samples (x[n]).

    MLAB ROM: Stores the fixed filter coefficients (h[n]).

    MAC (Multiply-Accumulate): Performs the operation y=∑(hi​⋅xi​) and manages the output bit-growth (19-bit output from 8-bit inputs).
