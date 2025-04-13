`timescale 1ns / 1ps

module LUT#(
    parameter DATA_WIDTH=3,
    parameter M=4,
    parameter N=4,
    parameter K=4
)(
    input rst,
    input clk,
    input gen_done,
    input  logic signed [DATA_WIDTH-1:0] A[K],
    input  logic signed [DATA_WIDTH-1:0] B[K],
    output logic signed  [2*DATA_WIDTH+1:0] C_out
);
    logic [4:0] t;
    logic clr;
    logic done;
    logic [K-1:0] bit_array;
    logic signed [2*DATA_WIDTH+1:0] LUT_out;
    logic signed [2*DATA_WIDTH+1:0] C;
    logic notA0;
    logic [DATA_WIDTH-1:0] A0;
    logic [K-2:0] addr;
    logic start;
    logic signed [2*DATA_WIDTH+1:0] p;
   
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            C <= 0;
            t <= 0;
            bit_array <= 0;
            clr <= 0;
            done <= 0;
            start<=0;
            
        end else if (gen_done) begin
            if (t == DATA_WIDTH+3) begin
                t <= 0;
                done <= 1;
                clr <= 1;
              
            end else if (done) begin
                done <= 0;
            end else if (clr) begin
                clr <= 0;
            end else begin
                t <= t + 1;
            end
            for (int i = 0; i < K; i++) begin
                bit_array[i] <= A[i][t];
                start<=1;
            end
            if(start) begin
                A0[t-1]<=bit_array[0];
                notA0 = ~bit_array[0];
   addr = bit_array[7:1] ^ {3{bit_array[0]}};
                
                end
            case (addr)
                7'b0000000: LUT_out <= +B[0]-B[1]-B[2]-B[3]-B[4]-B[5]-B[6]-B[7];
7'b0000001: LUT_out <= +B[0]-B[1]-B[2]-B[3]-B[4]-B[5]-B[6]+B[7];
7'b0000010: LUT_out <= +B[0]-B[1]-B[2]-B[3]-B[4]-B[5]+B[6]-B[7];
7'b0000011: LUT_out <= +B[0]-B[1]-B[2]-B[3]-B[4]-B[5]+B[6]+B[7];
7'b0000100: LUT_out <= +B[0]-B[1]-B[2]-B[3]-B[4]+B[5]-B[6]-B[7];
7'b0000101: LUT_out <= +B[0]-B[1]-B[2]-B[3]-B[4]+B[5]-B[6]+B[7];
7'b0000110: LUT_out <= +B[0]-B[1]-B[2]-B[3]-B[4]+B[5]+B[6]-B[7];
7'b0000111: LUT_out <= +B[0]-B[1]-B[2]-B[3]-B[4]+B[5]+B[6]+B[7];
7'b0001000: LUT_out <= +B[0]-B[1]-B[2]-B[3]+B[4]-B[5]-B[6]-B[7];
7'b0001001: LUT_out <= +B[0]-B[1]-B[2]-B[3]+B[4]-B[5]-B[6]+B[7];
7'b0001010: LUT_out <= +B[0]-B[1]-B[2]-B[3]+B[4]-B[5]+B[6]-B[7];
7'b0001011: LUT_out <= +B[0]-B[1]-B[2]-B[3]+B[4]-B[5]+B[6]+B[7];
7'b0001100: LUT_out <= +B[0]-B[1]-B[2]-B[3]+B[4]+B[5]-B[6]-B[7];
7'b0001101: LUT_out <= +B[0]-B[1]-B[2]-B[3]+B[4]+B[5]-B[6]+B[7];
7'b0001110: LUT_out <= +B[0]-B[1]-B[2]-B[3]+B[4]+B[5]+B[6]-B[7];
7'b0001111: LUT_out <= +B[0]-B[1]-B[2]-B[3]+B[4]+B[5]+B[6]+B[7];
7'b0010000: LUT_out <= +B[0]-B[1]-B[2]+B[3]-B[4]-B[5]-B[6]-B[7];
7'b0010001: LUT_out <= +B[0]-B[1]-B[2]+B[3]-B[4]-B[5]-B[6]+B[7];
7'b0010010: LUT_out <= +B[0]-B[1]-B[2]+B[3]-B[4]-B[5]+B[6]-B[7];
7'b0010011: LUT_out <= +B[0]-B[1]-B[2]+B[3]-B[4]-B[5]+B[6]+B[7];
7'b0010100: LUT_out <= +B[0]-B[1]-B[2]+B[3]-B[4]+B[5]-B[6]-B[7];
7'b0010101: LUT_out <= +B[0]-B[1]-B[2]+B[3]-B[4]+B[5]-B[6]+B[7];
7'b0010110: LUT_out <= +B[0]-B[1]-B[2]+B[3]-B[4]+B[5]+B[6]-B[7];
7'b0010111: LUT_out <= +B[0]-B[1]-B[2]+B[3]-B[4]+B[5]+B[6]+B[7];
7'b0011000: LUT_out <= +B[0]-B[1]-B[2]+B[3]+B[4]-B[5]-B[6]-B[7];
7'b0011001: LUT_out <= +B[0]-B[1]-B[2]+B[3]+B[4]-B[5]-B[6]+B[7];
7'b0011010: LUT_out <= +B[0]-B[1]-B[2]+B[3]+B[4]-B[5]+B[6]-B[7];
7'b0011011: LUT_out <= +B[0]-B[1]-B[2]+B[3]+B[4]-B[5]+B[6]+B[7];
7'b0011100: LUT_out <= +B[0]-B[1]-B[2]+B[3]+B[4]+B[5]-B[6]-B[7];
7'b0011101: LUT_out <= +B[0]-B[1]-B[2]+B[3]+B[4]+B[5]-B[6]+B[7];
7'b0011110: LUT_out <= +B[0]-B[1]-B[2]+B[3]+B[4]+B[5]+B[6]-B[7];
7'b0011111: LUT_out <= +B[0]-B[1]-B[2]+B[3]+B[4]+B[5]+B[6]+B[7];
7'b0100000: LUT_out <= +B[0]-B[1]+B[2]-B[3]-B[4]-B[5]-B[6]-B[7];
7'b0100001: LUT_out <= +B[0]-B[1]+B[2]-B[3]-B[4]-B[5]-B[6]+B[7];
7'b0100010: LUT_out <= +B[0]-B[1]+B[2]-B[3]-B[4]-B[5]+B[6]-B[7];
7'b0100011: LUT_out <= +B[0]-B[1]+B[2]-B[3]-B[4]-B[5]+B[6]+B[7];
7'b0100100: LUT_out <= +B[0]-B[1]+B[2]-B[3]-B[4]+B[5]-B[6]-B[7];
7'b0100101: LUT_out <= +B[0]-B[1]+B[2]-B[3]-B[4]+B[5]-B[6]+B[7];
7'b0100110: LUT_out <= +B[0]-B[1]+B[2]-B[3]-B[4]+B[5]+B[6]-B[7];
7'b0100111: LUT_out <= +B[0]-B[1]+B[2]-B[3]-B[4]+B[5]+B[6]+B[7];
7'b0101000: LUT_out <= +B[0]-B[1]+B[2]-B[3]+B[4]-B[5]-B[6]-B[7];
7'b0101001: LUT_out <= +B[0]-B[1]+B[2]-B[3]+B[4]-B[5]-B[6]+B[7];
7'b0101010: LUT_out <= +B[0]-B[1]+B[2]-B[3]+B[4]-B[5]+B[6]-B[7];
7'b0101011: LUT_out <= +B[0]-B[1]+B[2]-B[3]+B[4]-B[5]+B[6]+B[7];
7'b0101100: LUT_out <= +B[0]-B[1]+B[2]-B[3]+B[4]+B[5]-B[6]-B[7];
7'b0101101: LUT_out <= +B[0]-B[1]+B[2]-B[3]+B[4]+B[5]-B[6]+B[7];
7'b0101110: LUT_out <= +B[0]-B[1]+B[2]-B[3]+B[4]+B[5]+B[6]-B[7];
7'b0101111: LUT_out <= +B[0]-B[1]+B[2]-B[3]+B[4]+B[5]+B[6]+B[7];
7'b0110000: LUT_out <= +B[0]-B[1]+B[2]+B[3]-B[4]-B[5]-B[6]-B[7];
7'b0110001: LUT_out <= +B[0]-B[1]+B[2]+B[3]-B[4]-B[5]-B[6]+B[7];
7'b0110010: LUT_out <= +B[0]-B[1]+B[2]+B[3]-B[4]-B[5]+B[6]-B[7];
7'b0110011: LUT_out <= +B[0]-B[1]+B[2]+B[3]-B[4]-B[5]+B[6]+B[7];
7'b0110100: LUT_out <= +B[0]-B[1]+B[2]+B[3]-B[4]+B[5]-B[6]-B[7];
7'b0110101: LUT_out <= +B[0]-B[1]+B[2]+B[3]-B[4]+B[5]-B[6]+B[7];
7'b0110110: LUT_out <= +B[0]-B[1]+B[2]+B[3]-B[4]+B[5]+B[6]-B[7];
7'b0110111: LUT_out <= +B[0]-B[1]+B[2]+B[3]-B[4]+B[5]+B[6]+B[7];
7'b0111000: LUT_out <= +B[0]-B[1]+B[2]+B[3]+B[4]-B[5]-B[6]-B[7];
7'b0111001: LUT_out <= +B[0]-B[1]+B[2]+B[3]+B[4]-B[5]-B[6]+B[7];
7'b0111010: LUT_out <= +B[0]-B[1]+B[2]+B[3]+B[4]-B[5]+B[6]-B[7];
7'b0111011: LUT_out <= +B[0]-B[1]+B[2]+B[3]+B[4]-B[5]+B[6]+B[7];
7'b0111100: LUT_out <= +B[0]-B[1]+B[2]+B[3]+B[4]+B[5]-B[6]-B[7];
7'b0111101: LUT_out <= +B[0]-B[1]+B[2]+B[3]+B[4]+B[5]-B[6]+B[7];
7'b0111110: LUT_out <= +B[0]-B[1]+B[2]+B[3]+B[4]+B[5]+B[6]-B[7];
7'b0111111: LUT_out <= +B[0]-B[1]+B[2]+B[3]+B[4]+B[5]+B[6]+B[7];
7'b1000000: LUT_out <= +B[0]+B[1]-B[2]-B[3]-B[4]-B[5]-B[6]-B[7];
7'b1000001: LUT_out <= +B[0]+B[1]-B[2]-B[3]-B[4]-B[5]-B[6]+B[7];
7'b1000010: LUT_out <= +B[0]+B[1]-B[2]-B[3]-B[4]-B[5]+B[6]-B[7];
7'b1000011: LUT_out <= +B[0]+B[1]-B[2]-B[3]-B[4]-B[5]+B[6]+B[7];
7'b1000100: LUT_out <= +B[0]+B[1]-B[2]-B[3]-B[4]+B[5]-B[6]-B[7];
7'b1000101: LUT_out <= +B[0]+B[1]-B[2]-B[3]-B[4]+B[5]-B[6]+B[7];
7'b1000110: LUT_out <= +B[0]+B[1]-B[2]-B[3]-B[4]+B[5]+B[6]-B[7];
7'b1000111: LUT_out <= +B[0]+B[1]-B[2]-B[3]-B[4]+B[5]+B[6]+B[7];
7'b1001000: LUT_out <= +B[0]+B[1]-B[2]-B[3]+B[4]-B[5]-B[6]-B[7];
7'b1001001: LUT_out <= +B[0]+B[1]-B[2]-B[3]+B[4]-B[5]-B[6]+B[7];
7'b1001010: LUT_out <= +B[0]+B[1]-B[2]-B[3]+B[4]-B[5]+B[6]-B[7];
7'b1001011: LUT_out <= +B[0]+B[1]-B[2]-B[3]+B[4]-B[5]+B[6]+B[7];
7'b1001100: LUT_out <= +B[0]+B[1]-B[2]-B[3]+B[4]+B[5]-B[6]-B[7];
7'b1001101: LUT_out <= +B[0]+B[1]-B[2]-B[3]+B[4]+B[5]-B[6]+B[7];
7'b1001110: LUT_out <= +B[0]+B[1]-B[2]-B[3]+B[4]+B[5]+B[6]-B[7];
7'b1001111: LUT_out <= +B[0]+B[1]-B[2]-B[3]+B[4]+B[5]+B[6]+B[7];
7'b1010000: LUT_out <= +B[0]+B[1]-B[2]+B[3]-B[4]-B[5]-B[6]-B[7];
7'b1010001: LUT_out <= +B[0]+B[1]-B[2]+B[3]-B[4]-B[5]-B[6]+B[7];
7'b1010010: LUT_out <= +B[0]+B[1]-B[2]+B[3]-B[4]-B[5]+B[6]-B[7];
7'b1010011: LUT_out <= +B[0]+B[1]-B[2]+B[3]-B[4]-B[5]+B[6]+B[7];
7'b1010100: LUT_out <= +B[0]+B[1]-B[2]+B[3]-B[4]+B[5]-B[6]-B[7];
7'b1010101: LUT_out <= +B[0]+B[1]-B[2]+B[3]-B[4]+B[5]-B[6]+B[7];
7'b1010110: LUT_out <= +B[0]+B[1]-B[2]+B[3]-B[4]+B[5]+B[6]-B[7];
7'b1010111: LUT_out <= +B[0]+B[1]-B[2]+B[3]-B[4]+B[5]+B[6]+B[7];
7'b1011000: LUT_out <= +B[0]+B[1]-B[2]+B[3]+B[4]-B[5]-B[6]-B[7];
7'b1011001: LUT_out <= +B[0]+B[1]-B[2]+B[3]+B[4]-B[5]-B[6]+B[7];
7'b1011010: LUT_out <= +B[0]+B[1]-B[2]+B[3]+B[4]-B[5]+B[6]-B[7];
7'b1011011: LUT_out <= +B[0]+B[1]-B[2]+B[3]+B[4]-B[5]+B[6]+B[7];
7'b1011100: LUT_out <= +B[0]+B[1]-B[2]+B[3]+B[4]+B[5]-B[6]-B[7];
7'b1011101: LUT_out <= +B[0]+B[1]-B[2]+B[3]+B[4]+B[5]-B[6]+B[7];
7'b1011110: LUT_out <= +B[0]+B[1]-B[2]+B[3]+B[4]+B[5]+B[6]-B[7];
7'b1011111: LUT_out <= +B[0]+B[1]-B[2]+B[3]+B[4]+B[5]+B[6]+B[7];
7'b1100000: LUT_out <= +B[0]+B[1]+B[2]-B[3]-B[4]-B[5]-B[6]-B[7];
7'b1100001: LUT_out <= +B[0]+B[1]+B[2]-B[3]-B[4]-B[5]-B[6]+B[7];
7'b1100010: LUT_out <= +B[0]+B[1]+B[2]-B[3]-B[4]-B[5]+B[6]-B[7];
7'b1100011: LUT_out <= +B[0]+B[1]+B[2]-B[3]-B[4]-B[5]+B[6]+B[7];
7'b1100100: LUT_out <= +B[0]+B[1]+B[2]-B[3]-B[4]+B[5]-B[6]-B[7];
7'b1100101: LUT_out <= +B[0]+B[1]+B[2]-B[3]-B[4]+B[5]-B[6]+B[7];
7'b1100110: LUT_out <= +B[0]+B[1]+B[2]-B[3]-B[4]+B[5]+B[6]-B[7];
7'b1100111: LUT_out <= +B[0]+B[1]+B[2]-B[3]-B[4]+B[5]+B[6]+B[7];
7'b1101000: LUT_out <= +B[0]+B[1]+B[2]-B[3]+B[4]-B[5]-B[6]-B[7];
7'b1101001: LUT_out <= +B[0]+B[1]+B[2]-B[3]+B[4]-B[5]-B[6]+B[7];
7'b1101010: LUT_out <= +B[0]+B[1]+B[2]-B[3]+B[4]-B[5]+B[6]-B[7];
7'b1101011: LUT_out <= +B[0]+B[1]+B[2]-B[3]+B[4]-B[5]+B[6]+B[7];
7'b1101100: LUT_out <= +B[0]+B[1]+B[2]-B[3]+B[4]+B[5]-B[6]-B[7];
7'b1101101: LUT_out <= +B[0]+B[1]+B[2]-B[3]+B[4]+B[5]-B[6]+B[7];
7'b1101110: LUT_out <= +B[0]+B[1]+B[2]-B[3]+B[4]+B[5]+B[6]-B[7];
7'b1101111: LUT_out <= +B[0]+B[1]+B[2]-B[3]+B[4]+B[5]+B[6]+B[7];
7'b1110000: LUT_out <= +B[0]+B[1]+B[2]+B[3]-B[4]-B[5]-B[6]-B[7];
7'b1110001: LUT_out <= +B[0]+B[1]+B[2]+B[3]-B[4]-B[5]-B[6]+B[7];
7'b1110010: LUT_out <= +B[0]+B[1]+B[2]+B[3]-B[4]-B[5]+B[6]-B[7];
7'b1110011: LUT_out <= +B[0]+B[1]+B[2]+B[3]-B[4]-B[5]+B[6]+B[7];
7'b1110100: LUT_out <= +B[0]+B[1]+B[2]+B[3]-B[4]+B[5]-B[6]-B[7];
7'b1110101: LUT_out <= +B[0]+B[1]+B[2]+B[3]-B[4]+B[5]-B[6]+B[7];
7'b1110110: LUT_out <= +B[0]+B[1]+B[2]+B[3]-B[4]+B[5]+B[6]-B[7];
7'b1110111: LUT_out <= +B[0]+B[1]+B[2]+B[3]-B[4]+B[5]+B[6]+B[7];
7'b1111000: LUT_out <= +B[0]+B[1]+B[2]+B[3]+B[4]-B[5]-B[6]-B[7];
7'b1111001: LUT_out <= +B[0]+B[1]+B[2]+B[3]+B[4]-B[5]-B[6]+B[7];
7'b1111010: LUT_out <= +B[0]+B[1]+B[2]+B[3]+B[4]-B[5]+B[6]-B[7];
7'b1111011: LUT_out <= +B[0]+B[1]+B[2]+B[3]+B[4]-B[5]+B[6]+B[7];
7'b1111100: LUT_out <= +B[0]+B[1]+B[2]+B[3]+B[4]+B[5]-B[6]-B[7];
7'b1111101: LUT_out <= +B[0]+B[1]+B[2]+B[3]+B[4]+B[5]-B[6]+B[7];
7'b1111110: LUT_out <= +B[0]+B[1]+B[2]+B[3]+B[4]+B[5]+B[6]-B[7];
7'b1111111: LUT_out <= +B[0]+B[1]+B[2]+B[3]+B[4]+B[5]+B[6]+B[7];

                default: LUT_out <= 0;
            endcase
            C <= LUT_out;
         
         
           
        end
    end


always_comb begin
    logic signed [2*DATA_WIDTH+1:0] sum = 0;
    for (int i = 0; i < K; i++) begin
        sum = sum + B[i];
    end
    // 先将 sum 除以 2，再乘以 (2^DATA_WIDTH - 1)
    p = (((1 <<< DATA_WIDTH) - 1) * sum);
end


    SA #(
        .DATA_WIDTH(DATA_WIDTH),
        .M(M),
        .N(N),
        .K(K)
    ) SA (
        .clk(clk),
        .rst(rst),
        .done(done),
        .clr(clr),
        .C_in(C),
        .C_out(C_out),
        .t(t),
        .A0(A0),
        .p(p)
    );
endmodule
