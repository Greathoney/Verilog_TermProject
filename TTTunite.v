module TTT(IsMain_dip, keydata_1, clk, rst, key_row, key_col, seg_txt, seg_com, dot_col, dot_row, check_IsMain, check_notIsMain, check_keypad, check_result);
	input clk, rst; //클럭, 리셋
	input [3:0]key_row; //keypad 스캔
	output [2:0]key_col; //keypad 스캔
	output [6:0]seg_txt; //7-segment 한 자리에 대해 문자 표현
	output [7:0]seg_com; //7-segment 위치 결정
	output [13:0] dot_col; //dot maxtrix 정보
	output [9:0] dot_row; //dot maxtrix 정보
	output check_IsMain;
	output check_notIsMain;
	output keydata_1;
	output check_keypad;
	output [1:0] check_result;
	reg check_keypad;
	reg keydata_1;
	input IsMain_dip;

	reg [3:0]key_data; //key_row, key_col을 바탕으로 값 결정
	integer IsMain = 1; //초기상태(1)인지, 게임상태(0)인지 표현, 1로 초기화
	reg IsRight = 0; //보드판이 오른쪽으로 갔는지(1) 아닌지(0) 확인, 0으로 초기화
	reg IsTurnO = 0; //O의 차례인지(1) X의 차례인지(0) 확인, 0으로 초기화
	reg [17:0] board = 18'b00_00_00_00_00_00_00_00_00; //보드에 어떤 돌이 놓여있는지 확인 0: 없음, 1: X돌, 2: O돌
	reg check_IsMain, check_notIsMain;
	reg [1:0] check_result;

	//keypad_scan
	reg	[2:0] state;
	reg [13:0] counts;
	reg clk1;
	wire key_stop;

	parameter no_scan = 3'b000;
	parameter column1 = 3'b001;
	parameter column2 = 3'b010;
	parameter column3 = 3'b100;

	//mainstate
	reg [20:0]clk_count;
	reg [20:0]clk_count2;
	reg [7:0] seg_com;
	reg [6:0] seg_txt;
	reg [3:0] sel_seg;
	reg clk2;

	//gamestate
    reg [1:0] result; // 00 : 진행중   01 : X승   10 : O승   11 : 무승부

	//dot_display
	reg [13:0] dot_col;
	reg [9:0] dot_row;
	reg [3:0] cnt_row, cnt_fra;
	reg [7:0] cnt_col;
	reg clk_col, clk_fra;
	reg clk4;
	reg [14:0] count;

	always @(posedge clk) begin
		if (IsMain == 1) begin check_IsMain <= 1; check_notIsMain <= 0; end
		else if (IsMain == 0) begin check_IsMain <= 0; check_notIsMain <= 1; end

		if (key_data == 1) keydata_1 <= 1;
		else keydata_1 <= 0;

		if(key_data == 4) check_keypad <= 1;
		else check_keypad <= 0;

		check_result = result;

	end




	//Module keypad_scan
	//키패드 스캔하기, key_data를 받아옴
	//누르지 않을때는 key_data <= 12'b0000_0000_0000 누르는 동안 어느 숫자가 1로 변함
	// define state of FSM

	assign key_stop = key_row[0] | key_row[1] | key_row[2] | key_row[3] ;
	assign key_col = state;

	always @(posedge clk or posedge rst) begin
		if(rst) begin counts <= 0; clk1 <= 1; end
		else if (counts >= 12499) begin counts <= 0; clk1 <= !clk1; end
		else counts <= counts +1;
	end

	// FSM drive
	always @(posedge clk1 or posedge rst) begin
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
	always @ (posedge rst or posedge clk1) begin
		// if (rst) IsRight <= 0;
		case (state)
			column1 : case (key_row)
				4'b0001 : key_data <= 1; // key_1
				4'b0010 : key_data <= 4; // key_4
				4'b0100 : key_data <= 7; // key_7
				4'b1000 : IsRight <= 0; // key_*
			endcase
			column2 : case (key_row)
				4'b0001 : key_data <= 2; // key_2
				4'b0010 : key_data <= 5; // key_5
				4'b0100 : key_data <= 8; // key_8
				4'b1000 : key_data <= 0; // key_0 : 아무일 안함
			endcase
		  column3 : case (key_row)
				4'b0001 : key_data <= 3; // key_3
				4'b0010 : key_data <= 6; // key_6
				4'b0100 : key_data <= 9; // key_9
				4'b1000 : IsRight <= 1; // key_#
			endcase
			//default : key_data <= 0;
		endcase
	end



	//Module MainState
	//main(=1)상태에서 입력도 받고 출력도 하는 모듈
	//main == 0 이면 필요없어진다

	always @(posedge clk) begin // clk2 설계
		if (1 == 1) begin
			if (clk_count2 >= 24999) begin
				clk_count2 <= 0;
				clk2 <= 1;
			end
			else begin
				clk_count2 <= clk_count2 + 1;
				clk2 <= 0;
			end
		end
		else if (1==1) begin
			if (clk_count >= 24999) begin
				clk_count <= 0;
				clk2 <= 1;
			end
			else begin
				clk_count <= clk_count + 1;
				clk2 <= 0;
			end
		end
	end

	always @(clk) begin  //키 1번이 입력되면 Main이 풀리고 게임모드로 진입하도록 설계
		if (IsMain_dip)
		IsMain <= 1;
		else if (IsMain_dip == 0)
		IsMain <= 0;
	end


	//main(=0)상태가 아닌 게임상태에서 입력도 받고 출력도 하는 모듈

  always @(posedge clk2) begin
	if (sel_seg == 7) sel_seg <= 0;
		else sel_seg <= sel_seg + 1;
	end

  always @(sel_seg) begin
	if (IsMain == 1) begin // sel_seg 합침
		case(sel_seg)
			0: begin seg_com <= 8'b01111111; seg_txt <= 7'b1110011; end //p =>abefg
			1: begin seg_com <= 8'b10111111; seg_txt <= 7'b1010000; end //r =>eg
			2: begin seg_com <= 8'b11011111; seg_txt <= 7'b1111001; end //e =>adefg
			3: begin seg_com <= 8'b11101111; seg_txt <= 7'b1101101; end //s =>acdfg
			4: begin seg_com <= 8'b11110111; seg_txt <= 7'b1101101; end //s =>acdfg
			5: begin seg_com <= 8'b11111011; seg_txt <= 7'b0000000; end //' '
			6: begin seg_com <= 8'b11111101; seg_txt <= 7'b0111110; end //u =>bcdef
			7: begin seg_com <= 8'b11111110; seg_txt <= 7'b1110011; end //p =>abefg
		endcase
	end

    else begin //IsMain == 0;
	  case (result)
	    0: begin
          if (IsTurnO == 1) begin
            //7-segment에 P2를 표시하게 된다.
            case(sel_seg)
              0: begin seg_com <= 8'b01111111; seg_txt <= 7'b1110011; end //P => abefg
              1: begin seg_com <= 8'b10111111; seg_txt <= 7'b1011011; end //2 => abdeg
							default: begin seg_com <= 8'b11111111; end
            endcase
          end

          else begin
            //7-segment에 P1을 표시하게 된다.
            case(sel_seg)
              0: begin seg_com <= 8'b01111111; seg_txt <= 7'b1110011; end //P => abefg
              1: begin seg_com <= 8'b10111111; seg_txt <= 7'b0000110; end //1 => bc
													default: begin seg_com <= 8'b11111111; end
            endcase
          end
		end
		1: begin
          case(sel_seg)
	        //P2 lose segment를 띄우게 된다.
	          0: begin seg_com <= 8'b01111111; seg_txt <= 7'b1110011; end //p =>abefg
	          1: begin seg_com <= 8'b10111111; seg_txt <= 7'b1011011; end //2 => ABDEG
	          2: begin seg_com <= 8'b11011111; seg_txt <= 7'b0000000; end //' '
	          3: begin seg_com <= 8'b11101111; seg_txt <= 7'b0000000; end //' '
	          4: begin seg_com <= 8'b11110111; seg_txt <= 7'b0111000; end //L => def
	          5: begin seg_com <= 8'b11111011; seg_txt <= 7'b0111111; end //O => abcdef
	          6: begin seg_com <= 8'b11111101; seg_txt <= 7'b1101101; end //s =>acdfg
	          7: begin seg_com <= 8'b11111110; seg_txt <= 7'b1111001; end //E => adefg
          endcase
        end

        2: begin
          case(sel_seg)
	        //P1 lose를 7segment로 띄우게 된다.
            0: begin seg_com <= 8'b01111111; seg_txt <= 7'b1110011; end //p =>abefg
            1: begin seg_com <= 8'b10111111; seg_txt <= 7'b0000110; end //1 => bc
            2: begin seg_com <= 8'b11011111; seg_txt <= 7'b0000000; end //' '
            3: begin seg_com <= 8'b11101111; seg_txt <= 7'b0000000; end //' '
            4: begin seg_com <= 8'b11110111; seg_txt <= 7'b0111000; end //L => def
            5: begin seg_com <= 8'b11111011; seg_txt <= 7'b0111111; end //O => abcdef
            6: begin seg_com <= 8'b11111101; seg_txt <= 7'b1101101; end //s =>acdfg
            7: begin seg_com <= 8'b11111110; seg_txt <= 7'b1111001; end //E => adefg
            endcase
        end

        3: begin
          case(sel_seg)
            0: begin seg_com <= 8'b01111111; seg_txt <= 7'b1111000; end // t => defg
            1: begin seg_com <= 8'b10111111; seg_txt <= 7'b0110000; end // i => ef
            2: begin seg_com <= 8'b11011111; seg_txt <= 7'b1111001; end //E => adefg
													default: begin seg_com <= 8'b11111111; end
          endcase
        end
      endcase
    end
  end
  // key data를 board로
	always @(posedge clk2 or posedge rst) begin
		if (rst) board <= 0;
		else if (IsMain_dip == 0 ) begin
		    case (key_data)
			    1: if (board[17:16]==0) begin if(IsTurnO) board[17] <= 1; else board[16] <= 1; end
			    2: if (board[15:14]==0) begin if(IsTurnO) board[15] <= 1; else board[14] <= 1; end
			    3: if (board[13:12]==0) begin if(IsTurnO) board[13] <= 1; else board[12] <= 1; end
			    4: if (board[11:10]==0) begin if(IsTurnO) board[11] <= 1; else board[10] <= 1; end
			    5: if (board[9:8]==0) begin if(IsTurnO) board[9] <= 1; else board[8] <= 1; end
			    6: if (board[7:6]==0) begin if(IsTurnO) board[7] <= 1; else board[6] <= 1; end
			    7: if (board[5:4]==0) begin if(IsTurnO) board[5] <= 1; else board[4] <= 1; end
			    8: if (board[3:2]==0) begin if(IsTurnO) board[3] <= 1; else board[2] <= 1; end
			    9: if (board[1:0]==0) begin if(IsTurnO) board[1] <= 1; else board[0] <= 1; end
				0: if (IsTurnO) IsTurnO = 0; else IsTurnO = 1;
			    // board[18 - 2 * key_data + IsTurnO] <= 1;
			endcase
		end
	end


	always @(posedge clk2) begin  //이거 외않돼
		//3목을 판별하는 알고리즘
		//IsTurnO를 이용한다.
	      // X의 삼목 판별
	      if (board[16] & board[14] & board[12]) result <= 2'b01;
	      else if (board[10] & board[8] & board[6]) result <= 2'b01;
	      else if (board[4] & board[2] & board[0]) result <= 2'b01;

	      else if (board[16] & board[10] & board[4]) result <= 2'b01;
	      else if (board[14] & board[8] & board[2]) result <= 2'b01;
	      else if (board[12] & board[6] & board[0]) result <= 2'b01;

	      else if (board[16] & board[8] & board[0]) result <= 2'b01;
	      else if (board[12] & board[8] & board[4]) result <= 2'b01;
	      // O의 삼목 판별
	      else if (board[17] & board[15] & board[13]) result <= 2'b10;
	      else if (board[11] & board[9] & board[7]) result <= 2'b10;
	      else if (board[5] & board[3] & board[1]) result <= 2'b10;

	      else if (board[17] & board[11] & board[5]) result <= 2'b10;
	      else if (board[15] & board[9] & board[3]) result <= 2'b10;
	      else if (board[13] & board[7] & board[1]) result <= 2'b10;

	      else if (board[17] & board[9] & board[1]) result <= 2'b10;
	      else if (board[13] & board[9] & board[5]) result <= 2'b10;


	    // board가 꽉 채워졌는지 판별
	    else if ((board[17]|board[16]) & (board[15]|board[14]) & (board[13]|board[12]) &
	      (board[11]|board[10]) & (board[9]|board[8]) & (board[7]|board[6]) &
	      (board[5]|board[4]) & (board[3]|board[2]) & (board[1]|board[0]))
	      begin
	        result <= 2'b11;
	      end

	    else begin result <= 2'b00; end

		//IsTurnO <= ~IsTurnO;
		//승패가 나오면 그 데이터를 가지고 다른 모듈에서 출력
	end




	//board 데이터를 바탕으로 dot display에 띄울 수 있게 합니다.

	// 25MHz 인 Entry II의 클록을 1KHz의 클록으로 분주한다.
	always @ (posedge clk or posedge rst) begin
		if (rst) begin count <= 0; clk4 <= 1; end
		else if (count >= 12499) begin count <= 0; clk4 <= ~clk4; end
		else count <= count + 1;
	end

	// 클록에 동기하여 cnt_row를 카운트하여 11개의 row 스캔 신호를 만든다.
	// row 스캔이 끝날 때마다 한번의 clk_col 신호를 생성한다.
	always @ (posedge clk4 or posedge rst) begin
		if (rst) begin
			dot_row <= 1;
			cnt_row <= 0;
			clk_col <= 0;
		end
		else begin
			if (cnt_row==9 || dot_row==512) begin
				dot_row <= 1;
				cnt_row <= 0;
				clk_col <= 1;
			end
			else begin
				dot_row <= dot_row << 1;
				cnt_row <= cnt_row + 1;
				clk_col <= 0;
			end
		end
	end

	// clk_col에 동기하여 cnt_col을 0~13까지 카운트
	// 카운트가 끝날 때마다 한 번의 clk_fra 신호 생성
	always @ (posedge clk_col or posedge rst) begin
		if (rst) begin
			cnt_col <= 0;
		end
		else begin
			if (cnt_col == 255) begin
				cnt_col <= 0;
				clk_fra <= 1;
			end
			else begin
				cnt_col <= cnt_col + 1;
				clk_fra <= 0;
			end
		end
	end

	// clk_fra에 동기하여 cnt_fra를 카운트
	always @ (posedge clk_fra or posedge rst) begin
		if (rst) cnt_fra <= 0;
		else begin
			if (cnt_fra == 9) cnt_fra <= 0;
			else cnt_fra <= cnt_fra + 1;
		end
	end

	// cnt_row+IsRight, cnt_fra를 주소로 하는 롬의 데이터를 dot_col로 출력
	always @ (cnt_fra) begin
		dot_col <= rom1(cnt_row+IsRight, board);
	end

    // 현재 행 위치와 board를 입력으로 받아
    // dot matrix display의 한 행의 값을 반환하는 함수
	function [13:0] rom1;
		input [3:0] row;
		input [17:0] board;

		begin
			case (row)
				0: rom1 = {3'b000, fun(0, board[5:4]), 1'b0, fun(0, board[11:10]), 1'b0, fun(0, board[17:16])};
				1: rom1 = {3'b000, fun(1, board[5:4]), 1'b0, fun(1, board[11:10]), 1'b0, fun(1, board[17:16])};
				2: rom1 = {3'b000, fun(0, board[5:4]), 1'b0, fun(0, board[11:10]), 1'b0, fun(0, board[17:16])};
				3: rom1 = 14'b00000000000000;
				4: rom1 = {3'b000, fun(0, board[3:2]), 1'b0, fun(0, board[9:8]), 1'b0, fun(0, board[15:14])};
				5: rom1 = {3'b000, fun(1, board[3:2]), 1'b0, fun(1, board[9:8]), 1'b0, fun(1, board[15:14])};
				6: rom1 = {3'b000, fun(0, board[3:2]), 1'b0, fun(0, board[9:8]), 1'b0, fun(0, board[15:14])};
				7: rom1 = 14'b00000000000000;
				8: rom1 = {3'b000, fun(0, board[1:0]), 1'b0, fun(0, board[7:6]), 1'b0, fun(0, board[13:12])};
				9: rom1 = {3'b000, fun(1, board[1:0]), 1'b0, fun(1, board[7:6]), 1'b0, fun(1, board[13:12])};
				10: rom1 = {3'b000, fun(0, board[1:0]), 1'b0, fun(0, board[7:6]), 1'b0, fun(0, board[13:12])};
				default: rom1 = 14'b00000000000000;

			endcase
		end

	endfunction


	function [2:0] fun;
		input isCenter;
		input [1:0] boardElement;

		begin
			case (boardElement)
				0: fun = 3'b000;
				1: if (isCenter) fun = 3'b010; else fun = 3'b101;	// X
				2: if (isCenter) fun = 3'b101; else fun = 3'b111;	// O
				default: fun = 3'b111;
			endcase
		end

	endfunction
endmodule
