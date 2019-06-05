module gameState(clk, key_data, IsMain, IsTurnO, board, seg_txt, seg_com, dot_col, dot_row, result);
//게임상태에서의 환경을 구축합니다.
//gameState에서 해야할 일
/*
1. key_data를 기반으로 board data를 수정할 수 있어야 함.
2. 순서진행상황에 따라 7-segment에 P1, P2를 띄워야 함.
*/

  input clk;
  input [3:0]key_data;
  input IsMain;
  inout IsTurnO;
  inout [18:0] board;
  inout [1:0] result;
  output [6:0] seg_txt;
  output [7:0] seg_com;
  output dot_col;
  output dot_row;
  reg [20:0] clk_count;
  reg [6:0] seg_txt;
  reg [7:0] seg_com;
  reg [3:0] sel_seg = 4'b0000;
  reg clk1;
  reg [17:0] board;
  reg result; // 00 : 진행중   01 : X승   10 : O승   11 : 무승부

  always @(posedge clk) begin // clk1 설계
    if (IsMain == 0 && result == 0) begin
      if (clk_count >= 24999) begin
        clk_count <= 0;
        clk1 <= 1;
      end
      else begin
        clk_count <= clk_count + 1;
        clk1 <= 0;
      end
    end
  end

  always @(posedge clk1) begin
    if(sel_seg == 1 && result == 0) sel_seg <= 0;  //승패가 갈리지 않았을 때 2글자만 띄우게 된다.
    else if (sel_seg == 4 && result == 3) sel_seg <= 0;  //무승부일때 4글자만 띄우게 된다.
    else if (sel_seg == 7 && result != 0) sel_seg <= 0; //승패가 갈릴때 8글자 모두 쓰게 된다.
    else sel_seg <= sel_seg + 1;
  end

  always @(sel_seg) begin
    if(IsMain==0 && result == 0)begin
      if (IsTurnO == 1) begin
        //7-segment에 P2를 표시하게 된다.
        case(sel_seg)
          0: begin seg_com <= 8'b01111111; seg_txt <= 7'b1110011; end //P => abefg
          1: begin seg_com <= 8'b10111111; seg_txt <= 7'b1011011; end //2 => abdeg
          endcase
        end

      else begin
        //7-segment에 P1을 표시하게 된다.
        case(sel_seg)
          0: begin seg_com <= 8'b01111111; seg_txt <= 7'b1110011; end //P => abefg
          1: begin seg_com <= 8'b10111111; seg_txt <= 7'b0000110; end //1 => bc
          endcase
        end
      end

    if (result == 1) begin
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

    else if (result == 2) begin
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

    else if (result == 3) begin
      case(sel_seg)
        0: begin seg_com <= 8'b01111111; seg_txt <= 7'b1111000; end // t => defg
        1: begin seg_com <= 8'b10111111; seg_txt <= 7'b0110000; end // i => ef 
        2: begin seg_com <= 8'b11011111; seg_txt <= 7'b1111001; end // E => adefg
        //3: begin end // => 
      endcase
    end
	end

  // key data를 board로
	always @(posedge key_data) begin
	    case (key_data)
		    1: if(IsTurnO) board[17] = 1; else board[16] = 1;
		    2: if(IsTurnO) board[15] = 1; else board[14] = 1;
		    3: if(IsTurnO) board[13] = 1; else board[12] = 1;
		    4: if(IsTurnO) board[11] = 1; else board[10] = 1;
		    5: if(IsTurnO) board[9] = 1; else board[8] = 1;
		    6: if(IsTurnO) board[7] = 1; else board[6] = 1;
		    7: if(IsTurnO) board[5] = 1; else board[4] = 1;
		    8: if(IsTurnO) board[3] = 1; else board[2] = 1;
		    9: if(IsTurnO) board[1] = 1; else board[0] = 1;
		    // board[18 - 2 * key_data + IsTurnO] = 1;
		endcase
	end

	always @(board) begin
		//3목을 판별하는 알고리즘
		//IsTurnO를 이용한다.
	    if (IsTurnO) begin
	      // X의 삼목 판별
	      if (board[16] && board[14] && board[12]) result = 2'b01;
	      else if (board[10] && board[8] && board[6]) result = 2'b01;
	      else if (board[4] && board[2] && board[0]) result = 2'b01;

	      else if (board[16] && board[10] && board[4]) result = 2'b01;
	      else if (board[14] && board[8] && board[2]) result = 2'b01;
	      else if (board[12] && board[6] && board[0]) result = 2'b01;

	      else if (board[16] && board[8] && board[0]) result = 2'b01;
	      else if (board[12] && board[8] && board[4]) result = 2'b01;
	    end
	    else begin
	      // O의 삼목 판별
	      if (board[17] && board[15] && board[13]) result = 2'b10;
	      else if (board[11] && board[9] && board[7]) result = 2'b10;
	      else if (board[5] && board[3] && board[1]) result = 2'b10;

	      else if (board[17] && board[11] && board[5]) result = 2'b10;
	      else if (board[15] && board[9] && board[3]) result = 2'b10;
	      else if (board[13] && board[7] && board[1]) result = 2'b10;

	      else if (board[17] && board[9] && board[1]) result = 2'b10;
	      else if (board[13] && board[9] && board[5]) result = 2'b10;
	    end

	    // board가 꽉 채워졌는지 판별
	    if ((board[17]|board[16]) & (board[15]|board[14]) & (board[13]|board[12]) &
	      (board[11]|board[10]) & (board[9]|board[8]) & (board[7]|board[6]) &
	      (board[5]|board[4]) & (board[3]|board[2]) & (board[1]|board[0]))
	      begin
	        result = 2'b11;
	      end

	    else begin result = 2'b00; end
		//승패가 나오면 그 데이터를 가지고 다른 모듈에서 출력
	end
endmodule
