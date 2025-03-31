//Control Unit Module
`timescale 1ns / 10ps
module control_unit (
    // Outputs
    output reg Gra, Grb, Grc, Rin, Rout, BAout, PCout, Zlowout, Zhighout, MDRout, LOout, HIout,
	 In_Portout, Cout, PCin, Zin, IRin, Yin, MARin, MDRin, HIin, LOin, Out_Portin, IncPC, Read,
	 Write, Clear, CONin, Run, LOAD, LOADI, STORE, ADD, ADDI, SUB, MUL, DIV, SHR, SHRA, SHL, ROR, ROL, AND, ANDI, OR, ORI, NEG, NOT,
	 BR, JR, JAL, IN, OUT, MFHI, MFLO, NOP, HALT, 
	 
    // Inputs
    input [31:0] IR,
    input Clock, Reset, Stop, CON_FF
);

	//change all the states, not enough bits for the number of states that are needed
	parameter reset_state = 8'b00000000, fetch0 = 8'b00000001, fetch1 = 8'b00000010, fetch2 = 8'b00000011,
				ld3 = 8'b00000100,ld4 = 8'b00000101, ld5 = 8'b00000110,ld6 = 8'b00000111, ld7 = 8'b00001000, // Ends at 8
				ldi3 = 8'b00001001, ldi4 = 8'b00001010, ldi5 = 8'b00001011, // Ends at 11 
				st3 = 8'b00001100, st4 = 8'b00001101, st5 = 8'b00001110,  // Ends at 14
				add3 = 8'b00001111, add4 = 8'b0001000, add5 = 8'b00010001, // Ends at 17
				addi3 = 8'b00010010, addi4 = 8'b00010011, addi5 = 8'b0001 0100, // Ends at 20 
				sub3 = 8'b00010101, sub4 = 8'b00010110, sub5 = 8'b00010111, // Ends at 23
				mul3 = 8'b00011000 , mul4 = 8'b00011001, mul5 = 8'b00011010, mul6 = 00011011, // Ends at 27
				div3 = 8'b00011100, div4 = 8'b00011101, div5 = 8'b00011110, div6 = 8'b00011111, // Ends at 31 
				shr3 = 8'b00100000, shr4 = 8'b00100001, shr5 = 8'b00100010, // Ends at 34
				shra3 = 8'b00100011, shra4 = 8'b00100100, shra5 = 8'b00100101, // Ends at 37
				shl3 =  8'b00100110 shl4 = 8'b00100111, shl5 = 8'b00101000, // Ends at 40
				ror3 = 8'b00101001, ror4 = 8'b00101010, ror5 = 8'b00101011, // Ends at 43
				rol3 = 8'b00101100, rol4 = 8'b00101101, rol5 = 8'b00101110, // Ends at 46
				and3 = 8'b00101111, and4 = 8'b00110000, and5 = 8'b00110001, // Ends at 49
				andi3 = 8'b00110010, andi4 = 8'b00110011, andi5 = 8'b00110100, // Ends at 52
				or3 = 8'b00110101, or4 = 8'b00110110, or5 = 8'b00110111, // Ends at 55
				ori3 = 8'b00111000, ori4 = 8'b00111001, ori5 = 8'b00111010, //Ends at 58
				neg3 = 8'b00111011, neg4 = 8'b00111100, //Ends at 60 
				not3 = 8'b00111101 , not4 = 8'b00111110, // Ends at 62
				br3 = 8'b00111111, br4 =8'b01000000, br5 = 8'b01000001, br6 = 8'b01000010, // Ends at 66
				jr3 = 8'b01000011, // Ends at 67
				jal3 = 8'b01000100, jal4 = 8'b01000101, // Ends at 69
				mfhi3 = 8'b01000110, // Ends at 70
				mflo3 = 8'b01000111, // Ends at 71
				in3 = 8'b01001000, // Ends at 72
				out3 = 8'b01001001, // Ends at 73
				nop3 = 8'b01001010, // Ends at 74
				halt3 = 8'b01001011; // Ends at 75

						
	reg [7:0] present_state = reset_state;
			
			
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
		 
		// Do the job for each state 
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
					PCout <= 1;
					MARin <= 1;
					IncPC <= 1;
					Zin <= 1; 
			  end
			
				//PC ← PC + 1, and start reading instruction → MDR
			  fetch1: begin
					PCout <= 0;
					MARin <= 0;
					IncPC <= 0;
					Zin <= 0; 
					Zlowout <= 1;
					PCin <= 1;
					Read <= 1;
					MDRin <= 1;
			  end
			  
			  
				//IR ← MDR — the instruction is ready to be decoded in the next cycle.
			  fetch2: begin
			  		Zlowout <= 0;
					PCin <= 0;
					Read <= 0;
					MDRin <= 0;
					MDRout <= 1;
					IRin <= 1;
			  end

				//ORI Control Sequences 
				ori3: begin
					MDRout <= 0; IRin <= 0;
					Grb <= 1; R_out <= 1; Yin <= 1;
				end 
				
				ori4: begin
					Grb <= 0; R_out <= 0; Yin <= 0;
					C_out <= 1;  Zlowin <= 1; ORI <= 1; 
				end 
				
				ori5: begin 
					C_out <= 0;  Zlowin <= 0; ORI <= 0; 
					Zlo_out <= 1; Gra <= 1; Rin <= 1;
					#20
					Zlo_out <= 0; Gra <= 0; Rin <= 0;
				end 
				
				//div control sequences
				div3: begin
					MDRout <= 0; IRin  <= 0; 
					Gra <= 1; Yin <= 1; Rout <= 1; 
				end
				
				div4: begin
					Gra <= 0; Yin <= 0; Rout <= 0;  
					Grb <= 1; Zlowin <= 1; Rout <= 1; DIV <= 1; 
				end 
				
				div5: begin
					Grb <= 0; Zlowin <= 0; Rout <= 0; DIV <= 0; 
					Zlowout <= 1; LOin <= 1; 
				end
				
				div6: begin 
					Zlowout <=0; LOin <= 0; 
					Zhighout <= 1; HIin <= 1; 
					#25 
					zhighout <= 0; HIin <= 0;
				end
				
				//Mul Control Sequences 
				mul3: begin
					MDRout <= 0; IRin <= 0; 
					Yin <= 1; Rout <= 1; Gra <= 1; 
				end
				
				mul4: begin 
					Yin <= 0; Rout <= 0; Gra <= 0; 
					Zin <= 1; Rout <= 1; Grb <= 1; MUL <= 1; 
				end
					
				mul5: begin
					Grb <= 0; Zlowin <= 0; Rout <= 0; MUL <= 0;  
					Zlowout <= 1; LOin <= 1; 
				end
					
				mul6: begin 
					Zlowout <= 0; LOin <= 0; 
					Zhighout <= 1; HIin <= 1;
					#25
					Zhighout <= 0; HIin <= 0;
				end 
				
				// Neg Control Sequence
				neg3: begin
					MDRout <= 0; IRin <= 0; 
					Rout <= 1; Zin <= 1; NEG <= 1; 
				end
				
				neg4: begin 
					Rout <= 0; Zin <= 0; 
					Zlowout <= 1; Rin <= 1; 
					#20 
					Zlowout <= 0; Rin <= 0; 
				end
				
				// Not Control Sequence
				not3: begin 
					MDRout <= 0; IRin <= 0; 
					NEG <= 1; Zin <= 1; Rout <= 1; 
				end
				
				not4: begin 
					NEG <= 0; Zin <= 0; Rout <= 0; 
					Zlowout <= 1; Rin <= 1; 
					#20
					Zlowout <= 1; Rin <= 1; 
				end
				
				// Branch Control Sequence
				br3: begin
					MDRout <= 0; IRin <= 0; 
					Gra <= 1; Rout <= 1; CONin <= 1; 
				end
				
				br4: begin
					Gra <= 0; Rout <= 0; CONin <= 0; 
					PCout <= 1; Yin <= 1; 
				end 
				
				br5: begin 
					PCout <= 0; Yin <= 0; 
					Cout <= 1; ADD <= 1; Zin <= 1; 
				end	
				
				br6: begin 
					Cout <= 0; ADD <= 0; Zin <= 0;
					Zlowout <= 1; PCin <= CONin; 
					#20 
					Zlowout <= 0; PCin <= 0; 
				end 	
				
				// Jump Control Sequence
				jr3: begin 
					MDRout <= 0; IRin <= 0; 
					Gra <= 1; Rout <= 1; PCin <= 1; 
					#20 
					Gra <= 0; Rout <= 0; PCin <= 0; 
				end 
				
				jal3: begin
					MDRout <= 0; IRin <= 0; 
					Zlo_out <= 1; Rin <= 1;
				end 
				
				jal4: begin 
					Zlo_out <= 0; Rin <= 0; 
					Gra <= 1; R_out <= 1; PCin <= 1; 
					#20 
					Gra <= 0; R_out <= 0; PCin <= 0;
				
				end
				
				//mfhi and mflo control sequences
				mfhi3: begin 
					MDRout <= 0; IRin <= 0; 
					Gra <= 1; Rin <= 1; HI_out <= 1;
					#20
					Gra <= 0; Rin <= 0; HI_out <= 0;
				end		
				
				mflo3: begin 
					MDRout <= 0; IRin <= 0; 
					Gra <= 1; Rin <= 1; LO_out <= 1;
					#20
					Gra <= 0; Rin <= 0; LO_out <= 0;
				end
				
				//in and out control sequence
				in3: begin 
					MDRout <= 0; IRin <= 0; 
					Gra <= 1; Rin <= 1; In_out <= 1;
					#20
					Gra <= 0; Rin <= 0; In_out <= 0;
				end
				
				out3: begin 
					MDRout <= 0; IRin <= 0; 
					Gra <= 1; R_out <= 1; Out_rd <= 1;
					#20
					Gra <= 0; R_out <= 0; Out_rd <= 0;
				end
				
				// NOP control sequence
				nop3: begin 
				end
				
				// Halt control sequence
				halt3: begin 
					Run <= 0;  
				end
				
		 endcase
	end
endmodule

