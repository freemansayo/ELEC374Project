`timescale 1ns/10ps
module jal_tb;

    reg[15:0] R_rd;
    reg[15:0] R_wrt;
    reg[4:0] op_sel;
    reg R_out, HI_out, LO_out, Zhi_out, Zlo_out, PC_out, MDR_out, MAR_out, In_out, C_out;
    reg Rin, MARin, Zlowin, PCin, MDRin, IRin, Yin, CONin;
    reg IncPC, Read, Write, Gra, Grb, Grc, BAout;
    reg clk, clear;

    parameter Default = 0, Reg_loadR5a = 1, Reg_loadR5b = 2, Reg_loadR5c = 3,
              Reg_loadR8a = 4, Reg_loadR8b = 5, Reg_loadR8c = 6,
              Reg_loadPCa = 7, Reg_loadPCb = 8, Reg_loadPCc = 9,
              T0 = 10, T1 = 11, T2 = 12, T3 = 13, T4 = 14;

    reg [4:0] Present_state = Default;

    wire [8:0] MAR_v;
    wire [31:0] MDR_v, r5_v, r8_v, C_v, IR_v, PC_v, Y_v, Zlo_v, BusMuxOut_v, regControl_v;
    wire CON_out;

    Datapath DUT(.R_rd_diog(R_rd), .R_wrt_diog(R_wrt), .Rin(Rin), .CONin(CONin), .R_out(R_out), .HI_out(HI_out), .LO_out(LO_out), .Zhi_out(Zhi_out), .Zlo_out(Zlo_out), .PC_out(PC_out), .MDR_out(MDR_out), 
                 .MAR_out(MAR_out), .In_out(In_out), .C_out(C_out), .CON_output(CON_out), .MAR_rd(MARin), .Zlo_rd(Zlowin), .PC_rd(PCin), .MDR_rd(MDRin), .IR_rd(IRin), .Y_rd(Yin),
                 .IncPC(IncPC), .Read(Read), .Write(Write), .clk(clk), .clr(clear), .Gra(Gra), .Grb(Grb), .Grc(Grc), .BAout(BAout),
                 .r5_view(r5_v), .r8_view(r8_v), .Y_view(Y_v), .Zlo_view(Zlo_v), .MDR_view(MDR_v), .MAR_view(MAR_v), .BusMuxOut(BusMuxOut_v), .regControl_view(regControl_v),
                 .PC_view(PC_v), .IR_view(IR_v), .C_extended_view(C_v));

    initial begin
        clk = 0;
        repeat(300) #10 clk = ~clk;
    end

    always @(posedge clk) begin
        case (Present_state)
            Default        : #40 Present_state = Reg_loadR5a;
            Reg_loadR5a    : #40 Present_state = Reg_loadR5b;
            Reg_loadR5b    : #40 Present_state = Reg_loadR5c;
            Reg_loadR5c    : #40 Present_state = Reg_loadR8a;
            Reg_loadR8a    : #40 Present_state = Reg_loadR8b;
            Reg_loadR8b    : #40 Present_state = Reg_loadR8c;
            Reg_loadR8c    : #40 Present_state = Reg_loadPCa;
            Reg_loadPCa    : #40 Present_state = Reg_loadPCb;
            Reg_loadPCb    : #40 Present_state = Reg_loadPCc;
            Reg_loadPCc    : #40 Present_state = T0;
            T0             : #40 Present_state = T1;
            T1             : #40 Present_state = T2;
            T2             : #40 Present_state = T3;
            T3             : #40 Present_state = T4;
        endcase
    end

	 //Execute jal R5
    always @(Present_state) begin
        case (Present_state)
            Default: begin
                R_out <= 0; HI_out <= 0; LO_out <= 0; Zhi_out <= 0; Zlo_out <= 0; PC_out <= 0;
                MDR_out <= 0; MAR_out <= 0; In_out <= 0; C_out <= 0;
                MARin <= 0; Zlowin <= 0; PCin <= 0; MDRin <= 0; IRin <= 0; Yin <= 0; Rin <= 0;
                R_rd <= 0; CONin <= 0; IncPC <= 0; Read <= 0;
                Gra <= 0; Grb <= 0; Grc <= 0; BAout <= 0;
                clear <= 1; #20 clear <= 0;
            end

            // Load jump target into R5 (memory[0])
            Reg_loadR5a: begin PC_out <= 1; MARin <= 1; #20 PC_out <= 0; MARin <= 0; end
            Reg_loadR5b: begin MDRin <= 1; Read <= 1; #20 MDRin <= 0; Read <= 0; end
            Reg_loadR5c: begin IncPC <= 1; #5 IncPC <= 0;
                          MDR_out <= 1; R_rd[5] <= 1; Rin <= 1;
                          #15 MDR_out <= 0; R_rd[5] <= 0; Rin <= 0;
            end

            // Load something into R8 just for completeness (won't be used)
            Reg_loadR8a: begin PC_out <= 1; MARin <= 1; #20 PC_out <= 0; MARin <= 0; end
            Reg_loadR8b: begin MDRin <= 1; Read <= 1; #20 MDRin <= 0; Read <= 0; end
            Reg_loadR8c: begin IncPC <= 1; #5 IncPC <= 0;
                          MDR_out <= 1; R_rd[8] <= 1; Rin <= 1;
                          #15 MDR_out <= 0; R_rd[8] <= 0; Rin <= 0;
            end

            // Load PC from memory[2]
            Reg_loadPCa: begin PC_out <= 1; MARin <= 1; #20 PC_out <= 0; MARin <= 0; end
            Reg_loadPCb: begin MDRin <= 1; Read <= 1; #20 MDRin <= 0; Read <= 0; end
            Reg_loadPCc: begin MDR_out <= 1; PCin <= 1; #20 MDR_out <= 0; PCin <= 0; end

            // Fetch jal R5 instruction
            T0: begin 
					IncPC <= 1; 
					#5 IncPC <= 0;
               PC_out <= 1; MARin <= 1; Zlowin <= 1;
               #15 
					PC_out <= 0; MARin <= 0; Zlowin <= 0;
            end

            T1: begin 
					Zlo_out <= 1; PCin <= 1; Read <= 1; MDRin <= 1;
               #20 
					Zlo_out <= 0; PCin <= 0; Read <= 0; MDRin <= 0;
            end

            T2: begin MDR_out <= 1; IRin <= 1;
                       #20 MDR_out <= 0; IRin <= 0;
            end

            // Save PC+1 into R8
            T3: begin 
					Zlo_out <= 1; R_rd[8] <= 1; Rin <= 1;
					#20
					Zlo_out <= 0; R_rd[8] <= 0; Rin <= 0;
				end


            // Jump to address in R5
            T4: begin 
					Gra <= 1; R_out <= 1; PCin <= 1; // Gra selects R5
					#20 
					Gra <= 0; R_out <= 0; PCin <= 0;
				end

        endcase
    end
endmodule
