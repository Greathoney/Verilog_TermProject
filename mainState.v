module mainState(clk, key_data, IsItMain, seg_txt, seg_com)
  input [11:0] key_data;
  input IsItMain;
  output [6:0] seg_txt;
  output [7:0] seg_com;

  reg [26:0]clk_count;
  reg [3:0] sel_seg;
  reg clk1;

  always @(IsItMain and key_data = 12'b1000_000_000) begin  //키 1번이 입력되면 Main이 풀리게 설계
    IsItMain = 0;
  end

  always @(IsItMain and negedge clk) begin // clk1 설계
    if (clk_count == 25000000) begin
      clk_count <= 0;
      clk1 <= 1;
    end
    else begin
      clk_count <= clk_count + 1;
      clk1 <= 0;
    end
  end

  always @(IsItMain and clk1) begin //clk1을 기반으로 sel_sag 설계
    if (sel_seg == 7) sel_sag <= 0;
    else sel_sag <= sel_sag + 1;

  always @(IsItMain and sel_sag) //sel_sag을 기반으로 7-segment에 표시
    case(sel_sag)
      0: begin seg_com <= 8'01111111 seg_text <= 7'b1111100 end //p
      1: begin seg_com <= 8'10111111 seg_text <= 7'00011000 end //r
      2: begin seg_com <= 8'11011111 seg_text <= 7'b1101101 end //e
      3: begin seg_com <= 8'11101111 seg_text <= 7'b1101010 end //s
      4: begin seg_com <= 8'11110111 seg_text <= 7'b1101010 end //s
      5: begin seg_com <= 8'11111011 seg_text <= 7'b0000000 end //' '
      6: begin seg_com <= 8'11111101 seg_text <= 7'b1110111 end //0
      7: begin seg_com <= 8'11111110 seg_text <= 7'b0010010 end //1
endmodule
