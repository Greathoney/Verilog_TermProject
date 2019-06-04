module TTT(clk, rst, key_row, key_col, seg_txt, seg_com, dot_col, dot_row);
	input clk, rst; //Ŭ��, ����
	input [3:0]key_row; //keypad ��ĵ
	output [2:0]key_col; //keypad ��ĵ
	output [6:0]seg_txt; //7-segment �� �ڸ��� ���� ���� ǥ��
	output [7:0]seg_com; //7-segment ��ġ ����
	output [13:0] dot_col; //dot maxtrix ����
	output [9:0] dot_row; //dot maxtrix ����

	reg [3:0]key_data; //key_row, key_col�� �������� �� ����
	integer IsMain = 1; //�ʱ����(1)����, ���ӻ���(0)���� ǥ��, 1�� �ʱ�ȭ
	reg IsRight = 0; //�������� ���������� ������(1) �ƴ���(0) Ȯ��, 0���� �ʱ�ȭ
	reg IsTurnO = 0; //O�� ��������(1) X�� ��������(0) Ȯ��, 0���� �ʱ�ȭ
	reg [18:0] board = 18'b00_00_00_00_00_00_00_00_00; //���忡 � ���� �����ִ��� Ȯ�� 0: ����, 1: X��, 2: O��

	//keypad_scan
	reg	[2:0] state;
	reg [13:0] counts;
	reg clk1;
	wire key_stop;

	parameter no_scan = 3'b000;
	parameter column1 = 3'b001;
	parameter column2 = 3'b010;
	parameter column3 = 3'b100;

	//mainstate
	reg [20:0]clk_count;
	reg [7:0] seg_com;
	reg [6:0] seg_txt;
	reg [3:0] sel_seg;
	reg clk2;


	always @(posedge rst) begin //reset �� �� �ִ� �κ�
		IsMain <= 0;
		IsRight <= 0;
		IsTurnO <= 0;
		board <= 18'b00_00_00_00_00_00_00_00_00;
	end


	//MODULE KEYPAD_SCAN
	//Ű�е� ��ĵ�ϱ�, key_data�� �޾ƿ�
	//������ �������� key_data = 12'b0000_0000_0000 ������ ���� ��� ���ڰ� 1�� ����
	// define state of FSM

	assign key_stop = key_row[0] | key_row[1] | key_row[2] | key_row[3] ;
	assign key_col = state;

	always @(posedge clk or posedge rst) begin
		if(rst) begin counts <= 0; clk1 <= 1; end
		else if (counts >= 12499) begin counts <= 0; clk1 <= !clk1; end
		else counts <= counts +1; end

	// FSM drive
	always @(posedge clk1 or posedge rst) begin
		if (rst) state <= no_scan;
		else begin
			if (!key_stop) begin
				case (state)
					no_scan : state <= column1;
					column1 : state <= column2;
					column2 : state <= column3;
					column3 : state <= column1;
					default : state <= no_scan;
				endcase
			end
		end
	end
	// key_data
	always @ (posedge clk1) begin
		case (state)
			column1 : case (key_row)
				4'b0001 : key_data <= 1; // key_1
				4'b0010 : key_data <= 4; // key_4
				4'b0100 : key_data <= 7; // key_7
				4'b1000 : IsRight <= 0; // key_*
				default : key_data <= 0;
			endcase
			column2 : case (key_row)
				4'b0001 : key_data <= 2; // key_2
				4'b0010 : key_data <= 5; // key_5
				4'b0100 : key_data <= 8; // key_8
				4'b1000 : key_data <= 0; // key_0 : �ƹ��� ����
				default : key_data <= 0;
			endcase
		  column3 : case (key_row)
				4'b0001 : key_data <= 3; // key_3
				4'b0010 : key_data <= 6; // key_6
				4'b0100 : key_data <= 9; // key_9
				4'b1000 : IsRight <= 1; // key_#
				default : key_data <= 0;
			endcase
			default : key_data <= 0;
		endcase
	end



	//Module MainState
	//main(=1)���¿��� �Էµ� �ް� ��µ� �ϴ� ���
	//main == 0 �̸� �ʿ��������

	//������ �Ϸ�: ������ �ּ� ����

	//���θ޴������� ���¸� ǥ���մϴ�. IsMain = 1�϶��� Ȱ��ȭ, 0���� �ٲ�� �ִ� ���� ����

	always @(posedge clk) begin // clk2 ����
		if (IsMain == 1) begin
			if (clk_count >= 24999) begin
				clk_count <= 0;
				clk2 <= 1;
			end
			else begin
				clk_count <= clk_count + 1;
				clk2 <= 0;
			end
		end
	end

	always @(posedge clk2) begin  //Ű 1���� �ԷµǸ� Main�� Ǯ���� ���Ӹ��� �����ϵ��� ����
		if (IsMain == 1) begin
			if (key_data == 1) begin
				IsMain <= 0;
			end
		end
	end

	always @(posedge clk1) begin //clk1�� ������� sel_seg ����
		if (IsMain == 1) begin
			if (sel_seg == 7) sel_seg <= 0;
			else sel_seg <= sel_seg + 1;
		end
	end

	always @(sel_seg) //sel_seg�� ������� 7-segment�� ǥ��
		if (IsMain == 1) begin
			case(sel_seg)
				0: begin seg_com <= 8'b01111111; seg_txt <= 7'b1110011; end //p =>abefg
				1: begin seg_com <= 8'b10111111; seg_txt <= 7'b1010000; end //r =>eg
				2: begin seg_com <= 8'b11011111; seg_txt <= 7'b1111001; end //e =>adefg
				3: begin seg_com <= 8'b11101111; seg_txt <= 7'b1101101; end //s =>acdfg
				4: begin seg_com <= 8'b11110111; seg_txt <= 7'b1101101; end //s =>acdfg
				5: begin seg_com <= 8'b11111011; seg_txt <= 7'b0000000; end //' '
				6: begin seg_com <= 8'b11111101; seg_txt <= 7'b0111111; end //0 =>abcdef
				7: begin seg_com <= 8'b11111110; seg_txt <= 7'b0000110; end //1 =>bc
			endcase
		end
endmodule





	//main(=0)���°� �ƴ� ���ӻ��¿��� �Էµ� �ް� ��µ� �ϴ� ���





	//board �����͸� �������� dot display�� ��� �� �ְ� �մϴ�.
