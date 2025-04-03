`timescale 1ns/10ps
module control_unit(	input clk, reset, stop, CON_FF,
							input[31:0] IR_contents,
								//Read-from-bus signals
							output reg 	Rin, HIin, LOin, CONin, PCin, IRin, Yin, Zin, MARin, MDRin, Outport_in,
								//Write-to-bus signals
											R_out, MDR_out, MAR_out, HI_out, LO_out, Zhi_out, Zlo_out, PC_out, C_out, Inport_out,
								//General register selection signals
											Gra, Grb, Grc, BAout,
								//ALU control signals (might also condense to one wire that takes on value of ALU opcode, might be less mess that way)
											ADD, SUB, MUL, DIV, SHR, SHRA, SHL, ROR, ROL, AND, OR, NEG, NOT,
								//memory operation control signals
											Read, Write,
								//Program control(?) signals
											Run, Clear, IncPC,
								//used for division
											reset_division
							);

	//Will follow Method 1 as described in the Phase 3 document
	
	//Set up FSM states
					//Basic steps that each instruction will complete
	parameter	resetState = 0, iFetch0 = 1, iFetch1 = 2, iFetch2 = 3, 
					//load instructions
					ld3 = 4, ld4 = 5, ld5 = 6, ld6 = 7, ld7 = 8, ldi3 = 9, ldi4 = 10, ldi5 = 11, ldi6 = 12, ldi7 = 13, //too many ldi steps
					//store instructions
					st3 = 14, st4 = 15, st5 = 16, st6 = 17, st7 = 18, 
					//add, addi instructions
					add3 = 19, add4 = 20, add5 = 21, addi3 = 22, addi4 = 23, addi5 = 24,
					//sub instructions
					sub3 = 25, sub4 = 26, sub5 = 27, 
					//and, andi instructions
					and3 = 28, and4 = 29, and5 = 30, andi3 = 31, andi4 = 32, andi5 = 33, 
					//or, ori instructions
					or3 = 34, or4 = 35, or5 = 36, ori3 = 37, ori4 = 38, ori5 = 39,
					//rotate right, rotate left instructions
					ror3 = 40, ror4 = 41, ror5 = 42, rol3 = 43, rol4 = 44, rol5 = 45, 
					//shift right, shift right arithmetic, shift left instructions
					shr3 = 46, shr4 = 47, shr5 = 48, shra3 = 49, shra4 = 50, shra5 = 51, shl3 = 52, shl4 = 53, shl5 = 54, 
					//division instruction
					div3 = 55, div4 = 56, div5 = 57, div6 = 58,
					//multiplication instruction
					mul3 = 59, mul4 = 60, mul5 = 61, mul6 = 62,
					//negation, NOT instructions
					neg3 = 63, neg4 = 64, not3 = 65, not4 = 66,
					//branch instruction
					br3 = 67, br4 = 68, br5 = 69, br6 = 70,
					//jal, jr instructions
					jal3 = 71, jal4 = 72, jr3 = 73,  
					//in, out instructions
					in3 = 74, out3 = 75, 
					//move from hi/lo instructions
					mfhi3 = 76, mflo3 = 77,
					//miscellaneous instructions
					nop3 = 78, halt3 = 79, stopState = 80;

	//current step of execution 
	reg[6:0] presentState = resetState;
	//Used for halt instruction, acts as a stop signal that can be turned on and off at will
	reg stopInternal;
	parameter clockRate = 40, halfClock = 20; //time expected for one complete cycle of the clock
	
	always @ (posedge clk or posedge reset) begin
		if(reset == 1) 
			presentState = resetState;
		else 
			//may need to add delays before each state assignment, will have to see
			case(presentState)
				resetState	:	#clockRate presentState = iFetch0;
				iFetch0		:	#clockRate presentState = iFetch1;
				iFetch1		: 	#clockRate presentState = iFetch2;
				iFetch2		:	#clockRate 
									begin
										//determine which instruction to begin executing
										case(IR_contents[31:27])
											default	:	presentState = resetState;
											5'b00000	:	presentState = ld3;
											5'b00001	:	presentState = ldi3;
											5'b00010	:	presentState = st3;
											5'b00011	:	presentState = add3;
											5'b00100	:	presentState = sub3;
											5'b00101	:	presentState = and3;
											5'b00110	:	presentState = or3;
											5'b00111	:	presentState = ror3;
											5'b01000	:	presentState = rol3;
											5'b01001	:	presentState = shr3;
											5'b01010	:	presentState = shra3;
											5'b01011	:	presentState = shl3;
											5'b01100	:	presentState = addi3;
											5'b01101	:	presentState = andi3;
											5'b01110	:	presentState = ori3;
											5'b01111	:	presentState = div3;
											5'b10000	:	presentState = mul3;
											5'b10001	:	presentState = neg3;
											5'b10010	:	presentState = not3;
											5'b10011	:	presentState = br3;
											5'b10100	:	presentState = jal3;
											5'b10101	:	presentState = jr3;
											5'b10110	:	presentState = in3;
											5'b10111	:	presentState = out3;
											5'b11000	:	presentState = mflo3;
											5'b11001	:	presentState = mfhi3;
											5'b11010	:	presentState = nop3;
											5'b11011	:	presentState = halt3;
										endcase
									end
				//ld
				ld3		:	 #clockRate presentState = ld4;
				ld4		:	 #clockRate presentState = ld5;
				ld5		:	 #clockRate presentState = ld6;
				ld6		:	 #clockRate presentState = ld7;
				ld7		:	 #clockRate presentState = iFetch0;
				//ldi
				ldi3		:	 #clockRate presentState = ldi4;
				ldi4		:	 #clockRate presentState = ldi5;
				ldi5		:	 #clockRate presentState = iFetch0;
				//st
				st3		:	 #clockRate presentState = st4;
				st4		:	 #clockRate presentState = st5;
				st5		:	 #clockRate presentState = st6;
				st6		:	 #clockRate presentState = st7;
				st7		:	 #clockRate presentState = iFetch0;
				//add
				add3		:	 #clockRate presentState = add4;
				add4		:	 #clockRate presentState = add5;
				add5		:	 #clockRate presentState = iFetch0;
				//sub
				sub3		:	 #clockRate presentState = sub4;
				sub4		:	 #clockRate presentState = sub5;
				sub5		:	 #clockRate presentState = iFetch0;
				//and
				and3		:	 #clockRate presentState = and4;
				and4		:	 #clockRate presentState = and5;
				and5		:	 #clockRate presentState = iFetch0;
				//or
				or3		:	 #clockRate presentState = or4;
				or4		:	 #clockRate presentState = or5;
				or5		:	 #clockRate presentState = iFetch0;
				//ror
				ror3		:	 #clockRate presentState = ror4;
				ror4		:	 #clockRate presentState = ror5;
				ror5		:	 #clockRate presentState = iFetch0;
				//rol
				rol3		:	 #clockRate presentState = rol4;
				rol4		:	 #clockRate presentState = rol5;
				rol5		:	 #clockRate presentState = iFetch0;
				//shr
				shr3		:	 #clockRate presentState = shr4;
				shr4		:	 #clockRate presentState = shr5;
				shr5		:	 #clockRate presentState = iFetch0;
				//shra
				shra3		:	 #clockRate presentState = shra4;
				shra4		:	 #clockRate presentState = shra5;
				shra5		:	 #clockRate presentState = iFetch0;
				//shl
				shl3		:	 #clockRate presentState = shl4;
				shl4		:	 #clockRate presentState = shl5;
				shl5		:	 #clockRate presentState = iFetch0;
				//addi
				addi3		:	 #clockRate presentState = addi4;
				addi4		:	 #clockRate presentState = addi5;
				addi5		:	 #clockRate presentState = iFetch0;
				//andi
				andi3		:	 #clockRate presentState = andi4;
				andi4		:	 #clockRate presentState = andi5;
				andi5		:	 #clockRate presentState = iFetch0;
				//ori
				ori3		:	 #clockRate presentState = ori4;
				ori4		:	 #clockRate presentState = ori5;
				ori5		:	 #clockRate presentState = iFetch0;
				//div
				div3		:	 #clockRate presentState = div4;
				div4		:	 #(clockRate * 33) presentState = div5; //THIS STEP WILL TAKE MULTIPLE CYCLES TO COMPLETE
				div5		:	 #clockRate presentState = div6;
				div6		:	 #clockRate presentState = iFetch0;
				//mul
				mul3		:	 #clockRate presentState = mul4;
				mul4		:	 #clockRate presentState = mul5;
				mul5		:	 #clockRate presentState = mul6;
				mul6		:	 #clockRate presentState = iFetch0;
				//neg
				neg3		:	 #clockRate presentState = neg4;
				neg4		:	 #clockRate presentState = iFetch0;
				//not
				not3		:	 #clockRate presentState = not4;
				not4		:	 #clockRate presentState = iFetch0;
				//br
				br3		:	 #clockRate presentState = br4;
				br4		:	 #clockRate presentState = br5;
				br5		:	 #clockRate presentState = br6;
				br6		:	 #clockRate presentState = iFetch0;
				//jal
				jal3		:	 #clockRate presentState = jal4;
				jal4		:	 #clockRate presentState = iFetch0;
				//jr
				jr3		:	 #clockRate presentState = iFetch0;
				//in
				in3		:	 #clockRate presentState = iFetch0;
				//out
				out3		:	 #clockRate presentState = iFetch0;
				//mflo
				mflo3		:	 #clockRate presentState = iFetch0;
				//mfhi
				mfhi3		:	 #clockRate presentState = iFetch0;
				//nop
				nop3		:	 #clockRate presentState = iFetch0;
				//halt
				halt3		:	 #clockRate presentState = stopState; //This will hold a stopped state until told otherwise
				
			endcase
		end
	
	//define FSM behaviour
	always @ (presentState) begin
		case(presentState)
			resetState	:	begin
				//reset all output signals
				Rin <= 0; HIin <= 0; LOin <= 0; CONin <= 0; PCin <= 0; IRin <= 0; Yin <= 0; Zin <= 0; MARin <= 0; MDRin <= 0; Outport_in <= 0;
				
				R_out <= 0; BAout <= 0; C_out <= 0; PC_out <= 0; MDR_out <= 0; Zhi_out <= 0; Zlo_out <= 0; HI_out <= 0; LO_out <= 0; Inport_out <= 0;
				
				Gra <= 0; Grb <= 0; Grc <= 0;
				
				ADD <= 0; SUB <= 0; MUL <= 0; DIV <= 0; SHR <= 0; SHRA <= 0; SHL <= 0; ROR <= 0; ROL <= 0; AND <= 0; OR <= 0; NEG <= 0; NOT <= 0;
				
				Read <= 0; Write <= 0;
				
				Run <= 1; stopInternal <= 0;
				
				reset_division <= 0;
				
				IncPC <= 0;
				
				Clear <= 1;
				#halfClock
				Clear <= 0;
			end
			
			iFetch0: begin
				PC_out <= 1; MARin <= 1; Zin <= 1;
				#20
				PC_out <= 0; MARin <= 0; Zin <= 0;
			end

			iFetch1: begin //Loads MDR from RAM output (loads from specified address in memory) 
				Zlo_out <= 1; PCin <= 1; Read <= 1; MDRin <= 1;
				#20
				Zlo_out <= 0; PCin <= 0; Read <= 0; MDRin <= 0;
			end

			iFetch2: begin //Load MDR contents into IR
				MDR_out <= 1; IRin <= 1; IncPC <= 1;
				#5
				IncPC <= 0;
				#20
				MDR_out <= 0; IRin <= 0;
			end
			
			//Execute ld instruction
			ld3: begin //Using select and encode logic, enable register b designated in opcode, and place stored value into Y
				Grb <= 1; BAout <= 1; R_out <= 1; Yin <= 1;
				#20
				Grb <= 0; BAout <= 0; R_out <= 0; Yin <= 0;
			end

			ld4: begin //Determine offsetted address, store result in Z, unsure how to go about properly starting the addition here
				C_out <= 1; ADD <= 1; Zin <= 1;
				#20;
				C_out <= 0; ADD <= 0; Zin <= 0;
			end

			ld5: begin //Place offsetted address in MAR
				Zlo_out <= 1; MARin <= 1;
				#20
				Zlo_out <= 0; MARin <= 0;
			end

			ld6: begin //Read memory at offsetted address into MAR
				Read <= 1; MDRin <= 1;
				#20
				Read <= 0; MDRin <= 0;
			end
			
			ld7: begin //Load MDR's contents into destination register
				MDR_out <= 1; Gra <= 1; Rin <= 1;
				#20
				MDR_out <= 0; Gra <= 0; Rin <= 0;
			end
			
			//Execute ldi instruction
			ldi3: begin //Using select and encode logic, enable register designated in opcode, and place stored value into Y
				Grb <= 1; BAout <= 1; R_out <= 1; Yin <= 1;
				#20
				Grb <= 0; BAout <= 0; R_out <= 0; Yin <= 0;
			end

			ldi4: begin //Determine offsetted value, store result in Z, unsure how to go about properly starting the addition here
				C_out <= 1; ADD <= 1; Zin <= 1;
				#20;
				C_out <= 0; ADD <= 0; Zin <= 0;
			end

			ldi5: begin //Place value in Z into destination register
				Zlo_out <= 1; Gra <= 1; Rin <= 1;
				#20
				Zlo_out <= 0; Gra <= 0; Rin <= 0;
			end
			
			//Execute st instruction
			st3: begin //Using select and encode logic, enable register b designated in opcode, and place stored value into Y
				Grb <= 1; BAout <= 1; R_out <= 1; Yin <= 1;
				#20
				Grb <= 0; BAout <= 0; R_out <= 0; Yin <= 0;
			end

			st4: begin //Determine offsetted address, store result in Z, unsure how to go about properly starting the addition here
				C_out <= 1; ADD <= 1; Zin <= 1;
				#20;
				C_out <= 0; ADD <= 0; Zin <= 0;
			end

			st5: begin //Place offsetted address in MAR
				Zlo_out <= 1; MARin <= 1;
				#20
				Zlo_out <= 0; MARin <= 0;
			end

			st6: begin //Place source register's data into MDR
				Gra <= 1; R_out <= 1; MDRin <= 1;
				#20
				Gra <= 0; R_out <= 0; MDRin <= 0;
			end
			
			st7: begin //Write to memory at offsetted address
				Write <= 1;
				#20
				Write <= 0;
			end
			
			//Execute add instruction
			add3: begin //Using select and encode logic, enable register B, and place stored value into Y
				Grb <= 1; BAout <= 0; R_out <= 1; Yin <= 1;
				#20
				Grb <= 0; BAout <= 0; R_out <= 0; Yin <= 0;
			end

			add4: begin //Perform addition with operand in register C, store result in Z
				Grc <= 1; ADD <= 1; Zin <= 1;
				#20;
				Grc <= 0; ADD <= 0; Zin <= 0;
			end

			add5: begin //Place value in Z into register A
				Zlo_out <= 1; Gra <= 1; Rin <= 1;
				#20
				Zlo_out <= 0; Gra <= 0; Rin <= 0;
			end
			
			//Execute sub instruction
			sub3: begin //Using select and encode logic, enable register designated in opcode, and place stored value into Y
				Grb <= 1; BAout <= 0; R_out <= 1; Yin <= 1;
				#20
				Grb <= 0; BAout <= 0; R_out <= 0; Yin <= 0;
			end

			sub4: begin //Perform subtraction with operand in register C, store result in Z
				Grc <= 1; SUB <= 1; Zin <= 1;
				#20;
				Grc <= 0; SUB <= 0; Zin <= 0;
			end

			sub5: begin //Place value in Z into register A
				Zlo_out <= 1; Gra <= 1; Rin <= 1;
				#20
				Zlo_out <= 0; Gra <= 0; Rin <= 0;
			end
			
			//Execute AND instruction
			and3: begin //Using select and encode logic, enable register B, and place stored value into Y
				Grb <= 1; BAout <= 0; R_out <= 1; Yin <= 1;
				#20
				Grb <= 0; BAout <= 0; R_out <= 0; Yin <= 0;
			end

			and4: begin //Perform and operation with operand in register B, store result in Z
				Grc <= 1; AND <= 1; Zin <= 1;
				#20;
				Grc <= 0; AND <= 0; Zin <= 0;
			end

			and5: begin //Place value in Z into register A
				Zlo_out <= 1; Gra <= 1; Rin <= 1;
				#20
				Zlo_out <= 0; Gra <= 0; Rin <= 0;
			end
			
			//Execute OR instruction
			or3: begin //Using select and encode logic, enable register B, and place stored value into Y
				Grb <= 1; BAout <= 0; R_out <= 1; Yin <= 1;
				#20
				Grb <= 0; BAout <= 0; R_out <= 0; Yin <= 0;
			end

			or4: begin //Perform operation with operand in register B, store result in Z
				Grc <= 1; OR <= 1; Zin <= 1;
				#20;
				Grc <= 0; OR <= 0; Zin <= 0;
			end

			or5: begin //Place value in Z into register A
				Zlo_out <= 1; Gra <= 1; Rin <= 1;
				#20
				Zlo_out <= 0; Gra <= 0; Rin <= 0;
			end
			
			//Execute ROR instruction
			ror3: begin //Using select and encode logic, enable register B, and place stored value into Y
				Grb <= 1; BAout <= 0; R_out <= 1; Yin <= 1;
				#20
				Grb <= 0; BAout <= 0; R_out <= 0; Yin <= 0;
			end

			ror4: begin //Perform operation with operand in register B, store result in Z
				Grc <= 1; ROR <= 1; Zin <= 1;
				#20;
				Grc <= 0; ROR <= 0; Zin <= 0;
			end

			ror5: begin //Place value in Z into register A
				Zlo_out <= 1; Gra <= 1; Rin <= 1;
				#20
				Zlo_out <= 0; Gra <= 0; Rin <= 0;
			end
			
			//Execute ROL instruction
			rol3: begin //Using select and encode logic, enable register B, and place stored value into Y
				Grb <= 1; BAout <= 0; R_out <= 1; Yin <= 1;
				#20
				Grb <= 0; BAout <= 0; R_out <= 0; Yin <= 0;
			end

			rol4: begin //Perform operation with operand in register B, store result in Z
				Grc <= 1; ROL <= 1; Zin <= 1;
				#20;
				Grc <= 0; ROL <= 0; Zin <= 0;
			end

			rol5: begin //Place value in Z into register A
				Zlo_out <= 1; Gra <= 1; Rin <= 1;
				#20
				Zlo_out <= 0; Gra <= 0; Rin <= 0;
			end
			
			//Execute SHR instruction
			shr3: begin //Using select and encode logic, enable register B, and place stored value into Y
				Grb <= 1; BAout <= 0; R_out <= 1; Yin <= 1;
				#20
				Grb <= 0; BAout <= 0; R_out <= 0; Yin <= 0;
			end

			shr4: begin //Perform operation with operand in register B, store result in Z
				Grc <= 1; SHR <= 1; Zin <= 1;
				#20;
				Grc <= 0; SHR <= 0; Zin <= 0;
			end

			shr5: begin //Place value in Z into register A
				Zlo_out <= 1; Gra <= 1; Rin <= 1;
				#20
				Zlo_out <= 0; Gra <= 0; Rin <= 0;
			end
			
			//Execute SHRA instruction
			shra3: begin //Using select and encode logic, enable register B, and place stored value into Y
				Grb <= 1; BAout <= 0; R_out <= 1; Yin <= 1;
				#20
				Grb <= 0; BAout <= 0; R_out <= 0; Yin <= 0;
			end

			shra4: begin //Perform operation with operand in register B, store result in Z
				Grc <= 1; SHRA <= 1; Zin <= 1;
				#20;
				Grc <= 0; SHRA <= 0; Zin <= 0;
			end

			shra5: begin //Place value in Z into register A
				Zlo_out <= 1; Gra <= 1; Rin <= 1;
				#20
				Zlo_out <= 0; Gra <= 0; Rin <= 0;
			end
			
			//Execute SHL instruction
			shl3: begin //Using select and encode logic, enable register B, and place stored value into Y
				Grb <= 1; BAout <= 0; R_out <= 1; Yin <= 1;
				#20
				Grb <= 0; BAout <= 0; R_out <= 0; Yin <= 0;
			end

			shl4: begin //Perform operation with operand in register B, store result in Z
				Grc <= 1; SHL <= 1; Zin <= 1;
				#20;
				Grc <= 0; SHL <= 0; Zin <= 0;
			end

			shl5: begin //Place value in Z into register A
				Zlo_out <= 1; Gra <= 1; Rin <= 1;
				#20
				Zlo_out <= 0; Gra <= 0; Rin <= 0;
			end
			
			//Execute addi instruction
			addi3: begin //Using select and encode logic, enable register B, and place stored value into Y
				Grb <= 1; BAout <= 0; R_out <= 1; Yin <= 1;
				#20
				Grb <= 0; BAout <= 0; R_out <= 0; Yin <= 0;
			end

			addi4: begin //Perform addition with contents of C register, store result in Z
				C_out <= 1; ADD <= 1; Zin <= 1;
				#20;
				C_out <= 0; ADD <= 0; Zin <= 0;
			end

			addi5: begin //Place value in Z into register A
				Zlo_out <= 1; Gra <= 1; Rin <= 1;
				#20
				Zlo_out <= 0; Gra <= 0; Rin <= 0;
			end
			
			//Execute andi instruction
			andi3: begin //Using select and encode logic, enable register B, and place stored value into Y
				Grb <= 1; BAout <= 0; R_out <= 1; Yin <= 1;
				#20
				Grb <= 0; BAout <= 0; R_out <= 0; Yin <= 0;
			end

			andi4: begin //Perform operation with contents of C register, store result in Z
				C_out <= 1; AND <= 1; Zin <= 1;
				#20;
				C_out <= 0; AND <= 0; Zin <= 0;
			end

			andi5: begin //Place value in Z into register A
				Zlo_out <= 1; Gra <= 1; Rin <= 1;
				#20
				Zlo_out <= 0; Gra <= 0; Rin <= 0;
			end
			
			//Execute ori instruction
			ori3: begin //Using select and encode logic, enable register B, and place stored value into Y
				Grb <= 1; BAout <= 0; R_out <= 1; Yin <= 1;
				#20
				Grb <= 0; BAout <= 0; R_out <= 0; Yin <= 0;
			end

			ori4: begin //Perform operation with contents of C register, store result in Z
				C_out <= 1; OR <= 1; Zin <= 1;
				#20;
				C_out <= 0; OR <= 0; Zin <= 0;
			end

			ori5: begin //Place value in Z into register A
				Zlo_out <= 1; Gra <= 1; Rin <= 1;
				#20
				Zlo_out <= 0; Gra <= 0; Rin <= 0;
			end
			
			//Execute div instruction (I suspect that this will need some reworking, potentially scrap using the Divider logic)
			div3: begin //Place value from register B into Y
				Grb <= 1; R_out <= 1; Yin <= 1;
				#20
				Grb <= 0; R_out <= 0; Yin <= 0;
			end
			
			div4: begin //Perform division with operand in register A
				Gra <= 1; R_out <= 1; DIV <= 1; Zin <= 1; reset_division <= 1;
				#20
				reset_division <= 0;
				#(clockRate * 32) //wait for division to complete
				Gra <= 0; R_out <= 0; Zin <= 0;
				
			end
			
			div5: begin //Place value from Zlo into LO register
				Zlo_out<= 1; LOin <= 1; 
				#20
				Zlo_out<= 0; LOin <= 0;
			end
			
			div6: begin //Place value from Zhi into HI register
				Zhi_out <= 1; HIin <= 1;
				#20 
				Zhi_out <= 0; HIin <= 0;
			end
			
			//Execute mul instruction
			mul3: begin //load value from register B into Y
				Grb <= 1; R_out <= 1; Yin <= 1;  
				#20
				Grb <= 0; R_out <= 0; Yin <= 0;
			end
			
			mul4: begin //perform multiplication with operand in register A
				Gra <= 1; R_out <= 1; MUL <= 1; Zin <= 0; 
				#20 
				Gra <= 0; R_out <= 0; MUL <= 0; Zin <= 0;
			end
			
			mul5: begin //Place value from Zlo into LO register
				Zlo_out<= 1; LOin <= 1; 
				#20 
				Zlo_out<= 0; LOin <= 0;
			end
			
			mul6: begin //Place value from Zhi into HI register
				Zhi_out <= 1; HIin <= 1;
				#20 
				Zhi_out <= 0; HIin <= 0;
			end
			
			//Execute NEG instruction
			neg3: begin //perform negation on operand in register B
				Grb <= 1; R_out <= 1; NEG <= 1; Yin <= 1; Zin <= 1;
				#20 
				Grb <= 0; R_out <= 0; NEG <= 0; Yin <= 0;	Zin <= 0; 
			end
			
			neg4: begin //place result in register A
				Zlo_out <= 1; Gra <= 1; Rin <= 1;
				#20
				Zlo_out <= 0; Gra <= 0; Rin <= 0;
			end
			
			//Execute NOT instruction
			not3: begin //perform NOT on operand in register B
				Grb <= 1; R_out <= 1; NOT <= 1; Yin <= 1; Zin <= 1;
				#20 
				Grb <= 0; R_out <= 0; NOT <= 0; Yin <= 0;	Zin <= 0; 
			end
			
			not4: begin //place result in register A
				Zlo_out <= 1; Gra <= 1; Rin <= 1;
				#20
				Zlo_out <= 0; Gra <= 0; Rin <= 0;
			end
			
			//Execute br instruction
			br3: begin //Using CON_FF logic, determine if condition is true
				Gra <= 1; BAout <= 0; R_out <= 1; CONin <= 1;
				#20
				Gra <= 0; BAout <= 0; R_out <= 0; CONin <= 0;
			end

			br4: begin //Place PC contents into Y
				PC_out <= 1; Yin <= 1;
				#20;
				PC_out <= 0; Yin <= 0;
			end

			br5: begin //Compute new PC value
				C_out <= 1; Zin <= 1;
				#20
				C_out <= 0; Zin <= 0;
			end

			br6: begin //If the condition is true, update the value of PC to branched address
				Zlo_out <= 1; PCin <= CON_FF;
				#20
				Zlo_out <= 0; PCin <= 0;
			end
			
			//Execute jal instruction (might have to make specific R8 enable signal for this)
         jal3: begin // Save PC+1 into R8
				Zlo_out <= 1; Gra <= 1; Rin <= 1;
				#20
				Zlo_out <= 0; Gra <= 0; Rin <= 0;
			end

			jal4: begin  //load contents of register A into PC register
				Gra <= 1; R_out <= 1; PCin <= 1; // Gra selects R5
				#20 
				Gra <= 0; R_out <= 0; PCin <= 0;
			end	
			
			//Execute jr instruction
			jr3: begin // Load in the contents of register A into PC register
				Gra <= 1; R_out <= 1; PCin <= 1;
				#20
				Gra <= 0; R_out <= 0; PCin <= 0;
			end	
			
			//Execute in instruction
			in3: begin // Load contents of Inport into register A
				Gra <= 1; Rin <= 1; Inport_out <= 1;
				#20
				Gra <= 0; Rin <= 0; Inport_out <= 0;
			end
			
			//Execute out instruction
			out3: begin // Load contents of register A into Out register
				Gra <= 1; R_out <= 1; Outport_in <= 1;
				#20
				Gra <= 0; R_out <= 0; Outport_in <= 0;
			end
			
			//Execute mflo instruction
			mflo3: begin // Load contents of LO register into register A
				Gra <= 1; Rin <= 1; LO_out <= 1;
				#20
				Gra <= 0; Rin <= 0; LO_out <= 0;
			end			
			
			//Execute mfhi instruction
			mfhi3: begin // Load contents of LO register into register A
				Gra <= 1; Rin <= 1; HI_out <= 1;
				#20
				Gra <= 0; Rin <= 0; HI_out <= 0;
			end			
			
			//Execute nop instruction
			nop3: begin 
				#20; //do nothing
			end
			
			//Execute halt instruction, set Run output to 0
			halt3: begin
				stopInternal <= 1; Run <= 0;
				#20;
			end
			
			//Execution stopped until reset
			stopState: begin
					#20;
			end
		endcase
	end
endmodule
