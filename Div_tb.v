//Divider Testbench DIVISION WORKS

`timescale 1ns/100ps
module Div_tb();
	
	reg[31:0] Qin, M;
	reg clk, reset, inloop;
	wire[63:0] result;
	wire[31:0] remainder, Qout, len_w, count_v;
	wire finish_v;
	Divider div_inst(Qin, M, clk, reset, result, len_w, count_v, finish_v);
	assign remainder = result[63:32];
	assign Qout = result[31:0];
	always #1 clk = ~clk;
	
	initial begin
		clk <= 0;
		reset <= 1;
		inloop <= 0;
		Qin <= 10;
		M <= 3;
		
		#4
		while(!finish_v) begin
		inloop <= 1;
		#1;
		end
		inloop <= 0;
			reset <= 0;
		#5 reset <= 1;
			Qin <= 68;
			M <= 2;
		#4
		while(!finish_v) begin
		inloop <= 1;
		#1;
		end
		inloop <= 0;
			reset <= 0;
		#5 reset <= 1;
			Qin <= 80;
			M <=1;
		#4
		while(!finish_v) begin
		inloop <= 1;
		#1;
		end
		inloop <= 0;	
			reset <= 0;
		#5 reset <= 1;
			Qin <= 30480;
			M <= 11;
		#4
		while(!finish_v) begin
		inloop <= 1;
		#1;
		end
		inloop <= 0;
		reset <= 0;
		#5 reset <= 1;
			Qin <= 1;
			M <= 32'hffffffff;
			
		#4
		while(!finish_v) begin
		inloop <= 1;
		#1;
		end
		inloop <= 0;
			reset <= 0;
		#5 reset <= 1;
			Qin <= 97;
			M <= 30;
	end
	
endmodule
