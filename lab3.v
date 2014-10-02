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
    input button,
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
	 inout [15:0] mem_data,
	 output dac_sout,
	 output dac_clock,
	 output dac_sync
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
    .in(seg_in), 
    .clk(clk_10m), 
    .seg(seg), 
    .anodes(anode)
    );
	
	//Button debouncers
	wire button_db;
	but_debounce db1 (
    .but_in(button), 
    .clk(clk_10m), 
    .reset(reset), 
    .but_out(button_db)
    );
	  
	 wire read_ready;
	 wire [7:0] datain;
	 wire read_sig, write_sig;
	 wire [3:0] addrin;
	mem_control ram_control (
		 .clk(clk_10m),
		 .data(mem_data), 
		 .read_ready(read_ready), 
		 .memclk(memclk), 
		 .adv_n(adv_n), 
		 .cre(cre), 
		 .ce_n(ce_n), 
		 .oe_n(oe_n), 
		 .we_n(we_n), 
		 .lb_n(lb_n), 
		 .ub_n(ub_n), 
		 .read(read_sig), 
		 .write(write_sig), 
		 .datain_b(datain), 
		 .dataout(dataout), 
		 .addr(addr), 
		 .reset(reset),
		 .addr_in(addrin)
		 );
	
	//counter to generate 10KHz clken_10KHz
	wire clken_10KHz;
	reg [6:0] clken_count;
	always @(posedge clk_10m)
	begin
	if(clken_count == 7'd99)
		clken_count <= 7'd0;
	else
		clken_count <= clken_count + 7'd1;
	end
	//generate clock enable at a rate of 10 KHz
	assign clken_10KHz = (clken_count == 7'd99);
	
	parameter [1:0] init = 2'd0, write = 2'd1, read = 2'd2, dac = 2'd3;
	
	//counter for address bus
	reg [3:0] count;
	always @(posedge clk_10m)
	begin
	if((state == write & button_db) | (state == dac & clken_10KHz))
		if(count == 4'd9)
			count <= 4'd0;
		else
			count <= count + 4'd1;
	end
	
	//instantiate dac driver
	
	wire [7:0] dac_data;
	wire dac_begin;
	dac_driver dac_drv(
		.clk(clk_10m),
		.dac_data(dac_data),
		.dac_control(8'b0),
		.dac_begin(dac_begin),
		.dac_sout(dac_sout),
		.dac_sync(dac_sync));
	
	//state registers
	reg [1:0] current_state, next_state;
	
	//next state logic
	always @(count, button_db)
	case(current_state)
		init:
			next_state = write;
		write:
			if(count == 4'd9)
				next_state = read;
			else
				next_state = write;
		read:
			if(button_db)
				next_state = dac;
			else
				next_state = read;
		dac:
			if(button_db)
				next_state = init;
			else
				next_state = read;
	endcase
	
	//synchronous state machine with asynchronous reset
	always @(posedge clk_10m, posedge reset)
	if(reset)
		current_state <= init;
	else
		current_state <= next_state;
	
	//output logic
	always @(current_state, count, clken_10KHz, button_db, sw, read_ready)
	begin
		case(current_state)
			init:
				addrin = 4'd0;
				datain = 8'd0;
				seg_in = 16'd0;
				read_sig = 1'b0;
				write_sig = 1'b0;
			write:
				addrin = count;
				datain = sw;
				seg_in = {8'd0, sw};
				read_sig = 1'b0;
				write_sig = button_db;
			read:
				addrin = {sw[3:0]}
				datain = 8'd0;
				seg_in = {8'd0, dataout};
				if(read_ready)
					read_sig = 1;
				else
					read_sig = 0;
				write_sig = 1'b0;
			dac:
				addrin = count;
				datain = 8'd0;
				seg_in = 16'd0;
				read_sig = clken_10KHz;
				write_sig = 1'b0;
		endcase
	end
	
	assign dac_begin = (current_state == dac & read_ready) ? 1'b1 : 0;
	
	assign dac_data = dataout;
	
	
endmodule
