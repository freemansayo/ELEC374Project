module CLA_4bit(input [3:0] i_add1, i_add2, input cin,
					 output [3:0] result, output cout);
	
	wire[3:0] G, P, C;
	

	//assign G, P, C values
	assign G = i_add1&i_add2;
	
	assign P = i_add1^i_add2;
	
	assign C[0] = cin;
	assign C[1]= G[0] | (P[0]&C[0]);
	assign C[2]= G[1] | (P[1]&G[0]) | P[1]&P[0]&C[0];
	assign C[3]= G[2] | (P[2]&G[1]) | P[2]&P[1]&G[0] | P[2]&P[1]&P[0]&C[0];
	assign cout = G[3] | (P[3]&G[2]) | P[3]&P[2]&G[1] | P[3]&P[2]&P[1]&G[0] | P[3]&P[2]&P[1]&P[0]&C[0];
	
	assign result = P^C;
	
endmodule
