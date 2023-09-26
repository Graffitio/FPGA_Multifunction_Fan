`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/30 09:20:35
// Design Name: 
// Module Name: FND_4digit_cntr
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FND_4digit_cntr( //// ring counter top module 생성 ---- 16bit의 값을 받아서 1ms 간격으로 한 자리씩 켜준다.
    input clk, rst, lap,
    input [15:0] value, //// 4자리니까 16bit
    output [3:0] com,
    output [7:0] seg_7
);
    reg [16:0] clk_1ms;//// 8ns * 2^17 = 1,048,576ns = 1048㎲ = 1.048ms
    always @(posedge clk) clk_1ms = clk_1ms + 1 ;
    
    ring_count_fnd ring1(.clk(clk_1ms[16]), .com(com)); //// 1ms posedge마다 좌시프트
                                                                   //// 1ms 마다 CT 순대로 LED가 점멸한다.
                                                                   
    wire [7:0] seg_7_font;
    reg [3:0] hex_value;
    decoder_7seg ring_seg_7(.hex_value(hex_value), .seg_7(seg_7_font));
    assign seg_7 = ~seg_7_font;
    
    always @(negedge clk) begin //// 카운팅은 posedge에 했으니, 겹치지 않게 negedge
        case(com)
            4'b1110 : hex_value = value[15:12]; //// CT1에 해당하는 hex_value는 value[15:12]
            4'b1101 : hex_value = value[11:8];
            4'b1011 : hex_value = value[7:4];
            4'b0111 : hex_value = value[3:0];
        endcase  //// edge triggering은 default에서 현재 값을 유지해도 FF가 만들어지니 상관없다.           
    end
endmodule