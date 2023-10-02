`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/25 10:09:00
// Design Name: 
// Module Name: fan_led_top
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

module fan_led_top(
    input clk, reset_p,
    input btn_LED,
    output reg party_mode_flag,
    output red, blue, green
    );
    
    wire pwm_pe;
//    button_cntr btn_pwm(.clk(clk), .reset_p(reset_p), .btn(btn_LED), .btn_pe(pwm_pe));
    
    //버튼을 눌러 링 카운터를 통한 모드 변환   
    reg [4:0] pwm_change;
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) pwm_change = 5'b0_0001;
//        else if(pwm_pe) begin
        else if(btn_LED) begin
            if(pwm_change == 5'b0_0001) pwm_change = 5'b0_0010;
            else if (pwm_change == 5'b0_0010) pwm_change = 5'b0_0100;
            else if (pwm_change == 5'b0_0100) pwm_change = 5'b0_1000;
            else if (pwm_change == 5'b0_1000) pwm_change = 5'b1_0000;
            else if (pwm_change == 5'b1_0000) pwm_change = 5'b0_0001;                
            else pwm_change = 5'b0_0001;
        end                    
    end
    
    //모드 설정
    wire [4:0] pwm_mode;    
    assign pwm_mode = pwm_change; 
    
    //발기 조절을 위한 duty ratio 설정            
    reg [11:0] duty_red, duty_blue, duty_green;
    reg party_time;
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin   //초기화 
            duty_red = 0;
            duty_blue = 0;
            duty_green = 0;
            party_time = 0;
            party_mode_flag = 0;
        end    
        else begin
            if (pwm_mode == 5'b0_0010)begin //밝기 33.3% 
                duty_red = 333;
                duty_blue = 333;
                duty_green = 333;
                party_time = 0;
                party_mode_flag = 0;
            end
            else if (pwm_mode == 5'b0_0100)begin //밝기 66.6%
                duty_red = 666;
                duty_blue = 666;
                duty_green = 666;
                party_time = 0;
                party_mode_flag = 0;
            end
            else if (pwm_mode == 5'b0_1000)begin //밝기 99.9% 
                duty_red = 999;
                duty_blue = 999;
                duty_green = 999;
                party_time = 0;
                party_mode_flag = 0;
            end
            else if (pwm_mode == 5'b1_0000)begin //party_mode
                party_time = 1;
                duty_red = 500;
                duty_blue = 0;
                duty_green = 0;
                party_mode_flag = 1;
                    if (party_time == 1)begin                        
                       if (duty_red >= 1000) duty_red = 0;
                       else  duty_red = duty_red + 125;
                       if (duty_blue >= 1000) duty_blue = 500;
                       else  duty_blue = duty_blue + 250;
                       if (duty_green >= 1000) duty_green = 0;
                       else duty_green = duty_green + 500;
                    end
            end                                                               
            else begin 
                duty_red = 0;
                duty_blue = 0;
                duty_green = 0;
                party_time = 0;
                party_mode_flag = 0;
            end
        end            
    end        
   
   //party_mode를 위한 frequency 설정
    wire [6:0] preq_red, preq_blue, preq_green; 
    assign preq_red = party_time ? 1 : 100;
    assign preq_blue = party_time ? 2 : 100;
    assign preq_green = party_time ? 3 : 100;
                  
    PWM_1000_led led_red(.clk(clk), .rstp(reset_p), .duty(duty_red), .pwm_freq(preq_red), .pwm_1000pc(red));
    PWM_1000_led led_blue(.clk(clk), .rstp(reset_p), .duty(duty_blue), .pwm_freq(preq_blue), .pwm_1000pc(blue));
    PWM_1000_led led_green(.clk(clk), .rstp(reset_p), .duty(duty_green), .pwm_freq(preq_green), .pwm_1000pc(green));                      

endmodule
