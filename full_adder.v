module full_adder(input x, y, c_in, output S, Cout);
	assign S = x ^ y ^ c_in;
	assign Cout = ((x ^ y) & c_in) | (x & y);
	
endmodule
