//multiplier testbench
`timescale 1ns/100ps
module Mult_tb();
		reg[31:0] A, B;
		wire[63:0] result;
		
		Multiplier mult_inst(A, B, result);
		
		initial begin 
			A <= 80;
			B <= 2;
			
			#10	A <= 960;
					B <= 68;
			
		end
		
endmodule