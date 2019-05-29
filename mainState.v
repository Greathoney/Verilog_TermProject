module mainState(key_data, IsItMain, seg_txt, seg_com)
  input [11:0] key_data;
  input IsItMain;
  output [6:0] seg_txt;
  output [7:0] seg_com;

  always @(key_data and IsItMain) begin  //키 입력이 되면 Main이 풀리게 설계
    IsItMain = 0;
  end

  always @(IsItMain) begin // 7-segment를 통해 press 출력

  end

endmodule
