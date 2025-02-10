module CLA_32bit(input [31:0] i_add1, i_add2, input cin,
					  output [31:0] result, output cout);
	wire cout1, cout2, cout3, cout4, cout5, cout6, cout7;
	
	CLA_4bit CLA_0
		(
			.i_add1(i_add1[3:0]),
			.i_add2(i_add2[3:0]),
			.cin(cin),
			.result(result[3:0]),
			.cout(cout1)
		);
	CLA_4bit CLA_1
		(
			.i_add1(i_add1[7:4]),
			.i_add2(i_add2[7:4]),
			.cin(cout1),
			.result(result[7:4]),
			.cout(cout2)
		);
	CLA_4bit CLA_2
		(
			.i_add1(i_add1[11:8]),
			.i_add2(i_add2[11:8]),
			.cin(cout2),
			.result(result[11:8]),
			.cout(cout3)
		);
	CLA_4bit CLA_3
		(
			.i_add1(i_add1[15:12]),
			.i_add2(i_add2[15:12]),
			.cin(cout3),
			.result(result[15:12]),
			.cout(cout4)
		);
	
	CLA_4bit CLA_4
		(
			.i_add1(i_add1[19:16]),
			.i_add2(i_add2[19:16]),
			.cin(cout4),
			.result(result[19:16]),
			.cout(cout5)
		);
	CLA_4bit CLA_5
		(
			.i_add1(i_add1[23:20]),
			.i_add2(i_add2[23:20]),
			.cin(cout5),
			.result(result[23:20]),
			.cout(cout6)
		);
	CLA_4bit CLA_6
		(
			.i_add1(i_add1[27:24]),
			.i_add2(i_add2[27:24]),
			.cin(cout6),
			.result(result[27:24]),
			.cout(cout7)
		);
	CLA_4bit CLA_7
		(
			.i_add1(i_add1[31:28]),
			.i_add2(i_add2[31:28]),
			.cin(cout7),
			.result(result[31:28]),
			.cout(cout)
		);
	
endmodule
