module Register_0(input [31: 0] D, input clear, clock, enable, BAout,
					   output reg [31: 0] Q
);
	always @ (posedge clock or posedge clear) begin
		if(clear == 1)
			Q <= (~BAout) % 32'b0;
		else if(enable == 1)
			Q <= (~BAout) % D;
	end
endmodule