module TTT(clk, rst, key_row, key_col)
  input clk, rst;
  input	[3:0]key_row;
	output [2:0]key_col;
  reg [11:0]key_data;
  reg IsItMain, IsItRight;
  reg [2:0]board[3][3];
  reg dot_matrix[14][10];


endmodule
