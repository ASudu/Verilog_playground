`timescale 1ns/1ps

// Subtask 1.1
module d_ff(output reg q, input d, input clk, input reset);
    always @(posedge clk or negedge reset) begin
        if(~reset)
            q <= 1'b0;
        else
            q <= d;        
    end
endmodule

module reg_32bit(output [31:0] q, input [31:0] d, input clk, input reset);
    genvar i;

    generate for (i=0; i < 32; i = i+1)
    begin
        d_ff d1(q[i],d[i],clk,reset);
    end
    endgenerate
endmodule

// Subtask 1.2
// 32:1 mux
module mux_2to1(output [31:0] out, input sel, input [31:0] in1, input [31:0] in2);
    assign out = sel ? in2 : in1;
endmodule

module mux_8to1(output [31:0] out, input [2:0] sel, input [31:0] a[7:0]);
    wire [3:0] level1_out;
    wire [1:0] level2_out;

    mux_2to1 m1(level1_out[0],sel[0],a[0],a[1]);
    mux_2to1 m2(level1_out[1],sel[0],a[2],a[3]);
    mux_2to1 m3(level1_out[2],sel[0],a[4],a[5]);
    mux_2to1 m4(level1_out[3],sel[0],a[6],a[7]);
    mux_2to1 m5(level2_out[0],sel[1],level1_out[0],level1_out[1]);
    mux_2to1 m6(level2_out[1],sel[1],level1_out[2],level1_out[3]);
    mux_2to1 m7(out,sel[2],level2_out[0],level2_out[1]);
endmodule

module mux_16to1(output [31:0] out, input [3:0] sel, input [31:0] a[15:0]);
    wire [1:0] level1_out;

    mux_8to1 me1(level1_out[0], sel[2:0], a[7:0]);
    mux_8to1 me2(level1_out[1], sel[2:0], a[15:8]);
    mux_2to1 me3(out,sel[3],level1_out[0],level1_out[1]);
endmodule

module mux_32to1(output [31:0] out, input [4:0] sel, input [31:0] a[31:0]);
    wire [1:0] level1_out;

    mux_16to1 ms1(level1_out[0], sel[3:0], a[15:0]);
    mux_16to1 ms2(level1_out[1], sel[3:0], a[31:16]);
    mux_2to1 ms3(out,sel[4],level1_out[0],level1_out[1]);   
endmodule

// 5:32 decoder
module decoder_2to4(output [3:0] out, input [1:0] a, input en);
    always@(a,en)
    begin
        if(en)
        begin
            case(a)
            begin
                2'b00: out <= 4'b0001;
                2'b01: out <= 4'b0010;
                2'b10: out <= 4'b0100;
                2'b11: out <= 4'b1000;
                default: out <= 4'b0000;
            end
            endcase
        end

        else
            out <= 4'b0000;
    end
endmodule

module decoder_3to8(output [7:0] out, input [2:0] a, input en);
    always@(a,en)
    begin
        if(en)
        begin
            case(a)
            begin
                3'b000: out <= 8'b00000001;
                3'b001: out <= 8'b00000010;
                3'b010: out <= 8'b00000100;
                3'b011: out <= 8'b00001000;
                3'b100: out <= 8'b00010000;
                3'b101: out <= 8'b00100000;
                3'b110: out <= 8'b01000000;
                3'b111: out <= 8'b10000000;
                default: out <= 8'b00000000;
            end
            endcase
        end

        else
            out <= 8'b00000000;
    end
endmodule

module decoder_5to32(output [31:0] out, input [4:0] a, input en);
    wire [3:0] dec_2to4;

    decoder_2to4 d1(dec_2to4, a[4:3],en);
    decoder_3to8 d2(out[7:0], a[2:0],dec_2to4[0]);
    decoder_3to8 d3(out[15:8], a[2:0],dec_2to4[1]);
    decoder_3to8 d4(out[23:16], a[2:0],dec_2to4[2]);
    decoder_3to8 d5(out[31:24], a[2:0],dec_2to4[3]);
endmodule

// Subtask 1.3
module reg_file(input clk, input reset, input [4:0] ReadReg1, input [4:0] ReadReg2,
                input [31:0] WriteData, input [4:0] WriteReg, input RegWrite,
                output reg [31:0] ReadData1, output reg[31:0] ReadData2);
    wire [31:0] regclk; // 32 clocks
    wire [31:0] dec_op;
    reg [31:0] regdata[31:0]; // The 32 registers
    genvar i;
    integer data;

    initial
    generate for(i=0; i<32; i=i+1)
    begin
        data = i;
        regdata[i] = data;
    end
    endgenerate

    // Read data1
    mux_32to1 mr1(ReadData1, ReadReg1, regdata);
    // Read data2
    mux_32to1 mr1(ReadData2, ReadReg2, regdata);

    // Decoder output
    decoder_5to32 dc(dec_op,WriteReg,1'b1);

    // Register clocks
    generate for (i=0; i<32; i=i+1)
    begin
        assign regclk[i] = (RegWrite & clk) & dec_op[i];
    end
    endgenerate

    // Write to register
    generate for(i=0; i<32; i=i+1)
    begin
        reg_32bit rw(regdata[i],WriteData,regclk[i],reset);
    end
    endgenerate
endmodule

module tb32reg;
    reg [31:0] a,b;
    reg sel;
    wire [31:0] q;

    mux_2to1 m1(q,sel,a,b);

    initial
    begin
        $monitor(,$time, " sel=%b, a=%h, b=%h, out=%h",sel,a,b,q);
        a = 32'h0;
        b = 32'hFFFFFFFF;
        sel = 1'b0;
        #20 sel = 1'b1;
        #20 $finish;
    end
endmodule