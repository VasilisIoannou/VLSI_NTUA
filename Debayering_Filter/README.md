Debayering Filter Implementation - Part A
Overview

The goal of this project is to implement a Debayering (Demosaicing) filter in VHDL for a Zynq SoC FPGA. The filter converts raw image data from a Bayer Color Filter Array (CFA) into a full RGB image by interpolating missing color components using the averages of neighboring pixels in 3x3 neighborhoods.

This implementation specifically targets the GBRG Bayer pattern and is designed for the Zybo development board using Xilinx Vivado.

Technical Specifications

    Target Pattern: GBRG Bayer mosaic.

Processing Method: 3x3 neighborhood bilinear interpolation.

Input Data: 8-bit streaming pixels in raster scan order.

Parameterization: The design is parametric (N x N image size) using VHDL generics (e.g., N=32,64,128).

Architecture Components

    Serial-to-Parallel Converter: Utilizes RAM FIFOs and Flip-Flops to store input pixels and provide the required 3x3 neighborhood in parallel to the calculation unit.

Finite State Machine (FSM): Manages synchronization and coordinates the overall circuit operation.

Counters: Includes row and pixel counters to identify the color of the incoming pixel and the current Bayer pattern line (GBG or RGR).

Signal Interface

    clk: System clock.

rst_n: Asynchronous active-low reset.

pixel[7:0]: 8-bit input pixel data.

valid_in: Indicates valid input data.

new_image: High for one cycle to indicate the start of a new image.

R[7:0], G[7:0], B[7:0]: Simultaneous 8-bit RGB output components.

valid_out: Indicates valid output data.

image_finished: High for one cycle to indicate the end of image processing.

Verification

The design is verified through simulation using a VHDL testbench.

    Reference Generation: A software program (MATLAB, C, or Python) reads raw pixel data and generates reference RGB values.

Simulation: The VHDL testbench uses the TextIO library to read input pixels and write the filter's output to a text file.

Comparison: The hardware-generated output is compared against the software reference to ensure correctness.
