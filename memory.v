//memory subsystem
module memory(input [31:0] Datain, input [8:0] Address, input Write, clk,
				  output [31:0] Dataout);

		reg [31:0] memory [511:0];
		
		//Note: Command Opcodes are all stored at the start of memory, check init.hex for exact addresses
		//Opcodes are written in order they appear in CPU_specification lab file
		initial begin
			$readmemh("init_jp.hex", memory);
		end
		
		always@ (posedge clk) begin
			if(Write) begin
				memory[Address] <= Datain;
			end
		end
		assign Dataout = memory[Address];
	endmodule
			
			
			