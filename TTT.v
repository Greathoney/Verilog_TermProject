module TTT(clk, rst, key_row, key_col, seg_txt, seg_com, dot_col, dot_row);
	input clk, rst; //Ŭ��, ����
	input	[3:0]key_row; //keypad ��ĵ
	output [2:0]key_col; //keypad ��ĵ
	output [6:0]seg_txt; //7-segment �� �ڸ��� ���� ���� ǥ��
  output [7:0]seg_com; //7-segment ��ġ ����
  output [13:0] dot_col; //dot maxtrix ����
  output [9:0] dot_row; //dot maxtrix ����

  reg [3:0]key_data; //key_row, key_col�� �������� �� ����
  reg IsMain = 1; //�ʱ����(1)����, ���ӻ���(0)���� ǥ��, 1�� �ʱ�ȭ
  reg IsRight = 0; //�������� ���������� ������(1) �ƴ���(0) Ȯ��, 0���� �ʱ�ȭ
  reg IsTurnO = 0; //O�� ��������(1) X�� ��������(0) Ȯ��, 0���� �ʱ�ȭ
  reg [18:0] board = 18'b00_00_00_00_00_00_00_00_00; //���忡 � ���� �����ִ��� Ȯ�� 0: ����, 1: X��, 2: O��

	always @(posedge rst) begin //reset �� �� �ִ� �κ�
		IsMain <= 1;
		IsRight <= 0;
		IsTurnO <= 0;
		board <= 18'b00_00_00_00_00_00_00_00_00;
	end

  keypad_scan U1(clk, rst, key_col, key_row, key_data); //Ű�е� ��ĵ�ϱ�, key_data�� �޾ƿ�
	//������ �������� key_data = 12'b0000_0000_0000 ������ ���� ��� ���ڰ� 1�� ����

  mainState U2(clk, key_data, IsMain, seg_txt, seg_com); //main(=1)���¿��� �Էµ� �ް� ��µ� �ϴ� ���
	//main == 0 �̸� �ʿ��������

	gameState U3(clk, key_data, IsMain, seg_txt, seg_com); //main(=0)���°� �ƴ� ���ӻ��¿��� �Էµ� �ް� ��µ� �ϴ� ���

	dot_display U4(clk, rst, board, dot_col, dot_row); //board �����͸� �������� dot display�� ��� �� �ְ� �մϴ�.


endmodule
