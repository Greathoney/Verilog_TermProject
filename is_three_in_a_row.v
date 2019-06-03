module is_three_in_a_row(board, result);
//ouput 0 1 2
    input [17:0] board;
    output result;

    begin
        if (board[17:16] && board[15:14] && board[13:12]) result = 1;
        else if (board[11:10] && board[9:8] && board[7:6]) result = 1;
        else if (board[5:4] && board[3:2] && board[1:0]) result = 1;

        else if (board[17:16] && board[11:10] && board[5:4]) result = 1;
        else if (board[15:14] && board[9:8] && board[3:2]) result = 1;
        else if (board[13:12] && board[7:6] && board[1:0]) result = 1;

        else if (board[17:16] && board[9:8] && board[1:0]) result = 1;
        else if (board[13:12] && board[9:8] && board[5:4]) result = 1;

        else result = 0;
    end
endmodule
