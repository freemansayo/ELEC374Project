//acts as Top-level design object, holds the control unit and datapath modules, facilitates communication between the two.
`timescale 1ns/10ps
module MiniSRC(input reset, stop);
	
	//set up system clock
	reg clk;
	reg reset, stop;
	initial begin
		//temporary for testing
		reset = 0;
		stop = 0;
		
		clk = 1;
		repeat(1000) clk = #10 ~clk; //entire clock cycle is 40ns
	end
	
	wire[12:0] op_sel; //defines which operation ALU should perform
	
	//PC incrementor
	wire IncPC;
	//synchronous clear signal
	wire Clear;
	//read-from-bus signals
	wire Rin, MDR_rd, MAR_rd, HI_rd, LO_rd, Z_rd, PC_rd, In_rd, Out_rd, C_rd, Y_rd, IR_rd; //In_rd may need to be an input to the MiniSRC
	//write-to-bus signals
	wire R_out, MDR_out, MAR_out, HI_out, LO_out, Zhi_out, Zlo_out, PC_out, Inport_out, C_out;
	//used by division circuitry
	wire reset_div;
	//memory control signals
	wire Read, Write;
	//Control signals for A, B, C registers and BAout
	wire Gra, Grb, Grc, BAout;
	//CON_FF signals
	wire CONin, CON_output;
	//Program contro lsignals (control unit outputs)
	
	//IR register contents
	wire[31:0] IR_contents;
	
	//define system architecture
	control_unit CU_inst(.clk(clk), .reset(reset), .stop(stop), .CON_FF(CON_output), .reset_division(reset_div), .IR_contents(IR_contents),
								.Rin(Rin), .HIin(HI_rd), .LOin(LO_rd), .CONin(CONin), .PCin(PC_rd), .IRin(IR_rd), .Yin(Y_rd), .Zin(Z_rd), .MARin(MAR_rd), .MDRin(MDR_rd), .Outport_in(Out_rd),
								.R_out(R_out), .MDR_out(MDR_out), .MAR_out(MAR_out), .HI_out(HI_out), .LO_out(LO_out), .Zhi_out(Zhi_out), .Zlo_out(Zlo_out), .PC_out(PC_out), 
								.C_out(C_out), .Inport_out(Inport_out),
								.Gra(Gra), .Grb(Grb), .Grc(Grc), .BAout(BAout), .ADD(op_sel[0]), .SUB(op_sel[1]), .MUL(op_sel[2]), .DIV(op_sel[3]), .SHR(op_sel[4]), .SHRA(op_sel[5]), 
								.SHL(op_sel[6]), .ROR(op_sel[7]), .ROL(op_sel[8]), .AND(op_sel[9]), .OR(op_sel[10]), .NEG(op_sel[11]), .NOT(op_sel[12]), .Read(Read), .Write(Write),
								.Run(Run), .Clear(Clear), .IncPC(IncPC));
	
	Datapath DP_inst(.clk(clk), .clr(Clear), .IncPC(IncPC), .Read(Read), .Write(Write), .Gra(Gra), .Grb(Grb), .Grc(Grc), .BAout(BAout), .CONin(CONin), 
						  .reset_div(reset_div), .op_sel(op_sel),
						  .Rin(Rin), .MDR_rd(MDR_rd), .MAR_rd(MAR_rd), .HI_rd(HI_rd), .LO_rd(LO_rd), .Z_rd(Z_rd), .PC_rd(PC_rd),
						  .In_rd(In_rd), .Out_rd(Out_rd), .C_rd(C_rd), .Y_rd(Y_rd), .IR_rd(IR_rd),
						  .R_out(R_out), .MDR_out(MDR_out), .MAR_out(MAR_out), .HI_out(HI_out), .LO_out(LO_out), .Zhi_out(Zhi_out), .Zlo_out(Zlo_out), .PC_out(PC_out), 
						  .Inport_out(Inport_out), .C_out(C_out),
						  .IR_contents(IR_contents), .In_input(Inport_contents));
	
	//Current contents of memory: 
	//ld r2, 0(0x20) (contains 0x55)
	//addi r3, r2, 0xC6 (result = 0x11B)
	//st r3, 0(0x21)
	//mul r3, r2 (result: 5DF7)
	//halt
	
endmodule 