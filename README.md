# FPGA Matrix Multiplication Accelerator

This project implements and evaluates a matrix multiplication accelerator on FPGA, combining **Distributed Arithmetic (DA)** techniques with a custom **Fixed-Input Partitioning (FIP)** optimization. The design is tested across matrix sizes from **4×4 to 16×16**, with performance metrics including logic utilization, timing, power consumption, and energy efficiency.

Please note: due to architectural updates during optimization, some early-stage testbenches may require adaptation to run with the final design.

The implementation is tested on Zynq UltraScale+ MPSoC ZCU104 Evaluation Kit, using vivado.


