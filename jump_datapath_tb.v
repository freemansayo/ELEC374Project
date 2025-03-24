// jump datapath_tb.v file: jump_datapath_tb
`timescale 1ns/10ps
module jump_datapath_tb;
//NOTE: USE ONLY THIS TB FOR BRANCH DEMOS, ACCESS "init_jr.hex" AND CHANGE THE MEMORY VALUES TO SWITCH
	//INSTRUCTIONS
	
	//ONLY USED FOR PRELOADING REGISTERS, USE OTHER SIGNALS FOR REGISTER CONTROL IN MAIN TB BODY
	reg[15:0] R_rd;
	reg[15:0] R_wrt;
	reg[4:0] op_sel;
	reg R_out, HI_out, LO_out, Zhi_out, Zlo_out, PC_out, MDR_out, MAR_out, In_out, C_out;
	reg Rin, MARin, Zlowin, PCin, MDRin, IRin, Yin, CONin;
	reg IncPC, Read, Write, Gra, Grb, Grc, BAout;
	reg clk, clear;
	parameter Default = 0, 	Reg_load1a = 1, Reg_load1b = 2, Reg_load1c = 3,
									Reg_loadPCa = 4, Reg_loadPCb = 5, Reg_loadPCc = 6,
									T0 = 7, T1 = 8, T2 = 9, T3 = 10;
	
	reg [4:0] Present_state = Default;
	
	// Want to view following signals on monitor
	wire [8:0] MAR_v;
	wire [31:0] MDR_v, r1_v, C_v, IR_v, PC_v, Y_v, Zlo_v, BusMuxOut_v, regControl_v;
	wire CON_out;
	
	Datapath DUT(.R_rd_diog(R_rd), .R_wrt_diog(R_wrt), .Rin(Rin), .CONin(CONin), .R_out(R_out), .HI_out(HI_out), .LO_out(LO_out), .Zhi_out(Zhi_out), .Zlo_out(Zlo_out), .PC_out(PC_out), .MDR_out(MDR_out), 
					 .MAR_out(MAR_out), .In_out(In_out), .C_out(C_out), .CON_output(CON_out), .MAR_rd(MARin), .Zlo_rd(Zlowin), .PC_rd(PCin), .MDR_rd(MDRin), .IR_rd(IRin), .Y_rd(Yin),
					 .IncPC(IncPC), .Read(Read), .Write(Write), .clk(clk), .clr(clear), .Gra(Gra), .Grb(Grb), .Grc(Grc), .BAout(BAout),
					 .r1_view(r1_v), .Y_view(Y_v), .Zlo_view(Zlo_v), .MDR_view(MDR_v), .MAR_view(MAR_v), .BusMuxOut(BusMuxOut_v), .regControl_view(regControl_v),
					 .PC_view(PC_v), .IR_view(IR_v), .C_extended_view(C_v));
	// add test logic here
initial 
	begin
		clk = 0;
		repeat(250) #10 clk = ~ clk; //entire clock cycle is 20ns
end
	always @(posedge clk)
        begin
            case (Present_state)
                Default			   :	#40 Present_state = Reg_load1a;
					 Reg_load1a 		:	#40 Present_state = Reg_load1b;
					 Reg_load1b			:	#40 Present_state = Reg_load1c;
					 Reg_load1c			:	#40 Present_state = Reg_loadPCa;
					 Reg_loadPCa 		:	#40 Present_state = Reg_loadPCb;
					 Reg_loadPCb		:	#40 Present_state = Reg_loadPCc;
					 Reg_loadPCc		:	#40 Present_state = T0;
					 T0					:	#40 Present_state = T1;
                T1					:	#40 Present_state = T2;
                T2					:	#40 Present_state = T3;
		    endcase
	end
//Location of instructions:
//Case 1: address 1

//Initial Register contents: 
//R1 = DEFINED VALUE BASED ON TEST, located at address 0
//PC = DEFINED VALUE BASED ON TEST, located at address 1 (points to address of instruction minus 1)
always @(Present_state) 
	begin
		case (Present_state) 
			Default: begin
				//initialize write-to-bus signals
				R_out <= 0; HI_out <= 0; LO_out <= 0; Zhi_out <= 0; Zlo_out <= 0; PC_out <= 0; MDR_out <= 0; MAR_out <= 0; BAout <= 0; R_wrt <= 0; 
				In_out <= 0; C_out <= 0;
				
				//initialize read-from-bus signals
				MARin <= 0; Zlowin <= 0; PCin <=0; MDRin <= 0; IRin <= 0; Yin <= 0; Rin <= 0; R_rd <= 0; CONin <= 0;
				
				//initialize memory-related signals
				IncPC <= 0; Read <= 0;
				
				//Initialize S&E-Related signals
				Gra <= 0; Grb <= 0; Grc <= 0;
				
				//Flush registers in case r0 gets used
				clear <= 1;
				#20
				clear <= 0;
			end
			
			//Load initial value into R8, first fetch from address 0 and place that data into MDR
			Reg_load1a: begin
				PC_out <= 1; MARin <= 1;
				#20
				PC_out <= 0; MARin <= 0; 
			end
			
			//Place data at address 0 into MDR
			Reg_load1b: begin
				MDRin <= 1;
				Read <= 1;
				#20
				MDRin <= 0;
				Read <= 0;
			end
			
			//Place data from MDR into R8
			Reg_load1c: begin
				IncPC <= 1;
				#5
				IncPC <= 0;
				MDR_out<= 1; R_rd[8] <= 1; 
				#15
				MDR_out <= 0; R_rd[8] <= 0;
			end
			
			//Load initial value into PC, first fetch from address 1 and place that data into MDR
			Reg_loadPCa: begin
				PC_out <= 1; MARin <= 1;
				#20
				PC_out <= 0; MARin <= 0; 
			end
			
			//Place data at address 1 into MDR
			Reg_loadPCb: begin
				MDRin <= 1;
				Read <= 1;
				#20
				MDRin <= 0;
				Read <= 0;
			end
			
			//Place data from MDR into PC
			Reg_loadPCc: begin
				MDR_out<= 1; PCin <= 1; 
				#20
				MDR_out <= 0; PCin <= 0;
			end
			
		//Start executing Case 1: jr R8 
			T0: begin 
				IncPC <= 1;
				#5
				IncPC <= 0;
				PC_out <= 1; MARin <= 1; Zlowin <= 1;
				#15
				PC_out <= 0; MARin <= 0; Zlowin <= 0;
			end

			T1: begin //Loads MDR from RAM output (loads from specified address in memory) 
				Zlo_out <= 1; PCin <= 1; Read <= 1; MDRin <= 1;
				#20
				Zlo_out <= 0; PCin <= 0; Read <= 0; MDRin <= 0;
			end

			T2: begin //Load MDR contents into IR
				MDR_out <= 1; IRin <= 1;
				#20
				MDR_out <= 0; IRin <= 0;
			end

			T3: begin // Load in the contents of R8 into PC register
				Gra <= 1; R_out <= 1; PCin <= 1;
				#20
				Gra <= 0; R_out <= 0; PCin <= 0;
			end

		endcase
	end			 
endmodule 
