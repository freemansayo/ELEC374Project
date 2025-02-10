module MDMux (input [31: 0] BusMuxOut, Mdatain,
				  input Read, output reg[31: 0] MDMuxOut);
	
	always @ (BusMuxOut or Mdatain or Read)
		begin
		case(Read)
			0			:	MDMuxOut <= BusMuxOut;
			1			:	MDMuxOut <= Mdatain;
			default	:	MDMuxOut <= BusMuxOut;
		endcase
	end
endmodule


module MDR(input Clear, input Clock, enable, Read_from_mem, input [31:0] in_from_bus, Mdatain,
			  output reg [31:0] Q);
	wire[31:0] D;
	MDMux mux_inst(.BusMuxOut(in_from_bus), .Mdatain(Mdatain), .Read(Read_from_mem), .MDMuxOut(D));
	always @ (posedge Clock or posedge Clear)
	begin
		if(Clear == 1)
			Q <= 32'b0;
		else if(enable == 1)
			Q <= D;
	end
endmodule
