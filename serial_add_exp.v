`timescale 1ns/1ps

module full_adder(s,cout,a,b,cin);
    input a,b,cin;
    reg rega,regb,regc;
    wire a_in,b_in,c_in;
    output sum, cout_wire;

    assign sum = (a_in^b_in)^c_in;
    assign cout = (a_in&b_in) | (c_in&(a_in|b_in));
endmodule

module shiftreg(shift, in, CLK, initial_value, pipo, Q);
input shift; 
input in; 
input [3:0]initial_value;
input CLK; 
input pipo;
output reg [3:0] Q;
always @(posedge CLK) begin 
    if(pipo)
        Q <= initial_value;
    else if (shift) 
        Q={in,Q[3:1]};

    // $monitor($time,"sreg=%b", Q);
end 
endmodule

module flipflop(d,clear,clk,q);
    input d,clear,clk;
    output reg q;
    initial q = 1'b0;
    always @(posedge clk, negedge clear) begin
        if (!clear)
            q <= 1'b0;
        else
            q <= d;
    end 
endmodule

module serial_add(c,a,b,clk,shift,clr, pipo);
    input [3:0] a,b;
    input clk,clr,shift, pipo;
    output reg c;
    wire [3:0] srega, sregb;
    wire so_A_wire, so_B_wire;
    wire si_wire, c_wire;
    wire d_clk;

    assign so_A_wire = srega[0];
    assign so_B_wire = sregb[0];
    assign d_clk = clk & shift;

    full_adder U0(si_wire,c_wire,so_A_wire,so_B_wire,d);

    shiftreg A(shift, si, clk, a, pipo, srega);
    shiftreg B(shift, 1'b0, clk, b, pipo, sregb);

    flipflop D(c, clr,d_clk,d);
    
    always@(c_wire) begin
        c <= c_wire;
    end
endmodule

module testbench;
    reg [3:0] a,b;
    reg clk,shift,clr, pipo;
    wire c;
    

    serial_add u1(c,a,b,clk,shift,clr, pipo);

    initial
    begin
        clk = 0;
        clr = 0;
        shift = 0;
        pipo = 1;

        #0 a=4'b0100; b=4'b0001; shift=0; clr=1; pipo = 1;
        #4 shift=1; pipo = 0;
        $monitor(,$time," clk=%b, a=%b, b=%b, sum=%b, cout= %b", clk,a,b,u1.srega,c);
        #20 a=4'b0100; b=4'b0010; shift=0; clr=1; pipo = 1;
        #2 shift = 1; pipo = 0;
        #100 $finish;
    end
    initial forever begin
            #2 clk = ~clk;
        end
endmodule