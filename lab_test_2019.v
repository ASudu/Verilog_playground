`timescale 1us/1ps

module MUX_2x1(output out, input sel, input a, input b);
	assign out = (sel==1'b1) ? b : a;
endmodule

module MUX_8x1(output out,input [2:0] sel,input[7:0] in);
	assign out = ((~sel[2])&(~sel[1])&(~sel[0])&in[0]) | ((~sel[2])&(~sel[1])&(sel[0])&in[1]) |
				((~sel[2])&(sel[1])&(~sel[0])&in[2]) | ((~sel[2])&(sel[1])&(sel[0])&in[3]) |
				((sel[2])&(~sel[1])&(~sel[0])&in[4]) | ((sel[2])&(~sel[1])&(sel[0])&in[5]) |
				((sel[2])&(sel[1])&(~sel[0])&in[6]) | ((sel[2])&(sel[1])&(sel[0])&in[0]);

endmodule

module MUX_ARRAY(output [7:0] E, input [7:0] F, input [7:0] C, input [7:0] D);
	genvar j;
	
	generate for(j=0; j<8; j=j+1)
	begin
		MUX_2x1 m(E[j],F[j],D[j],C[7-j]);
	end
	endgenerate	
endmodule

module T_FF(output reg Q, input T, input clk, input reset);
	always@(posedge clk or negedge reset)
	begin
		if(~reset)
			Q <= 1'b0;
		else
			if(T)
				Q <= ~Q;
			else
				Q <= Q;
	end
endmodule

module COUNTER_3BIT(output [2:0] Q, input clear, input clk);
	T_FF t1(Q[0],1'b1,clk,clear);
	T_FF t2(Q[1],Q[0],clk,clear);
	T_FF t3(Q[2],Q[0] & Q[1],clk,clear);
endmodule

module DECODER(output reg [7:0] B, input [2:0] A, input EN);
	always@(*)
	begin
		if(EN)
		begin
			case(A)
				3'b000: B <= 8'h01;
				3'b001: B <= 8'h02;
				3'b010: B <= 8'h04;
				3'b011: B <= 8'h08;
				3'b100: B <= 8'h10;
				3'b101: B <= 8'h20;
				3'b110: B <= 8'h40;
				3'b111: B <= 8'h80;
				default: B <= 8'h00;
			endcase
		end
	end
endmodule

module MEMORY(output reg [7:0] G, input [2:0] S);
	reg [7:0][7:0] mem;

	initial
	begin
		mem[0] = 8'h01;
		mem[1] = 8'h03;
		mem[2] = 8'h07;
		mem[3] = 8'h0F;
		mem[4] = 8'h1F;
		mem[5] = 8'h3F;
		mem[6] = 8'h7F;
		mem[7] = 8'hFF;
		G = mem[0];
	end

	always@(S)
	begin
		case(S)
			3'b000: G <= mem[0];
			3'b001: G <= mem[1];
			3'b010: G <= mem[2];
			3'b011: G <= mem[3];
			3'b100: G <= mem[4];
			3'b101: G <= mem[5];
			3'b110: G <= mem[6];
			3'b111: G <= mem[7];
			default: G <= 8'h00;
		endcase
	end

	
endmodule

module TOP_LEVEL(output O, input CLEAR, input CLK, input [2:0] S);
	wire [2:0] Q;
	reg [7:0] D;
	reg EN;
	wire [7:0] B, G, E;
	initial
	begin
		D = 8'h00;
		EN = 1'b1;
	end


	COUNTER_3BIT m1(Q, CLEAR, CLK);
	DECODER m2(B, Q, 1'b1);
	MEMORY m3(G, S);
	MUX_ARRAY m4(E, G, B, 8'h00);
	MUX_8x1 m5(O, Q, E);

	always @(*) begin
		$display(,$time, "E=%h Q=%h S=%h G=%h B=%h", E,Q,S,G,B);
	end
endmodule

module test;
	reg CLK;
	reg CLEAR;
	reg [2:0] S;
	wire O;
	
	TOP_LEVEL tl(O,CLEAR,CLK,S);
	
	always
		#500 CLK = ~CLK;
	
	initial
	begin
		$monitor(,$time," S=%b, O=%b",S,O);
		#0 CLEAR = 1'b0; CLK = 1'b0; S = 3'b000;
		#8000 S = 3'b001;
		#8000 S = 3'b010;
		#8000 S = 3'b011;
		#8000 S = 3'b100;
		#8000 S = 3'b101;
		#8000 S = 3'b110;
		#8000 S = 3'b111;
		#10000 $finish;
	end
endmodule