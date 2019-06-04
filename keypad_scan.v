

//컴파일 완료 수정시 주석삭제


// 2010.11.18
// 4X3 keypad driver
// input : 4 row,
// output : 12 bit, 3 column

module keypad_scan(clk, rst, key_col, key_row, key_data, IsRight);
	input 	clk, rst;
	input	[3:0] 	key_row;
	output	[2:0]	key_col;
	output	[3:0]	key_data;
	output 	IsRight;
	reg	[3:0]	key_data;
	reg	[2:0]	state;
	reg [13:0]  counts;
	reg clk1;
	reg IsRight;
	wire	key_stop;
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
		else counts <= counts +1; end

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
	  	4'b1000 : key_data <= 0; // key_0 : 아무일 안함
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
endmodule
