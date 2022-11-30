`timescale 1ns/1ps

module sign(s,a);
    input [3:0] a;
    output  s;
    reg s;

    // assign s = a[3];
    always @(a) 
    begin
        if (a[3] == 1)
            s = 1;
        else
            s = 0;       
    end
endmodule

module comparator(g,e,l,a,b);
    input [3:0] a,b;
    reg g,e,l;
    output g,e,l;
    wire s_a, s_b;
    
    sign a1(s_a,a);
    sign b1(s_b,b);
    
    always @(a or b or s_a or s_b)
    begin
        if(s_a > s_b)
            begin
                g = 0;
                e = 0;
                l = 1;
            end

        else if( s_a < s_b)
            begin
                g = 1;
                e = 0;
                l = 0;
            end
        else
            if (a > b)
                begin
                    g = 1;
                    e = 0;
                    l = 0;
                end
            else if (a < b)
                begin
                    g = 0;
                    e = 0;
                    l = 1;
                end
            else
                begin
                    g = 0;
                    e = 1;
                    l = 0;
                end

    end
endmodule

module testbench;
    reg [3:0] a,b;
    wire g,e,l;

    comparator c(g,e,l,a,b);

    initial
        begin
            $monitor(,$time, " a=%b, b= %b, g=%b, e=%b, l=%b ", a,b,g,e,l);
            #0 a=4'b0000; b= 4'b1000;
            #5 a=4'b0110; b= 4'b0010;
            #5 a=4'b0110; b= 4'b0110;
            #5 a=4'b0010; b= 4'b0100;
            #100 $finish;
        end
endmodule