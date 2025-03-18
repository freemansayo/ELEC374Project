`timescale 1ns/10ps
module mem_tb();
	
	reg clk, Write, Read, MDR_rd, MAR_rd;
	wire[8:0] mem_addr;
	reg[31:0] BusMuxOut;
	wire[31:0] MDR_bus, Mdatain;
	
	
	always #5 clk = ~clk;
	//Memory unit architecture:
	//MDR takes input from Bus when Read_from_mem = 0, from Memory otherwise
	//Memory unit cannot write directly to bus, desired cell must be selected with MAR, then read into MDR with Read_from_mem signal
	//MDR-Bus connection works the same as any other register; correct Data signal must be asserted to bus encoder
	memory mem_inst(.Datain(MDR_bus), .Address(mem_addr), .Write(Write), .clk(clk), .Dataout(Mdatain));
	MDR mem_data_reg(.Q(MDR_bus), .Clock(clk), .enable(MDR_rd), .Read_from_mem(Read), .in_from_bus(BusMuxOut), .Mdatain(Mdatain));
	Register mem_addr_reg(.D(BusMuxOut), .Q(mem_addr), .clock(clk), .enable(MAR_rd));
	
	
	//Simulate a load from address 0x54 (should read 0x97 from that address)
	//Then, simulate a store to address 0x34 (will store the value 0xB6, initial value at 0x34 = 0x25)
	initial begin
		//Assert initial values
		clk <= 0;
		Write <= 0;
		MAR_rd <= 0;
		MDR_rd <= 0;
		Read <= 0;
		BusMuxOut <= 0;
		#10
		
		//memory unit operation (Reading a cell): 2 clock cycles
		//Determine address to access: 1 cycle
		BusMuxOut <= 9'h54;
		MAR_rd <= 1;
		#10
		MAR_rd <= 0;
		
		//Read accessed cell from memory (data visible on MDR_bus, in this case 0x97): 1 cycle
		Read <= 1;
		MDR_rd <=1;
		#10
		Read <= 0;
		MDR_rd <= 0;
		
		#10
		
		//memory unit operation (Writing to a cell): 3 cycles, extra cycles in this example for illustrative steps
		//Determine address to access, and read current value into MDR for comparison's sake: 1 cycle
		BusMuxOut <= 32'h34;
		MAR_rd <= 1;
		Read <= 1;
		#10
		MAR_rd <= 0;
		Read <= 0;
		
		//Read value to be written into MDR: 1 cycle
		BusMuxOut <= 9'h80;
		Read <= 0; //Ensure Read-From-Memory signal is low so Bus input is read
		MDR_rd <= 1;
		#10
		MDR_rd <= 0;
		
		//Write new value into selected cell: 1 cycle
		Write <= 1;
		#10
		Write <= 0;
		
		//Following steps are optional
		//Write 0 into MDR to show operation's effects: 1 cycle
		BusMuxOut <= 32'd0;
		MDR_rd <= 1;
		#10
		MDR_rd <= 0;
		
		//Read selected cell's content into MDR: 1 cycle
		Read <= 1;
		MDR_rd <= 1;
		#10
		Read <= 0;
		MDR_rd <= 0;
		
	end
	
endmodule
