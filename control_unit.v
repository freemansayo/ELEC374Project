module control_unit(	input clk, reset, stop, CON_FF,
							input[31:0] IR_contents,
							//Read-from-bus signals
							output 	Rin, HIin, LOin, CONin, PCin, IRin, Yin, Zin, MARin, MDRin, Outport_in,
							//Write-to-bus signals
										Rout, BAout, Cout, PCout, MDRout, Zhiout, Zloout, HIout, LOout, Inport_out,
							//General register selection signals
										Gra, Grb, Grc, 
							//ALU control signals (might also condense to one wire that takes on value of ALU opcode, might be less mess that way)
										ADD, SUB, MUL, DIV, SHR, SHL, ROR, ROL, AND, OR, NEG,
							//memory operation control signals
										Read, Write,
							//Program control(?) signals
										Run, Clear
							);

	//Will follow Method 1 as described in the Phase 3 document
	
	
	
	
	
endmodule
