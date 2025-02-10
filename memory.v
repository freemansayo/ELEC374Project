//memory subsystem
module memory(input [31:0] Datain, input [8:0] Address, input Write, clk,
				  output [31:0] Dataout);

		reg [31:0] memory [0:511];
		reg [31:0] selectedVal;
		integer i = 0;
		
		//Note: Command Opcodes are all stored at the start of memory, check init.mif for exact addresses
		//Opcodes are written in order they appear in CPU_specification lab file
		initial begin
			$readmemb("init.mif", memory);
			/*for(i = 0; i < 512; i = i + 1) begin
				memory[i] = i;
			end*/
		end
		
		always@ (posedge clk) begin
			if(Write) begin
				memory[Address] <= Datain;
			selectedVal <= Address;
			end
		end
		assign Dataout = memory[Address];
	endmodule
			
			
			