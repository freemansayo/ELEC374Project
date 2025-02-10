// DIV datapath_tb.v file: (NOT WORKING)
`timescale 1ns/10ps
module div_datapath_tb;
	
	//add any other signals to see in your simulation
	reg HI_out, LO_out, Zhi_out, Zlo_out, PC_out, MDR_out, MAR_out, In_out, C_out;
	reg[15:0] R_in;
	reg[15:0] R_out;
	reg MARin, Zhi_in, Zlowin, PCin, MDRin, IRin, Yin;
	reg IncPC, Read;
	reg HI_in, LOin;
	reg [4:0] opcode;
	reg Clock, clear, inloop, reset;
	reg [31:0] Mdatain;
	wire calc_finished;
	parameter Default =4'b0000, Reg_load2a = 4'b0001, Reg_load2b = 4'b0010, Reg_load6a = 4'b0011,
				 Reg_load6b = 4'b0100, T0 = 4'b0101, T1 = 4'b0110, T2 = 4'b0111, T3 = 4'b1000, 
				 T4 = 4'b1001, T5 = 4'b1010, T6 = 4'b1011;
	reg [3:0] Present_state = Default;
	
	//want to see following signals on monitor
	wire[31:0] r2_v, r6_v, Y_v, Zhi_v, Zlo_v, HI_v, LO_v, MDR_v, BusMuxOut_v, Data_v, PC_v;
Datapath DUT(.R_rd(R_in), .R_wrt(R_out), .HI_out(HI_out), .LO_out(LO_out), .Zhi_out(Zhi_out), .Zlo_out(Zlo_out), .PC_out(PC_out), .MDR_out(MDR_out), 
					 .MAR_out(MAR_out), .In_out(In_out), .C_out(C_out), .MAR_rd(MARin), .Zhi_rd(Zhi_in), .Zlo_rd(Zlowin), .PC_rd(PCin), .MDR_rd(MDRin), .IR_rd(IRin), .Y_rd(Yin),
					 .IncPC(IncPC), .Read(Read), .op_sel(opcode), .clk(Clock), .clr(clear), .Mdatain(Mdatain), 
					 .r2_view(r2_v), .r6_view(r6_v), .Y_view(Y_v), .Zhi_view(Zhi_v), .Zlo_view(Zlo_v), .MDR_view(MDR_v), .BusMuxOut(BusMuxOut_v), .Data_view(Data_v), .PC_view(PC_v),
					 .reset_div(reset), .calc_finished(calc_finished));

	// add test logic here
	
initial begin
		reset <= 1;
		Clock = 0;
		inloop <= 0;
		forever #10 Clock = ~ Clock;
		
end

always @(posedge Clock)//finite state machine; if clock rising-edge
begin
	case (Present_state)
		Default			:	#40 Present_state = Reg_load2a;
		Reg_load2a		:	#40 Present_state = Reg_load2b;
		Reg_load2b		:	#40 Present_state = Reg_load6a;
		Reg_load6a		:	#40 Present_state = Reg_load6b;
		Reg_load6b		:	#40 Present_state = T0;
		T0					:	#40 Present_state = T1;
		T1					:	#40 Present_state = T2;
		T2					:	#40 Present_state = T3;
		T3					:	#40 Present_state = T4;
		T4					:	#400 Present_state = T5;
		T5					:	#40 Present_state = T6;
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
				MARin <= 0;   Zlowin <= 0; PCin <=0;   MDRin <= 0;   IRin  <= 0;   Yin <= 0; R_in <= 0; R_in[2] <= 0; R_in[6] <= 0; Mdatain <= 32'h00000000;
				IncPC <= 0;   Read <= 0;   opcode <= 0;
		end
		Reg_load2a: begin 
				Mdatain <= 32'd97;
				Read = 0; MDRin = 0;	
				#10 Read <= 1; MDRin <= 1;  
				#15 Read <= 0; MDRin <= 0;
		end
		Reg_load2b: begin
				#10 MDR_out<= 1; R_in[2] <= 1;  
				#15 MDR_out<= 0; R_in[2] <= 0;
		end
		Reg_load6a: begin 
				Mdatain <= 32'd30;
				#10 Read <= 1; MDRin <= 1;  
				#15 Read <= 0; MDRin <= 0;
		end
		Reg_load6b: begin
				#10 MDR_out<= 1; R_in[6] <= 1;  
				#15 MDR_out<= 0; R_in[6] <= 0;
		end	
		T0: begin
				Mdatain <= 32'h00000007; 
				PCin <= 1; MDR_out <=1;
				
				#10 PCin <= 0; MDR_out <=0; PC_out<= 0; MARin <= 0; IncPC <= 1;
				#10 PC_out<= 0; MARin <= 1; IncPC <= 0; //ZLowIn <= 1;
		end
		T1: begin
				Mdatain <= 32'h4A920000; //Change this later  
				Read <= 1; MDRin <= 1;
				#10 Read <= 0; MDRin <= 0;
				
		end
		T2: begin
				MDR_out<= 1; IRin <= 1;
				#10 MDR_out<= 0; IRin <= 0;
		end
		T3: begin
				#10 R_out[2] <= 1; Yin <= 1;  
				#10 R_out[2] <= 0; Yin <= 0;
		end
		T4: begin //Zhi, Zlo take in correct value but do not output it to HI and LO registers properly
				R_out[6] <= 1; 
				
				#5 opcode <= 5'b01111; 
				
				reset <= 0;
				#5 reset <= 1;
				#20
				while(!calc_finished) begin
				#1;
				inloop = 1;
				end
				inloop <= 0;
				
				#9 R_out[6] <= 0; Zhi_in <= 1; Zlowin <= 1;
				#20 Zhi_in <= 0; Zlowin <= 0; 
				
		end
		T5: begin
				Zlo_out<= 1; LOin <= 1; 
				#25 Zlo_out<= 0; LOin <= 0;
		end
		T6: begin
				Zhi_out <= 1; HI_in <= 1;
				#25 Zhi_out <= 0; HI_in <= 0;
		end
	endcase
end
endmodule
