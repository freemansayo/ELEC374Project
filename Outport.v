//Output port
module Outport(input[31:0] D, input clear, clock, enable,
					output [31:0] Q);
					
	/*always @ (posedge clock or posedge clear) begin
		if(clear == 1)
			Q <= 32'b0;
		else if(enable == 1)
			Q <= D;
	end*/
	
	Register reg_inst(.D(D), .clear(clear), .clock(clock), .enable(enable), .Q(Q));
endmodule
