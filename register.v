module Register(input [31: 0] D, input clear, input clock, input enable, enable_diog,
	output reg [31: 0] Q
);
	initial begin
		Q <= 0;
	end
	always @ (posedge clock or posedge clear) begin
		if(clear == 1)
			Q <= 32'b0;
		else if(enable == 1 || enable_diog == 1)
			Q <= D;
	end
endmodule
