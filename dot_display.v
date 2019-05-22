module dot_display(freq, rst, dot_col, dot_row);
		
	input freq, rst;
	output [13:0] dot_col;
	output [9:0] dot_row;
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
			0: dot_col = rom1(cnt_row);
			1: dot_col = rom1(cnt_row);
			2: dot_col = rom1(cnt_row);
			3: dot_col = rom1(cnt_row);
			4: dot_col = rom1(cnt_row);
			5: dot_col = rom1(cnt_row);
			6: dot_col = rom1(cnt_row);
			7: dot_col = rom1(cnt_row);
			8: dot_col = rom1(cnt_row);
			9: dot_col = rom1(cnt_row);
		default: dot_col = 0;
		endcase
	end
	
	
function [13:0] rom1;
	input [3:0] addr_in;
	
	begin 
		case (addr_in)
			0: rom1 = 14'b00000000000000;
			1: rom1 = 14'b00000111111111;
			2: rom1 = 14'b00111111111111;
			3: rom1 = 14'b00111100000000;
			4: rom1 = 14'b11000000000000;
			5: rom1 = 14'b11000000000000;
			6: rom1 = 14'b01111000000000;
			7: rom1 = 14'b00111111111111;
			8: rom1 = 14'b00000111111111;
			9: rom1 = 14'b00000000000000;
		default: rom1 = 14'b00000000000000;
		endcase
	end
endfunction
			
endmodule		

