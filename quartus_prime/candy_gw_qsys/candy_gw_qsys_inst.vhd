	component candy_gw_qsys is
		port (
			adc_export                        : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- export
			altpll_locked_export              : out   std_logic;                                        -- export
			clk_clk                           : in    std_logic                     := 'X';             -- clk
			codec_clk_clk                     : out   std_logic;                                        -- clk
			codec_reset_export                : out   std_logic;                                        -- export
			grove1_in_port                    : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- in_port
			grove1_out_port                   : out   std_logic_vector(1 downto 0);                     -- out_port
			i2s_lrclk_i_mst                   : in    std_logic                     := 'X';             -- lrclk_i_mst
			i2s_data_i_mst                    : in    std_logic                     := 'X';             -- data_i_mst
			i2s_data_o_mst                    : out   std_logic;                                        -- data_o_mst
			i2s_lrclk_o_slv                   : out   std_logic;                                        -- lrclk_o_slv
			i2s_data_o_slv                    : out   std_logic;                                        -- data_o_slv
			i2s_bitclk_o_slv                  : out   std_logic;                                        -- bitclk_o_slv
			new_sdram_controller_0_wire_addr  : out   std_logic_vector(12 downto 0);                    -- addr
			new_sdram_controller_0_wire_ba    : out   std_logic_vector(1 downto 0);                     -- ba
			new_sdram_controller_0_wire_cas_n : out   std_logic;                                        -- cas_n
			new_sdram_controller_0_wire_cke   : out   std_logic;                                        -- cke
			new_sdram_controller_0_wire_cs_n  : out   std_logic;                                        -- cs_n
			new_sdram_controller_0_wire_dq    : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
			new_sdram_controller_0_wire_dqm   : out   std_logic_vector(1 downto 0);                     -- dqm
			new_sdram_controller_0_wire_ras_n : out   std_logic;                                        -- ras_n
			new_sdram_controller_0_wire_we_n  : out   std_logic;                                        -- we_n
			oe_export                         : out   std_logic;                                        -- export
			onbrd_led_pwm_out                 : out   std_logic_vector(3 downto 0);                     -- pwm_out
			pmod2_export                      : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- export
			qspi_dclk                         : out   std_logic;                                        -- dclk
			qspi_ncs                          : out   std_logic;                                        -- ncs
			qspi_data                         : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- data
			reset_reset_n                     : in    std_logic                     := 'X';             -- reset_n
			sdclk_clk_clk                     : out   std_logic;                                        -- clk
			uart_rxd                          : in    std_logic                     := 'X';             -- rxd
			uart_txd                          : out   std_logic;                                        -- txd
			uart_cts_n                        : in    std_logic                     := 'X';             -- cts_n
			uart_rts_n                        : out   std_logic;                                        -- rts_n
			wb_ack_i                          : in    std_logic                     := 'X';             -- ack_i
			wb_adr_o                          : out   std_logic_vector(31 downto 0);                    -- adr_o
			wb_clk_o                          : out   std_logic;                                        -- clk_o
			wb_cyc_o                          : out   std_logic;                                        -- cyc_o
			wb_dat_i                          : in    std_logic_vector(31 downto 0) := (others => 'X'); -- dat_i
			wb_dat_o                          : out   std_logic_vector(31 downto 0);                    -- dat_o
			wb_err_i                          : in    std_logic                     := 'X';             -- err_i
			wb_rst_o                          : out   std_logic;                                        -- rst_o
			wb_rty_i                          : in    std_logic                     := 'X';             -- rty_i
			wb_sel_o                          : out   std_logic_vector(3 downto 0);                     -- sel_o
			wb_stb_o                          : out   std_logic;                                        -- stb_o
			wb_we_o                           : out   std_logic;                                        -- we_o
			i2s_bclk_mst_clk                  : in    std_logic                     := 'X'              -- clk
		);
	end component candy_gw_qsys;

	u0 : component candy_gw_qsys
		port map (
			adc_export                        => CONNECTED_TO_adc_export,                        --                         adc.export
			altpll_locked_export              => CONNECTED_TO_altpll_locked_export,              --               altpll_locked.export
			clk_clk                           => CONNECTED_TO_clk_clk,                           --                         clk.clk
			codec_clk_clk                     => CONNECTED_TO_codec_clk_clk,                     --                   codec_clk.clk
			codec_reset_export                => CONNECTED_TO_codec_reset_export,                --                 codec_reset.export
			grove1_in_port                    => CONNECTED_TO_grove1_in_port,                    --                      grove1.in_port
			grove1_out_port                   => CONNECTED_TO_grove1_out_port,                   --                            .out_port
			i2s_lrclk_i_mst                   => CONNECTED_TO_i2s_lrclk_i_mst,                   --                         i2s.lrclk_i_mst
			i2s_data_i_mst                    => CONNECTED_TO_i2s_data_i_mst,                    --                            .data_i_mst
			i2s_data_o_mst                    => CONNECTED_TO_i2s_data_o_mst,                    --                            .data_o_mst
			i2s_lrclk_o_slv                   => CONNECTED_TO_i2s_lrclk_o_slv,                   --                            .lrclk_o_slv
			i2s_data_o_slv                    => CONNECTED_TO_i2s_data_o_slv,                    --                            .data_o_slv
			i2s_bitclk_o_slv                  => CONNECTED_TO_i2s_bitclk_o_slv,                  --                            .bitclk_o_slv
			new_sdram_controller_0_wire_addr  => CONNECTED_TO_new_sdram_controller_0_wire_addr,  -- new_sdram_controller_0_wire.addr
			new_sdram_controller_0_wire_ba    => CONNECTED_TO_new_sdram_controller_0_wire_ba,    --                            .ba
			new_sdram_controller_0_wire_cas_n => CONNECTED_TO_new_sdram_controller_0_wire_cas_n, --                            .cas_n
			new_sdram_controller_0_wire_cke   => CONNECTED_TO_new_sdram_controller_0_wire_cke,   --                            .cke
			new_sdram_controller_0_wire_cs_n  => CONNECTED_TO_new_sdram_controller_0_wire_cs_n,  --                            .cs_n
			new_sdram_controller_0_wire_dq    => CONNECTED_TO_new_sdram_controller_0_wire_dq,    --                            .dq
			new_sdram_controller_0_wire_dqm   => CONNECTED_TO_new_sdram_controller_0_wire_dqm,   --                            .dqm
			new_sdram_controller_0_wire_ras_n => CONNECTED_TO_new_sdram_controller_0_wire_ras_n, --                            .ras_n
			new_sdram_controller_0_wire_we_n  => CONNECTED_TO_new_sdram_controller_0_wire_we_n,  --                            .we_n
			oe_export                         => CONNECTED_TO_oe_export,                         --                          oe.export
			onbrd_led_pwm_out                 => CONNECTED_TO_onbrd_led_pwm_out,                 --                   onbrd_led.pwm_out
			pmod2_export                      => CONNECTED_TO_pmod2_export,                      --                       pmod2.export
			qspi_dclk                         => CONNECTED_TO_qspi_dclk,                         --                        qspi.dclk
			qspi_ncs                          => CONNECTED_TO_qspi_ncs,                          --                            .ncs
			qspi_data                         => CONNECTED_TO_qspi_data,                         --                            .data
			reset_reset_n                     => CONNECTED_TO_reset_reset_n,                     --                       reset.reset_n
			sdclk_clk_clk                     => CONNECTED_TO_sdclk_clk_clk,                     --                   sdclk_clk.clk
			uart_rxd                          => CONNECTED_TO_uart_rxd,                          --                        uart.rxd
			uart_txd                          => CONNECTED_TO_uart_txd,                          --                            .txd
			uart_cts_n                        => CONNECTED_TO_uart_cts_n,                        --                            .cts_n
			uart_rts_n                        => CONNECTED_TO_uart_rts_n,                        --                            .rts_n
			wb_ack_i                          => CONNECTED_TO_wb_ack_i,                          --                          wb.ack_i
			wb_adr_o                          => CONNECTED_TO_wb_adr_o,                          --                            .adr_o
			wb_clk_o                          => CONNECTED_TO_wb_clk_o,                          --                            .clk_o
			wb_cyc_o                          => CONNECTED_TO_wb_cyc_o,                          --                            .cyc_o
			wb_dat_i                          => CONNECTED_TO_wb_dat_i,                          --                            .dat_i
			wb_dat_o                          => CONNECTED_TO_wb_dat_o,                          --                            .dat_o
			wb_err_i                          => CONNECTED_TO_wb_err_i,                          --                            .err_i
			wb_rst_o                          => CONNECTED_TO_wb_rst_o,                          --                            .rst_o
			wb_rty_i                          => CONNECTED_TO_wb_rty_i,                          --                            .rty_i
			wb_sel_o                          => CONNECTED_TO_wb_sel_o,                          --                            .sel_o
			wb_stb_o                          => CONNECTED_TO_wb_stb_o,                          --                            .stb_o
			wb_we_o                           => CONNECTED_TO_wb_we_o,                           --                            .we_o
			i2s_bclk_mst_clk                  => CONNECTED_TO_i2s_bclk_mst_clk                   --                i2s_bclk_mst.clk
		);

