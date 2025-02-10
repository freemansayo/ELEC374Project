//rotate left
module ALU_ROL(input[31:0] A, input[4:0] B,
					output reg[31:0] rotated);
	always@(*) begin
		case(B)
			5'd1 : rotated <= {A[30:0], A[31]};
			5'd2 : rotated <= {A[29:0], A[31:30]};
			5'd3 : rotated <= {A[28:0], A[31:29]};
			5'd4 : rotated <= {A[27:0], A[31:28]};
			5'd5 : rotated <= {A[26:0], A[31:27]};
			5'd6 : rotated <= {A[25:0], A[31:26]};
			5'd7 : rotated <= {A[24:0], A[31:25]};
			5'd8 : rotated <= {A[23:0], A[31:24]};
			5'd9 : rotated <= {A[22:0], A[31:23]};
			5'd10: rotated <= {A[21:0], A[31:22]};
			5'd11: rotated <= {A[20:0], A[31:21]};
			5'd12: rotated <= {A[19:0], A[31:20]};
			5'd13: rotated <= {A[18:0], A[31:19]};
			5'd14: rotated <= {A[17:0], A[31:18]};
			5'd15: rotated <= {A[16:0], A[31:17]};
			5'd16: rotated <= {A[15:0], A[31:16]};
			5'd17: rotated <= {A[14:0], A[31:15]};
			5'd18: rotated <= {A[13:0], A[31:14]};
			5'd19: rotated <= {A[12:0], A[31:13]};
			5'd20: rotated <= {A[11:0], A[31:12]};
			5'd21: rotated <= {A[10:0], A[31:11]};
			5'd22: rotated <= {A[9:0], A[31:10]};
			5'd23: rotated <= {A[8:0], A[31:9]};
			5'd24: rotated <= {A[7:0], A[31:8]};
			5'd25: rotated <= {A[6:0], A[31:7]};
			5'd26: rotated <= {A[5:0], A[31:6]};
			5'd27: rotated <= {A[4:0], A[31:5]};
			5'd28: rotated <= {A[3:0], A[31:4]};
			5'd29: rotated <= {A[2:0], A[31:3]};
			5'd30: rotated <= {A[1:0], A[31:2]};
			5'd31: rotated <= {A[0], A[31:1]};
			default: rotated <= A;
		endcase
	end   
endmodule 