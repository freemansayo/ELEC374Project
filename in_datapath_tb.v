 // mfhi datapath_tb.v file: jump_datapath_tb
`timescale 1ns/10ps
module in_datapath_tb;
//NOTE: USE ONLY THIS TB FOR BRANCH DEMOS, ACCESS "init_jr.hex" AND CHANGE THE MEMORY VALUES TO SWITCH
	//INSTRUCTIONS
	
	//ONLY USED FOR PRELOADING REGISTERS, USE OTHER SIGNALS FOR REGISTER CONTROL IN MAIN TB BODY
	reg[31:0] Input_unit;
	reg[15:0] R_rd;
	reg[15:0] R_wrt;
	reg[4:0] op_sel;
	reg R_out, HI_out, LO_out, Zhi_out, Zlo_out, PC_out, MDR_out, MAR_out, In_out, Out_out, C_out;
	reg Rin, MARin, Zlowin, PCin, MDRin, IRin, Yin, CONin, HI_rd, Out_rd;
	reg IncPC, Read, Write, Gra, Grb, Grc, BAout;
	reg clk, clear;
	
    parameter Default = 0, Reg_loadR3a = 1, Reg_loadR3b = 2, Reg_loadR3c = 3, Reg_loadIn = 4,
              T0 = 5, T1 = 6, T2 = 7, T3 = 8, T4 = 9;
	
	reg [4:0] Present_state = Default;
	
	// Want to view following signals on monitor
	wire [8:0] MAR_v;
	wire [31:0] MDR_v, r3_v, In_v, C_v, IR_v, PC_v, Y_v, Zlo_v, BusMuxOut_v, regControl_v;
	wire CON_out;
	
	
	Datapath DUT(.R_rd_diog(R_rd), .R_wrt_diog(R_wrt), .Rin(Rin), .HI_rd(HI_rd), .CONin(CONin), .R_out(R_out), .HI_out(HI_out), .LO_out(LO_out), .Out_out(Out_out), .Zhi_out(Zhi_out), .Zlo_out(Zlo_out), .PC_out(PC_out), .MDR_out(MDR_out), 
					 .MAR_out(MAR_out), .In_out(In_out), .C_out(C_out), .CON_output(CON_out), .MAR_rd(MARin), .Zlo_rd(Zlowin), .PC_rd(PCin), .MDR_rd(MDRin), .IR_rd(IRin), .Y_rd(Yin),
					 .IncPC(IncPC), .Read(Read), .Write(Write), .clk(clk), .clr(clear), .Gra(Gra), .Grb(Grb), .Grc(Grc), .BAout(BAout),
					 .r3_view(r3_v), .Inport_view(In_v), .In_input(Input_unit), .Y_view(Y_v), .Zlo_view(Zlo_v), .MDR_view(MDR_v), .MAR_view(MAR_v), .BusMuxOut(BusMuxOut_v), .regControl_view(regControl_v),
					 .PC_view(PC_v), .IR_view(IR_v), .C_extended_view(C_v));
	// add test logic here
initial 
	begin
		clk = 0;
		repeat(250) #10 clk = ~ clk; //entire clock cycle is 20ns
end
    always @(posedge clk) begin
        case (Present_state)
            Default        : #40 Present_state = Reg_loadR3a;
            Reg_loadR3a    : #40 Present_state = Reg_loadR3b;
            Reg_loadR3b    : #40 Present_state = Reg_loadR3c;
            Reg_loadR3c    : #40 Present_state = Reg_loadIn;
				Reg_loadIn    : #40 Present_state = T0;
            T0             : #40 Present_state = T1;
            T1             : #40 Present_state = T2;
            T2             : #40 Present_state = T3;
            T3             : #40 Present_state = T4;
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
				
				Input_unit <= 0;
				
				//Flush registers in case r0 gets used
				clear <= 1;
				#20
				clear <= 0;
			end
			
			// Load R3 initial value (memory[0])
         Reg_loadR3a: begin 
				PC_out <= 1; MARin <= 1;
				#20
				PC_out <= 0; MARin <= 0; 
			end
           Reg_loadR3b: begin 
				MDRin <= 1; Read <= 1;
				#20
				MDRin <= 0; Read <= 0;
			end
           Reg_loadR3c: begin 
				IncPC <= 1;
				#5 
				IncPC <= 0; 
				MDR_out <= 1; R_rd[3] <= 1;
            #15 
				MDR_out <= 0; R_rd[3] <= 0;
			end
			
			//Load HI reg initial value
			Reg_loadIn: begin
				IncPC <= 1; Input_unit <= 39;
				#5
				IncPC <= 0;
			end			
			
		//Start executing in R3
			T0: begin
				PC_out <= 1; MARin <= 1; Zlowin <= 1;
				#20
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

			T3: begin // Load contents of R3 into Hi register
				Gra <= 1; Rin <= 1; In_out <= 1;
				#20
				Gra <= 0; Rin <= 0; In_out <= 0;
			end

		endcase
	end			 
endmodule 
