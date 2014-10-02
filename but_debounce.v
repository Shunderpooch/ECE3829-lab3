`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Lukas Hunker, Brede Doerner
// 
// Create Date:    14:31:12 09/25/2014 
// Design Name: 
// Module Name:    but_debounce 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: Debounces the signal in but_in, and outputs it to but_out
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
	//Uses 4 states to delay change from but_in to but_out
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
	always @ (curr_state, but_in, but_out)
		case (curr_state)
			s0: begin
					if(but_in)
						next_state = s1;
					else
						next_state = s0;
				end
			s1: begin
				if(but_in)
					next_state = s2;
				else
					next_state = s0;
			end
			s2: begin
				if(but_in)
					next_state = s3;
				else
					next_state = s1;
			end
			s3: begin
					//but_out = 1'b1;
					if(but_in)
						next_state = s3;
					else
						next_state = s2;
				end
		endcase
		
		//output
		always @ (posedge clk)
			if (curr_state == s3)
				but_out <= 1'b1;
			else if (curr_state == s0)
				but_out <= 1'b0;
			else
				but_out <= but_out;
			

endmodule
