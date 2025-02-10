//rotate right
module ALU_ROR(input[31:0] A, input [4:0] B,
					output reg[31:0] rotated);
					
	reg[31:0] temp;
	always @(*) begin
		temp <= A << 32 - B;
		rotated <= (A >> B) | temp;
	end
endmodule
