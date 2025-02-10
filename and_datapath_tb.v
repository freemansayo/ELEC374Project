	// and datapath_tb.v file: (WORKS AS INTENDED)
`timescale 1ns/10ps
module and_datapath_tb;
	
	//add any other signals to see in your simulation
	reg HI_out, LO_out, Zhi_out, Zlo_out, PC_out, MDR_out, MAR_out, In_out, C_out;
	reg[15:0] R_in;
	reg[15:0] R_out;
	reg MARin, Zlowin, PCin, MDRin, IRin, Yin;
	reg IncPC, Read;
	reg [4:0] opcode;
	reg Clock, clear;
	reg [31:0] Mdatain;
	parameter Default =4'b0000, Reg_load3a = 4'b0001, Reg_load3b = 4'b0010, Reg_load4a = 4'b0011,
				 Reg_load4b = 4'b0100, Reg_load7a = 4'b0101, Reg_load7b = 4'b0110, T0 = 4'b0111,
				 T1 = 4'b1000, T2 = 4'b1001, T3 = 4'b1010, T4 = 4'b1011, T5 = 4'b1100;
	reg [3:0] Present_state = Default;
	
	//want to see following signals on monitor
	wire[31:0] r3_v, r4_v, r7_v, Y_v, Zlo_v, MDR_v, BusMuxOut_v, Data_v, PC_v;
	Datapath DUT(.R_rd(R_in), .R_wrt(R_out), .HI_out(HI_out), .LO_out(LO_out), .Zhi_out(Zhi_out), .Zlo_out(Zlo_out), .PC_out(PC_out), .MDR_out(MDR_out), 
					 .MAR_out(MAR_out), .In_out(In_out), .C_out(C_out), .MAR_rd(MARin), .Zlo_rd(Zlowin), .PC_rd(PCin), .MDR_rd(MDRin), .IR_rd(IRin), .Y_rd(Yin),
					 .IncPC(IncPC), .Read(Read), .op_sel(opcode), .clk(Clock), .clr(clear), .Mdatain(Mdatain), .r3_view(r3_v), 
					 .r4_view(r4_v), .r7_view(r7_v), .Y_view(Y_v), .Zlo_view(Zlo_v), .MDR_view(MDR_v), .BusMuxOut(BusMuxOut_v), .Data_view(Data_v), .PC_view(PC_v));
	// add test logic here
initial 
	begin
		Clock = 0;
		repeat(250) #10 Clock = ~ Clock;
end

always @(posedge Clock)//finite state machine; if clock rising-edge
begin
	case (Present_state)
		Default			:	#40 Present_state = Reg_load3a;
		Reg_load3a		:	#40 Present_state = Reg_load3b;
		Reg_load3b		:	#40 Present_state = Reg_load4a;
		Reg_load4a		:	#40 Present_state = Reg_load4b;
		Reg_load4b		:	#40 Present_state = Reg_load7a;
		Reg_load7a		:	#40 Present_state = Reg_load7b;
		Reg_load7b		:	#40 Present_state = T0;
		T0					:	#40 Present_state = T1;
		T1					:	#40 Present_state = T2;
		T2					:	#40 Present_state = T3;
		T3					:	#40 Present_state = T4;
		T4					:	#40 Present_state = T5;
		endcase
	end

always @(Present_state)// do the required job ineach state
begin
	case (Present_state)              //assert the required signals in each clock cycle
		Default: begin
				clear <= 0;
				//initialize write-to-bus signals
				R_out <= 0; HI_out <= 0; LO_out <= 0; Zhi_out <= 0; Zlo_out <= 0; PC_out <= 0; MDR_out <= 0; MAR_out <= 0; 
				In_out <= 0; C_out <= 0;
				//initialize read-from-bus signals
				MARin <= 0;   Zlowin <= 0; PCin <=0;   MDRin <= 0;   IRin  <= 0;   Yin <= 0; R_in <= 0; R_in[3] <= 0; R_in[4] <= 0; R_in[7] <= 0; Mdatain <= 32'h00000000;
				IncPC <= 0;   Read <= 0;   opcode <= 0;
				
		end
		Reg_load3a: begin 
				Mdatain<= 32'h00000099; //1001 1001
				Read = 0; MDRin = 0;	
				#10 Read <= 1; MDRin <= 1;  
				#15 Read <= 0; MDRin <= 0;
		end
		Reg_load3b: begin
				#10 MDR_out<= 1; R_in[3] <= 1;  
				#15 MDR_out<= 0; R_in[3] <= 0;
		end
		Reg_load4a: begin 
				Mdatain <= 32'h00000014; //0001 0100
				#10 Read <= 1; MDRin <= 1;  
				#15 Read <= 0; MDRin <= 0;
		end
		Reg_load4b: begin
				#10 MDR_out<= 1; R_in[4] <= 1;  
				#15 MDR_out<= 0; R_in[4] <= 0;
		end
		Reg_load7a: begin 
				Mdatain <= 32'h000000F6; //1111 0110
				#10 Read <= 1; MDRin <= 1;  
				#15 Read <= 0; MDRin <= 0;
		end
		Reg_load7b: begin
				#10 MDR_out<= 1; R_in[7] <= 1;  
				#15 MDR_out<= 0; R_in[7] <= 0;
		end
	
		T0: begin
				Mdatain <= 32'h00000007; 
				PCin <= 1; MDR_out <=1;
				
				#10 PCin <= 0; MDR_out <=0; PC_out<= 0; MARin <= 0; IncPC <= 1;
				#10 /*PC_out<= 1;*/ MARin <= 1; IncPC <= 0; //ZLowIn <= 1;
		end
		T1: begin
				Mdatain <= 32'h2A2B8000;    //opcode for and R4, R3, R7
				Read <= 1; MDRin <= 1;
				#10 Read <= 0; MDRin <= 0;
				
		end
		T2: begin
				MDR_out<= 1; IRin <= 1; 
				#10 MDR_out<= 0; IRin <= 0; 
		end
		T3: begin
				#10 R_out[3] <= 1; Yin <= 1;  
				#10 R_out[3] <= 0; Yin <= 0;
		end
		T4: begin
				R_out[7] <= 1; opcode <= 5'b00101; Zlowin <= 1; 
				#25 R_out[7] <= 0; Zlowin <= 0; 
		end
		T5: begin
				Zlo_out<= 1; R_in[4] <= 1; 
				#25 Zlo_out<= 0; R_in[4] <= 0;
				
		end
	endcase
end
endmodule
