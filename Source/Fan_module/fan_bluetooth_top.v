`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 2023/09/25 17:43:10
//// Design Name: 
//// Module Name: fan_bluetooth_top
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////


module bluetooth_rx(
    input clk,         // 클럭 입력
    input reset_p,     // 리셋 신호 입력
    input RX,          // 블루투스에서 수신된 데이터 입력
    output [7:0] dx_data,  // 데이터 출력
    output reg start
);
    // 9600 bps : 1sec에 9600bit 전송, 1bit에 0.0001041667sec(104,166ns)
    // sys clk : 1sec에 125,000,000bit 전송 1bit에 8ns                          
//    parameter T = 15'd10414; // 9600 보드레이트에 대한 전송 1비트에 필요한 카운트 값
    parameter BAUDRATE = 15'd13021; // 9600 BAUDRATE에 대한 전송 1비트에 필요한 카운트 값
//    parameter BAUDRATE = 15'd1628; // 9600 BAUDRATE에 대한 전송 1비트에 필요한 카운트 값
    
//    reg [7:0] clk_div;
//    always @(posedge clk) clk_div = clk_div + 1;

    // 9600 BAUDRATE 에 대한 카운트 값 계산
    // reg start;
    reg [14:0] cnt;
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) cnt <= 15'd0;
        else if(cnt == BAUDRATE) cnt <= 15'd0;
        else if(start) cnt <= cnt + 1'b1;
        else cnt <= 1'b0;
    end

    // 데이터 샘플링을 위해 카운트 값을 중간 위치로 설정(통신의 정확도를 높이기 위한 셋팅)
    wire collect;
    assign collect = (cnt == 15'd814) ? 1'b1 : 1'b0;

    // 데이터 수신 시 하강 에지 생성(통신이 시작됐다는 의미)
    reg [1:0] start_bit;
    always @(posedge clk or posedge reset_p) begin
        if(reset_p)	
            start_bit <= 2'b11;
        else begin
            start_bit[0] <= RX; // 블루투스 장치에서 통신을 시작하면 첫 bit는 Low로 주고 RX로 받게 된다.
            start_bit[1] <= start_bit[0];
        end
    end

    // 하강 에지 검출
    wire neg_edge;
    assign neg_edge = start_bit[1] & ~start_bit[0]; // start_bit[0] = 0, start_bit[1] = 1이면, 하강엣지 검출
    
//    reg [7:0] RX_before, RX_after;
//    reg [3:0] RX_count;
//    always @(posedge clk or posedge reset_p) begin
//        if(reset_p) begin
//            RX_count = 0;
//        end
//        else begin
//            RX_count = RX_count + 1;
//            case(RX_count)
//                0 : RX_after[0] = RX;
//                1 : RX_after[1] = RX;
//                2 : RX_after[2] = RX;
//                3 : RX_after[3] = RX;
//                4 : RX_after[4] = RX;
//                5 : RX_after[5] = RX;
//                6 : RX_after[6] = RX;
//                7 : RX_after[7] = RX;
//            endcase
//        end
//    end

    // UART 프로토콜 관련 신호 처리
    reg [3:0] num;
    reg rx_on; // 데이터 수신 중인 상태를 나타내는 신호
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin	
            start <= 1'b0;	
            rx_on <= 1'b0;
        end
        else if(neg_edge) begin // 하강엣지 검출되면, 통신이 시작되었다는 의미.
            start <= 1'b1; // 테이터 통신 시작
            rx_on <= 1'b1; // 수신 상태 중
        end
        else if(num == 4'd10) begin // 통신 종료
            start <= 1'b0;	
            rx_on <= 1'b0;
        end
    end

    // 데이터 저장
    reg [7:0] rx_data_temp_r;  // 현재 데이터 수신 레지스터
    reg [7:0] rx_data_r;       // 데이터 락 레지스터
    
    always @(posedge clk or posedge reset_p) begin
        if(reset_p)	begin	
            rx_data_r = 8'd0;
            rx_data_temp_r = 8'd0;
            num = 4'd0;
        end
        else if(rx_on) begin
            if(collect) begin
                num <= num + 1'b1;
                case(num)
                    4'd1: rx_data_temp_r[0] = RX;
                    4'd2: rx_data_temp_r[1] = RX;	
                    4'd3: rx_data_temp_r[2] = RX;	
                    4'd4: rx_data_temp_r[3] = RX;	
                    4'd5: rx_data_temp_r[4] = RX;
                    4'd6: rx_data_temp_r[5] = RX;	
                    4'd7: rx_data_temp_r[6] = RX;	
                    4'd8: rx_data_temp_r[7] = RX;	
                    default: ;
                endcase
            end
            else if(num == 4'd10) begin
                rx_data_r = rx_data_temp_r;
//                RX_before = rx_data_temp_r;
                num <= 4'd0;
            end
//            else if(num == 4'd11) begin
//                rx_data_temp_r <= 8'b0000_0000;
                
//            end
        end
    end

    // 데이터를 출력에 전달
    assign dx_data = rx_data_r;

//reg emcy_LED;
//// 비상 상태 신호 설정
//always @ (*)
//begin
//   if(dx_data != 8'b0011_0000 && dx_data != 8'b0)
//   begin
//       emcy_LED <= 1;
//   end
//   else
//   begin
//       emcy_LED <= 0;
//   end
//end    

endmodule






//module fan_bluetooth_top(
//    input clk,       // 125MHz 시스템 클럭
//    input reset_p,   // 리셋 신호
//    input RX,        // 블루투스에서 수신된 데이터 입력
////    output emcy_LED, // 비상 LED 출력
//    output reg [3:0] LED_bar, // LED 바 출력
//    output [3:0] com,
//    output [7:0] seg_7
//);

//// 블루투스 모듈 인스턴스화
//    bluetooth_rx bt(
//        .clk(clk),
//        .reset_p(reset_p),
//        .RX(RX),
////    .emcy_LED(emcy_LED),
//        .dx_data(dx_data)
//    );
//  wire [7:0] dx_data;
//    //reg [1:0] dx_data; // 블루투스 모듈에서 수신한 데이터

//    // LED 바 표시 로직
//    always @(posedge clk or posedge reset_p) begin
//        if (reset_p) begin
//            LED_bar <= 4'b0000;
//        end
//        else begin
//            case(dx_data)
//                8'd0 : LED_bar <= 4'b0001; // 숫자 0일 때 LED_bar[0] 켜기
//                8'd1 : LED_bar <= 4'b0010; // 숫자 1일 때 LED_bar[1] 켜기
//                8'd2 : LED_bar <= 4'b0100; // 숫자 2일 때 LED_bar[2] 켜기
//                8'd3 : LED_bar <= 4'b1000; // 숫자 3일 때 LED_bar[3] 켜기
//                default : LED_bar <= 4'b0000; // 그 외의 경우 모두 끄기
//            endcase
//        end
//    end

//    FND_4digit_cntr fnd_cntr(.clk(clk), .rst(reset_p), .value({8'b0000_0000, dx_data}), .com(com), .seg_7(seg_7));
//endmodule






module UART_RX
  #(parameter CLKS_PER_BIT = 13021)
  (
   input            reset_p,
   input            clk,
   input            Rx_Serial,
   output reg       Rx_DataValid,        //RX Data Valid for one cycle
   output reg [7:0] Rx_Byte
   );
   
  localparam IDLE         = 3'b000;
  localparam RX_START_BIT = 3'b001;
  localparam RX_DATA_BITS = 3'b010;
  localparam Rx_StopBit  = 3'b011;
  localparam CLEANUP      = 3'b100;
  
  reg [$clog2(CLKS_PER_BIT)-1:0] clock_count; 
  reg [2:0] bit_index; //8 bits total
  reg [2:0] state; 
  
  
  // Purpose: Control RX state machine
  always @(posedge clk or posedge reset_p)
  begin
    if (reset_p) begin
        state <= 3'b000;
        Rx_DataValid   <= 1'b0;
    end
    else begin
        case (state)
            IDLE : begin
                Rx_DataValid       <= 1'b0;
                clock_count <= 0;
                bit_index   <= 0;
                if (Rx_Serial == 1'b0)          // Start bit detected
                    state <= RX_START_BIT;
                else state <= IDLE;
            end
            // Check middle of start bit to make sure it's still low
            RX_START_BIT : begin
                if (clock_count == (CLKS_PER_BIT-1)/2) begin
                    if (Rx_Serial == 1'b0) begin
                        clock_count <= 0;  // reset counter, found the middle
                        state     <= RX_DATA_BITS;
                    end
                    else state <= IDLE;
                end
                else begin
                    clock_count <= clock_count + 1;
                    state     <= RX_START_BIT;
                end
            end // case: RX_START_BIT
            // Wait CLKS_PER_BIT-1 clock cycles to sample serial data
            RX_DATA_BITS : begin
                if (clock_count < CLKS_PER_BIT-1) begin
                    clock_count <= clock_count + 1;
                    state     <= RX_DATA_BITS;
                end
                else begin
                    clock_count          <= 0;
                    Rx_Byte[bit_index] <= Rx_Serial;
                    // Check if we have received all bits
                    if (bit_index < 7) begin
                        bit_index <= bit_index + 1;
                        state   <= RX_DATA_BITS;
                    end
                else begin
                    bit_index <= 0;
                    state   <= Rx_StopBit;
                end
            end
        end // case: RX_DATA_BITS
      
      // Receive Stop bit.  Stop bit = 1
      Rx_StopBit :
        begin
          // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
          if (clock_count < CLKS_PER_BIT-1)
          begin
            clock_count <= clock_count + 1;
            state     <= Rx_StopBit;
          end
          else
          begin
            Rx_DataValid       <= 1'b1;
            clock_count <= 0;
            state     <= CLEANUP;
          end
        end // case: Rx_StopBit
      
      
      // Stay here 1 clock
      CLEANUP :
        begin
          state <= IDLE;
          Rx_DataValid   <= 1'b0;
        end
      
      
      default :
        state <= IDLE;
      
    endcase
    end // else: !if(~reset_p)
  end // always @ (posedge clk or posedge reset_p)
  
endmodule // UART_RX







module UART_TX 
  #(parameter CLKS_PER_BIT = 13021)
  (
   input       reset_p,
   input       clk,
   input       Tx_DataValid,         //TX Data Valid for one cycle
   input [7:0] Tx_Byte, 
   output reg  Tx_Active,
   output reg  Tx_Serial,
   output reg  Tx_Done
   );
 
  localparam IDLE         = 3'b000;
  localparam TX_START_BIT = 3'b001;
  localparam TX_DATA_BITS = 3'b010;
  localparam TX_STOP_BIT  = 3'b011;
  localparam CLEANUP      = 3'b100;
  
  reg [2:0] state;
  reg [$clog2(CLKS_PER_BIT):0] clock_count;
  reg [2:0] bit_index;
  reg [7:0] Tx_Data;


  // Purpose: Control TX state machine
  always @(posedge clk or posedge reset_p)
  begin
    if (reset_p)
    begin
      state <= 3'b000;
      Tx_Done <= 1'b0;
    end
    else
    begin
      case (state)
      IDLE :
        begin
          Tx_Serial   <= 1'b1;         // Drive Line High for Idle
          Tx_Done     <= 1'b0;
          clock_count <= 0;
          bit_index   <= 0;
          
          if (Tx_DataValid == 1'b1)
          begin
            Tx_Active <= 1'b1;
            Tx_Data   <= Tx_Byte;
            state   <= TX_START_BIT;
          end
          else
            state <= IDLE;
        end // case: IDLE
      
      
      // Send out Start Bit. Start bit = 0
      TX_START_BIT :
        begin
          Tx_Serial <= 1'b0;
          
          // Wait CLKS_PER_BIT-1 clock cycles for start bit to finish
          if (clock_count < CLKS_PER_BIT-1)
          begin
            clock_count <= clock_count + 1;
            state     <= TX_START_BIT;
          end
          else
          begin
            clock_count <= 0;
            state     <= TX_DATA_BITS;
          end
        end // case: TX_START_BIT
      
      
      // Wait CLKS_PER_BIT-1 clock cycles for data bits to finish         
      TX_DATA_BITS :
        begin
          Tx_Serial <= Tx_Data[bit_index];
          
          if (clock_count < CLKS_PER_BIT-1)
          begin
            clock_count <= clock_count + 1;
            state     <= TX_DATA_BITS;
          end
          else
          begin
            clock_count <= 0;
            
            // Check if we have sent out all bits
            if (bit_index < 7)
            begin
              bit_index <= bit_index + 1;
              state   <= TX_DATA_BITS;
            end
            else
            begin
              bit_index <= 0;
              state   <= TX_STOP_BIT;
            end
          end 
        end // case: TX_DATA_BITS
      
      
      // Send out Stop bit.  Stop bit = 1
      TX_STOP_BIT :
        begin
          Tx_Serial <= 1'b1;
          
          // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
          if (clock_count < CLKS_PER_BIT-1)
          begin
            clock_count <= clock_count + 1;
            state     <= TX_STOP_BIT;
          end
          else
          begin
            Tx_Done     <= 1'b1;
            clock_count <= 0;
            state     <= CLEANUP;
            Tx_Active   <= 1'b0;
          end 
        end // case: TX_STOP_BIT
      
      
      // Stay here 1 clock
      CLEANUP :
        begin
          state <= IDLE;
        end
      
      
      default :
        state <= IDLE;
      
    endcase
    end // else: !if(~reset_p)
  end // always @ (posedge clk or posedge reset_p)

  
endmodule











module fan_bluetooth_top(
  input clk,           // 클럭 신호
  input reset_p,         // 리셋 신호
  input RX,     // UART 수신 핀 (Bluetooth 모듈에서 데이터 수신)
//  output TX,    // UART 송신 핀 (Bluetooth 모듈로 데이터 송신)
  output reg [5:0] blue_btn_l
//  output [7:0] rx_data
//  output led,           // LED 출력
//  output [3:0] com,
//  output [7:0] seg_7,
//  output reg [3:0] LED_bar
);

  wire Rx_DataValid;        // UART 수신 데이터 유효 여부
  wire [5:0] Rx_Byte;       // UART 수신 데이터
  
//  wire Tx_Active;           // UART 송신 동작 활성화 여부
//  wire Tx_Done;             // UART 송신 완료 여부
//  wire [7:0] Tx_Byte;       // UART 송신 데이터

//  // UART_RX 모듈 인스턴스화
//  UART_RX #(.CLKS_PER_BIT(13021)) rx_inst (
//    .reset_p(reset_p),
//    .clk(clk),
//    .Rx_Serial(RX),
//    .Rx_DataValid(Rx_DataValid),
//    .Rx_Byte(Rx_Byte)
//  );
  
  bluetooth_rx uart(
    .clk(clk),         // 클럭 입력
    .reset_p(reset_p),     // 리셋 신호 입력
    .RX(RX),          // 블루투스에서 수신된 데이터 입력
    .dx_data(Rx_Byte),  // 데이터 출력
    .start(start)
);

//  // UART_TX 모듈 인스턴스화
//  UART_TX #(.CLKS_PER_BIT(13021)) tx_inst (
//    .reset_p(reset_p),
//    .clk(clk),
//    .Tx_DataValid(1'b1),   // 항상 데이터 유효
//    .Tx_Byte(Tx_Byte),
//    .Tx_Active(Tx_Active),
//    .Tx_Done(Tx_Done),
//    .Tx_Serial(TX)
//  );

//  // LED 제어 로직
//  reg led_state = 1'b0; // LED 초기 상태 (끈 상태)
  
//  wire [5:0] blue_btn_l_buf;
////  wire [5:0] blue_btn_l;
//  assign blue_btn_l = blue_btn_l_buf;
  
//  assign blue_btn_l[0] = (Rx_Byte == 8'd48) ? 1 : 0;
//  assign blue_btn_l[1] = (Rx_Byte == 8'd49) ? 1 : 0;
//  assign blue_btn_l[2] = (Rx_Byte == 8'd50) ? 1 : 0;
//  assign blue_btn_l[3] = (Rx_Byte == 8'd51) ? 1 : 0;
//  assign blue_btn_l[4] = (Rx_Byte == 8'd52) ? 1 : 0;
//  assign blue_btn_l = (Rx_Byte == 8'd53) ? 6'b000_000 : 0;

//    parameter BAUDRATE = 15'd13021;
//    reg [15:0] count;
//    reg count_en;
//    always@(negedge clk or posedge reset_p) begin
//        if(reset_p) begin
//            count = 0;
//        end
//        else begin
//            if(clk && count_en) count = count + 1;
//            else if(!count_en) count = 0;
//        end
//    end
    
//    reg [3:0] state, next_state;
//    always@(negedge clk or posedge reset_p) begin
//        if(reset_p) begin
//            state = 0;
//        end
//        else begin
//            state = next_state;
//        end
//    end

    edge_detector_n edg(.clk(clk), .cp_in(start), .rst(reset_p), .n_edge(start_nedge));

    // 원인 : 블루투스로 한 번 입력을 하면, 그 입력이 계속 들어 와 있는 상태이다.
    // 따라서 0으로 초기화를 시켜줘도 다시 그 입력이 적용되어버림.
    // 그러면 입력을 초기화하는 방법을 적용보는 것이 좋을 것이다.
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) blue_btn_l = 6'b000_000;
        else if(start_nedge) begin
            if(Rx_Byte == 8'd48) blue_btn_l = 8'b000_001; // FND 0 0
            else if(Rx_Byte == 8'd49) blue_btn_l = 6'b000_010; // PWR 1 1
            else if(Rx_Byte == 8'd50) blue_btn_l = 6'b000_100; // Auto 2 2
            else if(Rx_Byte == 8'd51) blue_btn_l = 6'b001_000; // LED 3 3
            else if(Rx_Byte == 8'd52) blue_btn_l = 6'b010_000; // TIM 4 4
            else if(Rx_Byte == 8'd53) blue_btn_l = 6'b100_000; // 5
        end 
        else begin
            blue_btn_l = 6'b000_000;
        end
                        
//            else if(Rx_Byte == 8'd49) begin
//                if(count < 10) begin
//                    count_en = 1;
//                    blue_btn_l[0] = 1;
//                end
//                else begin
//                    count_en = 0;
//                    blue_btn_l = 6'b000_000;
//                end
//            end
//            else if(Rx_Byte == 8'd50) begin
//                if(count < 10) begin
//                    count_en = 1;
//                    blue_btn_l[1] = 1;
//                end
//                else begin
//                    count_en = 0;
//                    blue_btn_l = 6'b000_000;
//                end
//            end            
//            else if(Rx_Byte == 8'd51) begin 
//                if(count < 10) begin
//                    count_en = 1;
//                    blue_btn_l[2] = 1;
//                end
//                else begin
//                    count_en = 0;
//                    blue_btn_l = 6'b000_000;
//                end
//            end            
//            else if(Rx_Byte == 8'd52) begin
//                if(count < 10) begin
//                    count_en = 1;
//                    blue_btn_l[3] = 1;
//                end
//                else begin
//                    count_en = 0;
//                    blue_btn_l = 6'b000_000;
//                end
//            end            
//            else if(Rx_Byte == 8'd53) begin
//                if(count < 10) begin
//                    count_en = 1;
//                    blue_btn_l[4] = 1;
//                end
//                else begin
//                    count_en = 0;
//                    blue_btn_l = 6'b000_000;
//                end
//            end            
//            else blue_btn_l = 6'b000_000;
//        end
    end
    
  
//  always @(posedge clk or posedge reset_p) begin
//    if(reset_p) begin
//        blue_btn_l = 6'b000_000;
//    end
//    else begin
//            case(Rx_Byte)
//                5'h30 : begin
//                    blue_btn_l[0] = 1;
////                blue_btn_l_buf = 6'b000001;
//                end
//                5'h31 : begin
//                    blue_btn_l[1] = 1;
////                blue_btn_l_buf = 6'b000010;
//                end
//                8'h32 : begin
//                    blue_btn_l[2] = 1;
////                blue_btn_l_buf = 6'b000100;
//                end
//                5'h33 : begin
//                    blue_btn_l[3] = 1;
////                blue_btn_l_buf = 6'b001000;
//                end
//                5'h34 : begin
//                    blue_btn_l[4] = 1;
////                blue_btn_l_buf = 6'b010000;
//                end
//                5'h35 : begin
//                    blue_btn_l = 6'b000_000;
////                blue_btn_l_buf = 6'b100000;
//                end                                                            
//            endcase
//    end
//  end

endmodule


module bluetooth_tx(
  input clk, reset_p,
  input [7:0] data,
  output reg TX
);

    // 125,000,000 / 9,600 = 13,021 
    parameter BAUDRATE = 15'd13021; // 9600 BAUDRATE에 대한 1비트 전송에 필요한 카운트 값

    // 9600 BAUDRATE에 대한 카운트 값 계산
    reg start;
    reg [14:0] cnt;
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) cnt <= 15'd0;
        else if(cnt == BAUDRATE) cnt <= 15'd0; // 1비트 전송되면, 다시 카운트 0으로
        else if(start) cnt <= cnt + 1'b1; // 전송이 시작되면 카운트 시작
        else cnt <= 1'b0; // 전송 중이 아니면, 카운터는 0으로 대기
    end

    // 데이터 샘플링을 위해 카운트 값을 중간 위치로 설정(통신의 정확도를 높이기 위한 셋팅)
    wire collect;
    assign collect = (cnt == 15'd6516) ? 1'b1 : 1'b0;

    // 데이터 수신 시 하강 에지 생성(통신이 시작됐다는 의미)
    reg [1:0] start_bit;
    always @(posedge clk or posedge reset_p) begin
        if(reset_p)	
            start_bit <= 2'b11;
        else begin
            start_bit[0] <= TX; // 블루투스 장치에서 통신을 시작하면 첫 bit는 Low로 주고 RX로 받게 된다.
            start_bit[1] <= start_bit[0];
        end
    end

    // 하강 에지 검출
    wire neg_edge;
    assign neg_edge = start_bit[1] & ~start_bit[0]; // start_bit[0] = 0, start_bit[1] = 1이면, 하강엣지 검출

    // UART 프로토콜 관련 신호 처리
    reg [3:0] num;
    reg tx_on; // 데이터 수신 중인 상태를 나타내는 신호
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin	
            start <= 1'b0;	
            tx_on <= 1'b0;
        end
        else if(neg_edge) begin // 하강엣지 검출되면, 통신이 시작되었다는 의미.
            start <= 1'b1; // 테이터 통신 시작
            tx_on <= 1'b1; // 수신 상태 중
        end
        else if(num == 4'd10) begin // 통신 종료
            start <= 1'b0;	
            tx_on <= 1'b0;
        end
    end

    // 데이터 저장
    reg [7:0] tx_data_temp_t;  // 현재 데이터 수신 레지스터
    reg [7:0] tx_data_t;       // 데이터 락 레지스터
    always @(posedge clk or posedge reset_p) begin
        if(reset_p)	begin	
            tx_data_t <= 8'd0;
            tx_data_temp_t <= 8'd0;
            num <= 4'd0;
        end
        else if(tx_on) begin
            if(collect) begin
                num <= num + 1'b1;
                case(num)
                    4'd1: TX <= data[0];
                    4'd2: TX <= data[1];	
                    4'd3: TX <= data[2];	
                    4'd4: TX <= data[3];	
                    4'd5: TX <= data[4];
                    4'd6: TX <= data[5];	
                    4'd7: TX <= data[6];	
                    4'd8: TX <= data[7];	
                    default: ;
                endcase
            end
            else if(num == 4'd10) begin
                num <= 4'd0;
            end
        end
    end
endmodule