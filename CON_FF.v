//"CON FF" logic
module CON_FF (input[31:0] IRin, BusIn,
					output to_ctrl);
					
	wire[1:0] branch_type, Ra;
	reg branch_ok;
	assign branch_type = IRin[20:19];
	always @(branch_type or Ra) begin
		branch_ok <= 0;
		case(branch_type)
			2'b00 : begin //branch if zero
						if(Ra == 0)
							branch_ok <= 1;
					  end
			2'b01 : begin //branch if nonzero
						if(Ra != 0)
							branch_ok <= 1;
					  end
			2'b10 : begin //branch if positive
						if(Ra > 0)
							branch_ok <= 1;
					  end
			2'b11 : begin //branch if negative
						if(Ra < 0)
							branch_ok <= 1;
					  end
			endcase
	end

endmodule
