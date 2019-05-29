module TTT(clk, rst, key_row, key_col, seg_txt, seg_com, dot_col, dot_row);
	output [2:0]key_col; //keypad 스캔
	output [6:0]seg_txt; //7-segment 한 자리에 대해 문자 표현
  output [7:0]seg_com; //7-segment 위치 결정
  output [13:0] dot_col; //dot maxtrix 정보
  output [9:0] dot_row; //dot maxtrix 정보
  input clk;
	input rst; //클럭, 리셋
  input	[3:0]key_row; //keypad 스캔

  reg [11:0]key_data; //key_row, key_col을 바탕으로 값 결정
  reg IsItMain = 1; //초기상태(1)인지, 게임상태(0)인지 표현
  reg IsItRight = 0; //보드판이 오른쪽으로 갔는지(1) 아닌지(0) 확인
  reg IsTurnO = 0; //O의 차례인지(1) X의 차례인지(0) 확인
  reg [1:0]board[8:0]; //보드에 어떤 돌이 놓여있는지 확인 0: 없음, 1: X돌, 2: O돌

  keypad_scan U0(clk, rst, key_col, key_row, key_data); //키패드 스캔하기
  mainState U1(clk, key_data, IsItMain, seg_txt, seg_com);//main상태에서 입력을 받는 모듈

  //더 많은 것들...

endmodule

module keypad_scan(clk, rst, key_col, key_row, key_data);
	input 	clk, rst;
	input	[3:0] 	key_row;
	output	[2:0]	key_col;
	output	[11:0]	key_data;
	reg	[11:0]	key_data = 12'b000000000000;
	reg	[2:0]	state;
	reg [13:0]  counts;
	reg clk1;
	wire	key_stop;
	// define state of FSM
	parameter no_scan = 3'b000;
	parameter column1 = 3'b001;
	parameter column2 = 3'b010;
	parameter column3 = 3'b100;

	assign key_stop = key_row[0] | key_row[1] | key_row[2] | key_row[3] ;
	assign key_col = state;

	always @(posedge clk or posedge rst)  begin
	  	if(rst) begin counts <= 0; clk1 <= 1; end
		else if (counts >= 12499) begin counts <= 0; clk1 <= !clk1; end
		else counts <= counts +1; end

	// FSM drive
	always @(posedge clk1 or posedge rst)
	begin
		if (rst) state <= no_scan;
		else begin
		  if (!key_stop) begin
		    case (state)
		    no_scan : state <= column1;
		    column1 : state <= column2;
		    column2 : state <= column3;
		    column3 : state <= column1;
		    default : state <= no_scan;
		    endcase
		  end
		end
	end
	// key_data
	always @ (posedge clk1) begin
	case (state)
	  column1 : case (key_row)
	  	4'b0001 : key_data <= 12'b0000_0000_0001; // key_1
	  	4'b0010 : key_data <= 12'b0000_0000_1000; // key_4
	  	4'b0100 : key_data <= 12'b0000_0100_0000; // key_7
	  	4'b1000 : key_data <= 12'b0010_0000_0000; // key_*
	  	default : key_data <= 12'b0000_0000_0000;
	  	endcase
	  column2 : case (key_row)
	  	4'b0001 : key_data <= 12'b0000_0000_0010; // key_2
	  	4'b0010 : key_data <= 12'b0000_0001_0000; // key_5
	  	4'b0100 : key_data <= 12'b0000_1000_0000; // key_8
	  	4'b1000 : key_data <= 12'b0100_0000_0000; // key_0
	  	default : key_data <= 12'b000000000000;
	  	endcase
	  column3 : case (key_row)
	  	4'b0001 : key_data <= 12'b0000_0000_0100; // key_3
	  	4'b0010 : key_data <= 12'b0000_0010_0000; // key_6
	  	4'b0100 : key_data <= 12'b0001_0000_0000; // key_9
	  	4'b1000 : key_data <= 12'b1000_0000_0000; // key_#
	  	default : key_data <= 12'b000000000000;
	  	endcase
	  default : key_data <= 12'b0000_0000_0000;
	endcase
	end
endmodule

module mainState(clk, key_data, IsItMain, seg_txt, seg_com);
  input [11:0] key_data;
	input clk;
  inout IsItMain;
  output [6:0] seg_txt;
  output [7:0] seg_com;
  reg [26:0]clk_count;
	reg [7:0]seg_com;
	reg [6:0] seg_txt;
	reg IsItMain;
  reg [3:0] sel_seg = 4'b0000;
  reg clk1;


  always @(posedge clk) begin // clk1 설계
		if (IsItMain == 1) begin
	    	if (clk_count == 25000) begin
	      	clk_count <= 0;
	      	clk1 <= 1;
	    	end
	    	else begin
	      	clk_count <= clk_count + 1;
	      	clk1 <= 0;
	    	end
			end
  	end

		always @(clk1) begin  //키 1번이 입력되면 Main이 풀리게 설계
			if (IsItMain == 1)
				if (0 == 1)
	    		IsItMain <= 0;
	  end

  always @(posedge clk1) begin //clk1을 기반으로 sel_sag 설계
		if (IsItMain == 1) begin
    	if (sel_seg == 7) sel_seg <= 0;
    		else sel_seg <= sel_seg + 1;
			end
		end

  always @(sel_seg) //sel_sag을 기반으로 7-segment에 표시
		if (IsItMain == 1) begin
	    case(sel_seg)
	      0: begin seg_com <= 8'b01111111; seg_txt <= 7'b1110011; end //p =>abefg
	      1: begin seg_com <= 8'b10111111; seg_txt <= 7'b1010000; end //r =>eg
	      2: begin seg_com <= 8'b11011111; seg_txt <= 7'b1111001; end //e =>adefg
	      3: begin seg_com <= 8'b11101111; seg_txt <= 7'b1101101; end //s =>acdfg
	      4: begin seg_com <= 8'b11110111; seg_txt <= 7'b1101101; end //s =>acdfg
	      5: begin seg_com <= 8'b11111011; seg_txt <= 7'b0000000; end //' '
	      6: begin seg_com <= 8'b11111101; seg_txt <= 7'b0111111; end //0 =>abcdef
	      7: begin seg_com <= 8'b11111110; seg_txt <= 7'b0000110; end //1 =>bc
			endcase
		end
endmodule
