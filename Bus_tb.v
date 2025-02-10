//Bus testbench (NOTE: to test this, Bus files must be in their own directory)
`timescale 1ns/100ps
module Bus_tb;
	reg [31: 0] r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, HIreg, LOreg, Zhigh, Zlo, PC, MDR, Inport, C_extended, Data;
	reg [4:0] sel;
	wire [31:0] Bus_out;
	
	Bus bus_instance(r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, HIreg, LOreg, Zhigh, Zlo, PC, MDR, Inport, C_extended, Data,
			  Bus_out);
	
	//Should show contents of r0, then r1 in Bus_out signal
	initial begin
		r0 <= 32'd9007;
		r1 <= 32'd69696969;
		Data <= 32'b1;
		#100 	Data <= 32'b10;
		
	end
	
endmodule