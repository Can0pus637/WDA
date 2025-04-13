`timescale 1ns / 1ps 

module TOP_OBC #(
    parameter DATA_WIDTH = 3,
    parameter M = 16,
    parameter N = 16,
    parameter K = 16,
    parameter CLK_DIV = 10  // 用于生成串行发送时钟
)(
    input  clk_p,
    input  clk_n,
    input  rst,
    output tx  // 串行输出接口
);
    wire clk;
    // 内部信号，不再作为外部并行IO输出
    wire signed [2*DATA_WIDTH+1:0] C_out [0:M-1][0:N-1];

    // 用于模块间传递生成完成标志
    wire gen_done;
    
    // 声明 random_matrix 生成的 A 和 B 矩阵
    logic signed [DATA_WIDTH-1:0] A [0:M-1][0:K-1];
    logic signed [DATA_WIDTH-1:0] B [0:K-1][0:N-1];

    // 以下 done 与 clr 信号根据需求调整，此处未使用
    // assign done = 1'b0;
    // assign clr  = 1'b0;

    // 实例化 random_matrix 模块
  IBUFGDS clkgen (
        .O(clk),
        .I(clk_p),
        .IB(clk_n)
    );
    random_matrix #(
        .DATA_WIDTH(DATA_WIDTH),
        .M(M),
        .K(K),
        .N(N)
    ) u_random_matrix (
        .clk(clk),
        .rst(rst),
        .A(A),
        .B(B),
        .gen_done(gen_done)
    );

    // 实例化 FIP_OBC 模块，将运算结果送到内部信号 C_out
    FIP_OBC #(
        .DATA_WIDTH(DATA_WIDTH),
        .M(M),
        .N(N),
        .K(K)
    ) u_Array_Input (
        .clk(clk),
        .rst(rst),
        .gen_done(gen_done),
        .A(A),
        .B(B),
        .final_out(C_out)
    );

    // ---------------------------
    // 串行输出逻辑：将 C_out 矩阵元素依次通过 tx 发送
    // ---------------------------
    localparam ELEMENT_WIDTH = 2*DATA_WIDTH+2;  // 每个矩阵元素的位宽
    localparam STATE_IDLE  = 2'd0,
               STATE_START = 2'd1,
               STATE_DATA  = 2'd2,
               STATE_STOP  = 2'd3;

    // 生成串行发送时钟
    reg [31:0] clk_divider;
    reg serial_clk;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_divider <= 0;
            serial_clk  <= 0;
        end else begin
            if (clk_divider == CLK_DIV - 1) begin
                clk_divider <= 0;
                serial_clk  <= ~serial_clk;
            end else begin
                clk_divider <= clk_divider + 1;
            end
        end
    end

    // FSM寄存器：扫描矩阵、串行发送数据
    reg [1:0] state;
    reg [$clog2(ELEMENT_WIDTH):0] bit_index;  // 用于计数数据位
    reg [ELEMENT_WIDTH-1:0] shift_reg;         // 存储当前待发送数据
    reg [$clog2(M)-1:0] row_idx;
    reg [$clog2(N)-1:0] col_idx;

    reg tx_reg;
    assign tx = tx_reg;  // tx输出

    always @(posedge serial_clk or posedge rst) begin
        if (rst) begin
            state     <= STATE_IDLE;
            bit_index <= 0;
            shift_reg <= 0;
            row_idx   <= 0;
            col_idx   <= 0;
            tx_reg    <= 1; // UART空闲状态为高
        end else begin
            case (state)
                STATE_IDLE: begin
                    // 加载当前矩阵元素到移位寄存器
                    shift_reg <= C_out[row_idx][col_idx];
                    bit_index <= 0;
                    state     <= STATE_START;
                end
                STATE_START: begin
                    // 发送起始位（0）
                    tx_reg <= 0;
                    state  <= STATE_DATA;
                end
                STATE_DATA: begin
                    // LSB优先发送数据位
                    tx_reg    <= shift_reg[0];
                    shift_reg <= shift_reg >> 1;
                    bit_index <= bit_index + 1;
                    if (bit_index == ELEMENT_WIDTH - 1)
                        state <= STATE_STOP;
                end
                STATE_STOP: begin
                    // 发送停止位（1）
                    tx_reg <= 1;
                    // 选择下一个元素（行优先扫描）
                    if (col_idx == N-1) begin
                        col_idx <= 0;
                        if (row_idx == M-1)
                            row_idx <= 0;
                        else
                            row_idx <= row_idx + 1;
                    end else begin
                        col_idx <= col_idx + 1;
                    end
                    state <= STATE_IDLE;
                end
                default: state <= STATE_IDLE;
            endcase
        end
    end

endmodule
