`timescale 1ns/1ps

module multi_dim_array(a,b,c);
    output [2:0][7:0] a;
    input [7:0] b;
    input [7:0] c;

    assign a[0] = b | c;
    assign a[1] = b & c;
    assign a[2] = b ^ c;
endmodule;

module test;
    reg [7:0] b,c;
    wire [2:0][7:0] a;

    multi_dim_array m(a,b,c);

    initial
    begin
        $monitor(,$time, " b=%b, c=%b, a[0]=%b, a[1]=%b, a[2]=%b",b,c,a[0],a[1],a[2]); 
        #0 b=8'hA5; c=8'h5A;
    end
endmodule

