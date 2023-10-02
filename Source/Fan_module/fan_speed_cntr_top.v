`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/22 09:31:06
// Design Name: 
// Module Name: fan_speed_cntr_top
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

module fan_speed_cntr_top(
    input clk, reset_p,
    input btn_speed,
    input btn_auto,
    inout dht11_data,
    output speed,
    output reg state,
    output [15:0] value_data,
    output reg [2:0] LED_speed,
    output reg LED_auto
    );
    
    parameter STOP = 0;
    parameter RUN = 1;
    parameter LOW = 1;
    parameter HIGH = 2; 
    parameter MAX = 3;
    
//    button_cntr btn_cntr_auto(.clk(clk), .reset_p(reset_p), .btn(btn_auto), .btn_ne(auto_en));
//    t_flip_flop_p tff_setmode(.clk(clk), .rst(reset_p), .t(auto_en), .q(auto_onoff)); // auto_en에 따라 auto_onoff 토글
    t_flip_flop_p tff_setmode(.clk(clk), .rst(reset_p), .t(btn_auto), .q(auto_onoff)); // auto_en에 따라 auto_onoff 토글
    
    wire [2:0] stage, stage_auto, stage_man;
    assign stage = auto_onoff ? stage_auto : stage_man;
    
    fan_temp_humid_top auto_mode(.clk(clk), .reset_p(reset_p), .dht11_data(dht11_data), .stage_auto(stage_auto), .value_data(value_data));
    
    wire stage_select;
//    assign stage_select = auto_onoff ? 0 : stage_btn; // auto 모드 동작 중에는 power 버튼 입력이 안 되도록
    assign stage_select = auto_onoff ? 0 : btn_speed; // auto 모드 동작 중에는 power 버튼 입력이 안 되도록
    
//    button_cntr btn_cntr_stage(.clk(clk), .reset_p(reset_p), .btn(btn_speed), .btn_pe(stage_btn));
    counter_speed_stage stage_cntr(.clk(clk), .reset_p(reset_p), .btn(stage_select), .dec1(stage_man));
    
    reg [7:0] duty;
    always @(negedge clk, posedge reset_p) begin
        if(reset_p) begin
            duty = 0;
            state = STOP;
            LED_speed = 3'b000;
            LED_auto = 2'b00;
        end
        else begin
            case(stage)
                STOP : begin
                    duty = 0;
                    state = STOP;
                    LED_speed[2:0] = 3'b000;
                    if(auto_onoff) LED_auto = 1'b1;
                    else LED_auto = 1'b0;
                end
                LOW : begin
                    duty = 33;
                    state = RUN;
                    LED_speed[2:0] = 3'b001;
                    if(auto_onoff) LED_auto = 1'b1;
                    else LED_auto = 1'b0;                  
                end
                HIGH : begin
                    duty = 66;
                    state = RUN;
                    LED_speed[2:0] = 3'b011;
                    if(auto_onoff) LED_auto = 1'b1;
                    else LED_auto = 1'b0;
                end
                MAX : begin
                    duty = 99;
                    state = RUN;
                    LED_speed[2:0] = 3'b111;
                    if(auto_onoff) LED_auto = 1'b1;
                    else LED_auto = 1'b0;
                end
            endcase
        end
    end
    PWM_100 pwm_dc(.clk(clk), .rstp(reset_p), .duty(duty), .pwm_freq(100), .pwm_100pc(speed));
endmodule
