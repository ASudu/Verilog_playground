`timescale 1ns/1ps

module encoder(output [2:0] op_code, input [7:0] func_code);
    assign op_code[0] = func_code[1] | func_code[3] | func_code[5] | func_code[7];
    assign op_code[1] = func_code[2] | func_code[3] | func_code[6] | func_code[7];
    assign op_code[2] = func_code[4] | func_code[5] | func_code[6] | func_code[7];
endmodule

module ALU(output reg [3:0] result, input [3:0] A, input [3:0] B, input [2:0] op_code);
    always @(*)
    begin
        case(op_code)
            3'b000: result = A + B;
            3'b001: result = A - B;
            3'b010: result = A ^ B;
            3'b011: result = A | B;
            3'b100: result = A & B;
            3'b101: result = ~(A | B);
            3'b110: result = ~(A & B);
            3'b111: result = ~(A ^ B);
            default: result = 4'bxxxx;
        endcase
    end
endmodule

module even_parity_generator(output parity, input [3:0] X);
    assign parity = X[0] ^ X[1] ^ X[2] ^ X[3];
endmodule

module test;
    reg [7:0] func_code;
    reg [3:0] A,B;
    reg [10:0] pipeline_reg1;
    wire [3:0] pipeline_reg2;
    wire [2:0] op_code;
    wire parity;

    // Stage 1
    encoder m1(op_code,func_code);
    initial
    begin
        pipeline_reg1[10:8] = op_code;
        pipeline_reg1[7:4] = A;
        pipeline_reg1[3:0] = B;
    end

    // Stage 2
    ALU m2(pipeline_reg2,A,B,op_code);
    // Stage 3
    even_parity_generator m3(parity,pipeline_reg2);

    initial
    begin
        $monitor(,$time," func_code=%b, op_code=%b, result=%b, parity=%b",func_code,op_code,pipeline_reg2,parity);
        #0 func_code = 8'h01; A = 4'b0001; B = 4'b0011;
        #2 func_code = 8'h02;
        #2 func_code = 8'h04;
        #2 func_code = 8'h08;
        #2 func_code = 8'h10;
        #2 func_code = 8'h20;
        #2 func_code = 8'h40;
        #2 func_code = 8'h80;
        #10 $finish;
    end
endmodule