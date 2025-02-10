// LD datapath_tb.v file
`timescale 1ns/10ps
module ld_datapath_tb;

    reg clr, clk;
    reg IncPC;
    reg CON_enable; // not in datapath yet
    wire [31:0] bus_contents;
    reg RAM_write;
    reg MDR_enable, MDRout, IR_enable, MAR_enable, Y_enable;
    reg R_enable, Read; //RAM_write;
    reg Rout;
    reg [15:0] R0_R15_enable, R0_R15_out;
    reg Gra, Grb, Grc;
    reg HI_enable, LO_enable, ZLowIn, PC_enable;
	 reg InPortout, PCout, ZLowout, ZHighout, BAout;
    reg [31:0] InPort_input;
    reg [31:0] D;  // not sure about these two

    parameter Default = 4'b0000, Load_mem = 4'b0001, T0 = 4'b0010, T1 = 4'b0011, T2 = 4'b0100, T3 = 4'b0101, T4 = 4'b0110, T5 = 4'b0111, T6 = 4'b1000, T7 = 4'b1001;

    reg [3:0] Present_state = Default;
		
	 wire[31:0] r0_v, r1_v, MDR_v, PC_v;
	 wire[8:0] MAR_v;
    Datapath DUT(
        	.PC_out(PCout),          	
			.Zlo_out(ZLowout),
			.MDR_out(MDRout), 
			.Y_rd(Y_enable),
			.MAR_rd(MAR_enable), 
			.MDR_rd(MDR_enable),   	
			.PC_rd(PC_enable), 
			.IR_rd(IR_enable),
			.IncPC(IncPC),
			.clk(clk),
			.clr(clr),                       
			.Zlo_rd(ZLowIn),
			.Gra(Gra),								
			.Grb(Grb),                       
			.Grc(Grc),	
			.BAout(BAout),
			.Rin(R0_R15_enable), 
			.Rout(R0_R15_out),
			.BusMuxOut(bus_contents),
			.Read(Read),
			.Write(RAM_write),
			.r0_view(r0_v), .r1_view(r1_v), .MAR_view(MAR_v), .MDR_view(MDR_v), .PC_view(PC_v)
    );

	initial 
	begin
		clk = 0;
		forever #10 clk = ~ clk;
end

	always @(posedge clk)
        begin
            case (Present_state)
                Default			   :	#80 Present_state = Load_mem;
					 Load_mem			:	#40 Present_state = T0;
                T0					:	#40 Present_state = T1;
                T1					:	#40 Present_state = T2;
                T2					:	#40 Present_state = T3;
                T3					:	#40 Present_state = T4;
                T4					:	#40 Present_state = T5;
                T5					:	#40 Present_state = T6;
                T6					:	#40 Present_state = T7;
		    endcase
end

//Test 1: Load contents of address 0x75 into R1
//Test 2: Load Contents of Address 0x45 + R1
always @(Present_state) 

	begin
		case (Present_state) 
			Default: begin
				PCout <= 0; ZLowout <= 0; MDRout <= 0; 
				MAR_enable <= 0; ZLowIn <= 0; CON_enable<=0; 
				PC_enable <=0; MDR_enable <= 0; IR_enable <= 0; Y_enable <= 0;
				IncPC <= 0; 
				Gra<=0; Grb<=0; Grc<=0;
				Rout<=0; R_enable<=0; Read <= 0; RAM_write<=0;
				R0_R15_enable<= 16'd0; R0_R15_out<=16'd0;
			end
			
			//Load opcode in from memory (ld command: addr 0)
			Load_mem: begin
				Read <= 1; MAR_enable <= 1;
				#20
				Read <= 0; MAR_enable <= 0;
			end
			
			//Determine starting address
			T0: begin 
				PCout <= 1; MAR_enable <= 1;
				IncPC <= 1;
				#20 IncPC <= 0;
				PCout <= 0; MAR_enable <= 0;
			end

			T1: begin //Loads MDR from RAM output (loads from specified address in memory) 
				
				MDR_enable <= 1; Read <= 1;
				IncPC <= 1;
				#20 IncPC <= 0;
				MDR_enable <= 0; Read <= 0;
			end

			T2: begin //Load MDR contents into IR
				
				MDRout <= 1; IR_enable <= 1; 
				IncPC <= 1;
				#20 IncPC <= 0;
				MDRout <= 0; IR_enable <= 0;
			end

			T3: begin //Using select and encode logic, enable register designated in opcode, and place stored value into Y
				Grb <=1; BAout <= 1; R0_R15_out <= 1; Y_enable <= 1;
				IncPC <= 1;
				#20 IncPC <= 0;
				Grb <= 0; BAout <= 0; Rout <= 0; Y_enable <= 0; 
			end

			T4: begin
				
				Grb<=0; BAout<=0;
				ZLowIn <= 1;
				IncPC <= 1;
				#20 IncPC <= 0;
			end

			T5: begin
				
				ZLowIn <= 0;
				IncPC <= 1;
				#20 IncPC <= 0;
			end

			T6: begin
				MAR_enable <= 1; PCout <= 1;
				
				MAR_enable <= 0; PCout <= 0;
				Read <= 1; MDR_enable <= 1;
				IncPC <= 1;
				#20 IncPC <= 0;
			end
			T7: begin
				
				Read <= 0; MDR_enable <= 0;
				MDRout <= 1; //Gra <= 1; R_enable <= 1;
				IncPC <= 1;
				#20 IncPC <= 0;
			end
		endcase
	end

endmodule
