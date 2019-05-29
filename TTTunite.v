module TTT(clk, rst, key_row, key_col, seg_txt, seg_com, dot_col, dot_row);
	input clk, rst; //Ŭ��, ����
	input	[3:0]key_row; //keypad ��ĵ
	output [2:0]key_col; //keypad ��ĵ
	output [6:0]seg_txt; //7-segment �� �ڸ��� ���� ���� ǥ��
  output [7:0]seg_com; //7-segment ��ġ ����
  output [13:0]dot_col; //dot maxtrix ����
  output [9:0]dot_row; //dot maxtrix ����

  reg [11:0]key_data; //key_row, key_col�� �������� �� ����
  reg IsMain = 1; //�ʱ����(1)����, ���ӻ���(0)���� ǥ��, 1�� �ʱ�ȭ
  reg IsRight = 0; //�������� ���������� ������(1) �ƴ���(0) Ȯ��, 0���� �ʱ�ȭ
  reg IsTurnO = 0; //O�� ��������(1) X�� ��������(0) Ȯ��, 0���� �ʱ�ȭ
  reg [18:0] board = 2'b00_00_00_00_00_00_00_00_00; //���忡 � ���� �����ִ��� Ȯ�� 0: ����, 1: X��, 2: O��

	always @(negedge rst) begin //reset �� �� �ִ� �κ�
		IsMain <= 1;
		IsRight <= 0;
		IsTurnO <= 0;
		board = 2'b00_00_00_00_00_00_00_00_00;
	end

  keypad_scan U1(clk, rst, key_col, key_row, key_data); //Ű�е� ��ĵ�ϱ�, key_data�� �޾ƿ�
  mainState U2(clk, key_data, IsMain, seg_txt, seg_com); //main���¿��� �Է��� �޴� ���
	gameState U3(clk, key_data, IsItMain, IsItRight, IsTurnO, board);

  //�� ���� �͵�...

endmodule

module keypad_scan(clk, rst, key_col, key_row, key_data);
  //Ű�е带 ��ĵ�մϴ�. key_data�� �޾ƿɴϴ�.
	input clk, rst;
	input	[3:0]	key_row;
	output [2:0] key_col;
	output [11:0]	key_data;
	reg	[11:0] key_data;
	reg	[2:0]	state;
	reg [13:0] counts;
	reg clk1;
	wire key_stop;
	// define state of FSM
	parameter no_scan = 3'b000;
	parameter column1 = 3'b001;
	parameter column2 = 3'b010;
	parameter column3 = 3'b100;

	assign key_stop = key_row[0] | key_row[1] | key_row[2] | key_row[3] ;
	assign key_col = state;

	always @(posedge clk or posedge rst)  begin
	  if(rst) begin counts <= 0; clk1 <= 1; end
		else if (counts >= 12499) begin counts <= 0; clk1 <= !clk1; end
		else counts <= counts + 1; end

	// FSM drive
	always @(posedge clk1 or posedge rst)
	begin
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
	  	4'b0001 : key_data <= 12'b0000_0000_0001; // key_1
	  	4'b0010 : key_data <= 12'b0000_0000_1000; // key_4
	  	4'b0100 : key_data <= 12'b0000_0100_0000; // key_7
	  	4'b1000 : key_data <= 12'b0010_0000_0000; // key_*
	  	default : key_data <= 12'b0000_0000_0000;
	  	endcase
	  column2 : case (key_row)
	  	4'b0001 : key_data <= 12'b0000_0000_0010; // key_2
	  	4'b0010 : key_data <= 12'b0000_0001_0000; // key_5
	  	4'b0100 : key_data <= 12'b0000_1000_0000; // key_8
	  	4'b1000 : key_data <= 12'b0100_0000_0000; // key_0
	  	default : key_data <= 12'b0000_0000_0000;
	  	endcase
	  column3 : case (key_row)
	  	4'b0001 : key_data <= 12'b0000_0000_0100; // key_3
	  	4'b0010 : key_data <= 12'b0000_0010_0000; // key_6
	  	4'b0100 : key_data <= 12'b0001_0000_0000; // key_9
	  	4'b1000 : key_data <= 12'b1000_0000_0000; // key_#
	  	default : key_data <= 12'b0000_0000_0000;
	  	endcase
	  default : key_data <= 12'b0000_0000_0000;
	endcase
	end
endmodule

module mainState(clk, key_data, IsMain, seg_txt, seg_com);
  //���θ޴������� ���¸� ǥ���մϴ�. IsMain = 1�϶��� Ȱ��ȭ, 0���� �ٲ�� �ִ� ���� ����
  input [11:0] key_data;
	input clk;
  inout IsMain;
  output [6:0] seg_txt;
  output [7:0] seg_com;
  reg [20:0]clk_count;
	reg [7:0] seg_com;
	reg [6:0] seg_txt;
	reg IsItMain;
  reg [3:0] sel_seg = 4'b0000;
  reg clk1;


  always @(posedge clk) begin // clk1 ����
		if (IsMain == 1) begin
	    if (clk_count >= 24999) begin
	      clk_count <= 0;
	     	clk1 <= 1;
	    end
	    else begin
	      clk_count <= clk_count + 1;
	      clk1 <= 0;
	    end
  	end

		always @(posedge clk1) begin  //Ű 1���� �ԷµǸ� Main�� Ǯ���� ���Ӹ��� �����ϵ��� ����
			if (IsMain == 1)
				if (key_data == 12'b0000_0000_0001)
	    		IsMain <= 0;
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

module gameState(clk, key_data, IsItMain, IsItRight, IsTurnO, board);
	//���ӻ��¿����� ȯ���� �����մϴ�.
	input clk;
	input [11:0]key_data;
	input IsItMain;
	inout IsItRight;
	inout IsTurnO;
	inout [18:0] board;

	always @(IsTurnO) begin
		if (IsTurnO == 1)
			//7-segment�� P2�� ǥ���ϰ� �ȴ�.
		else
		  //7-segment�� P1�� ǥ���ϰ� �ȴ�.


	always @(key_data) begin
		case(key_data)
			12'b0000_0000_0001: if (board[1:0] == 2'b00) IsTurnO ? board[1:0] = 2'b10 : board[1:0] = 2'b01; //else... �Ұ����ϴٰ� �����ִ� Ʈ����
			12'b0000_0000_0010:  //board[3:2]
			12'b0000_0000_0100:  //...
			12'b0000_0000_1000:
			12'b0000_0001_0000:
			12'b0000_0010_0000:
			12'b0000_0100_0000:
			12'b0000_1000_0000:
			12'b0001_0000_0000:
			12'b0010_0000_0000:
			12'b0100_0000_0000:
			12'b1000_0000_0000:
		endcase
	end

		always @(board) begin
		//3���� �Ǻ��ϴ� �˰���
		//IsTurnO�� �̿��Ѵ�.

		//���а� ������ �� �����͸� ������ �ٸ� ��⿡�� ���
		end
endmodule
