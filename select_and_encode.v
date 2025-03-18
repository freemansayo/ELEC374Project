//select and encode logic
module select_and_encode(input[31:0] IRin, input Gra, Grb, Grc, Rin, Rout, BAout,
								 output[31:0] C_extended, output[15:0] R_rd, R_wrt);
		wire[3:0] Ra, Rb, Rc;
		assign Ra = IRin[26:23];
		assign Rb = IRin[22:19];
		assign Rc = IRin[18:15];
		
		reg[3:0] Decoder_in;
		reg[15:0] Decoder_out;
		
		//4-to-16 Decoder
		always @(Gra or Grb or Grc) begin
			Decoder_in = (Ra & {4{Gra}}) | (Rb & {4{Grb}}) | (Rc & {4{Grc}});
			case(Decoder_in)
				default : Decoder_out <= 16'b0;
				4'b0000 : Decoder_out <= 16'b0000000000000001;
				4'b0001 : Decoder_out <= 16'b0000000000000010;
				4'b0010 : Decoder_out <= 16'b0000000000000100;
				4'b0011 : Decoder_out <= 16'b0000000000001000;
				4'b0100 : Decoder_out <= 16'b0000000000010000;
				4'b0101 : Decoder_out <= 16'b0000000000100000;
				4'b0110 : Decoder_out <= 16'b0000000001000000;
				4'b0111 : Decoder_out <= 16'b0000000010000000;
				4'b1000 : Decoder_out <= 16'b0000000100000000;
				4'b1001 : Decoder_out <= 16'b0000001000000000;
				4'b1010 : Decoder_out <= 16'b0000010000000000;
				4'b1011 : Decoder_out <= 16'b0000100000000000;
				4'b1100 : Decoder_out <= 16'b0001000000000000;
				4'b1101 : Decoder_out <= 16'b0010000000000000;
				4'b1110 : Decoder_out <= 16'b0100000000000000;
				4'b1111 : Decoder_out <= 16'b1000000000000000;
			endcase
		end
		
		assign R_rd = Decoder_out & {16{Rin}};
		assign R_wrt = Decoder_out & ({16{Rout}} | {16{BAout}});
		//MSB of C field in IR is fanned out by 13 bits
		assign C_extended = {IRin[18],IRin[18],IRin[18],IRin[18],IRin[18],IRin[18],IRin[18],IRin[18],IRin[18],IRin[18],IRin[18],IRin[18],IRin[18],IRin[18:0]};
		
		
endmodule
