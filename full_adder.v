`timescale 1ns/1ps

module full_adder(s,cout,a,b,cin);
    input a,b,cin;
    output reg s,cout;

    always @(*)
    begin
        if(cin == 0)
            begin
                s = a ^ b;
                cout = a * b;
            end
        else
            begin
                s = ~(a ^ b);
                cout = a | b;
            end
    end
endmodule



module xor_array(b_new,b,m);
    input [3:0] b;
    input m;
    output reg [3:0] b_new;

    always @(*) begin
        if(m)
            b_new = ~b;
        else
            b_new = b;
    end
endmodule

module full_adder_4bit(s,cout,a,b,cin);
input [3:0] a,b;
input cin;
output [3:0] s;
output cout;
reg cout;
wire [4:0] x;

always @(cin or x[4]) begin
    x[0] <= cin;
    cout <= x[4];
end

full_adder f1(s[0],x[1],a[0],b[0],x[0]);
full_adder f2(s[1],x[2],a[1],b[1],x[1]);
full_adder f3(s[2],x[3],a[2],b[2],x[2]);
full_adder f4(s[3],x[4],a[3],b[3],x[3]);

endmodule

module addsub(s,cout,a,b,m);
    input [3:0] a,b;
    input m;
    output [3:0] s;
    reg [3:0] s;
    output reg cout;
    wire [3:0] b_new;

    xor_array U0(b_new,b,m);

    full_adder_4bit U1(s,cout,a,b_new,m);
endmodule

module testbench;
    reg [3:0] a,b;
    reg m;
    wire [3:0] s,cout;

    addsub as(s,cout,a,b,m);

    initial
    begin
        $monitor(,$time," a=%b, b=%b, m=%b, s=%b, cout= %b", a,b,m,s,cout);
        #0 a=4'b0100; b=4'b0001; m=1'b0;
        #5 a=4'b0100; b=4'b0010; m=1'b1;
        #100 $finish;
    end
endmodule