`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Lukas Hunker, Brede Doerner
// 
// Create Date:    14:20:37 09/25/2014 
// Design Name: 
// Module Name:    lab3 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: Top level of lab 3. Reads 8 values into sram, then allows them to be read back
//					then outputs values to DAC
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
	 
	 //output clock from the dcm
	 wire clk_10m;
	 
	 //oddr2 register to forward clock to the dac
	 ODDR2 #(
		.DDR_ALIGNMENT("NONE"),
		.INIT(1'b0),
		.SRTYPE("SYNC")
		) clock_forward_inst (
			.Q(dac_clock),
			.C0(~clk_10m),
			.C1(clk_10m),
			.CE(1'b1),
			.D0(1'b0),
			.D1(1'b1),
			.R(1'b0),
			.S(1'b0)
		);

	  dcm_10 clock_mod
		(// Clock in ports
		 .CLK_IN1(clk),      // IN
		 // Clock out ports
		 .CLK_OUT1(clk_10m),     // OUT
		 // Status and control signals
		 .RESET(reset));       // IN
	
	//seven seg display
	reg [15:0] seg_in;
	seven_seg display (
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
	  
	 //memory interface
	 wire read_ready;
	 reg [7:0] datain;
	 wire [7:0] dataout;
	 reg read_sig, write_sig;
	 reg [3:0] addrin;
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
	reg [9:0] clken_count;
	always @(posedge clk_10m)
	begin
	if(clken_count == 999)
		clken_count <= 7'd0;
	else
		clken_count <= clken_count + 1'b1;
	end
	//generate clock enable at a rate of 10 KHz
	assign clken_10KHz = (clken_count == 0);
	
	//state machine parameters
	parameter [1:0] init = 2'h0, write = 2'h1, read = 2'h2, dac = 2'h3;
	
	//generate a delayed 
	reg button_pressed;
	always @(posedge clk_10m)
		button_pressed <= button_db;
	
	//counter for address bus
	reg [3:0] count;
	always @(posedge clk_10m)
	begin
		if((current_state == write) & button_db & ~button_pressed)
			count <= count + 1'b1;
		else if((current_state == dac) & clken_10KHz)
		begin
			if(count == 7)
				count <= 4'b0;
			else
				count <= count + 1'b1;
		end
		else if(current_state == init)
			count <= 4'h0;
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
	always @(count, button_db, current_state, button_pressed)
	case(current_state)
		init:
			next_state = write;
		write:
			if(count == 4'h8)
				next_state = read;
			else
				next_state = write;
		read:
			if(button_db & ~button_pressed)
				next_state = dac;
			else
				next_state = read;
		dac:
			if(button_db & ~button_pressed)
				next_state = init;
			else
				next_state = dac;
	endcase
	
	//synchronous state machine with asynchronous reset
	always @(posedge clk_10m, posedge reset)
	if(reset)
		current_state <= init;
	else
		current_state <= next_state;
	
	//output logic
	always @(dataout, current_state, count, clken_10KHz, button_db, sw)
	begin
		case(current_state)
			init:
			begin
				addrin = 4'h0;
				datain = 8'h0;
				seg_in = 16'h0;
				read_sig = 1'b0;
				write_sig = 1'b0;
			end
			write:
			begin
				addrin = count;
				datain = sw;
				seg_in = {4'h0, count, sw};
				read_sig = 1'b0;
				write_sig = button_db;
			end
			read:
			begin
				addrin = sw[3:0];
				datain = 8'h0;
				seg_in = {addrin, 4'b0, dataout};
				read_sig = 1'b1;
				write_sig = 1'b0;
			end
			dac:
			begin
				addrin = count;
				datain = 8'h0;
				seg_in = {16'b0};
				read_sig = 1'b1;
				write_sig = 1'b0;
			end
		endcase
	end
	
	assign dac_begin = (current_state == dac & read_ready) ? 1'b1 : 1'b0;
	
	assign dac_data = dataout;
	
	
endmodule
