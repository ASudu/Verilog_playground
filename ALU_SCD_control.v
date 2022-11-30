`timescale 1ns/1ps
`include "single_cycle_aux.v"

module in3_mux_2to1_32bit(output [31:0] out, input[1:0] sel, input [31:0] in1, input [31:0] in2, input [31:0] in3);
    wire [31:0] sel_a_b;

    mux_2to1_32bit m1(sel_a_b,sel[0],in1,in2);
    mux_2to1_32bit m2(out,sel[1],sel_a_b,in3);
endmodule

module FA_32bit(output [31:0] sum, output cout, input [31:0] a, input [31:0] b, input cin);
    // wire [32:0] carry;
    // genvar i;

    // assign carry[0] = cin;

    // generate for(i=0; i<32; i=i+1)
    // begin
    //     FA f1(sum[i], carry[i+1], a[i], b[i], carry[i]);
    // end
    // endgenerate

    // assign cout = carry[32];

    assign {cout,sum} = a + b + cin;
endmodule

module ALU(output [31:0] result, output cout,  input [31:0] a, input [31:0] b, input [1:0] op, input binvert, input cin);
    reg [31:0] b_in;
    wire [31:0] resand, resor, resar;
    
    bit32AND a2(resand,a,b);
    bit32OR o2(resor,a,b);
    FA_32bit f2(resar,cout,a,b_in,cin);

    always @(*)
    begin
        if(binvert)
            b_in = ~b;
        else
            b_in = b;
    end

    in3_mux_2to1_32bit m3(result, op, resand, resor, resar);
endmodule

module Main_Control (output RegDst, output ALUSrc, output MemtoReg, output RegWrite,
                     output  MemRead, output MemWrite,output Branch,output ALUOp0,output ALUOp1,input [5:0] Op);
    wire Rformat, lw, sw, beq,j;

    assign Rformat= (~Op[0]) & (~Op[1]) & (~Op[2]) & (~Op[3]) & (~Op[4]) & (~Op[5]);
    assign lw = (Op[0]) & (Op[1]) & (~Op[2]) & (~Op[3]) & (~Op[4]) & (Op[5]);
    assign sw = (Op[0]) & (Op[1]) & (~Op[2]) & (Op[3]) & (~Op[4]) & (Op[5]);
    assign beq = (~Op[0]) & (~Op[1]) & (Op[2]) & (~Op[3]) & (~Op[4]) & (~Op[5]);
    assign j = (~Op[0]) & (Op[1]) & (~Op[2]) & (~Op[3]) & (~Op[4]) & (~Op[5]);

    assign RegDst <= Rformat;
    assign ALUSrc <= lw | sw;
    assign MemtoReg <= lw;
    assign RegWrite <= Rformat | lw;
    assign MemRead <= lw;
    assign MemWrite <= sw;
    assign Branch <= beq;
    assign ALUOp0 <= Rformat;
    assign ALUOp1 <= beq;
endmodule

module ALU_Control(input ALUOp0, input ALUOp1, input [5:0] Funct, output [2:0] Op);
    assign Op[0] = (Funct[0] | Funct[3]) & ALUOp1;
    assign Op[1] = ~(Funct[2] & ALUOp1);
    assign Op[2] = ALUOp0 | (ALUOp1 & Funct[1]);
endmodule

// module test;
//     reg [31:0] a,b;
//     reg [1:0] op;
//     reg binvert,cin;
//     wire [31:0] result;
//     wire cout;

//     ALU a3(result,cout,a,b,op,binvert,cin);

//     initial
//     begin
//         $monitor(,$time," a=%h, b=%h, op=%b, binvert=%b, result=%h",a,b,op,binvert,result);
//         a=32'ha5a5a5a5;
//         b=32'h5a5a5a5a;
//         op=2'b00;
//         binvert=1'b0;
//         cin=1'b0; //must perform AND resulting in zero
//         #100 op=2'b01; //OR
//         #100 op=2'b10; //ADD
//         #100 binvert=1'b1; cin=binvert;//SUB
//         #200 $finish;
//         $dumpfile("single_cycle.vcd");
//         $dumpvars;
//     end
// endmodule