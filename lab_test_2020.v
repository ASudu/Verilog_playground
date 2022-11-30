`timescale 1ns/1ps

module RS_FF(output reg q, output reg qbar, input s, input r,input clk, input reset);
	always@(posedge clk)
	begin
		if(reset)
        begin
			q <= 1'b0;
            qbar <= 1'b1;
        end

        else
            case({s,r})
                2'b01: begin q <= 1'b0; qbar <= 1'b1; end
                2'b10: begin q <= 1'b1; qbar <= 1'b0; end
                2'b11: begin q <= ~q; qbar <= q; end
                default: begin q <= 1'bx; qbar <= 1'bx; end
            endcase
	end
endmodule

module D_FF(output q, output qbar, input d, input clk, input reset);
    wire dbar;
    assign dbar = ~d;

    RS_FF m1(q,qbar,d,dbar,clk,reset);
endmodule

module Ripple_counter(output [3:0] q, output [3:0] qbar, input clk, input reset);
    D_FF ff0(q[0], qbar[0],qbar[0],clk,reset);
    D_FF ff1(q[1],qbar[1],qbar[1],qbar[0],reset);
    D_FF ff2(q[2],qbar[2],qbar[2],qbar[1],reset);
    D_FF ff3(q[3],qbar[3],qbar[3],qbar[2],reset);
endmodule

module MEM1(output reg [8:0] data, input [2:0] addr);
    reg [7:0][8:0] mem1;

    initial
    begin
        mem1[0] <= 9'b0001_1111_1;
        mem1[1] <= 9'b0011_0001_1;
        mem1[2] <= 9'b0101_0011_1;
        mem1[3] <= 9'b0111_0101_1;
        mem1[4] <= 9'b1001_0111_1;
        mem1[5] <= 9'b1011_1001_1;
        mem1[6] <= 9'b1101_1011_1;
        mem1[7] <= 9'b1111_1101_1;
    end

    always@(addr)
    begin
        case(addr)
            3'b000: data <= mem1[0];
            3'b001: data <= mem1[1];
            3'b010: data <= mem1[2];
            3'b011: data <= mem1[3];
            3'b100: data <= mem1[4];
            3'b101: data <= mem1[5];
            3'b110: data <= mem1[6];
            3'b111: data <= mem1[7];
            default: data <= 9'b0000_0001_1;
        endcase
    end
endmodule

module MEM2(output reg [8:0] data, input [2:0] addr);
    reg [7:0][8:0] mem2;

    initial
    begin
        mem2[0] <= 9'b0000_0000_0;
        mem2[1] <= 9'b0010_0010_0;
        mem2[2] <= 9'b0100_0100_0;
        mem2[3] <= 9'b0110_0110_0;
        mem2[4] <= 9'b1000_1000_0;
        mem2[5] <= 9'b1010_1010_0;
        mem2[6] <= 9'b1100_1100_0;
        mem2[7] <= 9'b1110_1110_0;
    end

    always@(addr)
    begin
        case(addr)
            3'b000: data <= mem2[0];
            3'b001: data <= mem2[1];
            3'b010: data <= mem2[2];
            3'b011: data <= mem2[3];
            3'b100: data <= mem2[4];
            3'b101: data <= mem2[5];
            3'b110: data <= mem2[6];
            3'b111: data <= mem2[7];
            default: data <= 9'b1111_1110_0;
        endcase
    end
endmodule

module MUX2to1(output o, input sel, input a, input b);
    assign o = (sel == 1)? b : a;
endmodule

module MUX16to8(output [7:0] out, input sel, input [7:0] mem1, input [7:0] mem2);
    genvar i;

    generate for(i=0; i<8; i=i+1)
        MUX2to1 s1(out[i],sel,mem1[i],mem2[i]);
    endgenerate
endmodule

module Fetch_Data(output [7:0] data, output parity, input [3:0] addr);
    wire [8:0] mem1, mem2;

    MEM1 m0(mem1,addr[2:0]);
    MEM2 m1(mem2,addr[2:0]);
    MUX16to8 m2(data,addr[3],mem1[8:1],mem2[8:1]);
    MUX2to1 m3(parity,addr[3],mem1[0],mem2[0]);
endmodule

module Parity_checker(output matches, input [7:0] data, input stored_parity);
    assign matches = ~(data[0] ^ stored_parity);
endmodule

module Design(output parity_check, input clk, input reset);
    wire [3:0] q,qbar;
    wire [7:0] data;
    wire parity;
	
    Ripple_counter r1(q,qbar,clk,reset);
    Fetch_Data f1(data,parity,q);
    Parity_checker p1(parity_check,data,parity);
endmodule

module test;
	reg clk,reset;
    wire parity_check;
	
    Design d1(parity_check,clk,reset);

	initial
	begin
		clk <= 1'b0;
		reset <= 1'b1;
	end
	
	always
	begin
		#5 clk <= ~clk;
	end
	
	initial
	begin
		$monitor($time," clk=%b, reset=%b, parity_check=%b",clk,reset,parity_check);
        #10 reset = 1'b0;
        #100 $finish;
	end
endmodule