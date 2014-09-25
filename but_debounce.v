`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Lukas Hunker
// 
// Create Date:    14:31:12 09/25/2014 
// Design Name: 
// Module Name:    but_debounce 
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
module but_debounce(
    input but_in,
    input clk,
	 input reset,
    output reg but_out
    );

	//Reduce 10 Mhz clock
	reg [16:0] count;
	wire clk_en;
	
	always @ (posedge clk, posedge reset)
		if(reset)
			count <= 0;
		else
			if (count == 99999)
				count <= 0;
			else
				count <= count + 1'b1;
				
	assign clk_en = (count == 0);
	
	//State Machine
	parameter [1:0] s0 = 0, s1 = 1, s2 = 2, s3 = 3;
	
	reg [1:0] curr_state, next_state;
	
	//State machine flip flop
	always @ (posedge clk, posedge reset)
		if(reset)
			curr_state <= s0;
		else
			if(clk_en)
				curr_state <= next_state;
			else
				curr_state <= curr_state;
				
	//Next State logic
	always @ (curr_state, but_in)
		case (curr_state)
			s0: begin
					but_out = 1'b0;
					if(but_in)
						next_state = s1;
					else
						next_state = s0;
				end
			s1: begin
				//but_out = but_out;
				if(but_in)
					next_state = s2;
				else
					next_state = s0;
			end
			s2: begin
				//but_out = but_out;
				if(but_in)
					next_state = s3;
				else
					next_state = s1;
			end
			s3: begin
					but_out = 1'b1;
					if(but_in)
						next_state = s3;
					else
						next_state = s2;
				end
		endcase

endmodule
