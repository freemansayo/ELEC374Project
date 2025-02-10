//Datapath module
module Datapath(//clock:
					 input clk, 
					 //synchronous clear
					 clr,
					 //PC incrementor
					 input IncPC, 
					 //Signals for memory Read/Write operations
							 Read, Write,
					 //read-from-bus signals for general registers
					 input[15:0] R_rd,
					 //read-from-bus signals					 
					 input MDR_rd, MAR_rd, HI_rd, LO_rd, Zhi_rd, Zlo_rd, PC_rd, In_rd, Out_rd, C_rd, Y_rd, IR_rd,
					 //write-to-bus enable signals for general registers
					 input[15:0] R_wrt,
					 //Write-to-bus enable signals
					 input MDR_out, MAR_out, HI_out, LO_out, Zhi_out, Zlo_out, PC_out, In_out, Out_out, C_out,
					 //Used in test bench demos
					 input[31:0] Mdatain,
					 input[31:0] In_input,
					 //Signals for ALU operation
					 input[31:0] op_sel,
					 output[31: 0] BusMuxOut,
					 //To view register contents
					 output[31:0] r0_view, r1_view, r2_view, r3_view, r4_view, r5_view, r6_view, r7_view, r8_view, r9_view, r10_view, r11_view, r12_view, r13_view, r14_view, r15_view,
									  HI_view, LO_view, Zhi_view, Zlo_view, PC_view, MDR_view, MAR_view, Inport_view, Outport_view, C_extended_view,									  
									  Data_view, Y_view, IR_view,
					input reset_div, Gra, Grb, Grc, Rin, Rout, BAout,
					output calc_finished, con_ff_view, mem_data_out
					);	
	//List of registers, may still be useful
	//r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15,
	//HIreg, LOreg, Zhigh, Zlo, PC, MDR, Inport, C_extended, Data,
	
	wire[31:0] SEL_bus, IR_contents;
	Register IR(.D(BusMuxOut), .Q(IR_contents), .clear(clr), .clock(clk), .enable(IR_rd));
	assign IR_view = IR_contents;
	
	/*
	wire[15:0] R_wrt;
	wire[15:0] R_rd;
	//instantiate select and encode logic module)
	select_and_encode SEL_E_inst(.IRin(IR_view), .Gra(Gra), .Grb(Grb), .Grc(Grc), .Rin(Rin), .Rout(Rout), .BAout(BAout), .C_extended(SEL_bus), .R_rd(R_rd), .R_wrt(R_wrt));
	*/
	//assign general register control signals	
	wire r0_rd, r1_rd, r2_rd, r3_rd, r4_rd, r5_rd, r6_rd, r7_rd, r8_rd, r9_rd, r10_rd, r11_rd, r12_rd, r13_rd, r14_rd, r15_rd;
	
	//Register data signals (going to bus)
	wire[31:0] r0_bus, r1_bus, r2_bus, r3_bus, r4_bus, r5_bus, r6_bus, r7_bus, r8_bus, r9_bus, r10_bus, r11_bus, r12_bus, r13_bus, r14_bus, r15_bus,
				  HI_bus, LO_bus, Zhi_bus, Zlo_bus, PC_bus, MDR_bus, In_bus, C_bus;
	
	
	//Instantiate general registers with select encode logic
	Register_0 r0(.D(BusMuxOut), .Q(r0_bus), .clear(clr), .clock(clk), .enable(R_rd[0]), .BAout(BAout));
	Register r1(.D(BusMuxOut), .Q(r1_bus), .clear(clr), .clock(clk), .enable(R_rd[1])); 
	Register r2(.D(BusMuxOut), .Q(r2_bus), .clear(clr), .clock(clk), .enable(R_rd[2]));
	Register r3(.D(BusMuxOut), .Q(r3_bus), .clear(clr), .clock(clk), .enable(R_rd[3]));
	Register r4(.D(BusMuxOut), .Q(r4_bus), .clear(clr), .clock(clk), .enable(R_rd[4]));
	Register r5(.D(BusMuxOut), .Q(r5_bus), .clear(clr), .clock(clk), .enable(R_rd[5]));
	Register r6(.D(BusMuxOut), .Q(r6_bus), .clear(clr), .clock(clk), .enable(R_rd[6]));
	Register r7(.D(BusMuxOut), .Q(r7_bus), .clear(clr), .clock(clk), .enable(R_rd[7]));
	Register r8(.D(BusMuxOut), .Q(r8_bus), .clear(clr), .clock(clk), .enable(R_rd[8]));
	Register r9(.D(BusMuxOut), .Q(r9_bus), .clear(clr), .clock(clk), .enable(R_rd[9]));
	Register r10(.D(BusMuxOut), .Q(r10_bus), .clear(clr), .clock(clk), .enable(R_rd[10]));
	Register r11(.D(BusMuxOut), .Q(r11_bus), .clear(clr), .clock(clk), .enable(R_rd[11]));
	Register r12(.D(BusMuxOut), .Q(r12_bus), .clear(clr), .clock(clk), .enable(R_rd[12]));
	Register r13(.D(BusMuxOut), .Q(r13_bus), .clear(clr), .clock(clk), .enable(R_rd[13]));
	Register r14(.D(BusMuxOut), .Q(r14_bus), .clear(clr), .clock(clk), .enable(R_rd[14]));
	Register r15(.D(BusMuxOut), .Q(r15_bus), .clear(clr), .clock(clk), .enable(R_rd[15]));
	
	assign r0_view = r0_bus;
	assign r1_view = r1_bus;
	assign r2_view = r2_bus;
	assign r3_view = r3_bus;
	assign r4_view = r4_bus;
	assign r5_view = r5_bus;
	assign r6_view = r6_bus;
	assign r7_view = r7_bus;
	assign r8_view = r8_bus;
	assign r9_view = r9_bus;
	assign r10_view = r10_bus;
	assign r11_view = r11_bus;
	assign r12_view = r12_bus;
	assign r13_view = r13_bus;
	assign r14_view = r14_bus;
	assign r15_view = r15_bus;
	
	wire[31:0] extended_val;
	//Instantiate unique general registers
	Register HIreg(.D(BusMuxOut), .Q(HI_bus), .clear(clr), .clock(clk), .enable(HI_rd));
	Register LOreg(.D(BusMuxOut), .Q(LO_bus), .clear(clr), .clock(clk), .enable(LO_rd));	
	Inport Inport_inst(.D(In_out), .Q(In_bus), .clear(clr), .clock(clk));
	Outport Outport_inst(.D(BusMuxOut), .Q(Outport_view), .clear(clr), .clock(clk), .enable(Out_rd));
	Register C_extended(.D(extended_val), .Q(C_bus), .clear(clr), .clock(clk), .enable(1));
	
	assign HI_view = HI_bus;
	assign LO_view = LO_bus;
	assign Inport_view = In_bus;
	
	/*
	//Instantiate Memory registers (MDR, MAR) and Memory
	wire[8:0] mem_addr;
	wire[31:0] Mdatain;
	*/
	MDR mem_data_reg(.Q(MDR_bus), .Clear(clr), .Clock(clk), .enable(MDR_rd), .Read_from_mem(Read), .in_from_bus(BusMuxOut), .Mdatain(Mdatain));
	Register mem_addr_reg(.D(BusMuxOut), .Q(mem_addr), .clear(clr), .clock(clk), .enable(MAR_rd));
	assign MDR_view = MDR_bus;
	assign MAR_view = mem_addr;
	/*
	memory memory_inst(.Datain(MDR_bus), .Address(mem_addr), .Write(Write), .clk(clk), .Dataout(Mdatain));
	

	*/
	//Data signal is all Write-to-bus signals concatenated together.
	
	PCreg PC(.D(BusMuxOut), .Q(PC_bus), .clr(clr), .clk(clk), .increment(IncPC), .enable(PC_rd));
	assign PC_view = PC_bus;
	
	wire[31:0] Data;
	assign Data[31:24] = 0; //To fix high-impedance error
	assign Data[23:0] = {C_out, In_out, MDR_out, PC_out, Zlo_out, Zhi_out, LO_out, HI_out, 
								R_wrt[15], R_wrt[14], R_wrt[13], R_wrt[12], R_wrt[11], R_wrt[10], R_wrt[9], R_wrt[8], R_wrt[7], R_wrt[6], R_wrt[5], R_wrt[4], R_wrt[3], R_wrt[2], R_wrt[1], R_wrt[0]};
	
	assign Data_view = Data;
	Bus bus_inst(.r0(r0_bus), .r1(r1_bus), .r2(r2_bus), .r3(r3_bus), .r4(r4_bus), .r5(r5_bus), .r6(r6_bus), .r7(r7_bus), .r8(r8_bus), .r9(r9_bus), .r10(r10_bus), .r11(r11_bus),
					 .r12(r12_bus), .r13(r13_bus), .r14(r14_bus), .r15(r15_bus), .HIreg(HI_bus), .LOreg(LO_bus), .Zhigh(Zhi_bus), .Zlo(Zlo_bus), .PC(PC_bus), .MDR(MDR_bus), .Inport(In_bus),
					 .C_extended(C_bus), .Data(Data),
					 .BusMuxOut(BusMuxOut));
	
	wire[31:0] Y_contents;
	//register for Holding A operand
	Register Y(.D(BusMuxOut), .Q(Y_contents), .clear(clr), .clock(clk), .enable(Y_rd));
	assign Y_view = Y_contents;
	
	wire[31:0] Zhi_input, Zlo_input;
	ALU alu_inst(.A(BusMuxOut), .B(BusMuxOut), .Y(Y_contents), .op_sel(op_sel), .Zhigh(Zhi_input), .Zlo(Zlo_input),
					 .calc_finished(calc_finished), .reset(reset_div), .clk(clk)); //three ports for getting division to work	
	//ALU output registers
	Register Zhigh(.D(Zhi_input), .Q(Zhi_bus), .clear(clr), .clock(clk), .enable(Zhi_rd));
	Register Zlo(.D(Zlo_input), .Q(Zlo_bus), .clear(clr), .clock(clk), .enable(Zlo_rd));
	assign Zhi_view = Zhi_bus;
	assign Zlo_view = Zlo_bus;
	
	//Instantiate "CON FF" logic module
	//CON_FF con_ff_inst(.IRin(IR_contents), .BusIn(BusMuxOut), .to_ctrl(con_ff_view));
endmodule
	