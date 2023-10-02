`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/20 12:18:53
// Design Name: 
// Module Name: PWM_100
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


module PWM_100(
    input clk, rstp,
    input [6:0] duty, // 듀티비 설정 변수 
    input [13:0] pwm_freq, // parameter 대신 여기에 선언해도 된다. 10,000Hz 쓸 거니까 14bit
    output reg pwm_100pc // pc : % -> 하나당 센티(1/100)이라는 뜻
    );
    
    reg [7:0] clk_div;
    always @(posedge clk) begin
        clk_div = clk_div + 1;
    end
    
    parameter sys_clk_freq = 125_000_000; // cora boadr의 시스템 클락
//    parameter pwm_freq = 1000; // 1000Hz짜리 pwm을 만들기 위한 define
    
    reg [26:0] cnt;
    reg clk_freqX100; // 100배된 클럭 주기 생성을 위한 변수 
    always @(posedge clk, posedge rstp) begin
        if(rstp) begin
            cnt = 0;
            clk_freqX100 = 0;
        end
        else begin
            // 125000까지 카운트하고 클럭 주기 생성
//            if(cnt >= 124_999) begin  // 1000Hz짜리를 만들 것이기 때문에 sys clk를 1000으로 나눔
//            if(cnt >= (sys_clk_freq / pwm_freq / 2)) begin // 토글시켜서 사용할 것이니까 2로 나눔
//            if(cnt >= (sys_clk_freq / pwm_freq / 2 / 100)) begin // 듀티비를 계산하기 위해 100 나눠주고 clk_freqX100을 카운트하여 0과 1을 부여한다.
//            if(cnt >= (sys_clk_freq / pwm_freq / 200)) begin // always문 들어 올때마다 나누기 연산하게 되므로, Negative Slack 발생 가능성 높아짐. 간단하게 바꿔주자
            if(cnt >= (625000 / pwm_freq)) begin // always문 들어 올때마다 나누기 연산하게 되므로, Negative Slack 발생 가능성 높아짐. 간단하게 바꿔주자
                cnt = 0;
                clk_freqX100 = ~clk_freqX100; // pwm 한 주기를 만들기 위한 문장
            end
            else begin
                cnt = cnt + 1; // 클락을 세는 카운터
            end
//            // Duty cycle : 50%
//            if(cnt < 62500) begin
//                pwm_100pc = 0;
//            end
//            else begin
//                pwm_100pc = 1;
//            end
        end
    end 
    
    wire clk_freqX100_n;
    edge_detector_p edg(.clk(clk), .cp_in(clk_freqX100), .rst(rstp), .n_edge(clk_freqX100_n)); // Edge Detector
    // 이전 always문에서 clk_freqX100 동작하고 4ns 후에나 edge 잡을 것이다.
    // Timing 문제로 인해 posedge clk를 사용하는 edge detector를 사용하는 것이 좋다.
    // 지금 상황에서는 nedge clk보다 pedge clk가 약 2배정도 더 여유가 있다.
    
    reg [6:0] cnt_duty; // 듀티사이클의 카운터 변수 
    always @(negedge clk, posedge rstp) begin
        if(rstp) begin
            cnt_duty = 0;
            pwm_100pc = 0;
        end
        else if(clk_freqX100_n) begin
            if(cnt_duty >= 99) begin
                cnt_duty = 0;    
            end
            else begin
                cnt_duty = cnt_duty + 1;
            end
            if(cnt_duty < duty) pwm_100pc = 1; // 예를 들어 50을 duty로 받으면, 50까지는 1, 나머지는 0
            else pwm_100pc = 0;
        end
    end 
endmodule


module PWM_1000(
    input clk, rstp,
    input [9:0] duty, // 듀티비 설정 변수 
    input [13:0] pwm_freq, // parameter 대신 여기에 선언해도 된다. 10,000Hz 쓸 거니까 14bit
    output reg pwm_1000pc // pc : % -> 하나당 센티(1/100)이라는 뜻
    );
    
    parameter sys_clk_freq = 125_000_000; // cora boadr의 시스템 클락
//    parameter pwm_freq = 1000; // 1000Hz짜리 pwm을 만들기 위한 define
    
    reg [26:0] cnt;
    reg clk_freqX1000; // pwm 주기의 1000배된 클럭 주기 생성을 위한 변수 
    always @(posedge clk, posedge rstp) begin
        if(rstp) begin
            cnt = 0;
            clk_freqX1000 = 0;
        end
        else begin
            // 125000까지 카운트하고 클럭 주기 생성
//            if(cnt >= 124_999) begin  // 1000Hz짜리를 만들 것이기 때문에 sys clk를 1000으로 나눔
//            if(cnt >= (sys_clk_freq / pwm_freq / 2)) begin // 토글시켜서 사용할 것이니까 2로 나눔
//            if(cnt >= (sys_clk_freq / pwm_freq / 2 / 100)) begin // 듀티비를 계산하기 위해 100 나눠주고 clk_freqX100을 카운트하여 0과 1을 부여한다.
            if(cnt >= (sys_clk_freq / pwm_freq / 2000)) begin // always문 들어 올때마다 나누기 연산하게 되므로, Negative Slack 발생 가능성 높아짐. 간단하게 바꿔주자
                cnt = 0;
                clk_freqX1000 = ~clk_freqX1000; // pwm 한 주기를 만들기 위한 문장
            end
            else begin
                cnt = cnt + 1; // 클락을 세는 카운터
            end
//            // Duty cycle : 50%
//            if(cnt < 62500) begin
//                pwm_100pc = 0;
//            end
//            else begin
//                pwm_100pc = 1;
//            end
        end
    end 
    
    wire clk_freqX1000_n;
    edge_detector_p edg(.clk(clk), .cp_in(clk_freqX1000), .rst(rstp), .n_edge(clk_freqX1000_n)); // Edge Detector
    // 이전 always문에서 clk_freqX100 동작하고 4ns 후에나 edge 잡을 것이다.
    // Timing 문제로 인해 posedge clk를 사용하는 edge detector를 사용하는 것이 좋다.
    // 지금 상황에서는 nedge clk보다 pedge clk가 약 2배정도 더 여유가 있다.
    
    reg [9:0] cnt_duty; // 듀티사이클의 카운터 변수 
    always @(posedge clk, posedge rstp) begin
        if(rstp) begin
            cnt_duty = 0;
            pwm_1000pc = 0;
        end
        else if(clk_freqX1000_n) begin
            if(cnt_duty >= 999) begin
                cnt_duty = 0;    
            end
            else begin
                cnt_duty = cnt_duty + 1;
            end
            if(cnt_duty < duty) pwm_1000pc = 1; // 예를 들어 50을 duty로 받으면, 50까지는 1, 나머지는 0
            else pwm_1000pc = 0;
        end
    end 
endmodule





module PWM_100_song(
    input clk, rstp,
    input [6:0] duty, // 듀티비 설정 변수 
    input [13:0] pwm_freq, // parameter 대신 여기에 선언해도 된다. 10,000Hz 쓸 거니까 14bit
    output reg pwm_100pc // pc : % -> 하나당 센티(1/100)이라는 뜻
    );
    
    reg [7:0] clk_div; // 나눗셈 연산으로 인해 발생한 Slack을 제거하기 위한 분주기
    always @(posedge clk) begin
        clk_div = clk_div + 1;
    end
    
    parameter sys_clk_freq = 125_000_000; // cora boadr의 시스템 클락
//    parameter pwm_freq = 1000; // 1000Hz짜리 pwm을 만들기 위한 define
    
    reg [26:0] cnt;
    reg clk_freqX100; // 100배된 클럭 주기 생성을 위한 변수 
    reg [14:0] pwm_temp;
    always @(posedge clk_div[7] or posedge rstp) begin // 나눗셈 연산은 1클락 안에 동작하지 않아. 그러니까 시간을 이렇게 써주면 더 좋지
        if(rstp) begin
            pwm_temp = 0;
        end
        else begin
             pwm_temp = 625000 / pwm_freq;
        end
    end
    
    always @(posedge clk or posedge rstp) begin 
        if(rstp) begin
            cnt = 0;
            clk_freqX100 = 0;
        end
        else begin
            // 125000까지 카운트하고 클럭 주기 생성
//            if(cnt >= 124_999) begin  // 1000Hz짜리를 만들 것이기 때문에 sys clk를 1000으로 나눔
//            if(cnt >= (sys_clk_freq / pwm_freq / 2)) begin // 토글시켜서 사용할 것이니까 2로 나눔
//            if(cnt >= (sys_clk_freq / pwm_freq / 2 / 100)) begin // 듀티비를 계산하기 위해 100 나눠주고 clk_freqX100을 카운트하여 0과 1을 부여한다.
//            if(cnt >= (sys_clk_freq / pwm_freq / 200)) begin // always문 들어 올때마다 나누기 연산하게 되므로, Negative Slack 발생 가능성 높아짐. 간단하게 바꿔주자
            if(cnt >= (pwm_temp)) begin // always문 들어 올때마다 나누기 연산하게 되므로, Negative Slack 발생 가능성 높아짐. 간단하게 바꿔주자
                cnt = 0;
                clk_freqX100 = ~clk_freqX100; // pwm 한 주기를 만들기 위한 문장
            end
            else begin
                cnt = cnt + 1; // 클락을 세는 카운터
            end
//            // Duty cycle : 50%
//            if(cnt < 62500) begin
//                pwm_100pc = 0;
//            end
//            else begin
//                pwm_100pc = 1;
//            end
        end
    end 
    
    wire clk_freqX100_n;
    edge_detector_p edg(.clk(clk), .cp_in(clk_freqX100), .rst(rstp), .n_edge(clk_freqX100_n)); // Edge Detector
    // 이전 always문에서 clk_freqX100 동작하고 4ns 후에나 edge 잡을 것이다.
    // Timing 문제로 인해 posedge clk를 사용하는 edge detector를 사용하는 것이 좋다.
    // 지금 상황에서는 nedge clk보다 pedge clk가 약 2배정도 더 여유가 있다.
    
    reg [6:0] cnt_duty; // 듀티사이클의 카운터 변수 
    always @(negedge clk, posedge rstp) begin
        if(rstp) begin
            cnt_duty = 0;
            pwm_100pc = 0;
        end
        else if(clk_freqX100_n) begin
            if(cnt_duty >= 99) begin
                cnt_duty = 0;    
            end
            else begin
                cnt_duty = cnt_duty + 1;
            end
            if(cnt_duty < duty) pwm_100pc = 1; // 예를 들어 50을 duty로 받으면, 50까지는 1, 나머지는 0
            else pwm_100pc = 0;
        end
    end 
endmodule





module PWM_1000_led(
    input clk, rstp,
    input [9:0] duty, // 듀티비 설정 변수 
    input [13:0] pwm_freq, // parameter 대신 여기에 선언해도 된다. 10,000Hz 쓸 거니까 14bit
    output reg pwm_1000pc // pc : % -> 하나당 센티(1/100)이라는 뜻
    );
    
    reg [7:0] clk_div; // 나눗셈 연산으로 인해 발생한 Slack을 제거하기 위한 분주기
    always @(posedge clk) begin
        clk_div = clk_div + 1;
    end
    
    parameter sys_clk_freq = 125_000_000; // cora boadr의 시스템 클락
//    parameter pwm_freq = 1000; // 1000Hz짜리 pwm을 만들기 위한 define
    
    reg [26:0] cnt;
    reg clk_freqX1000; // pwm 주기의 1000배된 클럭 주기 생성을 위한 변수 
    reg [14:0] pwm_temp;
    always @(posedge clk_div[3] or posedge rstp) begin // 나눗셈 연산은 1클락 안에 동작하지 않아. 그러니까 시간을 이렇게 써주면 더 좋지
        if(rstp) begin
            pwm_temp = 0;
        end
        else begin
             pwm_temp = 625000 / pwm_freq;
        end
    end
    
    
    always @(posedge clk, posedge rstp) begin
        if(rstp) begin
            cnt = 0;
            clk_freqX1000 = 0;
        end
        else begin
            // 125000까지 카운트하고 클럭 주기 생성
//            if(cnt >= 124_999) begin  // 1000Hz짜리를 만들 것이기 때문에 sys clk를 1000으로 나눔
//            if(cnt >= (sys_clk_freq / pwm_freq / 2)) begin // 토글시켜서 사용할 것이니까 2로 나눔
//            if(cnt >= (sys_clk_freq / pwm_freq / 2 / 100)) begin // 듀티비를 계산하기 위해 100 나눠주고 clk_freqX100을 카운트하여 0과 1을 부여한다.
//            if(cnt >= (sys_clk_freq / pwm_freq / 2000)) begin // always문 들어 올때마다 나누기 연산하게 되므로, Negative Slack 발생 가능성 높아짐. 간단하게 바꿔주자
            if(cnt >= (pwm_temp)) begin // always문 들어 올때마다 나누기 연산하게 되므로, Negative Slack 발생 가능성 높아짐. 간단하게 바꿔주자
                cnt = 0;
                clk_freqX1000 = ~clk_freqX1000; // pwm 한 주기를 만들기 위한 문장
            end
            else begin
                cnt = cnt + 1; // 클락을 세는 카운터
            end
//            // Duty cycle : 50%
//            if(cnt < 62500) begin
//                pwm_100pc = 0;
//            end
//            else begin
//                pwm_100pc = 1;
//            end
        end
    end 
    
    wire clk_freqX1000_n;
    edge_detector_p edg(.clk(clk), .cp_in(clk_freqX1000), .rst(rstp), .n_edge(clk_freqX1000_n)); // Edge Detector
    // 이전 always문에서 clk_freqX100 동작하고 4ns 후에나 edge 잡을 것이다.
    // Timing 문제로 인해 posedge clk를 사용하는 edge detector를 사용하는 것이 좋다.
    // 지금 상황에서는 nedge clk보다 pedge clk가 약 2배정도 더 여유가 있다.
    
    reg [9:0] cnt_duty; // 듀티사이클의 카운터 변수 
    always @(posedge clk, posedge rstp) begin
        if(rstp) begin
            cnt_duty = 0;
            pwm_1000pc = 0;
        end
        else if(clk_freqX1000_n) begin
            if(cnt_duty >= 999) begin
                cnt_duty = 0;    
            end
            else begin
                cnt_duty = cnt_duty + 1;
            end
            if(cnt_duty < duty) pwm_1000pc = 1; // 예를 들어 50을 duty로 받으면, 50까지는 1, 나머지는 0
            else pwm_1000pc = 0;
        end
    end 
endmodule