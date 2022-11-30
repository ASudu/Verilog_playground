`timescale 1ns/1ps

module shiftreg(EN,in,clk,Q);
    input EN, in, clk;
    output reg [3:0] Q;

    initial
    Q = 4'b0000;

    always@(posedge clk)
    begin
        if(EN)
        Q = {in,Q[3:1]};
    end
endmodule