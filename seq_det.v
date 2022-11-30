`timescale 1ns/1ps

module moore_seq_det(clk,rst,in,out);
    input clk, rst, in;
    output reg out;
    reg [2:0] state;

    always@(posedge clk, posedge rst)
    begin
        if(rst)
        begin
            state <= 2'b00;
            out <= 1'b0;
        end

        else
        begin
            case(state)
                3'b000: begin
                    if(in)
                    begin
                        state <= 3'b001;
                        out <= 1'b0;
                    end

                    else
                    begin
                        state <= 3'b000;
                        out <= 1'b0;
                    end
                end
                
                3'b001: begin
                    if(in)
                    begin
                        state <= 3'b001;
                        out <= 1'b0;
                    end

                    else
                    begin
                        state <= 3'b010;
                        out <= 1'b0;
                    end
                end

                3'b010: begin
                    if(in)
                    begin
                        state <= 3'b011;
                        out <= 1'b0;
                    end

                    else
                    begin
                        state <= 3'b000;
                        out <= 1'b0;
                    end
                end

                3'b011: begin
                    if(in)
                    begin
                        state <= 3'b100;
                        out <= 1'b0;
                    end

                    else
                    begin
                        state <= 3'b010;
                        out <= 1'b0;
                    end
                end

                3'b100: begin
                    if(in)
                    begin
                        state <= 3'b001;
                        out <= 1'b0; 
                    end

                    else
                    begin
                        state <= 3'b010;
                        out <= 1'b1; // sequence detected
                    end
                end

                default:begin
                    state <= 3'b000;
                    out <= 1'b0;
                end
            endcase
        end
    end
endmodule

module moore_test;
    reg clk, rst, in;
    wire out;
    reg [15:0] sequence;
    integer i;

    moore_seq_det u1(clk,rst,in,out);

    initial
    begin
        clk = 0;
        rst = 1;
        sequence = 16'b0101_0110_0011_1001;
        #5 rst = 0;

        for(i =15; i >= 0; i = i-1)
        begin
            in = sequence[i];
            #2 clk = 1;
            #2 clk = 0;
            $display("State=",u1.state," input=",in," output=",out);
        end
        testing;
    end

    initial
    begin
        $dumpfile("seq_det.vcd");
        $dumpvars;
    end 

    task testing;
        for(i =0; i <= 15; i = i+1)
        begin
            in = $random % 2;
            #2 clk = 1;
            #2 clk = 0;
            $display("State=",u1.state," input=",in," output=",out);
        end
    endtask  
endmodule