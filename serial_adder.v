module full_adder(  input a,
                    input b,
                    input cin,
                    output s,
                    output cout);

assign s = (a^b)^cin;
assign cout = (a&b) | (b&cin) | (a&cin);
endmodule

module shiftreg(    input shift_in,
                    input shift,
                    input clk,
                    input pipo,
                    input [3:0]value,
                    output reg [3:0]Q
                    );
initial Q = 4'd0;
always @(posedge clk) begin
    if(pipo)
        Q <= value;
    else if(shift) begin
        Q <= {shift_in,Q[3:1]};
    end
end
endmodule

module flipflop(    input d,
                    input clear,
                    input clk,
                    output reg q);
initial q = 1'b0;
always @(posedge clk, negedge clear) begin
    if(~clear)
        q<= 1'b0;
    else
        q <= d; 
end
endmodule

module serial_add(  input [3:0]a,
                    input [3:0]b,
                    input shift,
                    input clear,
                    input clk,
                    input pipo,
                    output reg [3:0]sum,
                    output reg cout);

wire sum_full_adder;
wire cout_full_adder;
wire [3:0]shiftreg_A;
wire [3:0]shiftreg_B;
wire d;
wire d_clk;

assign d_clk = clk & shift;

shiftreg U0(sum_full_adder,shift,clk,pipo,a,shiftreg_A);
shiftreg U1(1'b0,shift,clk,pipo,b,shiftreg_B);

full_adder U2(shiftreg_A[0],shiftreg_B[0], d, sum_full_adder,cout_full_adder);

flipflop U3(cout_full_adder, clear,d_clk, d);

always @(shiftreg_A, cout_full_adder) begin
    sum <= shiftreg_A;
    cout <= cout_full_adder;
end

endmodule

module testbench;
    reg [3:0] a,b;
    reg shift,clk,clear,pipo;
    wire [3:0] sum;
    wire cout;

    serial_add u1(a,b,shift,clear,clk,pipo,sum,cout);

    initial
    begin
        clk = 0;
        clear = 0;
        shift = 0;
        pipo = 1;

        #0 a=4'b0100; b=4'b0001; shift=0; clear=1; pipo = 1;
        #4 shift=1; pipo = 0;
        $monitor(,$time," clk=%b, a=%b, b=%b, sum=%b, cout= %b", clk,a,b,sum,cout);
        #100 $finish;
    end
    initial forever begin
            #2 clk = ~clk;
        end

endmodule

