# Runtime Reconfigurable Debayering Filter (VHDL, Zynq / Zybo)

A hardware **debayering (demosaicing) filter** written in VHDL for the Xilinx Zynq-7000 SoC on the **Digilent Zybo** board. It converts a raw **Bayer GBRG** image into **24-bit RGB**, streaming one pixel per clock cycle. The image size is chosen **at runtime** from software over AXI-Lite, so the same bitstream handles several image sizes without reprogramming the FPGA.

Developed for the *Digital VLSI Systems* course (Labs 5 & 6), School of ECE, National Technical University of Athens (NTUA).

> **Note:** This repository contains **only the VHDL sources** (design + testbench). The Vivado and Vitis projects, block design, bitstream and software application are not included. See [Rebuilding the hardware project](#rebuilding-the-hardware-project) for how to recreate them.

---

## Features

- Bilinear debayering over a **3×3 neighbourhood** (average of neighbouring pixels of each missing colour)
- **Bayer pattern:** GBRG
- **Streaming:** 1 pixel in / 1 RGB pixel out per clock cycle (raster-scan order)
- **Zero padding** for neighbours outside the image borders
- **Runtime-selectable image size:** 64×64, 128×128, 256×256, 512×512, 1024×1024
- **AXI4-Stream** slave (pixels in) and master (RGB out) interfaces
- **AXI4-Lite** slave interface for setting the image dimension from the ARM processor

---

## Algorithm

Every pixel of a Bayer image carries only one colour. The other two are reconstructed from the 3×3 neighbourhood around it:

| Centre pixel | Known | Missing colours computed as |
|---|---|---|
| Green on a G-B row | G | **B** = avg of 2 horizontal neighbours, **R** = avg of 2 vertical neighbours |
| Green on an R-G row | G | **R** = avg of 2 horizontal neighbours, **B** = avg of 2 vertical neighbours |
| Red | R | **G** = avg of 4 cross neighbours, **B** = avg of 4 diagonal neighbours |
| Blue | B | **G** = avg of 4 cross neighbours, **R** = avg of 4 diagonal neighbours |

GBRG pattern (top-left corner of the image):

```
G B G B ...
R G R G ...
G B G B ...
...
```

---

## Architecture

```
                    ┌──────────────── AXI-Lite Slave ─────────────────┐
                    │            image_dim    image_dim_vld            │
                    │                 │            │                   │
 S_AXIS ──TDATA───► │  ┌──────────────▼────────────▼───────────────┐   │ ──TDATA──► M_AXIS
        ──TVALID──► │  │    Runtime Configurable Debayering Filter │   │ ──TVALID─►
        ◄─TREADY─── │  │                                           │   │ ◄─TREADY──
        ──TLAST───► │  └───────────────────────────────────────────┘   │ ──TLAST──►
                    └─────────────────────────────────────────────────┘
```

### Main building blocks

- **Serial-to-parallel converter** – three line-buffer FIFOs plus a 3×3 array of registers that turn the 1-pixel-per-cycle input stream into a full 3×3 window every cycle. The FIFOs are sized for the largest supported image (N = 1024); smaller images are handled with extra control logic that uses the runtime line length.
- **Row / column counters** – track the current pixel position, which determines its Bayer colour (G-B row vs. R-G row, even vs. odd column) and the border cases for zero padding.
- **Averaging datapath** – computes the missing colour components for the centre pixel of the window.
- **Control FSM** – handles configuration, `new_image`, pipeline fill/flush and generation of `valid_out` / `image_finished`.
- **AXI wrappers** – AXI-Lite register for the image dimension; AXI-Stream slave/master mapping for data.

### Top-level debayering core I/O

| Signal | Dir | Width | Description |
|---|---|---|---|
| `clk` | in | 1 | System clock |
| `rst_n` | in | 1 | Asynchronous active-low reset |
| `image_dim` | in | — | Selected image size (see below) |
| `image_dim_vld` | in | 1 | High when `image_dim` holds a valid value |
| `new_image` | in | 1 | Pulsed for 1 cycle together with the first `valid_in` of an image |
| `valid_in` | in | 1 | `pixel` is valid (asserted N² times per image) |
| `pixel` | in | 8 | Raw Bayer pixel |
| `R`, `G`, `B` | out | 8 each | Reconstructed colour components |
| `valid_out` | out | 1 | `R`/`G`/`B` are valid (asserted N² times per image) |
| `image_finished` | out | 1 | Pulsed together with the last `valid_out` |

### AXI mapping

| AXI signal | Core signal |
|---|---|
| `S_AXIS_TDATA[7:0]` | `pixel[7:0]` |
| `S_AXIS_TVALID` | `valid_in` |
| `S_AXIS_TREADY` | `'1'` only after the core has been configured with an image size |
| `M_AXIS_TDATA[31:0]` | `x"00" & R & G & B` |
| `M_AXIS_TVALID` | `valid_out` |
| `M_AXIS_TLAST` | `image_finished` |
| AXI-Lite `slv_reg0` | `image_dim` / `image_dim_vld` |

### Image dimension encoding

<!-- Adjust this table to match the encoding used in your code. -->

`image_dim` holds the side length N of the (square) N×N image:

| Image | `image_dim` |
|---|---|
| 64×64 | 64 |
| 128×128 | 128 |
| 256×256 | 256 |
| 512×512 | 512 |
| 1024×1024 | 1024 |

---

## Repository structure

<!-- Replace with your actual file names. -->

```
.
├── src/
│   ├── debayering.vhd            # Top-level debayering core
│   ├── serial_to_parallel.vhd    # FIFO line buffers + 3x3 register window
│   ├── debayer_compute.vhd       # Averaging datapath
│   ├── control_fsm.vhd           # Control FSM and counters
│   └── reconfigurable_debayering_v1_0.vhd   # Packaged IP top (AXI-Lite + AXI-Stream)
├── tb/
│   └── tb_debayering.vhd         # Testbench (TextIO-based)
└── README.md
```

---

## Simulation

The testbench reads raw Bayer pixels from a text file using VHDL **TextIO**, drives the core one pixel per cycle, and writes the valid R, G, B outputs to another text file. That output can be compared against a software reference model (C / Python / MATLAB) that implements the same 3×3 averaging with zero padding.

1. Create a new Vivado project (board: **Zybo**) and add the files from `src/` and `tb/`.
2. Generate the **FIFO Generator** IP used for the line buffers (depth ≥ 1024, 8-bit width) with the same component name used in the source.
3. Put the input pixel file where the testbench expects it and set the image size in the testbench.
4. Run behavioural simulation and diff the output file against the software reference.

---

## Rebuilding the hardware project

The Vivado/Vitis projects are not included, but they can be rebuilt as follows:

1. **Package the IP** – In Vivado, *Tools → Create and Package New IP* → AXI4 peripheral with three interfaces: `S00_AXI` (AXI-Lite slave), `S00_AXIS` (AXI-Stream slave, 32-bit) and `M00_AXIS` (AXI-Stream master). Replace/extend the generated VHDL with the sources in `src/`.
2. **Block design** – Start from the Lab 5 block design (Zynq PS + two AXI DMAs: `PS2PL_DMA` MM2S and `PL2PS_DMA` S2MM). Add the packaged IP, connect `PS2PL_DMA/M_AXIS_MM2S → S00_AXIS` and `M00_AXIS → PL2PS_DMA/S_AXIS_S2MM`, then run *Connection Automation* using the **100 MHz** clock (`FCLK_CLK1`) for the AXI-Lite interface as well. Delete any unconnected leftover ports.
3. **Bitstream** – Generate the bitstream and export the hardware (`.xsa`) including the bitstream.
4. **Software (Vitis)** – Create a platform from the `.xsa` and a bare-metal application that:
   - writes the image dimension to the AXI-Lite register and reads it back to verify it,
   - generates a random Bayer image on the ARM,
   - sends it through the MM2S DMA and receives the RGB result through the S2MM DMA,
   - computes the same result in software and compares them,
   - reports the **CPU vs. FPGA speedup**.

   Build the application in **Release** mode, not Debug.

With one bitstream the board can then process e.g. a 128×128 image followed by a 1024×1024 image without reprogramming.

---

## Results

All image sizes were run back-to-back on the Zybo with a single bitstream. The FPGA output matched the ARM software reference for every pixel (**0 mismatches**).

### CPU vs. FPGA speedup

| Image | CPU time (ARM) | FPGA time | Speedup |
|---|---|---|---|
| 64×64 | 479.94 µs | 55.01 µs | **8.72×** |
| 1024×1024 | 122,577.43 µs | 10,510.64 µs | **11.66×** |

The speedup grows with image size for three main reasons:
- The fixed DMA/AXI setup overhead is spread over more pixels.
- The streaming pipeline stays full for longer, producing one RGB pixel per cycle.
- On the CPU, larger images no longer fit in the L1/L2 caches, so the software slows down from external memory accesses. The FPGA streaming design avoids that cost.

### Static vs. runtime-reconfigurable resources

The static (generic-based) version from Lab 5 uses only the resources a given N needs. However, any change of size requires re-synthesis. The runtime-reconfigurable version always uses the resources of the worst case (1024×1024 line buffers in BRAM), plus a small AXI-Lite control overhead, even when processing smaller images. It trades area for flexibility.

## Tools

- Xilinx Vivado / Vitis
- Target: Digilent Zybo (Zynq-7000, XC7Z010)
- Language: VHDL
