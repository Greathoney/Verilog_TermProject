module TTT(clk, rst, key_row, key_col, seg_txt, seg_com, dot_col, dot_row);
	input clk, rst; //클럭, 리셋
	input	[3:0]key_row; //keypad 스캔
	output [2:0]key_col; //keypad 스캔
	output [6:0]seg_txt; //7-segment 한 자리에 대해 문자 표현
	output [7:0]seg_com; //7-segment 위치 결정
	output [13:0] dot_col; //dot maxtrix 정보
	output [9:0] dot_row; //dot maxtrix 정보

	reg [3:0]key_data; //key_row, key_col을 바탕으로 값 결정
	reg IsMain = 1; //초기상태(1)인지, 게임상태(0)인지 표현, 1로 초기화
	reg IsRight = 0; //보드판이 오른쪽으로 갔는지(1) 아닌지(0) 확인, 0으로 초기화
	reg IsTurnO = 0; //O의 차례인지(1) X의 차례인지(0) 확인, 0으로 초기화
	reg [18:0] board = 18'b00_00_00_00_00_00_00_00_00; //보드에 어떤 돌이 놓여있는지 확인 0: 없음, 1: X돌, 2: O돌

	always @(posedge rst) begin //reset 할 수 있는 부분
		IsMain <= 1;
		IsRight <= 0;
		IsTurnO <= 0;
		board <= 18'b00_00_00_00_00_00_00_00_00;
	end

	keypad_scan U1(clk, rst, key_col, key_row, key_data); //키패드 스캔하기, key_data를 받아옴
	//누르지 않을때는 key_data = 12'b0000_0000_0000 누르는 동안 어느 숫자가 1로 변함

	mainState U2(clk, key_data, IsMain, seg_txt, seg_com); //main(=1)상태에서 입력도 받고 출력도 하는 모듈
	//main == 0 이면 필요없어진다

	gameState U3(clk, key_data, IsMain, seg_txt, seg_com); //main(=0)상태가 아닌 게임상태에서 입력도 받고 출력도 하는 모듈

	dot_display U4(clk, rst, board, dot_col, dot_row); //board 데이터를 바탕으로 dot display에 띄울 수 있게 합니다.


endmodule
