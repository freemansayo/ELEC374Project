//Divider (using Restoring Division Algorithm)
module Divider (input[31:0] Qin, M, input clk, reset,
					 output[63:0] result, output[31:0] len_w, count_v, output finish_v);
	reg[32:0] A;
	reg[31:0] Q;
	reg[31:0] Mcopy;
	integer len = 0, i = 0;
	integer count = 0;
	reg finish;
	initial begin
		finish = 0;
		count = 0;
	end
	
	assign finish_v = finish;
	assign len_w = len;
	assign count_v = count;
	assign result[63:32] = A[31:0];
	assign result[31:0] = Q;
	
	always @(posedge clk or negedge reset) begin
		if(!reset) begin
			finish = 1;
		end else begin 
			if(finish) begin //Done with current operands, recompute quotient length and reset count
				A = 32'b0;
				Q = Qin;
				Mcopy = M;
				len = 0;
				for(i = 0; i < 32; i = i + 1) begin
					if(Q[i] == 1'b1)
						len = i;
				end
				len = len + 1; //len represents length of Qin in bits
				
				finish = 0;
				count = 0;
			end
			
			A = A << 1;
			A[0] = Q[len - 1];
			Q[len - 1] = 0;
			Q = Q << 1;
			
			if(A < Mcopy) //A < Mcopy -> A - Mcopy < 0
				Q[0] = 1'b0;
			else begin
				Q[0] = 1'b1;
				A = A - Mcopy;
			end
			if(count < len - 1) begin
				finish = 0;
				count = count + 1;
			end else begin
				finish = 1;
				count = count + 1;
			end
		end
	end
	
endmodule