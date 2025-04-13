`timescale 1ns / 1ps

module Array_Input#(
    parameter DATA_WIDTH = 3,
    parameter M = 4,
    parameter N = 4,
    parameter K = 4  // K 应为偶数
)(
    input  clk,
    input  rst,
    input  gen_done,
    input  clr,
    input  logic signed [DATA_WIDTH-1:0] A [M][K],
    input  logic signed [DATA_WIDTH-1:0] B [K][N],
    output logic signed [2*DATA_WIDTH+1:0] C_out [M][N]
);

    localparam integer K_half = K/2;

    genvar i, j, k;
    generate
        for(i = 0; i < M; i = i + 1) begin: gen_rows
            for(j = 0; j < N; j = j + 1) begin: gen_cols
                // 提取 A[i] 的前半部分与后半部分
                logic signed [DATA_WIDTH-1:0] A_first [0:K_half-1];
                logic signed [DATA_WIDTH-1:0] A_second [0:K_half-1];
                for(k = 0; k < K_half; k = k + 1) begin: extract_A
                    assign A_first[k]  = A[i][k];
                    assign A_second[k] = A[i][k + K_half];
                end

                // 提取 B 的当前列 j 的前半部分与后半部分
                logic signed [DATA_WIDTH-1:0] B_first [0:K_half-1];
                logic signed [DATA_WIDTH-1:0] B_second [0:K_half-1];
                for(k = 0; k < K_half; k = k + 1) begin: extract_B
                    assign B_first[k]  = B[k][j];
                    assign B_second[k] = B[k + K_half][j];
                end

                // 两个部分的结果
                logic signed [2*DATA_WIDTH+1:0] partial1;
                logic signed [2*DATA_WIDTH+1:0] partial2;
                
                // 第一部分：前半部分数据送入 LUT 模块
                LUT #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .M(M),
                    .N(N),
                    .K(K_half)
                ) LUT_first (
                    .rst(rst),
                    .clk(clk),
                    .gen_done(gen_done),
                    .A(A_first),
                    .B(B_first),
                    .C_out(partial1)
                );
                
                // 第二部分：后半部分数据送入另一设计（此处仍用 LUT 模块作为示例）
                LUT #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .M(M),
                    .N(N),
                    .K(K_half)
                ) LUT_second (
                    .rst(rst),
                    .clk(clk),
                    .gen_done(gen_done),
                    .A(A_second),
                    .B(B_second),
                    .C_out(partial2)
                );
                
                // 最终输出为两部分结果相加
                assign C_out[i][j] = partial1 + partial2;
            end
        end
    endgenerate

endmodule
