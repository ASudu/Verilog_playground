`timescale 1ns/1ps

module right_rot(output [3:0] out, input [3:0] in);
    assign out = (in << 3) | (in >> 1);
    // assign out = {in[0], in[3:1]};
endmodule

module test;
    reg [3:0] in;
    wire [3:0] out;

    right_rot m(out, in);

    initial
    begin
        $monitor(,$time," in=%b out=%b",in,out);
        in=4'b0001;
        #5 in=4'b0010;
        #5 in=4'b1000;
        #10 $finish;
    end
endmodule