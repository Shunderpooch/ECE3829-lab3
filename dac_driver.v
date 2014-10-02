module dac_driver(
	input clk,
	input [7:0] dac_data,
	input [7:0] dac_control,
	input dac_begin,
	output dac_sout,
	output dac_sync
	);
	
		reg dac_sync = 1;
		reg running = 0;
		
		assign s_out = shift[15];
		
		reg [3:0] counter = 4'b0000;
		reg [15:0] shift;
		
		always @ (negedge clk)
			if(dac_sync & dac_begin)
				begin
				shift <= {control, data};
				dac_sync <= 1'b0;
				counter <= 4'b0000;
				running <= 1'b1;
				end
			else if(counter != 4'b1111 & running)
				begin
				counter <= counter + 1'b1;
				shift <= {shift[14:0], 1'b0};
				end
			else
				begin
				dac_sync <= 1'b1;
				running <= 1'b0;
				end
				
endmodule