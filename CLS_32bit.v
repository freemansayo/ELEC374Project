module CLS_32bit(input [31:0] i_add1, i_add2, input cin,
					  output [31:0] result, output cout);
	wire[31:0] temp;
	
	assign temp = ~i_add2 + 1;
	CLA_32bit add(.i_add1(i_add1), .i_add2(temp), .cin(cin), .result(result), .cout(cout));	
	
endmodule
