// ANDI datapath_tb.v file
`timescale 1ns/10ps
module andi_datapath_tb;
	
	//ONLY USED FOR PRELOADING REGISTERS, USE OTHER SIGNALS FOR REGISTER CONTROL IN MAIN TB BODY
	reg[15:0] R_rd;
	reg[15:0] R_wrt;
	reg[4:0] op_sel;
	reg R_out, HI_out, LO_out, Zhi_out, Zlo_out, PC_out, MDR_out, MAR_out, In_out, C_out;
	reg Rin, MARin, Zlowin, PCin, MDRin, IRin, Yin;
	reg IncPC, Read, Write, Gra, Grb, Grc, BAout;
	reg clk, clear;
	parameter Default = 0, 	Reg_load5a = 1, Reg_load5b = 2, Reg_load5c = 3,
									Reg_load6a = 4, Reg_load6b = 5, Reg_load6c = 6,
									T0 = 7, T1 = 8, T2 = 9, T3 = 10, T4 = 11, T5 = 12;
	
	reg [4:0] Present_state = Default;
	
	//Want to view following signals on monitor
	wire [8:0] MAR_v;
	wire [31:0] MDR_v, r5_v, r6_v, IR_v, PC_v, Y_v, Zlo_v, BusMuxOut_v, regControl_v;
	
	
	Datapath DUT(.R_rd_diog(R_rd), .R_wrt_diog(R_wrt), .Rin(Rin), .R_out(R_out), .HI_out(HI_out), .LO_out(LO_out), .Zhi_out(Zhi_out), .Zlo_out(Zlo_out), .PC_out(PC_out), .MDR_out(MDR_out), 
					 .MAR_out(MAR_out), .In_out(In_out), .C_out(C_out), .MAR_rd(MARin), .Zlo_rd(Zlowin), .PC_rd(PCin), .MDR_rd(MDRin), .IR_rd(IRin), .Y_rd(Yin),
					 .IncPC(IncPC), .op_sel(op_sel), .Read(Read), .Write(Write), .clk(clk), .clr(clear), .Gra(Gra), .Grb(Grb), .Grc(Grc), .BAout(BAout),
					 .r5_view(r5_v), .r6_view(r6_v), .Y_view(Y_v), .Zlo_view(Zlo_v), .MDR_view(MDR_v), .MAR_view(MAR_v), .BusMuxOut(BusMuxOut_v), .regControl_view(regControl_v),
					 .PC_view(PC_v), .IR_view(IR_v));
	// add test logic here
initial 
	begin
		clk = 0;
		repeat(250) #10 clk = ~ clk; //entire clock cycle is 20ns
end
	always @(posedge clk)
        begin
            case (Present_state)
                Default			   :	#40 Present_state = Reg_load5a;
					 Reg_load5a 		:	#40 Present_state = Reg_load5b;
					 Reg_load5b			:	#40 Present_state = Reg_load5c;
					 Reg_load5c			:	#40 Present_state = Reg_load6a;
					 Reg_load6a 		:	#40 Present_state = Reg_load6b;
					 Reg_load6b			:	#40 Present_state = Reg_load6c;
					 Reg_load6c			:	#40 Present_state = T0;
					 T0					:	#40 Present_state = T1;
                T1					:	#40 Present_state = T2;
                T2					:	#40 Present_state = T3;
                T3					:	#40 Present_state = T4;
                T4					:	#40 Present_state = T5;
					 
		    endcase
	end
//Location of instructions:
//andi R5, R6, 0x95 @ address 3

//Initial Register contents:
//R5 = 0x45 @ address 0
//R6 = 0x50 @ address 1

always @(Present_state) 

	begin
		case (Present_state) 
			Default: begin
				//initialize write-to-bus signals
				R_out <= 0; HI_out <= 0; LO_out <= 0; Zhi_out <= 0; Zlo_out <= 0; PC_out <= 0; MDR_out <= 0; MAR_out <= 0; BAout <= 0; R_wrt <= 0; 
				In_out <= 0; C_out <= 0;
				//initialize read-from-bus signals
				MARin <= 0; Zlowin <= 0; PCin <=0; MDRin <= 0; IRin <= 0; Yin <= 0; Rin <= 0; R_rd <= 0;
				//initialize memory-related signals
				IncPC <= 0; Read <= 0;
				//Initialize S&E-Related signals
				Gra <= 0; Grb <= 0; Grc <= 0;
				clear <= 1;
				#20
				clear <= 0;
			end
			
			//Load initial value into R5, first fetch from address 0 and place that data into MDR
			Reg_load5a: begin
				PC_out <= 1; MARin <= 1;
				#20
				PC_out <= 0; MARin <= 0; 
			end
			
			//Place data at address 0 into MDR
			Reg_load5b: begin
				MDRin <= 1;
				Read <= 1;
				#20
				MDRin <= 0;
				Read <= 0;
			end
			
			//Place data from MDR into R5
			Reg_load5c: begin
				IncPC <= 1; MDR_out<= 1; R_rd[5] <= 1; 
				#5
				IncPC <= 0;
				#15 MDR_out <= 0; R_rd[5] <= 0;
			end
			
			Reg_load6a: begin
				PC_out <= 1; MARin <= 1;
				#20
				PC_out <= 0; MARin <= 0; 
			end
			
			//Place data at address 1 into MDR
			Reg_load6b: begin
				MDRin <= 1;
				Read <= 1;
				#20
				MDRin <= 0;
				Read <= 0;
			end
			
			//Place data from MDR into R6
			Reg_load6c: begin
				IncPC <= 1;MDR_out<= 1; R_rd[6] <= 1; 
				#5
				IncPC <= 0;
				#15
				MDR_out <= 0; R_rd[6] <= 0;
			end
			
		//Start executing andi R5, R6, 0x95
			//Determine starting address (@3)
			T0: begin
				IncPC <= 1; PC_out <= 1; MARin <= 1; Zlowin <= 1;
				#5
				IncPC <= 0;
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

			T3: begin //Using select and encode logic, enable register designated in opcode, and place stored value into Y
				Grb <= 1; BAout <= 1; R_out <= 1; Yin <= 1;
				#20
				Grb <= 0; BAout <= 0; R_out <= 0; Yin <= 0;
			end

			T4: begin //Perform addition, store result in Z
				C_out <= 1; op_sel <= 5'b00101; Zlowin <= 1;
				#20;
				C_out <= 0; op_sel <= 0; Zlowin <= 0;
			end

			T5: begin //Place value in Z into destination register
				Zlo_out <= 1; Gra <= 1; Rin <= 1;
				#20
				Zlo_out <= 0; Gra <= 0; Rin <= 0;
			end
		endcase
	end

endmodule
