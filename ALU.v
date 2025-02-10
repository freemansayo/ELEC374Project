module ALU(input [31:0] A, B, Y, input[4:0] op_sel, input clk, reset,
			  output reg [31:0] Zhigh, Zlo, output calc_finished);
	reg[63:0] Z;
	wire[31:0] CLA_res, CLS_res, SHRAres, ROR_res, ROL_res;
	wire[63:0] Divide_res, Multiply_res;
	wire CLA_cout, CLS_cout;
	

	always @ (A or B or Y or op_sel)
	begin
		Zhigh = 32'b0;
		Zlo = 32'b0;
		
		case(op_sel)
			5'b00011 	: 	begin
									Z[31:0] = CLA_res[31:0];//ADD
									Z[63:32] = Z[63:32] ^ Z[63:32];
								end
			5'b00100 	: 	begin
									Z[31:0] = CLS_res[31:0];//SUB
									Z[63:32] = Z[63:32] ^ Z[63:32];
								end
			5'b10000		: 	Z = Multiply_res;//MUL
			5'b01111 	:  Z = Divide_res;//DIV, remainder in Hi register
			5'b00111 	: 	Z = Y >> B;//SHR
			5'b01000 	: 	Z = $signed(Y) >>> B; //SHRA																	  
			5'b01001 	: 	Z = Y << B;//SHL
			5'b01010		: 	begin 
									Z = (Y >> B) | (Y << 32 - B); //ROR
									Z[63:32] = Z[63:32] & 0;
								end
			5'b01011		: 	begin 
									Z = (Y << B) | (Y >> 32 - B); //ROL
									Z[63:32] = Z[63:32] & 0;
								end
			5'b00101 	: 	Z = Y & B;//AND
			5'b00110 	: 	Z = Y | B;//OR
			5'b10001 	: 	begin
									Z = ~(B);//NEG
									Z = Z + 1;
								end
			5'b10010 	: 	Z = !(B);//NOT
			default		: 	Z = 64'b0111111111111111111111111111111101111111111111111111111111111111; //default case
		endcase
		
		Zhigh = Z[63:32];
		Zlo = Z[31:0];
	end
	
	CLA_32bit carry_lookahead_adder(.i_add1(Y), .i_add2(B), .cin(1'b0), .result(CLA_res), .cout(CLA_cout));
	CLS_32bit carry_lookahead_subtractor(.i_add1(Y),.i_add2(B), .cin(1'b0), .result(CLS_res), .cout(CLS_cout));
	Multiplier multiplier_instance(.A(Y), .B(B), .result(Multiply_res));
	Divider divider_instance(.Qin(Y), .M(B), .result(Divide_res), .finish_v(calc_finished), .reset(reset), .clk(clk));
	ALU_ROR rotate_right(.A(Y), .B(B), .rotated(ROR_res));
	ALU_ROL rotate_left(.A(Y), .B(B), .rotated(ROL_res));
endmodule
