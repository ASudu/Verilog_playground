`timescale 1ns/1ps

module sync_counter(EN, clk, Q);
    input EN,clk;
    output reg [3:0] Q;

    initial
    Q = 4'b0000;

    always@(posedge clk)
    begin
        if(EN)
            Q = Q+1;
    end
endmodule

module testbench;
    reg EN,clk;
    wire [3: 0] Q;

    sync_counter cnt_up(EN,clk,Q);

    initial
    begin
        clk = 0;
    end

    always
    #2 clk = ~clk;

    initial
    begin
        $monitor(,$time,"clk=%b, EN=%b, Q=%b", clk,EN,Q);
        #0 EN=0;
        #4 EN=1;
        #4 EN=0;
        #4 EN=1;
        #10 $finish;
    end
endmodule