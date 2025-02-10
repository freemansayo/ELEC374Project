//PC register
module PCreg(input[31:0] D, input clk, increment, clr, enable,
				 output reg[31:0] Q);
	initial begin
		Q <= 0;
	end
	always@(posedge clk) begin
		if(clr)
			Q <= 0;
		else if(increment)
			Q <= Q+1;
		else if(enable)
			Q <= D;
	end
	
endmodule
