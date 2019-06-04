
//컴파일 완료: 수정시 주석 삭제

module mainState(clk, key_data, IsMain, seg_txt, seg_com);
  //메인메뉴에서의 상태를 표시합니다. IsMain = 1일때만 활성화, 0으로 바뀔수 있는 조건 갖춤
  input [3:0] key_data;
	input clk;
  inout IsMain;
  output [6:0] seg_txt;
  output [7:0] seg_com;
  reg [20:0]clk_count;
	reg [7:0] seg_com;
	reg [6:0] seg_txt;
	reg IsMain;
  reg [3:0] sel_seg;
  reg clk1;

  always @(posedge clk) begin // clk1 설계
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
	end

	always @(posedge clk1) begin  //키 1번이 입력되면 Main이 풀리고 게임모드로 진입하도록 설계
			if (IsMain == 1) begin
				if (key_data == 1) begin
	    		IsMain <= 0;
        end
      end
	  end

  always @(posedge clk1) begin //clk1을 기반으로 sel_seg 설계
		if (IsMain == 1) begin
    	if (sel_seg == 7) sel_seg <= 0;
    		else sel_seg <= sel_seg + 1;
			end
		end

  always @(sel_seg) //sel_seg을 기반으로 7-segment에 표시
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
