`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Lukas Hunker, Brede Doerner
// 
// Create Date:    19:52:57 09/08/2014 
// Design Name: 
// Module Name:    seven_seg 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: Takes in a 16 bit number and converts it to seven segment display outputs
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module seven_seg(
    input [15:0] in,
	 input clk,
    output [6:0] seg,
    output [3:0] anodes
    );
	 
	 reg [1:0] mux = 0;	//anode selector mux
	 reg [14:0] count = 0;	//counter to scale down clock
	 
	 //Scale down clock to 1khz
	 always @ (posedge clk)
	 begin
		if (count == 9999)
			count <= 0;
		else
			count <= count + 1'b1;
	 end
	 
	 //Counter for selection
	 wire count_en;
	 
	 assign count_en = (count == 9999);	//enable for anode counter
	 
	 always @(posedge clk)
		if(count_en)
			mux <= mux + 1'b1;
	 

	//select input with mux (by setting anode)

	wire [3:0] display;
	assign anodes = (mux == 2'b00) ? 4'b1110 : 
		(mux == 2'b01) ? 4'b1101 :
		(mux == 2'b10) ? 4'b1011 :
		4'b0111;
		
	assign display = (mux == 2'b00) ? in[3:0] : 
		(mux == 2'b01) ? in[7:4] :
		(mux == 2'b10) ? in[11:8] :
		in[15:12];
		
	//convert input to 7 seg output
	
	//parameters for display
	parameter zero = 7'b000001;
	parameter one = 7'b1001111;
	parameter two = 7'b0010010;
	parameter three = 7'b0000110;
	parameter four = 7'b1001100;
	parameter five = 7'b0100100;
	parameter six = 7'b0100000;
	parameter seven = 7'b0001111;
	parameter eight = 7'b0000000;
	parameter nine = 7'b0001100;
	parameter ten = 7'b0001000;
	parameter eleven =  7'b1100000;
	parameter twelve = 7'b0110001;
	parameter thirteen = 7'b1000010;
	parameter fourteen = 7'b0110000;
	parameter fifteen = 7'b0111000;

	//setup display
	assign seg = (display == 4'b0000) ?  zero :
		(display == 4'b0001) ? one : 
		(display == 4'b0010) ? two :
		(display == 4'b0011) ? three : 	
		(display == 4'b0100) ? four : 
		(display == 4'b0101) ? five : 
		(display == 4'b0110) ? six :
		(display == 4'b0111) ? seven :
		(display == 4'b1000) ?  eight:
		(display == 4'b1001) ? nine : 	
		(display == 4'b1010) ? ten :
		(display == 4'b1011) ? eleven :
		(display == 4'b1100) ? twelve :
		(display == 4'b1101) ? thirteen :
		(display == 4'b1110) ? fourteen :
		fifteen;
	
endmodule

