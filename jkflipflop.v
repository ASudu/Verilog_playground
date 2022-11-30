`timescale 1ns/1ps

module jkff(q,qbar,j,k,clk,clr);
    input j,k,clk,clr;
    output reg q,qbar;

    always @(posedge clk) begin
        if(clr == 1'b1)
            begin
                q <= 1'b0;
                qbar <= 1'b1;
            end
        else
            case ({j,k})
                2'b00: begin q <= q; qbar <= qbar; end
                2'b01: begin q <= 1'b0; qbar <= 1'b1; end
                2'b10: begin q <= 1'b1; qbar <= 1'b0; end
                2'b11: begin q <= ~q; qbar <= ~qbar; end
                default: {q,qbar} <= 2'bxx;
            endcase
    end
endmodule

module testbench;
    reg j,k,clk,clr;
    wire q,qbar;

    jkff u1(q,qbar,j,k,clk,clr);

    initial
    begin
        $monitor(,$time, " clk=%b, j=%b, k= %b, clr=%b, q=%b, qbar=%b ", clk,j,k,clr,q,qbar);
        j = 0;
        k = 0;
        clk = 0;
        clr = 1;
    end

    always #1 clk = ~clk;
    always #2 {j,k} = {j,k} + 1'b1;
    initial #10 clr=1'b0;
    initial #30 $finish;
endmodule