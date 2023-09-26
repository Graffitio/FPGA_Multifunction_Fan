`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/22 10:25:12
// Design Name: 
// Module Name: fan_temp_humid_top
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


module fan_temp_humid_top(
    input clk, reset_p,
    inout dht11_data,
    output reg [2:0] stage_auto,
    output [15:0] value_data
    );
    
    parameter STOP = 0;
    parameter LOW = 1;
    parameter HIGH = 2; 
    parameter MAX = 3;
    
    wire [7:0] humidity, temperature;
    DHT11 dht(.clk(clk), .reset_p(reset_p), .dht11_data(dht11_data), .humidity(humidity), .temperature(temperature));
    
    always@(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            stage_auto = STOP;
        end
        else begin
            if(humidity > 60) begin // 습도가 높을 때는 2단계
                if(temperature >= 26) begin
                    stage_auto = MAX;
                end
                else begin
                    stage_auto = LOW;
                end
            end
            else begin // 습도가 낮을 때는 3단계
                if(temperature >= 30) begin
                    stage_auto = MAX;
                end
                else if((temperature >= 26) && (temperature < 30)) begin
                    stage_auto = HIGH;
                end
                else if((temperature > 23) && (temperature < 26)) begin
                    stage_auto = LOW;
                end
                else begin
                    stage_auto = STOP;
                end
            end
        end
    end
    
    wire [15:0] humi_dec, temp_dec;
    bin_to_dec humi_b2d(.bin({4'b0000,humidity}), .bcd(humi_dec));
    bin_to_dec temp_b2d(.bin({4'b0000 ,temperature}), .bcd(temp_dec));
    
    assign value_data = {humi_dec[7:0], temp_dec[7:0]};
    
endmodule
