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
    // -------------------------
    // 1. 内部信号声明
    // -------------------------
    // 由 random_matrix 生成的 A、B 矩阵
    wire signed [DATA_WIDTH-1:0] A [0:M-1][0:K-1];
    wire signed [DATA_WIDTH-1:0] B [0:K-1][0:N-1];

    // FIP_OBC (或 Array_Input) 计算得到的结果矩阵
    wire signed [2*DATA_WIDTH+1:0] C_out [0:M-1][0:N-1];

    // 由 random_matrix 输出的矩阵生成完成标志
    wire gen_done;

    // -------------------------
    // 2. 实例化随机矩阵生成模块
    // -------------------------
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

    // -------------------------
    // 3. 实例化运算模块
    // -------------------------
    Array_Input #(
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

    // -------------------------
    // 4. 串行发送逻辑 (UART风格)
    // -------------------------
    // 每个 C_out 元素宽度
    localparam ELEMENT_WIDTH = 2*DATA_WIDTH + 2;  
    // FSM 状态定义
    localparam STATE_IDLE  = 2'd0,
               STATE_START = 2'd1,
               STATE_DATA  = 2'd2,
               STATE_STOP  = 2'd3;

    // 简易波特率分频：在 clk 上进行分频，生成串行发送时钟 serial_clk
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

    // 用于扫描 C_out 矩阵并发送的寄存器
    reg [1:0] state;
    reg [$clog2(ELEMENT_WIDTH):0] bit_index;  
    reg [ELEMENT_WIDTH-1:0] shift_reg;        
    reg [$clog2(M)-1:0] row_idx;
    reg [$clog2(N)-1:0] col_idx;

    // 串行发送输出寄存器
    reg tx_reg;
    assign tx = tx_reg;  // 对外输出

    always @(posedge serial_clk or posedge rst) begin
        if (rst) begin
            state     <= STATE_IDLE;
            bit_index <= 0;
            shift_reg <= 0;
            row_idx   <= 0;
            col_idx   <= 0;
            tx_reg    <= 1; // 空闲状态为高电平
        end else begin
            case (state)
                // 空闲状态：加载下一个要发送的矩阵元素到移位寄存器
                STATE_IDLE: begin
                    shift_reg <= C_out[row_idx][col_idx];
                    bit_index <= 0;
                    state     <= STATE_START;
                end

                // 发送起始位 (0)
                STATE_START: begin
                    tx_reg <= 0;
                    state  <= STATE_DATA;
                end

                // LSB优先发送数据位
                STATE_DATA: begin
                    tx_reg    <= shift_reg[0];
                    shift_reg <= shift_reg >> 1;
                    bit_index <= bit_index + 1;
                    if (bit_index == ELEMENT_WIDTH - 1)
                        state <= STATE_STOP;
                end

                // 发送停止位 (1)，并更新下一个元素的索引
                STATE_STOP: begin
                    tx_reg <= 1;
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
