`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:20:37 09/25/2014 
// Design Name: 
// Module Name:    lab3 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module lab3(
    input [7:0] sw,
    input clk,
    input write,
    input read,
	 input reset,
    output [6:0] seg,
    output [3:0] anode,
	 output [25:0]addr,
	 output memclk,
	 output adv_n,
	 output cre,
	 output ce_n,
	 output oe_n,
	 output we_n,
	 output lb_n,
	 output ub_n,
	 inout [15:0] mem_data
    );

		wire clk_10m;
	  dcm_10 clock_mod
		(// Clock in ports
		 .CLK_IN1(clk),      // IN
		 // Clock out ports
		 .CLK_OUT1(clk_10m),     // OUT
		 // Status and control signals
		 .RESET(reset));       // IN
	
	//seven seg display
	wire[15:0] seg_in;
	wire[7:0] dataout;
	assign seg_in = (read) ? {4'b0, sw[7:4], dataout} :
		{4'b0, sw[7:4], 4'b0, sw[3:0]};
	seven_seg s (
    .in(seg_in), 
    .clk(clk_10m), 
    .seg(seg), 
    .anodes(anode)
    );
	
	//Button debouncers
	wire write_db;
	but_debounce db1 (
    .but_in(write), 
    .clk(clk_10m), 
    .reset(reset), 
    .but_out(write_db)
    );
	wire read_db;
	but_debounce db2 (
    .but_in(read), 
    .clk(clk_10m), 
    .reset(reset), 
    .but_out(read_db)
    );
	  
	 wire validread;
	mem_control ram_control (
		 .clk(clk_10m),
		 .data(mem_data), 
		 .read_ready(validread), 
		 .memclk(memclk), 
		 .adv_n(adv_n), 
		 .cre(cre), 
		 .ce_n(ce_n), 
		 .oe_n(oe_n), 
		 .we_n(we_n), 
		 .lb_n(lb_n), 
		 .ub_n(ub_n), 
		 .read(read_db), 
		 .write(write_db), 
		 .datain({4'b0, sw [3:0]}), 
		 .dataout(dataout), 
		 .addr(addr), 
		 .reset(reset),
		 .addr_in(sw[7:4])
		 );

endmodule
