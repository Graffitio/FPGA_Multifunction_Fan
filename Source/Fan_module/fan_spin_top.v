`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/22 09:53:51
// Design Name: 
// Module Name: fan_spin_top
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


module fan_spin_top(
    input clk, reset_p,
    input [4:0] btn,
    output spin,
    output reg [1:0] LED_spin
    );
    
    parameter STOP = 2'b00; 
    parameter LOW = 2'b01;
    parameter HIGH = 2'b10;
    // Stage Select
    wire spin_stage;
    wire [2:0] stage; // 1´Ü, 2´Ü
    button_cntr btn_cntr_spin(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(spin_stage));
    counter_spin_stage stage_select(.clk(clk), .btn(spin_stage), .dec1(stage)); // state = 0, 1, 2
       
    // Spin
    reg [21:0] clk_div;
    always @(posedge clk) clk_div = clk_div + 1;
    
    wire clk_div_21_ne;
    edge_detector_p edg_low(.clk(clk), .cp_in(clk_div[21]), .rst(reset_p), .n_edge(clk_div_21_ne)); // Edge Detector
    edge_detector_p edg_high(.clk(clk), .cp_in(clk_div[20]), .rst(reset_p), .n_edge(clk_div_20_ne)); // Edge Detector
    
    reg [9:0] duty, last_duty;
    reg down_up, last_down_up;
    parameter UP = 0;
    parameter DOWN = 1;
    always @(posedge clk, posedge reset_p)begin
        if(reset_p) begin
            duty = 77;
            down_up = 0;
            last_duty = 77;
            last_down_up = 0;
            LED_spin [1:0] = 2'b00;
        end
        else begin
            duty = last_duty;
            down_up = last_down_up;
            case(stage)
                STOP : begin
                    duty = last_duty;
                    down_up = last_down_up;
//                    duty = 77;
                    LED_spin [1:0] = 2'b00;
                end
                LOW : begin
                    LED_spin [1:0] = 2'b01;
                    if(clk_div_21_ne) begin 
                        if(down_up) begin
                            if(duty < 28) begin
                                down_up = UP;
                            end
                            else begin
                                duty = duty - 1;
                            end
                        end
                        else begin
                            if(duty > 128) begin
                                down_up = DOWN;
                            end
                            else begin
                                duty = duty + 1;
                            end
                        end
                    end
                    last_duty = duty;
                    last_down_up = down_up;
                end    
                HIGH : begin
                    LED_spin [1:0] = 2'b10;
                    if(clk_div_20_ne) begin 
                        if(down_up) begin
                            if(duty < 28) begin
                                down_up = UP;
                            end
                            else begin
                                duty = duty - 1;
                            end
                        end
                        else begin
                            if(duty > 128) begin
                                down_up = DOWN;
                            end
                            else begin
                                duty = duty + 1;
                            end
                        end
                    end
                    last_duty = duty;
                    last_down_up = down_up;
                end    
            endcase     
        end
    end
    PWM_1000 pwm_spin(.clk(clk), .rstp(reset_p), .duty(duty), .pwm_freq(50), .pwm_1000pc(spin));
endmodule