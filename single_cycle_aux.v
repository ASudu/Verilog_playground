`timescale 1ns/1ps

// Subtask 1.1
module mux_2to1(output out, input sel, input in1, input in2);
    assign out = sel? in2 : in1;
endmodule

module mux_2to1_8bit(output [7:0] out, input sel, input [7:0] in1, input [7:0] in2);
    genvar i;

    generate for(i = 0; i <=7; i = i+1)
    begin
       mux_2to1 m(out[i], sel, in1[i], in2[i]);
    end        
    endgenerate
endmodule

module mux_2to1_32bit(output [31:0] out, input sel, input [31:0] in1, input [31:0] in2);
    genvar j;

    generate for (j=0; j <4; j = j+1)
    begin
        mux_2to1_8bit m(out[8*j+7:8*j],sel,in1[8*j+7:8*j],in2[8*j+7:8*j]);
    end
    endgenerate
endmodule

// Subtask 1.2
module bit32AND (output [31:0] out, input [31:0] in1, input [31:0] in2);
    assign out = in1 & in2;
endmodule

module bit32OR (output [31:0] out, input [31:0] in1, input [31:0] in2);
    assign out = in1 | in2;
endmodule

// Subtask 1.3
module FA(output sum, output cout, input a, input b, input cin);
    assign {cout,sum} = a + b + cin;
endmodule


// module tb32bitand;
//     reg [31:0] IN1,IN2;
//     wire [31:0] OUT;
//     bit32OR a1 (OUT,IN1,IN2);
//     initial
//     begin
//         $monitor(,$time," out=%h",OUT);
//         IN1=32'hA5A5;
//         IN2=32'h5A5A;
//         #100 IN1=32'h5A5A;
//         #400 $finish;
//     end
// endmodule