`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/22 10:19:05
// Design Name: 
// Module Name: fan_top
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


module fan_top(
    input clk, reset_p,
    input [4:0] btn,
    input emcy_select,
    inout dht11_data,
    input echo,
    input RX,
//    output TX,
    output trig,
    output [3:0] com,
    output [7:0] seg_7,
    output speed, spin, song,
    output [3:0] LED_bar,
    output [2:0] timer_led,
    output emcy_LED, red, blue, green
    );
    
    wire timeout, state, timeout_ne;
    wire [15:0] value_data, value_timer;
    // Fan Speed 제어(btn1) 및 온습도에 따른 Auto mode(btn2)
    
    button_cntr btn_cntr_stage(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(stage_btn)); // 블루투스의 엣지 신호와 동기화시키기 위해 해당 기능의 모듈 밖으로 뺴놨음
    button_cntr btn_cntr_auto(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_ne(auto_en));
    fan_speed_cntr_top fan_speed(.clk(clk), .reset_p(reset_p | timeout_ne), .dht11_data(dht11_data), .btn_speed(stage_btn | blue_btn_l[1]), .btn_auto(auto_en | blue_btn_l[2]),
                                 .speed(speed_en), .state(state), .value_data(value_data), .LED_speed(LED_bar[2:0]), .LED_auto(LED_bar[3]));
    // Fan Spin 제어(btn2)                             
//    fan_spin_top fan_spin(.clk(clk), .reset_p(reset_p | timeout_ne), .btn(btn),
//                          .spin(spin_en), .LED_spin(LED_bar[4:3]));
    // Fan Timer 제어(btn4)
    button_cntr bcntr_1mintimer(.clk(clk), .reset_p(reset_p), .btn(btn[4]), .btn_ne(btn_settime_en));
    fan_timer_top fan_timer(.clk(clk), .reset_p(reset_p | timeout_ne | blue_btn_l[5]), .btn_tim(btn_settime_en | blue_btn_l[4]), .state(state),
                            .value_timer(value_timer), .timeout(timeout), .timer_led(timer_led)); // btn2
                            
    // Timer의 Timeout값을 받아서 Edge 신호 발생
    edge_detector_n ed_timeout(.clk(clk), .cp_in(timeout), .rst(reset_p), .n_edge(timeout_ne));
    
    // Fan Emergency Stop 기능
    fan_emcy_top fan_emcy(.clk(clk), .reset_p(reset_p), .echo(echo), .trig(trig), .emcy_signal(emcy_signal_en), .emcy_LED(emcy_LED));
    
    button_cntr btn_cntr_emcy(.clk(clk), .reset_p(reset_p), .btn(emcy_select), .btn_pe(emcy_select_pe));
    counter_emcy_stage stage_cntr_emcy(.clk(clk), .reset_p(reset_p), .btn(emcy_select_pe), .dec1(stage_emcy));
    wire emcy_signal;
    assign emcy_signal = stage_emcy ? 0 : emcy_signal_en;
    assign speed = emcy_signal ? 0 : speed_en;
//    assign spin = emcy_signal ? 0 : spin_en;
    
    wire party_mode_flag;
    button_cntr btn_pwm(.clk(clk), .reset_p(reset_p), .btn(btn[3]), .btn_pe(pwm_pe));
    fan_led_top fan_led(.clk(clk), .reset_p(reset_p), .btn_LED(pwm_pe | blue_btn_l[3]), .party_mode_flag(party_mode_flag), .red(red), .blue(blue), .green(green));
    fan_speaker_top fan_speaker(.clk(clk), .reset_p(reset_p), .song(song_en));
    
    assign song = party_mode_flag ? song_en : 0; 
    
    wire [5:0] blue_btn_l;
    wire [7:0] rx_data;
    fan_bluetooth_top fan_bluetooth(.clk(clk), .reset_p(reset_p), .RX(RX), .blue_btn_l(blue_btn_l));
    
    //FND stage control
    button_cntr btn_cntr_fnd(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(fnd_stage_btn));
    counter_fnd_stage stage_fnd(.clk(clk), .reset_p(reset_p), .btn(fnd_stage_btn | blue_btn_l[0]), .dec1(fnd_select));
    
    wire [15:0] value; // 버튼 입력에 따라 FND 출력 data 변경
    assign value = (fnd_select == 0) ? value_data : (fnd_select == 1) ? value_timer : 0;
    
    FND_4digit_cntr fnd_cntr(.clk(clk), .rst(reset_p), .value({value}), .com(com), .seg_7(seg_7));
endmodule
