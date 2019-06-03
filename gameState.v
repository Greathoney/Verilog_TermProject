module gameState(clk, key_data, IsItMain, IsItRight, IsTurnO, board, seg_txt, seg_com, dot_col, dot_row);
//���ӻ��¿����� ȯ���� �����մϴ�.
//gameState���� �ؾ��� ��
/*
1. key_data�� ������� board data�� ������ �� �־�� ��.
2. ���������Ȳ�� ���� 7-segment�� P1, P2�� ����� ��.
*/
  	input clk;
  	input [3:0]key_data;
  	input IsItMain;
  	inout IsItRight;
  	inout IsTurnO;
  	inout [18:0] board;

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


  	always @(IsTurnO) begin
  		if (IsTurnO == 1)
  			//7-segment�� P2�� ǥ���ϰ� �ȴ�.
  		else
  		  //7-segment�� P1�� ǥ���ϰ� �ȴ�.


  	always @(key_data) begin
  		case(key_data)
  			1: if (board[1:0] == 2'b00) IsTurnO ? board = 18'b10_00_00_00_00_00_00_00_00  : board[1:0] = 2'b01; //else... �Ұ����ϴٰ� �����ִ� Ʈ����
  			2:
            3:
            4:
            5:
            6:
            7:
            8:
            9:
            10:
            11:
            12:
  		endcase
  	end

  		always @(board) begin
  		//3���� �Ǻ��ϴ� �˰���
  		//IsTurnO�� �̿��Ѵ�.

  		//���а� ������ �� �����͸� ������ �ٸ� ��⿡�� ���
  		end
  endmodule
