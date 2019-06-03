module gameState(clk, key_data, IsMain, IsRight, IsTurnO, board, seg_txt, seg_com, dot_col, dot_row);
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
    reg [18:0] board;
    reg clk1;

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

      //김명지 부분
  	always @(IsTurnO) begin
  		if (IsTurnO == 1)
  			//7-segment에 P2를 표시하게 된다.
  		else
  		  //7-segment에 P1을 표시하게 된다.


  	always @(posedge key_data) begin
        board[18 - 2 * key_data + IsTurnO] = 1;
  		endcase
  	end

  		always @(board) begin
  		//3목을 판별하는 알고리즘
  		//IsTurnO를 이용한다.

  		//승패가 나오면 그 데이터를 가지고 다른 모듈에서 출력
  		end
  endmodule
