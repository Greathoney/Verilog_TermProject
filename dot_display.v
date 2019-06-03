
module dot_display(freq, rst, board, dot_col, dot_row, IsRight);

	input freq;
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
	reg clk;
	reg [14:0] count;

	// 25MHz �� Entry II�� Ŭ���� 1KHz�� Ŭ������ �����Ѵ�.
	always @ (posedge freq or posedge rst) begin
		if (rst) begin count <= 0; clk <= 1; end
		else if (count >= 12499) begin count <= 0; clk <= ~clk; end
		else count <= count + 1;
	end

	// Ŭ�Ͽ� �����Ͽ� cnt_row�� ī��Ʈ�Ͽ� 11���� row ��ĵ ��ȣ�� �����.
	// row ��ĵ�� ���� ������ �ѹ��� clk_col ��ȣ�� �����Ѵ�.
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

	// clk_col�� �����Ͽ� cnt_col�� 0~13���� ī��Ʈ
	// ī��Ʈ�� ���� ������ �� ���� clk_fra ��ȣ ����
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

	// clk_fra�� �����Ͽ� cnt_fra�� ī��Ʈ
	always @ (posedge clk_fra or posedge rst) begin
		if (rst) cnt_fra <= 0;
		else begin
			if (cnt_fra == 9) cnt <= 0;
			else cnt_fra <= cnt_fra + 1;
		end
	end

	// cnt_row+IsRight, cnt_fra�� �ּҷ� �ϴ� ���� �����͸� dot_col�� ���
	always @ (cnt_fra) begin
		dot_col = rom1(cnt_row+IsRight, board);
	end

    // ���� �� ��ġ�� board�� �Է����� �޾�
    // dot matrix display�� �� ���� ���� ��ȯ�ϴ� �Լ�
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
