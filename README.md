# FPGA Matrix Multiplication Accelerator

This project implements and evaluates a matrix multiplication accelerator on FPGA, combining **Distributed Arithmetic (DA)** techniques with a custom FIP optimization. 
Please note: due to architectural updates during optimization, some early-stage testbenches may require adaptation to run with the final design.

The implementation is tested on Zynq UltraScale+ MPSoC ZCU104 Evaluation Kit, using vivado.


This project includes implementations of the standard methods: OBC, TC, and IP, as well as their FIP-augmented versions: OBC+FIP, TC+FIP, and IP+FIP. You can identify them based on the folder names. A MATLAB script (FYM) is also provided to generate the bar charts used in the final report.

Please Note: All implementations are for architectural verification only. No dedicated timing optimization has been applied.

To test the designs, you need to manually modify the top-level parameters M, K, and N (default matrix dimensions: A is M×K, B is K×N), and set the corresponding bit-width. Lookup table contents must also be updated accordingly.

Example:
If you want to use the TC method to compute the multiplication of a 4×2 matrix and a 2×4 matrix with 8-bit values, you need to:
Set M = 4, K = 2, and N = 4 in the top-level file
Set the bit width to 8
Update the corresponding lookup table using a switch block with all 2^K = 4 possible input combinations
case (addr)
    2'b00: LUT_out = 0;
    2'b01: LUT_out = B[0];
    2'b10: LUT_out = B[1];
    2'b11: LUT_out = B[0] + B[1];
endcase

