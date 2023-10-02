`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/23 10:29:45
// Design Name: 
// Module Name: fan_timer_top
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


module fan_timer_top(
        input clk, reset_p,
        input btn_tim,
        input state,
        output [15:0] value_timer,
        output timeout,
        output [3:0] com,
        output [7:0] seg_7,
        output [2:0] timer_led
    );

    wire btn_settime, btn_settime_en;
    wire [2:0] cnt;
//    button_cntr bcntr_1mintimer(.clk(clk), .reset_p(reset_p), .btn(btn_tim), .btn_ne(btn_settime_en));
    counter_timer_stage tim_stage(.clk(clk), .reset_p(reset_p), .btn(btn_settime), .dec1(cnt)); // 3단 카운터

    // Fan이 Run 상태일 때만 Timer 기능이 동작되도록 
    reg btn_settime_buf;
    assign btn_settime = btn_settime_buf;
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            btn_settime_buf = 0;
        end
        else begin
//            if(state) btn_settime_buf = btn_settime_en;
            if(state) btn_settime_buf = btn_tim;
            else btn_settime_buf = 0;
        end
    end
    
    reg [3:0] min10_set, min1_set, sec10_set, sec1_set;
    reg [15:0] set_time; 
    always @(posedge clk or posedge reset_p) begin
        if(reset_p)         
            set_time = 0;    
        else 
            set_time = {min10_set, min1_set, sec10_set, sec1_set};
    end 
    
    wire cnt_flag;  
    reg cnt_flag_buf;
    assign cnt_flag = cnt_flag_buf;
    
    reg [2:0] timer_led_buf;
    assign timer_led = timer_led_buf;
    always@(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            sec1_set = 0;
            sec10_set = 0;
            min1_set = 0;
            min10_set = 0;
            cnt_flag_buf = 0;
            timer_led_buf = 3'b000;        
        end
        else begin
            case(cnt)
//                0 : begin // 연속 모드
//                    sec1_set = 0;
//                    sec10_set = 0;
//                    min1_set = 0;
//                    min10_set = 0;
//                    timer_led_buf = 3'b000;
//                end
                0 : begin // 연속 모드 시작 + 1단계 타이머 값 저장
                    sec1_set = 3;
                    sec10_set = 0;
                    min1_set = 0;
                    min10_set = 0;
                    cnt_flag_buf = 0;
                    timer_led_buf = 3'b000;
                end
                1 : begin // 1단계 타이머 시작 + 2단계 타이머 값 저장
                    sec1_set = 4;
                    sec10_set = 0;
                    min1_set = 0;
                    min10_set = 0;
                    cnt_flag_buf = 1;
                    timer_led_buf = 3'b001;
                end
                2 : begin // 3단계 타이머 시작 + 연속모드 타이머 값 저장
                    sec1_set = 5;
                    sec10_set = 0;
                    min1_set = 0;
                    min10_set = 0;
                    cnt_flag_buf = 1;
                    timer_led_buf = 3'b010;
                end                
                default : begin 
                    sec1_set = 0;
                    sec10_set = 0;
                    min1_set = 0;
                    min10_set = 0;
                    cnt_flag_buf = 1;
                    timer_led_buf = 3'b100;
                end
           endcase
       end
    end
        
    wire clk_usec, clk_msec, clk_sec, clk_min,clk_hour;
    clock_usec usec_clk(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec));    
    clock_div_1000 msec_clk(.clk(clk), .clk_source(clk_usec), .reset_p(reset_p), .clk_div_1000(clk_msec));    
    clock_div_1000 sec_clk(.clk(clk), .clk_source(clk_msec), .reset_p(reset_p), .clk_div_1000(clk_sec));
    clock_min min_clk(.clk(clk), .clk_sec(clk_sec), .reset_p(reset_p), .clk_min(clk_min));    
    clock_hour hour_clk(.clk(clk), .clk_min(clk_min), .reset_p(reset_p), .clk_hour(clk_hour));
    // clock 속도 만들어주는 instance
    
    wire clk_start, load_enable; 
    wire [3:0] sec1, sec10;
    wire [3:0] min1, min10;
    wire dec_clk;    
                               
    reg [15:0] count_time; 
    always @(posedge clk or posedge reset_p) begin
        if(reset_p)         
         count_time = 0;    
        else 
        count_time = {min10, min1, sec10, sec1};
    end
    
    wire dec_min;
    wire check_dec_min;
    assign check_dec_min = (count_time == 0) ? 0 : 1;
    assign clk_start = (count_time == 0) ? 0 : clk_sec;
    assign load_enable = btn_settime ? 1 : 0;
    assign dec_min = (check_dec_min) ?  dec_clk : 0;
    
    loadable_down_counter_dec_60 sec_60cntr(.clk(clk), .reset_p(reset_p),.clk_time(clk_start), 
                                 .load_enable(load_enable), .set_value1(sec1_set),.set_value10(sec10_set),
                                 .dec1(sec1), .dec10(sec10), .dec_clk(dec_clk));  
    
    loadable_down_counter_dec_60 min_100cntr(.clk(clk), .reset_p(reset_p),.clk_time(dec_min), 
                                 .load_enable(load_enable), .set_value1(min1_set),.set_value10(min10_set),
                                 .dec1(min1), .dec10(min10));
    
    // 연속모드일 때는 타입아웃 적용이 안 되고, 타이머 모드일 때에만 타임아웃 적용
    reg timeout_buf;
    assign timeout = timeout_buf;
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            timeout_buf = 1 ;
        end
        else begin
            if(cnt_flag == 0) timeout_buf = 1;
            else timeout_buf = |count_time;
        end
    end
    
    // 최종 출력값
    assign value_timer = count_time; 
    
endmodule
