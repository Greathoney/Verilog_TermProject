
module dot_display(clk, rst, board, dot_col, dot_row, IsRight);

	input clk;
	input rst;
	input [17:0] board;
	input IsRight;
	output [13:0] dot_col;
	output [9:0] dot_row;
	reg [17:0] board;
	reg [13:0] dot_col;
	reg [9:0] dot_row;
	reg [3:0] cnt_row, cnt_fra;
	reg [7:0] cnt_col;
	reg clk_col, clk_fra;
	reg clk4;
	reg [14:0] count;

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
		dot_col = rom1(cnt_row+IsRight, board);
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
				1: if (isCenter) fun = 3'b101; else fun = 3'b010;
				2: if (isCenter) fun = 3'b010; else fun = 3'b101;
				default: fun = 3'b000;
			endcase
		end

	endfunction

endmodule
