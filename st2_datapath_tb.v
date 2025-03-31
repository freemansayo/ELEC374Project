// ST2 datapath_tb.v file
`timescale 1ns/10ps
module st2_datapath_tb;
	
	//ONLY USED FOR PRELOADING REGISTERS, USE OTHER SIGNALS FOR REGISTER CONTROL IN MAIN TB BODY
	reg[15:0] R_rd;
	reg[15:0] R_wrt;
	reg[4:0] op_sel;
	reg R_out, HI_out, LO_out, Zhi_out, Zlo_out, PC_out, MDR_out, MAR_out, In_out, C_out;
	reg Rin, MARin, Zlowin, PCin, MDRin, IRin, Yin;
	reg IncPC, Read, Write, Gra, Grb, Grc, BAout;
	reg clk, clear;
	parameter Default = 0, Reg_load3a = 1, Reg_load3b = 2, Reg_load3c = 3,
				 T0 = 4, T1 = 5, T2 = 6, T3 = 7, T4 = 8, T5 = 9, T6 = 10, T7 = 11;
	
	reg [4:0] Present_state = Default;
	
	//Want to view following signals on monitor
	wire [8:0] MAR_v;
	wire [31:0] MDR_v, r3_v, IR_v, C_v, PC_v, Y_v, Zlo_v, BusMuxOut_v, regControl_v;
	
	
	Datapath DUT(.R_rd_diog(R_rd), .R_wrt_diog(R_wrt), .Rin(Rin), .R_out(R_out), .HI_out(HI_out), .LO_out(LO_out), .Zhi_out(Zhi_out), .Zlo_out(Zlo_out), .PC_out(PC_out), .MDR_out(MDR_out), 
					 .MAR_out(MAR_out), .In_out(In_out), .C_out(C_out), .MAR_rd(MARin), .Zlo_rd(Zlowin), .PC_rd(PCin), .MDR_rd(MDRin), .IR_rd(IRin), .Y_rd(Yin),
					 .IncPC(IncPC), .Read(Read), .Write(Write), .clk(clk), .clr(clear), .Gra(Gra), .Grb(Grb), .Grc(Grc), .BAout(BAout),
					 .r3_view(r3_v), .C_extended_view(C_v), .Y_view(Y_v), .Zlo_view(Zlo_v), .MDR_view(MDR_v), .MAR_view(MAR_v), .BusMuxOut(BusMuxOut_v), .regControl_view(regControl_v),
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
                Default			   :	#40 Present_state = Reg_load3a;
					 Reg_load3a 		:	#40 Present_state = Reg_load3b;
					 Reg_load3b			:	#40 Present_state = Reg_load3c;
					 Reg_load3c			:	#40 Present_state = T0;
					 T0					:	#40 Present_state = T1;
                T1					:	#40 Present_state = T2;
                T2					:	#40 Present_state = T3;
                T3					:	#40 Present_state = T4;
                T4					:	#40 Present_state = T5;
                T5					:	#40 Present_state = T6;
                T6					:	#40 Present_state = T7;
					 
		    endcase
	end
//Location of instructions:
//Case 2: address 7

//Initial Register contents: R3 = 0xB6, located at address 5
//Case 4: Store contents of R3 at address 0x34 + B6 = EA  (initially contains 0x19)
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
				IncPC <= 0; Read <= 0; Write <= 0;
				//Initialize S&E-Related signals
				Gra <= 0; Grb <= 0; Grc <= 0;
				//Flush registers in case r0 gets used
				clear <= 1;
				#20
				clear <= 0;
			end
			
			//Load initial value into R3, first fetch from address 5 and place that data into MDR
			Reg_load3a: begin
				IncPC <= 1; PC_out <= 1; MARin <= 1;
				#1
				IncPC <= 0;
				#1
				IncPC <= 1;
				#1
				IncPC <= 0;
				#1
				IncPC <= 1;
				#1
				IncPC <= 0;
				#1
				IncPC <= 1;
				#1
				IncPC <= 0;
				#1
				IncPC <= 1;
				#1
				IncPC <= 0;
				#11
				PC_out <= 0; MARin <= 0; 
			end
			
			//Place data at address 5 into MDR
			Reg_load3b: begin
				MDRin <= 1;
				Read <= 1;
				#20
				MDRin <= 0;
				Read <= 0;
			end
			
			//Place data from MDR into R3
			Reg_load3c: begin
				MDR_out<= 1; R_rd[3] <= 1; 
				#20
				MDR_out <= 0; R_rd[3] <= 0;
			end
			
		//Start executing Case 1: st 0x34, R3
			//Determine starting address (Case 2 instruction stored at address 7)
			T0: begin 
				IncPC <= 1;
				#1
				IncPC <= 0;
				#1
				IncPC <= 1;
				#1
				IncPC <= 0;
				PC_out <= 1; MARin <= 1; Zlowin <= 1;
				#17
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

			T3: begin //Using select and encode logic, enable register b designated in opcode, and place stored value into Y
				Grb <= 1; BAout <= 1; R_out <= 1; Yin <= 1;
				#20
				Grb <= 0; BAout <= 0; R_out <= 0; Yin <= 0;
			end

			T4: begin //Determine offsetted address, store result in Z, unsure how to go about properly starting the addition here
				C_out <= 1; op_sel <= 5'b00011; Zlowin <= 1;
				#20;
				C_out <= 0; op_sel <= 0; Zlowin <= 0;
			end

			T5: begin //Place offsetted address in MAR
				Zlo_out <= 1; MARin <= 1;
				#20
				Zlo_out <= 0; MARin <= 0;
			end

			T6: begin //Place source register's data into MDR
				Gra <= 1; R_out <= 1; MDRin <= 1;
				#20
				Gra <= 0; R_out <= 0; MDRin <= 0;
			end
			
			T7: begin //Write to memory at offsetted address
				Write <= 1;
				#20
				Write <= 0;
			end
			//Check memory in simulation to verify that the store went through
			
		endcase
	end

endmodule
