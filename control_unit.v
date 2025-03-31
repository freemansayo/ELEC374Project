//Control Unit Module
`timescale 1ns / 10ps

module control_unit (
    // Outputs
    output reg Gra, Grb, Grc, Rin, Rout, BAout, PCout, Zlowout, Zhighout, MDRout, LOout, HIout,
	 In_Portout, Cout, PCin, Zin, IRin, Yin, MARin, MDRin, HIin, LOin, Out_Portin, IncPC, Read,
	 Write, Clear, CONin, Run, ADD, SUB, MUL, DIV, SHR, SHRA, SHL, ROR, ROL, AND, OR, NEG, NOT,

    // Inputs
    input [31:0] IR,
    input Clock, Reset, Stop, CON_FF
);

	//change all the states, not enough bits for the number of states that are needed
	parameter reset_state = 4'b0000,
				fetch0 = 4'b0001,//multiple fetches for different clock cycles
				fetch1 = 4'b0010,//the bus can’t handle multiple data transfers simultaneously
				fetch2 = 4'b0011,
				ldi3 = 4'b0100,
				ldi4 = 4'b0101,
				add3 = 4'b0110,
				add4 = 4'b0111,
				add5 = 4'b1000
				ld3 = 4'b1001,
			   ld4 = 4'b1010,
			   ld5 = 4'b1011,
			   ld6 = 4'b1100,
					ld7 = 4'b1101;
						
	reg [3:0] present_state = reset_state;
			
			
	//FSM		
	always @(posedge Clock or posedge Reset) begin
		//reset	
		 if (Reset)
			  present_state <= reset_state;
		 else begin
			  case (present_state)//	

					reset_state: begin
						 present_state <= fetch0; //move to first fetch stage after reset
					end

					fetch0: begin
						 present_state <= fetch1; //PC to MAR, IncPC
					end

					fetch1: begin
						 present_state <= fetch2; //read memory, load into MDR
					end

					fetch2: begin
						 //instruction decode based on opcode (IR[31:27])
						 case (IR[31:27])
							  
							  5'b00000: present_state <= ld3;      //ld
							  5'b00001: present_state <= ldi3;     //ldi
							  5'b00010: present_state <= st3;      //st
							  5'b00011: present_state <= add3;     //add
							  5'b00100: present_state <= sub3;     //sub
							  5'b00101: present_state <= and3;     //and
							  5'b00110: present_state <= or3;      //or
							  5'b00111: present_state <= ror3;     //ror
							  5'b01000: present_state <= rol3;     //rol
							  5'b01001: present_state <= shr3;     //shr
							  5'b01010: present_state <= shra3;    //shra
							  5'b01011: present_state <= shl3;     //shl
							  5'b01100: present_state <= addi3;    //addi
							  5'b01101: present_state <= andi3;    //andi
							  5'b01110: present_state <= ori3;     //ori
							  5'b01111: present_state <= div3;     //div
							  5'b10000: present_state <= mul3;     //mul
							  5'b10001: present_state <= neg3;     //neg
							  5'b10010: present_state <= not3;     //not
							  5'b10011: present_state <= br3;      //brzr, brnz, brpl, brmi
							  5'b10100: present_state <= jal3;     //jal
							  5'b10101: present_state <= jr3;      //jr
							  5'b10110: present_state <= in3;      //in
							  5'b10111: present_state <= out3;     //out
							  5'b11000: present_state <= mflo3;    //mflo
							  5'b11001: present_state <= mfhi3;    //mfhi
							  5'b11010: present_state <= nop3;     //nop
							  5'b11011: present_state <= halt3;    //halt
							  default:  present_state <= reset_state;
						 endcase
					end
					//FSM instruction transition
					//LDI
					ldi3: present_state <= ldi4;
					ldi4: present_state <= fetch0;

					//ADD
					add3: present_state <= add4;
					add4: present_state <= add5;
					add5: present_state <= fetch0;

					//LD
					ld3: present_state <= ld4;
					ld4: present_state <= ld5;
					ld5: present_state <= ld6;
					ld6: present_state <= ld7;
					ld7: present_state <= fetch0;

					//ST 
					st3: present_state <= st4;
					st4: present_state <= st5;
					st5: present_state <= st6;
					st6: present_state <= fetch0;

					//SUB
					sub3: present_state <= sub4;
					sub4: present_state <= sub5;
					sub5: present_state <= fetch0;

					//AND
					and3: present_state <= and4;
					and4: present_state <= and5;
					and5: present_state <= fetch0;

					//OR
					or3: present_state <= or4;
					or4: present_state <= or5;
					or5: present_state <= fetch0;

					//ROR
					ror3: present_state <= ror4;
					ror4: present_state <= ror5;
					ror5: present_state <= fetch0;

					//ROL
					rol3: present_state <= rol4;
					rol4: present_state <= rol5;
					rol5: present_state <= fetch0;

					//SHR
					shr3: present_state <= shr4;
					shr4: present_state <= shr5;
					shr5: present_state <= fetch0;

					//SHRA
					shra3: present_state <= shra4;
					shra4: present_state <= shra5;
					shra5: present_state <= fetch0;

					//SHL
					shl3: present_state <= shl4;
					shl4: present_state <= shl5;
					shl5: present_state <= fetch0;

					//ADDI
					addi3: present_state <= addi4;
					addi4: present_state <= addi5;
					addi5: present_state <= fetch0;

					//ANDI
					andi3: present_state <= andi4;
					andi4: present_state <= andi5;
					andi5: present_state <= fetch0;

					//ORI
					ori3: present_state <= ori4;
					ori4: present_state <= ori5;
					ori5: present_state <= fetch0;

					//DIV
					div3: present_state <= div4;
					div4: present_state <= div5;
					div5: present_state <= div6;
					div6: present_state <= fetch0;

					//MUL
					mul3: present_state <= mul4;
					mul4: present_state <= mul5;
					mul5: present_state <= mul6;
					mul6: present_state <= fetch0;

					//NEG
					neg3: present_state <= neg4;
					neg4: present_state <= fetch0;

					//NOT
					not3: present_state <= not4;
					not4: present_state <= fetch0;

					//BRANCH(brzr, brnz, brpl, brmi)
					br3: present_state <= br4;
					br4: present_state <= br5;
					br5: present_state <= fetch0;

					//JAL
					jal3: present_state <= jal4;
					jal4: present_state <= fetch0;

					//JR
					jr3: present_state <= fetch0;

					//IN
					in3: present_state <= in4;
					in4: present_state <= fetch0;

					//OUT
					out3: present_state <= out4;
					out4: present_state <= fetch0;

					//MFLO
					mflo3: present_state <= fetch0;

					//MFHI
					mfhi3: present_state <= fetch0;

					//NOP
					nop3: present_state <= fetch0;

					//HALT
					halt3: present_state <= halt3;

					default: present_state <= reset_state;
			  endcase
		 end
		 
		always @(present_state) begin
			 //reset all control signals to 0
			 {Gra, Grb, Grc, Rin, Rout, BAout,
			  PCout, Zlowout, Zhighout, MDRout, LOout, HIout, In_Portout, Cout,
			  PCin, Zin, IRin, Yin, MARin, MDRin, HIin, LOin, Out_Portin,
			  IncPC, Read, Write, Clear, CONin, Run,
			  ADD, SUB, MUL, DIV, SHR, SHRA, SHL, ROR, ROL, AND, OR, NEG, NOT} = 0;

		 case (present_state)

			  
				//MAR <- PC, and preparing PC + 1 -> Z
			  fetch0: begin
					PCout = 1;
					MARin = 1;
					IncPC = 1;
					Zin = 1;
			  end
			
				//PC ← PC + 1, and start reading instruction → MDR
			  fetch1: begin
					Zlowout = 1;
					PCin = 1;
					Read = 1;
					MDRin = 1;
			  end
			  
			  
				//IR ← MDR — the instruction is ready to be decoded in the next cycle.
			  fetch2: begin
					MDRout = 1;
					IRin = 1;
			  end

			//add cases for each instruction

			  default: begin
			  end

		 endcase
	end

	end
