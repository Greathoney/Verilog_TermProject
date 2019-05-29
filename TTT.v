module TTT(clk, rst, key_row, key_col, seg_txt, seg_com)
  input clk, rst; //클럭, 리셋
  input	[3:0]key_row; //keypad 스캔
	output [2:0]key_col; //keypad 스캔
	output [6:0]seg_txt; //7-segment 한 자리에 대해 문자 표현
  output [7:0]seg_com; //7-segment 위치 결정
  output [13:0] dot_col; //dot maxtrix 정보
  output [9:0] dot_row; //dot maxtrix 정보

  reg [11:0]key_data; //key_row, key_col을 바탕으로 값 결정
  reg IsItMain = 1; //초기상태(1)인지, 게임상태(0)인지 표현
  reg IsItRight = 0; //보드판이 오른쪽으로 갔는지(1) 아닌지(0) 확인
  reg IsTurnO = 0; //O의 차례인지(1) X의 차례인지(0) 확인
  reg [1:0]board[3][3] = {{0, 0, 0}, {0, 0, 0}, {0, 0, 0}}; //보드에 어떤 돌이 놓여있는지 확인 0: 없음, 1: X돌, 2: O돌
  reg dot_matrix[10][14] = {
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    }; //매트릭스에 어떤 값을 띄울 것인지 확인

  mainState U0();
  keypad_scan U1(clk, rst, key_col, key_row, key_data); //키패드 스캔하기
  dot_display U2(clk, rst, dot_col, dot_row); //dot_display 띄우기
  //더 많은 것들...

endmodule
