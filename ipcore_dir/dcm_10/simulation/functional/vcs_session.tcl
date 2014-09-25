gui_open_window Wave
gui_sg_create dcm_10_group
gui_list_add_group -id Wave.1 {dcm_10_group}
gui_sg_addsignal -group dcm_10_group {dcm_10_tb.test_phase}
gui_set_radix -radix {ascii} -signals {dcm_10_tb.test_phase}
gui_sg_addsignal -group dcm_10_group {{Input_clocks}} -divider
gui_sg_addsignal -group dcm_10_group {dcm_10_tb.CLK_IN1}
gui_sg_addsignal -group dcm_10_group {{Output_clocks}} -divider
gui_sg_addsignal -group dcm_10_group {dcm_10_tb.dut.clk}
gui_list_expand -id Wave.1 dcm_10_tb.dut.clk
gui_sg_addsignal -group dcm_10_group {{Status_control}} -divider
gui_sg_addsignal -group dcm_10_group {dcm_10_tb.RESET}
gui_sg_addsignal -group dcm_10_group {{Counters}} -divider
gui_sg_addsignal -group dcm_10_group {dcm_10_tb.COUNT}
gui_sg_addsignal -group dcm_10_group {dcm_10_tb.dut.counter}
gui_list_expand -id Wave.1 dcm_10_tb.dut.counter
gui_zoom -window Wave.1 -full
