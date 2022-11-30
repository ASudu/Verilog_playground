`timescale 1us/1ps


// Assume active high clear
module T_FF(output reg q, output reg qbar, input t, input clk, input clear);
	always@(posedge clk)
	begin
		if(clear)
		begin
			q <= 1'b0;
			qbar <= 1'b1;
		end
		
		else
		begin
			if(t)
			begin
				q <= ~q;
				qbar <= ~qbar;
			end
			
			else
			begin
				q <= q;
				qbar <= qbar;
			end
		end
	end
endmodule

module COUNTER_4BIT(output [3:0] q, input clk, input clear, input EN);
	wire [3:0] qbar;
	
	T_FF ff0(q[0],qbar[0],(1'b1 | ~EN),clk,clear);
	T_FF ff1(q[1],qbar[1],(q[0] | ~EN) ,clk,clear);
	T_FF ff2(q[2],qbar[2],((q[0] & q[1]) | ~EN),clk,clear);
	T_FF ff3(q[3],qbar[3],((q[0] & q[1] & q[2]) | ~EN),clk,clear);	
endmodule

module D_FF(output reg q, output reg qbar, input d, input clk, input clear);
	always@(posedge clk)
	begin
		if(clear)
		begin
			q <= 1'b0;
			qbar <= 1'b1;
		end
		
		else
		begin
			q <= d;
			qbar <= ~d;
		end
	end
endmodule

module CONTROL_LOGIC(output [2:0] T, input s, input z, input x, input clk);
	wire dt0, dt1, dt2;
	wire t0bar, t1bar, t2bar;
	wire temp1, temp2, temp3,temp4,temp5,temp6,temp7,temp8,temp9,temp10;
	
	not (temp1,s); // temp1 = ~s
	and (temp2,T[0],temp1); // temp2 = T0*~s
	and (temp3,T[2],z); // temp3 = T2*z
	or (dt0,temp2,temp3); // dt0 = T0*~s + T2*z
	
	and (temp4,T[0],s); // temp4 = T0*s
	not (temp5,x); // temp5 = ~x
	and (temp6,T[1],temp5); // temp6 = T1*~x
	not (temp7,z); // temp7 = ~z
	and (temp8,T[2],temp6,temp7); // temp8 = T2*~x*~z
	or (dt1,temp4,temp6,temp8); // dt1 = T0*s + T1*~x + T2*~x*~z
	
	
	and (temp9,T[1],x); // temp9 = T1*x
	and (temp10,T[2],temp7,x); // temp10 = T2*~z*x
	or (dt2,temp9,temp10); // dt2 = T1*x + T2*~z*x

	// assign dt0 = (T[0]&(~s)) | (T[2]&z);
	// assign dt1 = (T[0]&s) | (T[1]&(~x)) | (T[2]&(~x)&(~z));
	// assign dt2 = x & (T[1] | (T[2]&(~z)));
	
	D_FF ff0(T[0],t0bar,dt0,clk,1'b0);
	D_FF ff1(T[1],t1bar,dt1,clk,1'b0);
	D_FF ff2(T[2],t2bar,dt2,clk,1'b0);
endmodule

module INTG(output [3:0] count, output G, input clk, input s, input x);
	reg [2:0] T;
	wire [2:0] T_wire;
	reg z;
	wire Gbar,temp1,temp2;
	
	initial
	begin
		#0 T <= 3'b001;
	end

	assign temp1 = (T[0] & s);
	assign temp2 = ((T[1] & x) | (T[2] & ~z & x));

	always@(count or T_wire)
	begin
		z <= (count[0]) & (count[1]) & (count[2]) & (count[3]);
		T <= T_wire;
	end
	
	COUNTER_4BIT m1(count,clk,temp1,temp2);
	CONTROL_LOGIC m2(T_wire,s,z,x,clk);
	D_FF m3(G,Gbar,(T[2] & z),clk,temp1);
endmodule

module test;
	reg clk, s, x;
	wire [3:0] q;
	wire G;

	

	initial
	begin
		clk = 1'b0;
		s = 1'b1;
		x = 1'b1;
	end

	always
	begin
		#500 clk <= ~clk;
	end
	INTG m(q,G,clk,s,x);

	initial
	begin
		$monitor($time," clk=%b, T2=%b, T1=%b, T0=%b, count=%b, g=%b",clk,m.T[2],m.T[1],m.T[0],q,G);
		#20000 $finish;
	end
endmodule
