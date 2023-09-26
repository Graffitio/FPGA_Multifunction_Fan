`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/24 23:03:53
// Design Name: 
// Module Name: fan_emcy_top
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


module fan_emcy_top(
    input clk, reset_p,
    input echo,
    output trig,
    output emcy_signal,
    output reg emcy_LED
    );
    
    wire clk_usec;
    clock_usec usec_clk(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec));
    
    wire [8:0] distance_cm;
//    UltraSonic_Profsr emcy_sensor(.clk(clk), .rst(reset_p), .echo(echo), .trig(trig), .distance_cm(distance_cm));
    UltraSonic emcy_sensor(.clk(clk), .reset_p(reset_p), .echo(echo), .trig(trig), .distance(distance_cm));
    
    reg emcy_signal_buf;
    assign emcy_signal = emcy_signal_buf;
    reg [8:0] distance_cm_buf;
    assign distance_cm = distance_cm_buf;
    always @(posedge clk_usec or posedge reset_p) begin
        if(reset_p) begin
            emcy_signal_buf = 0;
            emcy_LED = 0;
        end
        else begin
            if(distance_cm_buf < 10) begin
                emcy_signal_buf = 1;
                emcy_LED = 1;
            end
            else begin
                emcy_signal_buf = 0;
                emcy_LED = 0;
            end
        end
    end
    
//    edge_detector_n ed_emcy(.clk(clk), .cp_in(emcy_signal), .rst(reset_p), .p_edge(emcy_stop));
endmodule
