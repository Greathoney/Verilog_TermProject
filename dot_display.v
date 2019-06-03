
module dot_display(freq, rst, board, dot_col, dot_row);

	input freq;
	input rst;
	input [17:0] board;
	output [13:0] dot_col;
	output [9:0] dot_row;
	reg [17:0] board;
	reg [13:0] dot_col;
	reg [9:0] dot_row;
	reg [3:0] cnt_row, cnt_fra;
	reg [7:0] cnt_col;
	reg clk_col, clk_fra;
	reg clk;
	reg [14:0] count;

	always @ (posedge freq or posedge rst) begin
		if (rst) begin count <= 0; clk <= 1; end
		else if (count >= 12499) begin count <= 0; clk <= ~clk; end
		else count <= count + 1;
	end

	always @ (posedge clk or posedge rst) begin
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

	always @ (posedge clk_col or posedge rst) begin
		if (rst) begin
			cnt_col <= 0;
		end
		else begin
			if (cnt_col == 255) begin
				cnt_col <= cnt_col + 1;
				clk_fra <= 0;
			end
		end
	end

	always @ (posedge clk_fra or posedge rst) begin
		if (rst) cnt_fra <= 0;
		else begin
			if (cnt_fra == 9) cnt_fra <= 0;
			else cnt_fra <= cnt_fra + 1;
		end
	end

	always @ (cnt_fra) begin
		case (cnt_fra)
			0: dot_col = rom1(cnt_row+IsRight, board);
			1: dot_col = rom1(cnt_row, board);
			2: dot_col = rom1(cnt_row, board);
			3: dot_col = rom1(cnt_row, board);
			4: dot_col = rom1(cnt_row, board);
			5: dot_col = rom1(cnt_row, board);
			6: dot_col = rom1(cnt_row, board);
			7: dot_col = rom1(cnt_row, board);
			8: dot_col = rom1(cnt_row, board);
			9: dot_col = rom1(cnt_row, board);
		default: dot_col = 0;
		endcase
	end


    // 현재 행 위치와 board를 입력으로 받아
    // dot matrix display의 한 행의 값을 반환하는 함수
	function [13:0] rom1;
		input [3:0] row;
		input [17:0] board;
		reg [1:0] iter;

		begin
			iter = 2*(row/4);
			rom1 = {3'b000, fun(row, board[5-iter:4-iter]),
					1'b0, fun(row, board[11-iter:10-iter]),
					1'b0, fun(row, board[17-iter:16-iter])};
		end


		function [2:0] fun;
			input [3:0] row;
			input [1:0] boardElement;

			begin
				if (row % 4 == 1) begin
					case (boardElement)
						0: fun = 3'b000;
						1: fun = 3'b010;
						2: fun = 3'b101;
					endcase
				end
				else if (row % 4 == 3) fun = 3'b000;
				else begin
					case (boardElement)
						0: fun = 3'b000;
						1: fun = 3'b101;
						2: fun = 3'b010;
					endcase
				end
			end

		endfunction

	endfunction

endmodule
