//23-to-1 mux with 5-digit encoder input CURRENTLY WORKING
module Bus(
	input [31: 0] r0,
	input [31: 0] r1,
	input [31: 0] r2,
	input [31: 0] r3,
	input [31: 0] r4,
	input [31: 0] r5,
	input [31: 0] r6,
	input [31: 0] r7,
	input [31: 0] r8,
	input [31: 0] r9,
	input [31: 0] r10,
	input [31: 0] r11,
	input [31: 0] r12,
	input [31: 0] r13,
	input [31: 0] r14,
	input [31: 0] r15,
	input [31: 0] HIreg,
	input [31: 0] LOreg,
	input [31: 0] Zhigh,
	input [31: 0] Zlo,
	input [31: 0] PC,
	input [31: 0] MDR,
	input [31: 0] Inport,
	input [31: 0] C_extended,
	input [31: 0] Data,
	output reg [31: 0] BusMuxOut);
	
	wire [4:0] select;
	busEncoder encoder(.Data(Data),
							 .Code(select));
	always @ (*)
		begin
		case(select)
			5'b00000 : BusMuxOut <= r0;
			5'b00001 : BusMuxOut <= r1;
			5'b00010 : BusMuxOut <= r2;
			5'b00011 : BusMuxOut <= r3;
			5'b00100 : BusMuxOut <= r4;
			5'b00101 : BusMuxOut <= r5;
			5'b00110 : BusMuxOut <= r6;
			5'b00111 : BusMuxOut <= r7;
			5'b01000 : BusMuxOut <= r8;
			5'b01001 : BusMuxOut <= r9;
			5'b01010 : BusMuxOut <= r10;
			5'b01011 : BusMuxOut <= r11;
			5'b01100 : BusMuxOut <= r12;
			5'b01101 : BusMuxOut <= r13;
			5'b01110 : BusMuxOut <= r14;
			5'b01111 : BusMuxOut <= r15;
			5'b10000 : BusMuxOut <= HIreg;
			5'b10001 : BusMuxOut <= LOreg;
			5'b10010 : BusMuxOut <= Zhigh;
			5'b10011 : BusMuxOut <= Zlo;
			5'b10100 : BusMuxOut <= PC;
			5'b10101 : BusMuxOut <= MDR;
			5'b10110 : BusMuxOut <= Inport;
			5'b10111 : BusMuxOut <= C_extended;
			default	: BusMuxOut <= r0;
		endcase
	end
	
endmodule