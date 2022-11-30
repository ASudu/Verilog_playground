`timescale 1ns/1ps

module xor_gate(out,a,b);
    input a,b;
    output out;

    assign out = a^b;
endmodule

module test;
    reg a,b;
    wire out;

    xor_gate u1(out,a,b);

    initial
    begin
        $monitor(,$time," a=%b b=%b out=%b",a,b,out);
        #0 a=1'b0; b=1'b0;
        #2 a=1'b0; b=1'b1;
        #2 a=1'b1; b=1'b0;
        #2 a=1'b1; b=1'b1;
        #10 $finish;
    end

    initial
    begin
        $dumpfile("xor.vcd");
        $dumpvars;
    end
endmodule
