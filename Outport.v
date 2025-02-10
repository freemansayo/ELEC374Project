//Output port
module Outport(input[31:0] D, input clear, clock, enable,
					output[31:0] Q);
	Register reg_inst(.D(D), .Q(Q), .clear(clear), .clock(clock), .enable(enable));


endmodule
