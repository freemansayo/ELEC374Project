`timescale 1ns/10ps
module s_and_e_tb();

	reg[31:0] IRin;
	wire[4:0] opCode;
	assign opCode = IRin[31:27];
	wire[3:0] Ra, Rb, Rc;
	assign Ra = IRin[26:23];
	assign Rb = IRin[22:19];
	assign Rc = IRin[18:15];
	
	reg Gra, Grb, Grc, Rin, Rout, BAout;
	
	wire[3:0] Decoder_in;
	assign Decoder_in = (Ra & Gra) | (Rb & Grb) | (Rc & Grc);
	
	wire[18:0] C;
	assign C = IRin[18:0];
	wire[31:0] C_extended;
	wire[15:0] R_rd, R_wrt;
	
	
	select_and_encode SELE_inst(IRin, Gra, Grb, Grc, Rin, Rout, BAout,
										 C_extended, R_rd, R_wrt);

	initial begin
		IRin <= 0;
		Gra <= 0;
		Grb <= 0;
		Grc <= 0;
		Rin <= 0;
		Rout <= 0;
		BAout <= 0;
		
		//S&E operation
		#10
		IRin <= 32'b00000000000000000000000000000000;
		Grb <= 1;
		Rout <= 1;
		#10
		Rout <= 0;
		#10
		IRin <= 32'b11011000100101000000000000001111;
		Gra <= 1;
		Grb <= 0;
		Grc <= 0;
		#10
		Rin <= 1;
		#10
		Rin <= 0;
	end

endmodule
