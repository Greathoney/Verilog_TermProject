module gameState(clk, key_data, IsMain, IsRight, IsTurnO, board, seg_txt, seg_com, dot_col, dot_row, result);
//게임상태에서의 환경을 구축합니다.
//gameState에서 해야할 일
/*
1. key_data를 기반으로 board data를 수정할 수 있어야 함.
2. 순서진행상황에 따라 7-segment에 P1, P2를 띄워야 함.
*/

  	input clk;
  	input [3:0]key_data;
  	input IsMain;
  	inout IsRight;
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
  		if (IsMain == 1) begin
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
		if(sel_seg == 1) sel_seg <= 0;
		else sel_seg <= sel_seg + 1;
	end

  	always @(IsTurnO) begin
  		if (IsTurnO == 1) begin
  			//7-segment에 P2를 표시하게 된다.
			case(sel_seg)
				0: begin seg_com <= 8'b01111111; seg_txt <= 7'b1110011; end //P => abefg
				1: begin seg_com <= 8'b10111111; seg_txt <= 7'b1101101; end //2 => abdeg
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


	always @(posedge key_data) begin
      board[18 - 2 * key_data + IsTurnO] = 1;
	end

	always @(board) begin
	//3목을 판별하는 알고리즘
	//IsTurnO를 이용한다.
    if (isTurnO) begin
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

    else begin result = 2'b00; end;

	//승패가 나오면 그 데이터를 가지고 다른 모듈에서 출력
	end
endmodule
