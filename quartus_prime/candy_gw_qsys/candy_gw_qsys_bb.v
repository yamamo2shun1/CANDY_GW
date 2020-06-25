
module candy_gw_qsys (
	adc_export,
	altpll_locked_export,
	clk_clk,
	codec_clk_clk,
	codec_reset_export,
	grove1_in_port,
	grove1_out_port,
	i2s_lrclk_i_mst,
	i2s_data_i_mst,
	i2s_data_o_mst,
	i2s_lrclk_o_slv,
	i2s_data_o_slv,
	i2s_bitclk_o_slv,
	new_sdram_controller_0_wire_addr,
	new_sdram_controller_0_wire_ba,
	new_sdram_controller_0_wire_cas_n,
	new_sdram_controller_0_wire_cke,
	new_sdram_controller_0_wire_cs_n,
	new_sdram_controller_0_wire_dq,
	new_sdram_controller_0_wire_dqm,
	new_sdram_controller_0_wire_ras_n,
	new_sdram_controller_0_wire_we_n,
	oe_export,
	onbrd_led_pwm_out,
	pmod2_export,
	qspi_dclk,
	qspi_ncs,
	qspi_data,
	reset_reset_n,
	sdclk_clk_clk,
	uart_rxd,
	uart_txd,
	uart_cts_n,
	uart_rts_n,
	wb_ack_i,
	wb_adr_o,
	wb_clk_o,
	wb_cyc_o,
	wb_dat_i,
	wb_dat_o,
	wb_err_i,
	wb_rst_o,
	wb_rty_i,
	wb_sel_o,
	wb_stb_o,
	wb_we_o,
	i2s_bclk_mst_clk);	

	input	[7:0]	adc_export;
	output		altpll_locked_export;
	input		clk_clk;
	output		codec_clk_clk;
	output		codec_reset_export;
	input	[1:0]	grove1_in_port;
	output	[1:0]	grove1_out_port;
	input		i2s_lrclk_i_mst;
	input		i2s_data_i_mst;
	output		i2s_data_o_mst;
	output		i2s_lrclk_o_slv;
	output		i2s_data_o_slv;
	output		i2s_bitclk_o_slv;
	output	[12:0]	new_sdram_controller_0_wire_addr;
	output	[1:0]	new_sdram_controller_0_wire_ba;
	output		new_sdram_controller_0_wire_cas_n;
	output		new_sdram_controller_0_wire_cke;
	output		new_sdram_controller_0_wire_cs_n;
	inout	[15:0]	new_sdram_controller_0_wire_dq;
	output	[1:0]	new_sdram_controller_0_wire_dqm;
	output		new_sdram_controller_0_wire_ras_n;
	output		new_sdram_controller_0_wire_we_n;
	output		oe_export;
	output	[3:0]	onbrd_led_pwm_out;
	input	[3:0]	pmod2_export;
	output		qspi_dclk;
	output		qspi_ncs;
	inout	[3:0]	qspi_data;
	input		reset_reset_n;
	output		sdclk_clk_clk;
	input		uart_rxd;
	output		uart_txd;
	input		uart_cts_n;
	output		uart_rts_n;
	input		wb_ack_i;
	output	[31:0]	wb_adr_o;
	output		wb_clk_o;
	output		wb_cyc_o;
	input	[31:0]	wb_dat_i;
	output	[31:0]	wb_dat_o;
	input		wb_err_i;
	output		wb_rst_o;
	input		wb_rty_i;
	output	[3:0]	wb_sel_o;
	output		wb_stb_o;
	output		wb_we_o;
	input		i2s_bclk_mst_clk;
endmodule
