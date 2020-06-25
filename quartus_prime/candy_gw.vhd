library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity CANDY_GW is
	port(
		-- CLOCK & RESET
		CLK: in std_logic;
		RST: in std_logic;
		
		-- CLOCK OUT
		CODEC_CLKOUT: out std_logic;
		
		-- onboard LEDs
		LED: out std_logic_vector(3 downto 0);
		
		-- ADC
		ADC_IN: in std_logic_vector(7 downto 0);
		
		-- GROVE CONN
		GROVE1: inout std_logic_vector(1 downto 0);
		PMOD1:  out   std_logic_vector(3 downto 0);
		PMOD2:  in    std_logic_vector(3 downto 0);
		
		-- TX0104 output enable pin
		OE: out std_logic;
		
		-- I2S(ADAU1761)
		CODEC_SCL:      inout std_logic;
		CODEC_SDA:      inout std_logic;
		CODEC_RESET:    out std_logic;
		CODEC_BITCLOCK: inout std_logic;
		CODEC_LRCLOCK:  inout std_logic;
		CODEC_DATA_OUT: in std_logic;
		CODEC_DATA_IN:  out std_logic;
		
		-- DAC(MAX98357)
		DAC_BITCLOCK: out std_logic;
		DAC_LRCLOCK:  out std_logic;
		DAC_SDO:      out std_logic;
		
		-- UART(FT232HQ)
		UART_TX:  in  std_logic;
		UART_RX:  out std_logic;
		UART_CTS: out std_logic;
		UART_RTS: in  std_logic;
		
		-- SDRAM(AS4C16M16SA)
		DRAM_CLK:  out std_logic;
		DRAM_CKE:  out std_logic;
		DRAM_ADDR: out std_logic_vector(12 downto 0);
		DRAM_BA:   out std_logic_vector(1 downto 0);
		DRAM_CAS:  out std_logic;
		DRAM_RAS:  out std_logic;
		DRAM_CS:   out std_logic;
		DRAM_WE:   out std_logic;
		DRAM_UDQM: out std_logic;
		DRAM_LDQM: out std_logic;
		DRAM_DQ:   inout std_logic_vector(15 downto 0);
		
		-- FLASH(W25Q12JVSIQ)
		QSPI_CS:  out   std_logic;
		QSPI_CLK: out   std_logic;
		QSPI_IO:  inout std_logic_vector(3 downto 0)
	);
end CANDY_GW;

architecture RTL of CANDY_GW is
	component candy_gw_qsys is
		port (
			clk_clk                           : in    std_logic                     := 'X';             -- clk
         reset_reset_n                     : in    std_logic                     := 'X';             -- reset_n
			sdclk_clk_clk                     : out   std_logic;                                        -- clk
			codec_clk_clk                     : out   std_logic;                                        -- clk
			codec_reset_export                : out   std_logic;                                        -- export
--       user_led_export                   : out   std_logic_vector(3 downto 0);                     -- export
         grove1_in_port                    : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- in_port
         grove1_out_port                   : out   std_logic_vector(1 downto 0);                     -- out_port
--			pmod1_in_port                     : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- in_port
--       pmod1_out_port                    : out   std_logic_vector(1 downto 0);                     -- out_port
         pmod2_export                      : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- export
--       adc_pll_locked_export             : in    std_logic                     := 'X';             -- export
			adc_export                        : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- export
         altpll_locked_export              : out   std_logic;                                        -- export
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
			uart_rxd                          : in    std_logic                     := 'X';             -- rxd
         uart_txd                          : out   std_logic;                                        -- txd
			uart_cts_n                        : in    std_logic                     := 'X';             -- cts_n
			uart_rts_n                        : out   std_logic;                                        -- rts_n
--			i2c_sda_in                        : in    std_logic                     := 'X';             -- sda_in
--			i2c_scl_in                        : in    std_logic                     := 'X';             -- scl_in
--			i2c_sda_oe                        : out   std_logic;                                        -- sda_oe
--			i2c_scl_oe                        : out   std_logic;                                        -- scl_oe
			qspi_dclk                         : out   std_logic;                                        -- dclk
         qspi_ncs                          : out   std_logic;                                        -- ncs
         qspi_data                         : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- data
			onbrd_led_pwm_out                 : out   std_logic_vector(3 downto 0);                     -- pwm_out
			i2s_bclk_mst_clk                  : in    std_logic                     := 'X';             -- clk
			i2s_lrclk_i_mst                   : in    std_logic                     := 'X';             -- lrclk_i_mst
--			i2s_bitclk_i_mst                  : in    std_logic                     := 'X';             -- bitclk_i_mst
         i2s_data_i_mst                    : in    std_logic                     := 'X';             -- data_i_mst
         i2s_data_o_mst                    : out   std_logic;                                        -- data_o_mst
         i2s_lrclk_o_slv                   : out   std_logic;                                        -- lrclk_o_slv
         i2s_bitclk_o_slv                  : out   std_logic;                                        -- bitclk_o_slv
         i2s_data_o_slv                    : out   std_logic                                         -- data_o_slv
		);
	end component candy_gw_qsys;

	component i2c_master_top
		generic(
			ARST_LVL: std_logic := '0'
		);
		port(
			-- wishbone signals
         wb_clk_i      : in  std_logic;                    -- master clock input
         wb_rst_i      : in  std_logic := '0';             -- synchronous active high reset
         arst_i        : in  std_logic := not ARST_LVL;    -- asynchronous reset
         wb_adr_i      : in  std_logic_vector(2 downto 0); -- lower address bits
         wb_dat_i      : in  std_logic_vector(7 downto 0); -- Databus input
         wb_dat_o      : out std_logic_vector(7 downto 0); -- Databus output
         wb_we_i       : in  std_logic;                    -- Write enable input
         wb_stb_i      : in  std_logic;                    -- Strobe signals / core select signal
         wb_cyc_i      : in  std_logic;                    -- Valid bus cycle input
         wb_ack_o      : out std_logic;                    -- Bus cycle acknowledge output
         wb_inta_o     : out std_logic;                    -- interrupt request output signal

         -- i2c lines
         scl_pad_i     : in  std_logic;                    -- i2c clock line input
         scl_pad_o     : out std_logic;                    -- i2c clock line output
         scl_padoen_o  : out std_logic;                    -- i2c clock line output enable, active low
         sda_pad_i     : in  std_logic;                    -- i2c data line input
         sda_pad_o     : out std_logic;                    -- i2c data line output
         sda_padoen_o  : out std_logic                     -- i2c data line output enable, active low
		);
	end component i2c_master_top;
	
--	component i2s_to_codec
--		generic(
--			DATA_WIDTH: integer range 0 to 32 := 32
--		);
--		port(
--			CLK:      in std_logic;
--			RESET:    in std_logic;
--			LRCLK_I_MST:  in  std_logic;
--			BITCLK_I_MST: in  std_logic;
--			DATA_I_MST:   in  std_logic;
--			DATA_O_MST:   out std_logic;
--			LRCLK_O_SLV:  out std_logic;
--			BITCLK_O_SLV: out std_logic;
--			DATA_O_SLV:   out std_logic
--		);
--	end component i2s_to_codec;
	
	constant p_wb_offset_low: std_logic_vector(11 downto 0) := X"000";
	constant p_wb_offset_hi:  std_logic_vector(11 downto 0) := X"3FF";--X"3FFFFFFF";
	constant p_wb_i2c_low:    std_logic_vector(11 downto 0) := p_wb_offset_low + X"040";
	constant p_wb_i2c_hi:     std_logic_vector(11 downto 0) := p_wb_offset_low + X"07F";
		
	signal altpll_locked_export: std_logic;
	signal adc_pll_locked_export: std_logic;
	
	signal rstn: std_logic;
	
	-- wishbone
	signal wb_clk:     std_logic;
	signal wb_rst:     std_logic;
	signal wb_cyc:     std_logic;
	signal wb_stb:     std_logic;
	signal wb_adr:     std_logic_vector(31 downto 0);
	signal wb_sel:     std_logic_vector(3 downto 0);
	signal wb_we:      std_logic;
	signal wb_dati:    std_logic_vector(31 downto 0);
	signal wb_dato:    std_logic_vector(31 downto 0);
	signal wb_ack:     std_logic;
	signal wb_ack_dff: std_logic;
	signal wb_err:     std_logic;
	signal wb_rty:     std_logic;
	
	-- i2c
	signal cyc_i_i2c: std_logic;
	signal stb_i_i2c: std_logic;
	signal we_i_i2c:  std_logic;
	signal adr_i_i2c: std_logic_vector(2 downto 0);
	signal dat_o_i2c: std_logic_vector(7 downto 0);
	signal ack_o_i2c: std_logic;
	signal sel_i_i2c: std_logic;
	signal inta_i2c:  std_logic;
	
	signal scl_i:   std_logic;
	signal scl_o:   std_logic;
	signal scl_oen: std_logic;
	signal sda_i:   std_logic;
	signal sda_o:   std_logic;
	signal sda_oen: std_logic;
		
	begin
		adc_pll_locked_export <= altpll_locked_export;
		rstn <= (RST and altpll_locked_export);
		
		u0 : component candy_gw_qsys port map (
			clk_clk                            => CLK,                          --                         clk.clk
			reset_reset_n                      => rstn,                         --                       reset.reset_n
			codec_clk_clk                      => CODEC_CLKOUT,                 --                   codec_clk.clk
			codec_reset_export                 => CODEC_RESET,                  --                 codec_reset.export
--			user_led_export                    => LED,                          --                    user_led.export
			grove1_in_port                     => GROVE1,                       --                      grove1.in_port
			grove1_out_port                    => GROVE1,                       --                            .out_port
--			pmod1_in_port                      => PMOD1,                        --                       pmod1.in_port
--		 	pmod1_out_port                     => PMOD1,                        --                            .out_port
			pmod2_export                       => PMOD2,                        --                       pmod2.export
--			adc_pll_locked_export              => adc_pll_locked_export,        --              adc_pll_locked.export
			adc_export                         => ADC_IN,                       --                         adc.export
			altpll_locked_export               => altpll_locked_export,         --               altpll_locked.export
			sdclk_clk_clk                      => DRAM_CLK,                     --                   sdclk_clk.clk
			new_sdram_controller_0_wire_addr   => DRAM_ADDR,                    -- new_sdram_controller_0_wire.addr
			new_sdram_controller_0_wire_ba     => DRAM_BA,                      --                            .ba
			new_sdram_controller_0_wire_cas_n  => DRAM_CAS,                     --                            .cas_n
			new_sdram_controller_0_wire_cke    => DRAM_CKE,                     --                            .cke
			new_sdram_controller_0_wire_cs_n   => DRAM_CS,                      --                            .cs_n
			new_sdram_controller_0_wire_dq     => DRAM_DQ,                      --                            .dq
			new_sdram_controller_0_wire_dqm(1) => DRAM_UDQM,                    --                            .dqm
			new_sdram_controller_0_wire_dqm(0) => DRAM_LDQM,                    --                            .dqm
			new_sdram_controller_0_wire_ras_n  => DRAM_RAS,                     --                            .ras_n
			new_sdram_controller_0_wire_we_n   => DRAM_WE,                      --                            .we_n
			oe_export                          => OE,                           --                          oe.export
			wb_ack_i                           => wb_ack,                       --                          wb.ack_i
			wb_adr_o                           => wb_adr,                       --                            .adr_o
			wb_clk_o                           => wb_clk,                       --                            .clk_o
			wb_cyc_o                           => wb_cyc,                       --                            .cyc_o
			wb_dat_i                           => wb_dato,                      --                            .dat_i
			wb_dat_o                           => wb_dati,                      --                            .dat_o
			wb_err_i                           => wb_err,                       --                            .err_i
			wb_rst_o                           => wb_rst,                       --                            .rst_o
			wb_rty_i                           => wb_rty,                       --                            .rty_i
			wb_sel_o                           => wb_sel,                       --                            .sel_o
			wb_stb_o                           => wb_stb,                       --                            .stb_o
			wb_we_o                            => wb_we,                        --                            .we_o
			uart_rxd                           => UART_TX,                      --                        uart.rxd
         uart_txd                           => UART_RX,                      --                            .txd
			uart_cts_n                         => UART_RTS,                     --                            .cts_n
			uart_rts_n                         => UART_CTS,                     --                            .rts_n
--			i2c_sda_in                         => CODEC_SDA,                    --                         i2c.sda_in
--			i2c_scl_in                         => CODEC_SCL,                    --                            .scl_in
--			i2c_sda_oe                         => sda_oen,                      --                            .sda_oe
--			i2c_scl_oe                         => scl_oen,                      --                            .scl_oe
			qspi_dclk                          => QSPI_CLK,                     --                        qspi.dclk
         qspi_ncs                           => QSPI_CS,                      --                            .ncs
         qspi_data                          => QSPI_IO,                      --                            .data
			onbrd_led_pwm_out                  => LED,                          --                         pwm.pwm_out
			i2s_bclk_mst_clk                   => CODEC_BITCLOCK,               --                i2s_bclk_mst.clk
			i2s_lrclk_i_mst                    => CODEC_LRCLOCK,                --                         i2s.lrclk_i_mst
--			i2s_bitclk_i_mst                   => CODEC_BITCLOCK,               --                            .bitclk_i_mst
         i2s_data_i_mst                     => CODEC_DATA_OUT,               --                            .data_i_mst
         i2s_data_o_mst                     => CODEC_DATA_IN,                --                            .data_o_mst
         i2s_lrclk_o_slv                    => DAC_LRCLOCK,                  --                            .lrclk_o_slv
         i2s_bitclk_o_slv                   => DAC_BITCLOCK,                 --                            .bitclk_o_slv
         i2s_data_o_slv                     => DAC_SDO                       --                            .data_o_slv
      );
		
		u1 : i2c_master_top generic map (ARST_LVL => '0') port map (
			wb_clk_i  => wb_clk,
         wb_rst_i  => wb_rst,
         arst_i    => rstn,
			wb_adr_i  => adr_i_i2c,
			wb_dat_i  => wb_dati(7 downto 0),
			wb_dat_o  => dat_o_i2c,
         wb_we_i   => we_i_i2c,
			wb_stb_i  => stb_i_i2c,
         wb_cyc_i  => cyc_i_i2c,
         wb_ack_o  => ack_o_i2c,
         wb_inta_o => inta_i2c,

         -- i2c lines
         scl_pad_i    => scl_i,
         scl_pad_o    => scl_o,
         scl_padoen_o => scl_oen,
         sda_pad_i    => sda_i,
         sda_pad_o    => sda_o,
         sda_padoen_o => sda_oen
		);
		
--		u2 : i2s_to_codec generic map (DATA_WIDTH => 32) port map (
--				CLK          => CLK,
--				RESET        => RST,
--				LRCLK_I_MST  => CODEC_LRCLOCK,
--				BITCLK_I_MST => CODEC_BITCLOCK,
--				DATA_I_MST   => CODEC_DATA_OUT,
--				DATA_O_MST   => CODEC_DATA_IN,
--				LRCLK_O_SLV  => DAC_LRCLOCK,
--				BITCLK_O_SLV => DAC_BITCLOCK,
--				DATA_O_SLV   => DAC_SDO				
--		);
		
		-- I2C
		sel_i_i2c <= '1' when ((wb_adr >= p_wb_i2c_low) and (wb_adr <= p_wb_i2c_hi)) else '0';
		cyc_i_i2c <= wb_cyc when (sel_i_i2c = '1') else '0';
		stb_i_i2c <= wb_stb when (sel_i_i2c = '1') else '0';
		adr_i_i2c <= wb_adr(4 downto 2);
		we_i_i2c  <= wb_we when (sel_i_i2c = '1') else '0';
		
		wb_dato <= (dat_o_i2c & dat_o_i2c & dat_o_i2c & dat_o_i2c) when (sel_i_i2c = '1') else
					  X"00000000";
		
		wb_ack <= '1' when (wb_ack_dff = '1') else
					 ack_o_i2c when (sel_i_i2c = '1') else
					 wb_stb;
		
		process(wb_clk, rstn)
		begin
			if rstn = '0' then
				wb_ack_dff <= '0';
			elsif (wb_clk'event and wb_clk = '1') then
				if ((sel_i_i2c = '1') and (ack_o_i2c = '1')) then
					wb_ack_dff <= '1';
				else
					if (wb_stb = '0') then
						wb_ack_dff <= '0';
					else
						wb_ack_dff <= wb_ack_dff;
					end if;
				end if;
			end if;
		end process;
					 
		wb_err <= '0';
		wb_rty <= '0';

		-- I2C
		CODEC_SCL <= scl_o when (scl_oen = '0') else 'Z';
		CODEC_SDA <= sda_o when (sda_oen = '0') else 'Z';
		scl_i <= CODEC_SCL;
		sda_i <= CODEC_SDA;

end RTL;