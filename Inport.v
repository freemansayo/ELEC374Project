//Input port
module Inport(input[31:0] D, input clear, clock,
				  output[31:0] Q);
	Register reg_inst(.D(D), .Q(Q), .clear(clear), .clock(clock), .enable(1'b1));

endmodule
				  