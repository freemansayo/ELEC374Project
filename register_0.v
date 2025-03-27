module Register_0(input [31: 0] D, input clear, clock, enable, enable_diog, BAout,
					   output reg [31: 0] Q
);
	always @ (posedge clock or posedge clear) begin
		if(clear == 1)
			Q <= 32'b0;
		else if(enable == 1 || enable_diog == 1)
			Q <= (~BAout) & D;
	end
endmodule