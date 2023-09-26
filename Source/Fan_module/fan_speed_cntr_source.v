`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/22 09:42:19
// Design Name: 
// Module Name: fan_speed_cntr_source
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

// Mode용 카운터
module counter_speed_stage(
    input clk, reset_p,
    input btn,
    output reg [3:0] dec1
    );
    
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            dec1 = 0;
        end
        else begin
            if(btn) begin
                if(dec1 >= 3) begin
                    dec1 = 0;
                end
                else dec1 = dec1 + 1;
            end
        end
    end
endmodule

// Mode용 카운터
module counter_spin_stage(
    input clk, reset_p,
    input btn,
    output reg [3:0] dec1
    );
    
    always @(posedge clk) begin
      if(btn) begin
        if(dec1 >= 2) begin 
                dec1 <= 0;
            end
            else dec1 <= dec1 + 1;
        end
    end
endmodule

// Mode용 카운터
module counter_timer_stage(
    input clk, reset_p,
    input btn,
    output reg [3:0] dec1
    );
    
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            dec1 = 0;
        end
        else begin
            if(btn) begin
                if(dec1 == 3) begin
                    dec1 = 0;
                end
                else dec1 = dec1 + 1;
            end
        end
    end
endmodule

// Mode용 카운터
module counter_fnd_stage(
    input clk, reset_p,
    input btn,
    output reg [3:0] dec1
    );
    
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            dec1 = 0;
        end
        else begin
            if(btn) begin
                if(dec1 == 1) begin
                    dec1 = 0;
                end
                else dec1 = dec1 + 1;
            end
        end
    end
endmodule

// Mode용 카운터
module counter_emcy_stage(
    input clk, reset_p,
    input btn,
    output reg [3:0] dec1
    );
    
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            dec1 = 0;
        end
        else begin
            if(btn) begin
                if(dec1 == 1) begin
                    dec1 = 0;
                end
                else dec1 = dec1 + 1;
            end
        end
    end
endmodule