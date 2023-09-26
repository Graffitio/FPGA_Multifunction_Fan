`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/04 10:05:12
// Design Name: 
// Module Name: Clock_Library_
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


// Cora board sys clock : 125MHz
// 1 clock 당, 8ns

// Micro sec clock
module clock_usec_en(
    input clk, reset_p,
    input enable,
    output clk_usec
    );
    
    // 125개 카운트하면 1us
    reg [6:0] cnt_8nsec;
    wire cp_usec; // cp : clock pulse
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) cnt_8nsec = 0; // reset이 들어오면 cnt = 0
        else if (!enable) begin
            if(cnt_8nsec >= 124) cnt_8nsec = 0; // 0부터 124번까지 카운트하면 다시 0으로
            else cnt_8nsec = cnt_8nsec + 1;
        end
    end
    
    assign cp_usec = cnt_8nsec < 63 ? 0 : 1; // 0~62 : 0, 63~124 : 1 
    
    // 비정규 clock이므로 동기화가 필요하다.
    edge_detector_n edg(.clk(clk), .cp_in(cp_usec), .rst(reset_p), .n_edge(clk_usec)); /// 안 쓰는 출력은 빼버리면 된다.
    
endmodule


module clock_usec(
    input clk, reset_p,
    output clk_usec
    );
    
    // 125개 카운트하면 1us
    reg [6:0] cnt_8nsec;
    wire cp_usec; // cp : clock pulse
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) cnt_8nsec = 0; // reset이 들어오면 cnt = 0
            else if(cnt_8nsec >= 124) cnt_8nsec = 0; // 0부터 124번까지 카운트하면 다시 0으로
            else cnt_8nsec = cnt_8nsec + 1;
     end
    
    assign cp_usec = cnt_8nsec < 63 ? 0 : 1; // 0~62 : 0, 63~124 : 1 
    
    // 비정규 clock이므로 동기화가 필요하다.
    edge_detector_n edg(.clk(clk), .cp_in(cp_usec), .rst(reset_p), .n_edge(clk_usec)); /// 안 쓰는 출력은 빼버리면 된다.
    
endmodule


//// Mili sec clock
//module clock_msec(
//    input clk, clk_usec, reset_p,
//    output clk_msec
//    );
    
//    // 1000개 카운트하면 1ms
////    reg [9:0] cnt_usec;
////    wire cp_msec; // cp : clock pulse
    
////    always @(posedge clk, posedge reset_p) begin
////        if(reset_p) cnt_usec = 0; // reset이 들어오면 cnt = 0
////        else if (cnt_usec >= 999) cnt_usec = 0; // 0부터 125번까지 카운트하면 다시 0으로
////        else cnt_usec = cnt_usec + 1;
////    end
    
////    assign cp_msec = cnt_usec < 499 ? 0 : 1; // 0~498 : 0, 499~1000 : 1 

//    // 1000개 카운트하면 1ms
//    reg [8:0] cnt_usec;
//    reg cp_msec; // cp : clock pulse
    
//    always @(posedge clk, posedge reset_p) begin
//        if(reset_p) cnt_usec = 0; // reset이 들어오면 cnt = 0
//        else if(clk_usec) begin
//            if (cnt_usec >= 499) begin
//                cnt_usec = 0; // 0부터 499번까지 카운트하면 다시 0으로
//                cp_msec = ~cp_msec;
//            end
//            else cnt_usec = cnt_usec + 1;
//        end

//    end // 이렇게 카운트가 짝수일 경우, 위와 같이 코딩하여 1bit 줄일 수 있다.
    
//    // 비정규 clock이므로 동기화가 필요하다.
//    edge_detector_n edg(.clk(clk), .cp_in(cp_msec), .rst(reset_p), .n_edge(clk_msec)); /// 안 쓰는 출력은 빼버리면 된다.
    
//endmodule



//// sec clock
//module clock_sec(
//    input clk, clk_msec, reset_p,
//    output clk_sec
//    );

//    // 1000개 카운트하면 1s
//    reg [8:0] cnt_msec;
//    reg cp_sec; // cp : clock pulse
    
//    always @(posedge clk, posedge reset_p) begin
//        if(reset_p) cnt_msec = 0; // reset이 들어오면 cnt = 0
//        else if(clk_msec) begin 
//            if (cnt_msec >= 499) begin
//                cnt_msec = 0; // 0부터 499번까지 카운트하면 다시 0으로
//                cp_sec = ~cp_sec; // clock pulse 반전
//            end
//            else cnt_msec = cnt_msec + 1;
//        end
//    end // 이렇게 카운트가 짝수일 경우, 위와 같이 코딩하여 1bit 줄일 수 있다.
    
//    // 비정규 clock이므로 동기화가 필요하다.
//    edge_detector_n edg_sec(.clk(clk), .cp_in(cp_sec), .rst(reset_p), .n_edge(clk_sec)); /// 안 쓰는 출력은 빼버리면 된다.
    
//endmodule



// min clock
module clock_min(
    input clk, clk_sec, reset_p,
    output clk_min
    );

    // 60개 카운트하면 1s
    reg [5:0] cnt_sec;
    reg cp_min; // cp : clock pulse
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) cnt_sec = 0; // reset이 들어오면 cnt = 0
        else if(clk_sec) begin
            if (cnt_sec >= 29) begin
                cnt_sec = 0; // 0부터 번까지 카운트하면 다시 0으로
                cp_min = ~cp_min;
            end
            else cnt_sec = cnt_sec + 1;
        end
    end // 이렇게 카운트가 짝수일 경우, 위와 같이 코딩하여 1bit 줄일 수 있다.
    
    // 비정규 clock이므로 동기화가 필요하다.
    edge_detector_n edg_min(.clk(clk), .cp_in(cp_min), .rst(reset_p), .n_edge(clk_min)); /// 안 쓰는 출력은 빼버리면 된다.
    
endmodule





// 1000분주 clock
module clock_div_1000(
    input clk, clk_source, reset_p,
    output clk_div_1000
    );

    reg [8:0] cnt_clk_source;
    reg cp_div_1000; // cp : clock pulse
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) cnt_clk_source = 0; // reset이 들어오면 cnt = 0
        else if(clk_source) begin
            if (cnt_clk_source >= 499) begin
//            if (cnt_clk_source >= 999) begin
                cnt_clk_source = 0; // 0부터 499번까지 카운트하면 다시 0으로
                cp_div_1000 = ~cp_div_1000;
            end
            else cnt_clk_source = cnt_clk_source + 1;
        end
    end // 이렇게 카운트가 짝수일 경우, 위와 같이 코딩하여 1bit 줄일 수 있다.
    
    // 비정규 clock이므로 동기화가 필요하다.
    edge_detector_n edg_div_1000(.clk(clk), .cp_in(cp_div_1000), .rst(reset_p), .n_edge(clk_div_1000)); /// 안 쓰는 출력은 빼버리면 된다.
endmodule


// hour clock
module clock_hour(
    input clk, clk_min, reset_p,
    output clk_hour
    );

    // 60개 카운트하면 1s
    reg [5:0] cnt_min;
    reg cp_hour; // cp : clock pulse
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) cnt_min = 0; // reset이 들어오면 cnt = 0
        else if(clk_min) begin
            if (cnt_min >= 29) begin
                cnt_min = 0; // 0부터 번까지 카운트하면 다시 0으로
                cp_hour = ~cp_hour;
            end
            else cnt_min = cnt_min + 1;
        end
    end // 이렇게 카운트가 짝수일 경우, 위와 같이 코딩하여 1bit 줄일 수 있다.
    
    // 비정규 clock이므로 동기화가 필요하다.
    edge_detector_n edg_min(.clk(clk), .cp_in(cp_hour), .rst(reset_p), .n_edge(clk_hour)); /// 안 쓰는 출력은 빼버리면 된다.
    
endmodule



// 60bit_Counter
module counter_dec_60(
    input clk, reset_p,
    input clk_time,
    output reg [3:0] dec1, dec10
    );
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            dec1 = 0;
            dec10 = 0;
        end
        else if(clk_time) begin
            if(dec1 >= 9) begin 
                dec1 <= 0;
                if(dec10 >= 5) dec10 = 0;
                else dec10 <= dec10 + 1;
            end
            else dec1 <= dec1 + 1;
        end
    end
endmodule

// Loadable_60bit_Down_Counter
module loadable_down_counter_dec_60(
    input clk, reset_p,
    input clk_time,
    input load_enable, // user가 입력한 값을 받아오는 기능 추가 
    input [3:0] set_value1, set_value10, // 입력한 값
    output reg [3:0] dec1, dec10,
    output reg dec_clk // 다음 자리(예 : minute)에 신호(펄스)를 주기 위한 변수
    );
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            dec1 <= 0;
            dec10 <= 0;
            dec_clk <= 0;
        end
        else if(load_enable == 1) begin
            dec1 <= set_value1;
            dec10 <= set_value10;
        end
        else if(clk_time) begin
            if(dec1 == 0) begin
                dec1 <= 9;
                if(dec10 == 0) begin // 우리는 min과 sec 둘 다 구현하는 것이므로, min down counter에 신호를 넣어줘야 된다. 
                    dec10 <= 5;
                    dec_clk <= 1; // dec10, dec1 = 0, 0 이 되고 이후에 5, 9가 되면서 dec_clk 상승 펄스 발생
                end
                else dec10 <= dec10 - 1;
            end
            else dec1 <= dec1 - 1;
        end
        else dec_clk <= 0;
    end
endmodule

// 60bit_Counter_puler
module counter_dec_60_pul(
    input clk, reset_p,
    input clk_time,
    output reg [3:0] dec1, dec10,
    output reg dec_clk // 다음 자리(예 : minute)에 신호(펄스)를 주기 위한 변수
    );
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            dec1 = 0;
            dec10 = 0;
        end
        else if(clk_time) begin
            if(dec1 >= 9) begin 
                dec1 <= 0;
                if(dec10 >= 5) begin
                    dec10 = 0;
                    dec_clk <= 1; // dec10, dec1 = 0, 0 이 되고 이후에 5, 9가 되면서 dec_clk 상승 펄스 발생
                end
                else dec10 <= dec10 + 1;
            end
            else dec1 <= dec1 + 1;
        end
        else dec_clk <= 0;
    end
endmodule


// 60bit_Counter
module loadable_up_counter_dec_60(
    input clk, reset_p,
    input clk_time, load_enable,
    input [3:0] set_value1, set_value10,
    output reg [3:0] dec1, dec10,
    output reg dec_clk // 다음 자리(예 : minute)에 신호(펄스)를 주기 위한 변수
    );
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            dec1 = 0;
            dec10 = 0;
        end
        else if (load_enable) begin
            dec1 = set_value1;
            dec10 = set_value10;
        end
        else if(clk_time) begin
            if(dec1 >= 9) begin 
                dec1 <= 0;
                if(dec10 >= 5) begin
                    dec10 = 0;
                    dec_clk <= 1; // dec10, dec1 = 0, 0 이 되고 이후에 5, 9가 되면서 dec_clk 상승 펄스 발생
                end
                else dec10 <= dec10 + 1;
            end
            else dec1 <= dec1 + 1;
        end
        else dec_clk <= 0;
    end
endmodule