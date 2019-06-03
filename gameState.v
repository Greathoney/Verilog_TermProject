module gameState(clk, key_data, IsMain, IsRight, IsTurnO, board, seg_txt, seg_com, dot_col, dot_row);
//���ӻ��¿����� ȯ���� �����մϴ�.
//gameState���� �ؾ��� ��
/*
1. key_data�� ������� board data�� ������ �� �־�� ��.
2. ���������Ȳ�� ���� 7-segment�� P1, P2�� ����� ��.
*/

  	input clk;
  	input [3:0]key_data;
  	input IsMain;
  	inout IsRight;
  	inout IsTurnO;
  	inout [18:0] board;
    reg [18:0] board;
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

      //����� �κ�
  	always @(IsTurnO) begin
  		if (IsTurnO == 1)
  			//7-segment�� P2�� ǥ���ϰ� �ȴ�.
  		else
  		  //7-segment�� P1�� ǥ���ϰ� �ȴ�.


  	always @(posedge key_data) begin
        board[18 - 2 * key_data + IsTurnO] = 1;
  		endcase
  	end

  		always @(board) begin
  		//3���� �Ǻ��ϴ� �˰���
  		//IsTurnO�� �̿��Ѵ�.

  		//���а� ������ �� �����͸� ������ �ٸ� ��⿡�� ���
  		end
  endmodule
