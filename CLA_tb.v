//testbench, fully working 32_bit adder

module CLA_tb;
	reg [31:0] i_add1, i_add2;
	reg cin;
	wire [31:0] result;
	wire cout;
	
CLS_32bit carry_lookahead(i_add1,
								 i_add2,
								 cin,
								 result,
								 cout);
	initial begin
		i_add1 <= 32'd0;
		i_add2 <= 32'd0;
		cin <=32'd0;
		#300 	i_add1 <= 32'd256;
				i_add2 <= 32'd4096;
	end

endmodule