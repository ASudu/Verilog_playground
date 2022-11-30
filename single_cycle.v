`timescale 1ns/1ps
`include "ALU_SCD_control.v"
`include "reg_file.v"

module instruction_memory(output reg [31:0] Inst, input [31:0] PC, input clock);
    reg [31:0] memory [31:0];
    integer  addr;
    genvar i;

    initial
    begin
        memory[0] <= 32'h0; // nop
        memory[1] <= 32'h0; // nop
        memory[2] <= 32'h0; // nop
        memory[3] <= 32'h8C110008; // lw $s1($17) 8($0)
        memory[4] <= 32'h8C120004; // lw $s2($18) 4($0)
        memory[5] <= 32'h02324020; // add $t0($8), $s1($17), $s2($18)
    end

    generate for(i=6; i<32; i=i+1)
    begin
        memory[i] <= 32'h0; // nop
    end
    endgenerate

    always@(posedge clock)
    begin
        addr = PC[31:0];
        Inst = memory[addr/4]; // Since memory is word alogned
    end
endmodule

module PC(output reg [31:0] count, input clock, input reset);
    always@(posedge clock)
    begin
        if(!reset)
            count = count + 1;
        else
            count = 0;
    end
endmodule

// fadder_32bit is part of ALU_SCD_control.v
// register file is part of reg_file.v

// We define ALU again since there is a minor difference to the one in ALU_SCD_control.v
module ALU_scd(output zero, output [31:0] result, input [31:0] a, input [31:0] b, input [2:0] op);
    assign zero = (({result} == 0))? 1:0;

    always@(op or a or b)
    begin
        case(op)
            0: result <= a & b;
            1: result <= a | b;
            2: result <= a + b;
            6: result <= a - b;
            7: result <= (a < b)? 1'b1 : 1'b0;
        endcase
    end
endmodule

module data_memory(input [31:0] ReadAddress, input [31:0] WriteAddress, input [31:0] WriteData,
                   output reg [31:0] ReadData, input MemRead, input MemWrite, input clock);
    
    integer raddr, wraddr;
    reg [31:0] memory [31:0];
    genvar i;

    initial
    begin
        memory[0] <= 32'h0; // nop
        memory[1] <= 32'h54; // value of 84
        memory[2] <= 32'hB; // value of 11
    end

    generate for(i=3; i<32; i=i+1)
    begin
        memory[i] <= 32'h0; // nop
    end
    endgenerate

    always@(posedge clock)
    begin
        raddr = ReadAddress;
        wraddr = WriteAddress;

        if(MemRead)
            ReadData = memory[addr/4];
        else if(MemWrite)
            memory[addr/4] = WriteData;
    end
endmodule

// 32 bit 2:1 MUX is part of reg_file.v

module mux_2to1_5bit(output [4:0] out, input sel, input [4:0] in1, input [4:0] in2);
    assign out = sel ? in2 : in1;
endmodule

module sign_extender(output [31:0] out, input [15:0] in);
    assign out = {{16{in[15]}},in};
endmodule

module shift_left(output [31:0] out, input [31:0] input);
    assign out = {in[29:0], 1'b0, 1'b0};
endmodule

module concatJuPC(output [31:0] out, input [31:0] Ju, input [31:0] PC);
    assign out = {PC[31:28],Ju[27:0]};
endmodule

// ALU control is part of ALU_SCD_control.v

// Integrating all the submodules
module SCDataPath(output [31:0] result, input [31:0] PC, input reset, input clk);
    reg [31:0] PC_count, Inst, ReadData1, ReadData2, WriteData;
    wire RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp0, ALUOp1,zero;
    reg [2:0] Op;

    // Model program counter
    PC m1(PC_count, clk, reset);

    // IF Stage
    // Read instruction
    instruction_memory m2(Inst,PC,clk);

    // ID Stage
    // Instruction decode
    Main_Control m3(RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp0, ALUOp1, Inst[31:26]);
    // Register file read
    WriteData = 32h'0; // Dummy value
    reg_file m4(clk,reset,Inst[25:21],Inst[20:16],WriteData,Inst[15:11],RegWrite,ReadData1,ReadData2);

    // EX Stage
    // ALU control
    ALU_Control m5(ALUOp0,ALUOp1,Inst[5:0],Op);
    // ALU Operation
    ALU_scd m6(zero,result,ReadData1,ReadData2,Op);

    // WB Stage
    // Register file write
    reg_file m7(clk,reset,Inst[25:21],Inst[20:16],result,Inst[15:11],RegWrite,ReadData1,ReadData2);
endmodule

// Testing
module TestBench;
    wire [31:0] ALU_output;
    reg [31:0] PC;
    reg reset,clk;

    SCDataPath SCDP(ALU_output,PC,reset,clk);

    initial
    begin
        $monitor("at time %0d IPC = %d, Reset = %d , CLK = %d , ALU Output = %d",$time,start_pc,rst,clk, ALU_output);
        #0 clk = 0; PC = 5;
        #120 rst = 1;
        #400 $stop;
    end
    always
    begin
        #20 clk = ~clk;
    end
endmodule