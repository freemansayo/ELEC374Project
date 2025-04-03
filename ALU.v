module ALU(input [31:0] A, B, Y, input[12:0] op_sel, input clk, reset,
			  output reg [31:0] Zhigh, Zlo);
	reg[63:0] Z;
	wire[31:0] CLA_res, CLS_res, SHRAres, ROR_res, ROL_res;
	wire[63:0] Divide_res, Multiply_res;
	wire CLA_cout, CLS_cout;
	
	always @ (A or B or Y or op_sel)
	begin
		Zhigh = 32'b0;
		Zlo = 32'b0;
		
		case(op_sel)
			13'b0000000000001 :	begin //ADD
											Z[31:0] = CLA_res[31:0];
											Z[63:32] = Z[63:32] ^ Z[63:32];
										end
			13'b0000000000010 :	begin //SUB
											Z[31:0] = CLS_res[31:0];
											Z[63:32] = Z[63:32] ^ Z[63:32];
										end	
			13'b0000000000100 :	Z = Multiply_res;//MUL
			13'b0000000001000 :	Z = Divide_res;//DIV, remainder in Hi register
			13'b0000000010000 :	Z = Y >> B;//SHR
			13'b0000000100000	:	Z = $signed(Y) >>> B; //SHRA	
			13'b0000001000000 :	Z = Y << B;//SHL
			13'b0000010000000 : 	begin //ROR
											Z = (Y >> B) | (Y << 32 - B); 
											Z[63:32] = Z[63:32] & 0;
										end
			13'b0000100000000 :	begin //ROL
											Z = (Y << B) | (Y >> 32 - B);
											Z[63:32] = Z[63:32] & 0;
										end
			13'b0001000000000 :	Z = Y & B;//AND
			13'b0010000000000 :	Z = Y | B;//OR
			13'b0100000000000 :	begin //NEG
											Z = ~(B);
											Z = Z + 1;
										end
			13'b1000000000000 :	Z = !(B);//NOT
			default				:	Z = B; //default case, set Z to whatever's on the bus at that moment
		endcase
		
		Zhigh = Z[63:32];
		Zlo = Z[31:0];
	end
	
	CLA_32bit carry_lookahead_adder(.i_add1(Y), .i_add2(B), .cin(1'b0), .result(CLA_res), .cout(CLA_cout));
	CLS_32bit carry_lookahead_subtractor(.i_add1(Y),.i_add2(B), .cin(1'b0), .result(CLS_res), .cout(CLS_cout));
	Multiplier multiplier_instance(.A(Y), .B(B), .result(Multiply_res));
	Divider divider_instance(.Qin(Y), .M(B), .result(Divide_res), .reset(reset), .clk(clk));
	ALU_ROR rotate_right(.A(Y), .B(B), .rotated(ROR_res));
	ALU_ROL rotate_left(.A(Y), .B(B), .rotated(ROL_res));
endmodule
