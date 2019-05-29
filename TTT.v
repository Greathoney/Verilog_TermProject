module TTT(clk, rst, [3:0]key_row, [2:0]key_col, [6:0]seg_dec, [7:0]seg_com)
  input clk, rst; //클럭, 리셋
  input	[3:0]key_row; //keypad 스캔
	output [2:0]key_col; //keypad 스캔
  output [6:0]seg_dec; //7-segment 한 자리에 대해 수 표현
  output [7:0]seg_com; //7-segment 위치 결정

  reg [11:0]key_data; //key_row, key_col을 바탕으로 값 결정
  reg IsItMain; //초기상태(1)인지, 게임상태(0)인지 표현
  reg IsItRight; //보드판이 오른쪽으로 갔는지(1) 아닌지(0) 확인
  reg IsTurnO; //O의 차례인지(1) X의 차례인지(0) 확인
  reg [1:0]board[3][3]; //보드에 어떤 돌이 놓여있는지 확인 0: 없음, 1: X돌, 2: O돌
  reg dot_matrix[14][10]; //매트릭스에 어떤 값을 띄울 것인지 확인

  keypad_scan U0(clk, rst, key_col, key_row, key_data); //키패트드 스캔하기
  dot_display U1(clk, rst, dot_col, dot_row); //dot_display 띄우기
  //더 많은 것들...

endmodule
