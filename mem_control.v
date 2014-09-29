`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:57:45 09/25/2014 
// Design Name: 
// Module Name:    mem_control 
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
module mem_control(
	//memory interface i/o
    inout [15:0] data,
    output memclk,
    output adv_n,
    output cre,
    output ce_n,
    output oe_n,
    output we_n,
    output lb_n,
    output ub_n,
	 output [25:0] addr,
	 
	 //module i/o
	 input clk,
	 input reset,
	 input read,
	 output read_ready,
    input write,
    input [7:0] datain,
    output reg [7:0] dataout,
    input [3:0] addr_in
    );
	 
	 parameter [1:0] idle = 0, writing = 1, reading = 2, read_done = 3;

	 reg [1:0] current_state, next_state;
	 
	 //Flip Flop Control
	 always @ (posedge clk, posedge reset)
		if(reset)
			current_state <= idle;
		else
			current_state <= next_state;
			
	 //Next state logic
	 always @ (read, write, datain, addr_in, current_state)
		case (current_state)
			idle:
				if (read)
					next_state = reading;
				else if (write)
					next_state = writing;
				else
					next_state = idle;
			writing:
				if(write)
					next_state = writing;
				else if (read)
					next_state = reading;
				else
					next_state = idle;
			reading:
				next_state = read_done;
			read_done:
				if(read)
					next_state = read_done;
				else if (write)
					next_state = writing;
				else
					next_state = idle;		
		endcase
		
		//Output logic
		
		//set dataout to always show last read
		always @(posedge clk)
			if (current_state == read_done)
				dataout <= data[7:0];
			else
				dataout <= dataout;
				
		
		assign memclk = 0;
		assign ce_n = 0;
		assign lb_n = 0;
		assign ub_n = 0;
		assign we_n = (current_state != writing);
		assign addr = { 22'b0, addr_in};
		assign adv_n = 0;
		assign cre = 0;
		assign oe_n = ((current_state == reading || current_state == read_done)) ? 1'b0 : 1'b1;
		assign data = (current_state == writing) ? {8'b0, datain} :
			16'bZ;
		assign read_ready = (current_state == read_done);
		
		

endmodule
