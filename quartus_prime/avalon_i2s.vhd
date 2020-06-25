library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity AVALON_I2S is
	generic(
		DATA_WIDTH: integer range 1 to 512 := 32
	);
	port(
		-- clock
		bit_clk_mst: in std_logic;

		-- reset
		csi_reset_n: in std_logic;

		-- Avalon-MM Slave
		avs_s1_address:       in  std_logic_vector(1 downto 0);-- := (others => '0');
--		avs_s1_chipselect:    in  std_logic;
--		avs_s1_byteenable:    in  std_logic_vector(3 downto 0);
--		avs_s1_read:          in  std_logic;-- := '0';
		avs_s1_write:         in  std_logic;-- := '0';
		avs_s1_writedata:     in  std_logic_vector(31 downto 0);-- := (others => '0');
--		avs_s1_waitrequest:   out std_logic;
--		avs_s1_readdata:      out std_logic_vector(31 downto 0);
--		avs_s1_readdatavalid: out std_logic;
		
		-- Avalon-ST Source
--		av_st1_ready:          in  std_logic;
--		av_st1_valid:          out std_logic;
--		av_st1_data:           out std_logic_vector(DATA_WIDTH - 1 downto 0);
--		av_st1_channel:        out std_logic;
--		av_st1_error:          out std_logic;
		
		-- Avalon-MM Write Master
		av_mm1_address:     out std_logic_vector(2 downto 0);
		av_mm1_write:       out std_logic;
		av_mm1_writedata:   out std_logic_vector(31 downto 0);
		av_mm1_waitrequest: in std_logic;
		
		-- Avalon-ST Sink
--		av_st2_ready:          out std_logic;
--		av_st2_valid:          in  std_logic;
--		av_st2_data:           in  std_logic_vector(DATA_WIDTH - 1 downto 0);

		-- Avalon-MM Read Master
		av_mm2_address:     out std_logic_vector(2 downto 0);
		av_mm2_read:        out std_logic;
		av_mm2_readdata:    in  std_logic_vector(31 downto 0);
		av_mm2_waitrequest: in  std_logic;

		LRCLK_I_MST:  in  std_logic;
		DATA_I_MST:   in  std_logic;
		DATA_O_MST:   out std_logic;
		LRCLK_O_SLV:  out std_logic;
		BITCLK_O_SLV: out std_logic;
		DATA_O_SLV:   out std_logic		
	);
end AVALON_I2S;

architecture structural of AVALON_I2S is
	signal counter: integer range 0 to DATA_WIDTH := DATA_WIDTH - 1;
	signal counter_s: integer range 0 to DATA_WIDTH := DATA_WIDTH - 1;
	signal shift_reg_mst: std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
	signal data_l_mst: std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
	signal data_r_mst: std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
	signal data_l_slv: std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
	signal data_r_slv: std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
	
	signal lrclk_ff: std_logic_vector(1 downto 0) := (others => '0');
	signal lrclk_last: std_logic := '0';
	
	signal out_flag: std_logic := '0';
	signal odata: std_logic_vector(31 downto 0) := X"00000000";
	
	begin
		process(bit_clk_mst)
		begin
			if (falling_edge(bit_clk_mst)) then
				lrclk_ff <= lrclk_ff(0) & LRCLK_I_MST;
			end if;
		end process;

		BITCLK_O_SLV <= bit_clk_mst;
		LRCLK_O_SLV <= LRCLK_I_MST;

		cnt: process(bit_clk_mst, LRCLK_I_MST, csi_reset_n)
		begin
			if (csi_reset_n = '0') then
				counter <= DATA_WIDTH - 1;
			elsif (falling_edge(bit_clk_mst)) then
				if (lrclk_last /= lrclk_ff(1)) then
					counter <= DATA_WIDTH - 1;
					lrclk_last <= lrclk_ff(1);
				elsif (counter >= 0) then
					counter <= counter - 1;
					lrclk_last <= lrclk_ff(1);
				end if;
					
				if (counter = 4) then
					counter_s <= DATA_WIDTH - 1;
				else
					counter_s <= counter_s - 1;
				end if;
			end if;
		end process;
		
		rd_mst: process(bit_clk_mst, csi_reset_n)
			variable srm0: std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');

			variable vm0: signed(47 downto 0) := (others => '0');
			variable vm1: signed(23 downto 0) := (others => '0');
		begin
			if (csi_reset_n = '0') then
				data_l_mst <= (others => '0');
				data_r_mst <= (others => '0');
				
				shift_reg_mst <= (others => '0');
			elsif (falling_edge(bit_clk_mst)) then
				if (counter = 3) then
--					vm0 := signed(srm(30 downto 7)) * adc_0(23 downto 0);
--					vm0 := signed(srm(30 downto 7)) * X"00FFFF";
					vm0 := signed(odata(30 downto 7)) * X"00FFFF";
						
					vm1 := resize(shift_right(vm0, 12), 24);
					srm0 := '0' & std_logic_vector(vm1) & "0000000";
						
					if (lrclk_last = '0') then
						data_l_mst <= srm0;
					else
						data_r_mst <= srm0;
					end if;
				end if;
					
				shift_reg_mst <= shift_reg_mst(DATA_WIDTH - 2 downto 0) & DATA_I_MST;
			end if;
		end process;

		snd_to_av: process(bit_clk_mst, csi_reset_n)
		begin
			if (csi_reset_n = '0') then
--				av_st1_valid <= '0';
--				av_st1_channel <= '0';
--				av_st1_data <= X"00000000";
--				av_st1_error <= '0';
				av_mm1_address <= "000";
				av_mm1_write <= '0';
				av_mm1_writedata <= X"00000000";
			elsif (falling_edge(bit_clk_mst)) then
				if (counter = 2) then
					if (out_flag = '1') then
--						if av_st1_ready = '1' then
--							av_st1_valid <= '1';							
--							av_st1_channel <= '0';
--							av_st1_data <= shift_reg_mst(DATA_WIDTH - 2 downto 0) & '0';
--							av_st1_error <= '0';
--						end if;
						av_mm1_address <= "000";
						av_mm1_write <= '1';
						av_mm1_writedata <= shift_reg_mst(DATA_WIDTH - 1 downto 0);
					else
						av_mm1_write <= '0';
					end if;
				else
					-- test
					if (out_flag = '1') then
--						av_st1_valid <= '0';
						av_mm1_write <= '0';
					end if;
				end if;
			end if;
		end process;

		process(bit_clk_mst, csi_reset_n)
			begin
				if (csi_reset_n = '0') then					
					odata <= X"00000000";
				elsif (falling_edge(bit_clk_mst)) then
					if (out_flag = '1') then
						if (counter = 4) then
							av_mm2_address <= "000";
							av_mm2_read <= '1';
							odata <= av_mm2_readdata;
						else
							av_mm2_read <= '0';
						end if;
					end if;
				end if;
		end process;
		
		wr_mst: process(bit_clk_mst)
		begin
			if (falling_edge(bit_clk_mst)) then
				if (LRCLK_I_MST = '1') then
					DATA_O_MST <= data_l_mst(counter_s);
				else
					DATA_O_MST <= data_r_mst(counter_s);
				end if;
			end if;
		end process;

		wr_slv: process(bit_clk_mst)
		begin
			if (falling_edge(bit_clk_mst)) then
				if (LRCLK_I_MST = '1') then
					DATA_O_SLV <= data_l_mst(counter_s);
				else
					DATA_O_SLV <= data_r_mst(counter_s);
				end if;
			end if;
		end process;
	
		process(bit_clk_mst, csi_reset_n)
			begin
				if (csi_reset_n = '0') then
					out_flag <= '0';
				elsif (falling_edge(bit_clk_mst)) then
					if (avs_s1_write = '1' and avs_s1_address(1 downto 0) = "00") then
						out_flag <= avs_s1_writedata(0);
					end if;
				end if;
		end process;
end architecture structural;