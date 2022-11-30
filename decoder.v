`timescale 1ns/1ps

module fadder3x8(s,c,x,y,z);
    input x,y,z;
    output s,c;

    assign s = (~x)*(~y)*z + (~x)*y*(~z) + x*(~y)*(~z) + x*y*z;
    assign c = (~x)*y*z + x*(~y)*z + x*y*(~z) + x*y*z;
endmodule

module fadder_8(s,c,x,y, cin);
    input [7:0] x,y;
    input cin;
    output [7:0] s,c;
    genvar j;

    fadder3x8 f(s[0],c[0],x[0],y[0],cin);

    generate for(j=1; j<8; j=j+1) begin: add_loop
        fadder3x8 f1(s[j], c[j], x[j], y[j], c[j-1]);
    end
    endgenerate
endmodule

module testbench;
    reg [7:0] x,y;
    reg cin;
    wire [7:0] s,c;

    fadder_8 f1(s,c,x,y,cin);

    initial
    begin
        $monitor(,$time, " x=%b, y=%b, cin=%b, s=%b, c=%b ", x,y,cin,s,c);
        #0 x=8'b0; y=8'b0; cin = 0;
        #5 x=8'b0; y=8'b1; cin = 0;
        #10 x=8'b1; y=8'b0; cin = 0;
        #5 x=8'b1; y=8'b1; cin = 0;
        #100 $finish;
    end
endmodule