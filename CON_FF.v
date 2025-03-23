module FlipFlop_Logic(input wire clk, input wire D, output reg Q, output reg Q_not);	
	initial begin
		Q <= 0;
		Q_not <= 1;
	end
	
	always@(clk) 
	begin
		Q <= D;
		Q_not <= ~D;
	end
endmodule

module CON_FF(output CON_output, input[31:0]BusMuxOut, input [3:0]IR_out, input wire CON_input);
	//Decoder Signals and Variables
	wire[1:0] Decoder_in; 
	reg[3:0] Decoder_out; 
	assign Decoder_in = IR_out[1:0];

	// Flip-Flop Input Generator Signals 
	wire Equal, notEqual, GTE, LT; 
	wire D_Value;
	
	//2-to-4 Decoder 
	always @(Decoder_in) begin 
		case(Decoder_in)
			default: Decoder_out <= 4'b0000;
			2'b00 : Decoder_out <= 4'b0001;
			2'b01 : Decoder_out <= 4'b0010;
			2'b10 : Decoder_out <= 4'b0100;
			2'b11 : Decoder_out <= 4'b1000;
		endcase
	end


	//Logic for the D input of the Flip-Flop that will output q 
	assign Equal = Decoder_out[0] & ~|BusMuxOut; 
	assign notEqual = Decoder_out[1] & ~(~|BusMuxOut); 
	assign GTE = Decoder_out[2] & (~BusMuxOut[31]); 
	assign LT = Decoder_out[3] & BusMuxOut[31];

	assign D_Value  = Equal | notEqual | GTE | LT;


	//Pass it into a Flip Flop Module to Complete the Logic
	FlipFlop_Logic flipFlop(.clk(CON_input), .D(D_Value), .Q(CON_output));
endmodule
