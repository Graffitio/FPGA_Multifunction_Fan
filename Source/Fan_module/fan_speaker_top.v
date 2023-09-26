`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/23 01:21:23
// Design Name: 
// Module Name: fan_speaker_top
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


module fan_speaker_top(
    input clk, reset_p,
    output song
    );
    
    wire clk_usec, clk_msec;
//    wire clk_start;
//    assign clk_start = start_stop ? 0 : clk_usec;
    clock_usec usec_clk(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec));
    clock_div_1000 msec_clk(.clk(clk), .clk_source(clk_usec), .reset_p(reset_p), .clk_div_1000(clk_msec));
    
    // msec counter
    reg [15:0] cnt_msec;
    reg cnt_msec_e;

    // usec Counter
    always @(negedge clk, posedge reset_p) begin
        if(reset_p) cnt_msec = 0; // 리셋 누르면 출력이 0되도록 설계
        else begin
            // data가 들어올 때 동안만 count
            if(clk_msec && cnt_msec_e) cnt_msec = cnt_msec + 1; // enable이 1이고, clk_usec가 들어올 때만 count++
            else if(!cnt_msec_e) cnt_msec = 0;
        end
    end
    // 3옥타브 note
    parameter C_3 = 131; // 1046.502
    parameter CC_3 = 139; // 1108.731
    parameter D_3 = 147; // 1170.659
    parameter DD_3 = 156; // 1244.508
    parameter E_3 = 165; // 1318.510
    parameter F_3 = 175; // 1396.913
    parameter FF_3 = 185; // 1479.978
    parameter G_3 = 196; // 1567.982
    parameter GG_3 = 208; //1661.219
    parameter A_3 = 220; // 1760.0
    parameter AA_3 = 234; // 1864.655
    parameter B_3 = 247; // 1975.533
    
    // 4옥타브 note
    parameter C_4 = 262; // 1046.502
    parameter CC_4 = 277; // 1108.731
    parameter D_4 = 294; // 1170.659
    parameter DD_4 = 311; // 1244.508
    parameter E_4 = 330; // 1318.510
    parameter F_4 = 349; // 1396.913
    parameter FF_4 = 370; // 1479.978
    parameter G_4 = 392; // 1567.982
    parameter GG_4 = 415; //1661.219
    parameter A_4 = 440; // 1760.0
    parameter AA_4 = 466; // 1864.655
    parameter B_4 = 494; // 1975.533
    
    // 6옥타브 note
    parameter C_6 = 1047; // 1046.502
    parameter CC_6 = 1109; // 1108.731
    parameter D_6 = 1175; // 1170.659
    parameter DD_6 = 1245; // 1244.508
    parameter E_6 = 1319; // 1318.510
    parameter F_6 = 1397; // 1396.913
    parameter FF_6 = 1480; // 1479.978
    parameter G_6 = 1568; // 1567.982
    parameter GG_6 = 1661; //1661.219
    parameter A_6 = 1760; // 1760.0
    parameter AA_6 = 1865; // 1864.655
    parameter B_6 = 1976; // 1975.533
    
    // 7옥타브 note
    parameter C_7 = 2093; // 2093.005
    parameter CC_7 = 2217; // 2217.461
    parameter D_7 = 2349; // 2349.318
    parameter DD_7 = 2489; // 2489.016
    parameter E_7 = 2637; // 2637.020
    parameter F_7 = 2794; // 2793.826
    parameter FF_7 = 2960; // 2959.955
    parameter G_7 = 3136; // 3135.963
    parameter GG_7 = 3322; // 3322.438
    parameter A_7 = 3520; // 3520.0
    parameter AA_7 = 3729; // 3729.310
    parameter B_7 = 3951; // 3951.066
    
    
    // 생일축하노래
    // GGAG CB GGAG DC GG G'E CBA FFEC DC
    reg [15:0] birthday [0:24];
    initial begin
        birthday[0] = G_6;
        birthday[1] = G_6;
        birthday[2] = A_6;
        birthday[3] = G_6;
        birthday[4] = C_7;
        birthday[5] = B_6;
        birthday[6] = G_6;
        birthday[7] = G_6;
        birthday[8] = A_6;
        birthday[9] = G_6;
        birthday[10] = D_7;
        birthday[11] = C_7;
        birthday[12] = G_6;
        birthday[13] = G_6;
        birthday[14] = G_7;
        birthday[15] = E_7;
        birthday[16] = C_7;
        birthday[17] = B_6;
        birthday[18] = A_6;
        birthday[19] = F_7;
        birthday[20] = F_7;
        birthday[21] = E_7;
        birthday[22] = C_7;
        birthday[23] = D_7;
        birthday[24] = C_7;
    end

    // FSM 
    reg [7:0] state, next_state;
    always @(negedge clk or posedge reset_p) begin
        if(reset_p) begin
            state = 0;
        end
        else state = next_state;
    end
    
    reg [13:0] freq_buf;
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            cnt_msec_e = 0;
            next_state = 0;
            freq_buf = 0;
        end
        else begin
            case(state)
                0 : begin
                    if(cnt_msec < 200) begin
                        cnt_msec_e = 1;
                        freq_buf = birthday[0];
                    end
                    else begin
                        freq_buf = 0;
                        cnt_msec_e = 0;
                        next_state = 1;
                    end
                end
                1 : begin
                    if(cnt_msec < 200) begin
                        cnt_msec_e = 1;
                        freq_buf = birthday[1];
                    end
                    else begin
                        cnt_msec_e = 0;
                        next_state = 2;
                    end
                end
                2 : begin
                    if(cnt_msec < 560) begin
                        cnt_msec_e = 1;
                        freq_buf = birthday[2];                        
                    end
                    else begin
                        cnt_msec_e = 0;
                        next_state = 3;
                    end
                end
                3 : begin
                    if(cnt_msec < 560) begin
                        cnt_msec_e = 1;
                        freq_buf = birthday[3];
                    end
                    else begin
                        
                        cnt_msec_e = 0;
                        next_state = 4;
                    end
                end
                4 : begin
                    if(cnt_msec < 560) begin
                        cnt_msec_e = 1;
                        freq_buf = birthday[4];
                    end
                    else begin
                        
                        cnt_msec_e = 0;
                        next_state = 5;
                    end
                end
                5 : begin
                    if(cnt_msec < 1120) begin
                        cnt_msec_e = 1;
                        freq_buf = birthday[5];
                    end
                    else begin
                        
                        cnt_msec_e = 0;
                        next_state = 6;
                    end
                end
                6 : begin
                    if(cnt_msec < 200) begin
                        cnt_msec_e = 1;
                        freq_buf = birthday[6];
                    end
                    else begin
                        
                        cnt_msec_e = 0;
                        next_state = 7;
                    end
                end
                7 : begin
                    if(cnt_msec < 200) begin
                        cnt_msec_e = 1;
                        freq_buf = birthday[7];
                    end
                    else begin
                        
                        cnt_msec_e = 0;
                        next_state = 8;
                    end
                end
                8 : begin
                    if(cnt_msec < 560) begin
                        cnt_msec_e = 1;
                        freq_buf = birthday[8];
                    end
                    else begin
                        
                        cnt_msec_e = 0;
                        next_state = 9;
                    end
                end
                9 : begin
                    if(cnt_msec < 560) begin
                        cnt_msec_e = 1;
                        freq_buf = birthday[9];
                    end
                    else begin
                        
                        cnt_msec_e = 0;
                        next_state = 10;
                    end
                end
                10 : begin
                    if(cnt_msec < 560) begin
                        cnt_msec_e = 1;
                        freq_buf = birthday[10];
                    end
                    else begin
                        
                        cnt_msec_e = 0;
                        next_state = 11;
                    end
                end
                11 : begin
                    if(cnt_msec < 1120) begin
                        cnt_msec_e = 1;
                        freq_buf = birthday[11];
                    end
                    else begin
                        
                        cnt_msec_e = 0;
                        next_state = 12;
                    end
                end
                12 : begin
                    if(cnt_msec < 200) begin
                        cnt_msec_e = 1;
                        freq_buf = birthday[12];
                    end
                    else begin
                        
                        cnt_msec_e = 0;
                        next_state = 13;
                    end
                end
                13 : begin
                    if(cnt_msec < 200) begin
                        cnt_msec_e = 1;
                        freq_buf = birthday[13];
                    end
                    else begin
                        
                        cnt_msec_e = 0;
                        next_state = 14;
                    end
                end
                14 : begin
                    if(cnt_msec < 560) begin
                        cnt_msec_e = 1;
                        freq_buf = birthday[14];
                    end
                    else begin
                        
                        cnt_msec_e = 0;
                        next_state = 15;
                    end
                end
                15 : begin
                    if(cnt_msec < 560) begin
                        cnt_msec_e = 1;
                        freq_buf = birthday[15];
                    end
                    else begin
                        
                        cnt_msec_e = 0;
                        next_state = 16;
                    end
                end
                16 : begin
                    if(cnt_msec < 560) begin
                        cnt_msec_e = 1;
                        freq_buf = birthday[16];
                    end
                    else begin
                        
                        cnt_msec_e = 0;
                        next_state = 17;
                    end
                end
                17 : begin
                    if(cnt_msec < 560) begin
                        cnt_msec_e = 1;
                        freq_buf = birthday[17];
                    end
                    else begin
                        
                        cnt_msec_e = 0;
                        next_state = 18;
                    end
                end
                18 : begin
                    if(cnt_msec < 1120) begin
                        cnt_msec_e = 1;
                        freq_buf = birthday[18];
                    end
                    else begin
                        
                        cnt_msec_e = 0;
                        next_state = 19;
                    end
                end
                19 : begin
                    if(cnt_msec < 200) begin
                        cnt_msec_e = 1;
                        freq_buf = birthday[19];
                    end
                    else begin
                        
                        cnt_msec_e = 0;
                        next_state = 20;
                    end
                end
                20 : begin
                    if(cnt_msec < 200) begin
                        cnt_msec_e = 1;
                        freq_buf = birthday[20];
                    end
                    else begin
                        
                        cnt_msec_e = 0;
                        next_state = 21;
                    end
                end
                21 : begin
                    if(cnt_msec < 560) begin
                        cnt_msec_e = 1;
                        freq_buf = birthday[21];
                    end
                    else begin
                        
                        cnt_msec_e = 0;
                        next_state = 22;
                    end
                end
                22 : begin
                    if(cnt_msec < 560) begin
                        cnt_msec_e = 1;
                        freq_buf = birthday[22];
                    end
                    else begin
                        
                        cnt_msec_e = 0;
                        next_state = 23;
                    end
                end
                23 : begin
                    if(cnt_msec < 560) begin
                        cnt_msec_e = 1;
                        freq_buf = birthday[23];
                    end
                    else begin
                        
                        cnt_msec_e = 0;
                        next_state = 24;
                    end
                end
                24 : begin
                    if(cnt_msec < 1120) begin
                        cnt_msec_e = 1;
                        freq_buf = birthday[24];
                    end
                    else begin
                        
                        cnt_msec_e = 0;
                        next_state = 25;
                    end
                end
                25 : begin
                    if(cnt_msec < 1000) begin
                        freq_buf = 0;
                        cnt_msec_e = 1;
                    end
                    else begin
                        cnt_msec_e = 0;
                        next_state = 0;
                    end
                end                                                                                                                                                                                                                                                                                                                                                                                        
            endcase
        end
    end
    
    wire [13:0] freq;
    assign freq = freq_buf;
    PWM_100 pwm_sound(.clk(clk), .rstp(reset_p), .duty(80), .pwm_freq(freq), .pwm_100pc(song));
endmodule
