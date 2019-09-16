`timescale 1 ns / 10 ps

module display(clk, rst, data_in, sel, data_out);
    input clk;
    wire clk;
    input rst;
    wire rst;
    input [7 : 0] data_in;
    wire [7 : 0] data_in;
    
    output [1 : 0] sel;
    wire [1 : 0] sel;
    output [6 : 0] data_out;
    reg [6 : 0] data_out;
    
    reg clkout;
    reg [19 : 0] cnt;
    reg scan_cnt;
    reg [6 : 0] date_out_r1;
    reg [6 : 0] date_out_r2;
    reg [1 : 0] sel_r;

    always @(posedge clk or negedge rst)
        begin 
            if (!rst)
                cnt <= 0;
            else
            begin
                cnt <= cnt + 1;
                if (cnt == 300000)
                    clkout <= 1'b1;
                else if (cnt == 600000)
                begin
                    clkout <= 1'b0;
                    cnt <= 0;
                end
            end
        end
    
    always @(posedge clkout or negedge rst)
        begin
            if (!rst)
                scan_cnt <= 0;
            else
                scan_cnt <= scan_cnt + 1;
        end
    
    always @(*)
        begin
            case (scan_cnt)
                0: sel_r <= 2'b01;
                1: sel_r <= 2'b10;
                default: sel_r <= 2'b00;
            endcase
        end
    
    always @(*)
    begin
        case (data_in[3 : 0])
            0: date_out_r1 = 7'b0111111; // 0
            1: date_out_r1 = 7'b0000110; // 1
            2: date_out_r1 = 7'b1011011; // 2
            3: date_out_r1 = 7'b1001111; // 3
            4: date_out_r1 = 7'b1100110; // 4
            5: date_out_r1 = 7'b1101101; // 5
            6: date_out_r1 = 7'b1111101; // 6
            7: date_out_r1 = 7'b0100111; // 7
            8: date_out_r1 = 7'b1111111; // 8
            9: date_out_r1 = 7'b1100111; // 9
            10: date_out_r1 = 7'b1110111; // A
            11: date_out_r1 = 7'b1111100; // b
            12: date_out_r1 = 7'b0111001; // c
            13: date_out_r1 = 7'b1011110; // d
            14: date_out_r1 = 7'b1111001; // E
            15: date_out_r1 = 7'b1110001; // F
            default: date_out_r1 = 7'b0000000;
        endcase
        
        case (data_in[7 : 4])
            0: date_out_r2 = 7'b0111111; // 0
            1: date_out_r2 = 7'b0000110; // 1
            2: date_out_r2 = 7'b1011011; // 2
            3: date_out_r2 = 7'b1001111; // 3
            4: date_out_r2 = 7'b1100110; // 4
            5: date_out_r2 = 7'b1101101; // 5
            6: date_out_r2 = 7'b1111101; // 6
            7: date_out_r2 = 7'b0100111; // 7
            8: date_out_r2 = 7'b1111111; // 8
            9: date_out_r2 = 7'b1100111; // 9
            10: date_out_r2 = 7'b1110111; // A
            11: date_out_r2 = 7'b1111100; // b
            12: date_out_r2 = 7'b0111001; // c
            13: date_out_r2 = 7'b1011110; // d
            14: date_out_r2 = 7'b1111001; // E
            15: date_out_r2 = 7'b1110001; // F
            default: date_out_r2 = 7'b0000000;
        endcase
    end
    
    always @(*)
        case(sel_r)
            2'b01: data_out = date_out_r1;
            2'b10: data_out = date_out_r2;
            default: data_out = 7'b0000000;
        endcase
    assign sel = sel_r;
endmodule
