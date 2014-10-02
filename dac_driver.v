`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Brede Doerner and Lukas Hunker
// 
// Create Date:    9:57:15 09/14/2014 
// Design Name: 
// Module Name:    dac_counter 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: DAC driver that generates SPI interface signals 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
/////////////////////////////////////////////////////////////////////////////////

module dac_driver(
	input clk,
	input [7:0] dac_data,
	input [7:0] dac_control,
	input dac_begin,
	output dac_sout,
	output reg dac_sync
	);
	
		//FF used with dac_sync to encode the state of the SPI transmission

		reg running = 0;
		
		//serial output from the shift register
		assign dac_sout = shift[15];
		
		// counter and shift register used to shift out the 16 bits of data to the dac
		reg [3:0] counter = 4'b0000;
		reg [15:0] shift;
		
		always @ (negedge clk)
			if(dac_sync & dac_begin)	//initializing SPI transmission, clear sync
				begin
				shift <= {dac_control, dac_data};
				dac_sync <= 1'b0;
				counter <= 4'b0000;
				running <= 1'b1;
				end
			else if(counter != 4'b1111 & running)	//transmit data for 16 cycles
				begin
				counter <= counter + 1'b1;
				shift <= {shift[14:0], 1'b0};
				end
			else							//end SPI transmission, set sync
				begin
				dac_sync <= 1'b1;
				running <= 1'b0;
				end
				
endmodule