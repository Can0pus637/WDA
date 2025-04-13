`timescale 1ns / 1ps

module Array_Input#(
    parameter DATA_WIDTH = 3,
    parameter M = 4,      // A 的行数
    parameter K = 4,      // A 的列数（须偶数且建议可被4整除）
    parameter N = 4       // B 的列数（这里要求 M = N）
)(
    input  logic clk,
    input  logic rst,
    input  logic gen_done,
    // 输入矩阵 A: M×K, B: K×N
    input  logic signed [DATA_WIDTH-1:0] A [0:M-1][0:K-1],
    input  logic signed [DATA_WIDTH-1:0] B [0:K-1][0:N-1],
    // 输出最终结果：final_out = C_internal - alpha_internal - beta_internal
    output logic signed [2*DATA_WIDTH+1:0] final_out [0:M-1][0:M-1]
);

    // 内部信号
    logic signed [2*DATA_WIDTH+1:0] alpha_internal [0:M-1];
    logic signed [2*DATA_WIDTH+1:0] beta_internal  [0:N-1];
    logic signed [2*DATA_WIDTH+1:0] C_internal [0:M-1][0:M-1];

    localparam L      = K/2;     // 奇偶拆分后长度
    localparam L_half = L/2;     // 前后拆分后每部分长度

    // -------------------------------
    // 1. 计算 alpha_internal (对 A 的每一行)
    genvar i, k_idx;
    generate
      for(i = 0; i < M; i = i + 1) begin: gen_alpha_row
        // 奇偶拆分
        logic signed [DATA_WIDTH-1:0] A_even [0:L-1];
        logic signed [DATA_WIDTH-1:0] A_odd  [0:L-1];
        for(k_idx = 0; k_idx < L; k_idx = k_idx + 1) begin: split_A
          assign A_even[k_idx] = A[i][2*k_idx];
          assign A_odd[k_idx]  = A[i][2*k_idx+1];
        end

        // 前后拆分
        logic signed [DATA_WIDTH:0] A_even_first [0:L_half-1];
        logic signed [DATA_WIDTH:0] A_even_second[0:L_half-1];
        logic signed [DATA_WIDTH:0] A_odd_first  [0:L_half-1];
        logic signed [DATA_WIDTH:0] A_odd_second [0:L_half-1];
        for(k_idx = 0; k_idx < L_half; k_idx = k_idx + 1) begin: split_alpha_front
          assign A_even_first[k_idx] = A_even[k_idx];
          assign A_odd_first[k_idx]  = A_odd[k_idx];
        end
        for(k_idx = L_half; k_idx < L; k_idx = k_idx + 1) begin: split_alpha_back
          assign A_even_second[k_idx - L_half] = A_even[k_idx];
          assign A_odd_second[k_idx - L_half]  = A_odd[k_idx];
        end

        // 分段 LUT 计算并加和
        logic signed [2*DATA_WIDTH+1:0] alpha_part1;
        logic signed [2*DATA_WIDTH+1:0] alpha_part2;
        LUT #(
          .DATA_WIDTH(DATA_WIDTH+1),
          .K(L_half)
        ) LUT_alpha_first (
          .rst(rst),
          .clk(clk),
          .gen_done(gen_done),
          .A(A_even_first),
          .B(A_odd_first),
          .C_out(alpha_part1)
        );
        LUT #(
          .DATA_WIDTH(DATA_WIDTH+1),
          .K(L_half)
        ) LUT_alpha_second (
          .rst(rst),
          .clk(clk),
          .gen_done(gen_done),
          .A(A_even_second),
          .B(A_odd_second),
          .C_out(alpha_part2)
        );
        assign alpha_internal[i] = alpha_part1 + alpha_part2;
      end
    endgenerate

    // -------------------------------
    // 2. 计算 beta_internal (对 B 的每一列)
    genvar j;
    generate
      for(j = 0; j < N; j = j + 1) begin: gen_beta_col
        // 奇偶拆分（按行）
        logic signed [DATA_WIDTH-1:0] B_even [0:L-1];
        logic signed [DATA_WIDTH-1:0] B_odd  [0:L-1];
        for(k_idx = 0; k_idx < L; k_idx = k_idx + 1) begin: split_B
          assign B_even[k_idx] = B[2*k_idx][j];
          assign B_odd[k_idx]  = B[2*k_idx+1][j];
        end

        // 前后拆分
        logic signed [DATA_WIDTH:0] B_even_first [0:L_half-1];
        logic signed [DATA_WIDTH:0] B_even_second[0:L_half-1];
        logic signed [DATA_WIDTH:0] B_odd_first  [0:L_half-1];
        logic signed [DATA_WIDTH:0] B_odd_second [0:L_half-1];
        for(k_idx = 0; k_idx < L_half; k_idx = k_idx + 1) begin: split_beta_front
          assign B_even_first[k_idx] = B_even[k_idx];
          assign B_odd_first[k_idx]  = B_odd[k_idx];
        end
        for(k_idx = L_half; k_idx < L; k_idx = k_idx + 1) begin: split_beta_back
          assign B_even_second[k_idx - L_half] = B_even[k_idx];
          assign B_odd_second[k_idx - L_half]  = B_odd[k_idx];
        end

        // 分段 LUT 计算并加和
        logic signed [2*DATA_WIDTH+1:0] beta_part1;
        logic signed [2*DATA_WIDTH+1:0] beta_part2;
        LUT #(
          .DATA_WIDTH(DATA_WIDTH+1),
          .K(L_half)
        ) LUT_beta_first (
          .rst(rst),
          .clk(clk),
          .gen_done(gen_done),
          .A(B_even_first),
          .B(B_odd_first),
          .C_out(beta_part1)
        );
        LUT #(
          .DATA_WIDTH(DATA_WIDTH+1),
          .K(L_half)
        ) LUT_beta_second (
          .rst(rst),
          .clk(clk),
          .gen_done(gen_done),
          .A(B_even_second),
          .B(B_odd_second),
          .C_out(beta_part2)
        );
        assign beta_internal[j] = beta_part1 + beta_part2;
      end
    endgenerate

    // -------------------------------
    // 3. 计算 C_internal 对应矩阵乘积部分 (对每个 (p,q))
    localparam L_total = L;        // mid 数组总长
    localparam L_total_half = L_total/2;
    genvar p, q, k;
    generate
      for(p = 0; p < M; p = p + 1) begin: row_loop
        for(q = 0; q < M; q = q + 1) begin: col_loop
          // 生成中间数组：midA_val[k] = A[p][2*k] + B[2*k+1][q]
          //              midB_val[k] = A[p][2*k+1] + B[2*k][q]
          wire signed [DATA_WIDTH:0] midA_val [0:L_total-1];
          wire signed [DATA_WIDTH:0] midB_val [0:L_total-1];
          for(k = 0; k < L_total; k = k + 1) begin: gen_mid_vals
            assign midA_val[k] = A[p][2*k]   + B[2*k+1][q];
            assign midB_val[k] = A[p][2*k+1] + B[2*k][q];
          end

          // 前后拆分
          wire signed [DATA_WIDTH:0] midA_first [0:L_total_half-1];
          wire signed [DATA_WIDTH:0] midA_second[0:L_total_half-1];
          wire signed [DATA_WIDTH:0] midB_first [0:L_total_half-1];
          wire signed [DATA_WIDTH:0] midB_second[0:L_total_half-1];
          for(k = 0; k < L_total_half; k = k + 1) begin: split_mid_front
            assign midA_first[k] = midA_val[k];
            assign midB_first[k] = midB_val[k];
          end
          for(k = L_total_half; k < L_total; k = k + 1) begin: split_mid_back
            assign midA_second[k - L_total_half] = midA_val[k];
            assign midB_second[k - L_total_half] = midB_val[k];
          end

          // 两个 LUT 分别计算部分内积后加和
          logic signed [2*DATA_WIDTH+1:0] C_part1;
          logic signed [2*DATA_WIDTH+1:0] C_part2;
          LUT #(
            .DATA_WIDTH(DATA_WIDTH+1),
            .K(L_total_half)
          ) LUT_C_first (
            .rst(rst),
            .clk(clk),
            .gen_done(gen_done),
            .A(midA_first),
            .B(midB_first),
            .C_out(C_part1)
          );
          LUT #(
            .DATA_WIDTH(DATA_WIDTH+1),
            .K(L_total_half)
          ) LUT_C_second (
            .rst(rst),
            .clk(clk),
            .gen_done(gen_done),
            .A(midA_second),
            .B(midB_second),
            .C_out(C_part2)
          );
          assign C_internal[p][q] = C_part1 + C_part2;
        end
      end
    endgenerate

    // -------------------------------
    // 4. 计算最终输出
    genvar f_i, f_j;
    generate
      for(f_i = 0; f_i < M; f_i = f_i + 1) begin: final_out_gen
        for(f_j = 0; f_j < M; f_j = f_j + 1) begin: final_out_gen_inner
          assign final_out[f_i][f_j] = C_internal[f_i][f_j] - alpha_internal[f_i] - beta_internal[f_j];
        end
      end
    endgenerate

endmodule
