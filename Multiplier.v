//MultiplicAtion (booth Algorithm)

module Multiplier(input signed [31:0] A, B, //A is multiplicAnd, B is multiplier
						output [63:0] result);
//First figure out bit-pair recoding
	reg[2:0] cc[15:0];
	reg[32:0] pp[15:0];
	reg[63:0] spp[15:0];
	
	reg[63:0] product;
	
	wire [32:0] inv_A;
	assign inv_A = {~A[31], ~A} + 1;
	integer i,j;
	//iterate through A's digits in for loop
	always @ (A or B or inv_A) begin
	
		//recoding
		cc[0] = {B[1], B[0], 1'b0};
		for(i = 1; i < 16; i = i+1)
			cc[i] = {B[2*i+1], B[2*i], B[2*i-1]};
		//determine partial products
		for(i = 0; i < 16; i = i + 1) begin
			case(cc[i])
				3'b001  : 	pp[i] = {A[31], A};
				3'b010  : 	pp[i] = {A[31], A};
				3'b011  :	pp[i] = {A, 1'b0};
				3'b100  :	pp[i] = {inv_A[31:0], 1'b0};
				3'b101  :	pp[i] = inv_A;
				3'b110  :	pp[i] = inv_A;
				default :	pp[i] = 0;
			endcase
			spp[i] = $signed(pp[i]);
			
			for(j = 0; j < i; j = j + 1)
				spp[i] = {spp[i], 2'b00};
		end
		
		product = spp[0];
	
		for(i = 1; i < 16; i = i + 1)
			product = product + spp[i];
			
		end
		assign result = product;
	endmodule