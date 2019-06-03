module is_three_in_a_row(board, result, isTurnO);
    input [17:0] board;
    input isTurnO;
    output result;

    begin
      if (isTurnO) begin
        // XÀÇ »ï¸ñ ÆÇº°
        if (board[16] && board[14] && board[12]) result = 1;
        else if (board[10] && board[8] && board[6]) result = 1;
        else if (board[4] && board[2] && board[0]) result = 1;

        else if (board[16] && board[10] && board[4]) result = 1;
        else if (board[14] && board[8] && board[2]) result = 1;
        else if (board[12] && board[6] && board[0]) result = 1;

        else if (board[16] && board[8] && board[0]) result = 1;
        else if (board[12] && board[8] && board[4]) result = 1;

        else result = 0;
      end
      else begin
        ;
      end
    end
endmodule
