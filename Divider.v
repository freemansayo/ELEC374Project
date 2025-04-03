//Divider (using Restoring Division Algorithm)
module Divider (input[31:0] Qin, M, input clk, reset,
					 output[63:0] result);
	reg[31:0] A;
	reg[31:0] Q;
	reg[31:0] Mcopy;
	reg[63:0] shifted;

	integer i, count;

	reg finish;
	reg[5:0] len;
	
	initial begin
		finish <= 1;
		A <= 32'b0;
		Q <= 0;
		Mcopy <= 0;
		shifted <= 0;
	end
	
	assign result[63:0] = shifted;
	/*
	always @ (Qin) begin
		//determine length of Qin
		len = 0;
		for(i = 0; i < 32; i = i + 1) begin
			if(Qin[i] == 1'b1) begin
				len = i;
			end
		end
	*/
	always @(posedge clk) begin
		if(reset) begin
			finish = 0;
			
			//set up copies of operands for division
			A = 32'b0;
			Q = Qin;
			Mcopy = M;
			count = 0;
			
		end else if(!finish) begin //still operating on operands, perform iteration of algorithm
			
			shifted = {A, Q} << 1;
			A = shifted[63:32];
			Q = Q << 1;
			A = A - Mcopy;
			
			if(A[31]) begin //Check if A is negative
				Q[0] = 1'b0;
				A = A + Mcopy;
			end else begin
				Q[0] = 1'b1;
			end
		
			//determine if the algorithm continues
			if(count < 33) begin //Still more digits to go
				finish = 0;
				count = count + 1;
			end else begin //finished with division
				finish = 1;
			end
		end
	end
	
endmodule
