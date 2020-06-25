library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity AVALON2PWM is
	generic(
		WIDTH :           integer range 1 to 8     := 3;
		PWM_COUNTER_MAX : integer range 0 to 65535 := 60000
	);
	port(
		-- clock & reset
		csi_clk:     in std_logic;
		csi_reset_n: in std_logic;
		
		-- Avalon-MM
		avs_s1_address:       in  std_logic_vector(2 downto 0);-- := (others => '0');
--		avs_s1_chipselect:    in  std_logic;
----		avs_s1_byteenable:    in  std_logic_vector(3 downto 0);
		avs_s1_read:          in  std_logic;-- := '0';
		avs_s1_write:         in  std_logic;-- := '0';
		avs_s1_writedata:     in  std_logic_vector(31 downto 0);-- := (others => '0');
----		avs_s1_waitrequest:   out std_logic;
		avs_s1_readdata:      out std_logic_vector(31 downto 0);
--		avs_s1_readdatavalid: out std_logic;

		PWM_OUT: out std_logic_vector(WIDTH downto 0)
	);
end AVALON2PWM;

architecture structural of AVALON2PWM is
	signal pwm_counter0:  std_logic_vector(15 downto 0);
	signal pwm_counter1:  std_logic_vector(15 downto 0);
	signal pwm_counter2:  std_logic_vector(15 downto 0);
	signal pwm_counter3:  std_logic_vector(15 downto 0);
	signal pwm_duty0:     std_logic_vector(31 downto 0);
	signal pwm_duty1:     std_logic_vector(31 downto 0);
	signal pwm_duty2:     std_logic_vector(31 downto 0);
	signal pwm_duty3:     std_logic_vector(31 downto 0);
	signal pwm_step_max0: std_logic_vector(15 downto 0);
	signal pwm_step_max1: std_logic_vector(15 downto 0);
	signal pwm_step_max2: std_logic_vector(15 downto 0);
	signal pwm_step_max3: std_logic_vector(15 downto 0);
	signal pwm_step0:     std_logic_vector(15 downto 0);
	signal pwm_step1:     std_logic_vector(15 downto 0);
	signal pwm_step2:     std_logic_vector(15 downto 0);
	signal pwm_step3:     std_logic_vector(15 downto 0);
	
	begin
		process(csi_clk, csi_reset_n)
			begin
				if (csi_reset_n = '0') then
					pwm_counter0 <= X"0000";
					pwm_step_max0 <= X"0000";
					pwm_step0 <= X"0000";
				elsif (csi_clk'event and csi_clk = '1') then
					if avs_s1_write = '1' and avs_s1_address(2 downto 0) = "100" then
						pwm_step_max0 <= avs_s1_writedata(15 downto 0);
					end if;
						
					if pwm_step0 = pwm_step_max0 then
						if pwm_counter0 = PWM_COUNTER_MAX then
							pwm_counter0 <= X"0000";
						else
							pwm_counter0 <= pwm_counter0 + 1;
						end if;
					
						pwm_step0 <= X"0000";
					else
						pwm_step0 <= pwm_step0 + 1;
					end if;
				end if;
		end process;
		
		process(csi_clk, csi_reset_n)
			begin
				if (csi_reset_n = '0') then
					pwm_counter1 <= X"0000";
					pwm_step_max1 <= X"0000";
					pwm_step1 <= X"0000";
				elsif (csi_clk'event and csi_clk = '1') then
					if avs_s1_write = '1' and avs_s1_address(2 downto 0) = "101" then
						pwm_step_max1 <= avs_s1_writedata(15 downto 0);
					end if;
					
					if pwm_step1 = pwm_step_max1 then
						if pwm_counter1 = PWM_COUNTER_MAX then
							pwm_counter1 <= X"0000";
						else
							pwm_counter1 <= pwm_counter1 + 1;
						end if;
						
						pwm_step1 <= X"0000";
					else
						pwm_step1 <= pwm_step1 + 1;
					end if;
				end if;
		end process;
	
		process(csi_clk, csi_reset_n)
			begin
				if (csi_reset_n = '0') then
					pwm_counter2 <= X"0000";
					pwm_step_max2 <= X"0000";
					pwm_step2 <= X"0000";
				elsif (csi_clk'event and csi_clk = '1') then
					if avs_s1_write = '1' and avs_s1_address(2 downto 0) = "110" then
						pwm_step_max2 <= avs_s1_writedata(15 downto 0);
					end if;
					
					if pwm_step2 = pwm_step_max2 then
						if pwm_counter2 = PWM_COUNTER_MAX then
							pwm_counter2 <= X"0000";
						else
							pwm_counter2 <= pwm_counter2 + 1;
						end if;
					
						pwm_step2 <= X"0000";
					else
						pwm_step2 <= pwm_step2 + 1;
					end if;
				end if;
		end process;
	
		process(csi_clk, csi_reset_n)
			begin
				if (csi_reset_n = '0') then
					pwm_counter3 <= X"0000";
					pwm_step_max3 <= X"0000";
					pwm_step3 <= X"0000";
				elsif (csi_clk'event and csi_clk = '1') then
					if avs_s1_write = '1' and avs_s1_address(2 downto 0) = "111" then
						pwm_step_max3 <= avs_s1_writedata(15 downto 0);
					end if;
					
					if pwm_step3 = pwm_step_max3 then
						if pwm_counter3 = PWM_COUNTER_MAX then
							pwm_counter3 <= X"0000";
						else
							pwm_counter3 <= pwm_counter3 + 1;
						end if;
					
						pwm_step3 <= X"0000";
					else
						pwm_step3 <= pwm_step3 + 1;
					end if;
				end if;
		end process;
	
		process(csi_clk, csi_reset_n)
			begin
				if (csi_reset_n = '0') then
					pwm_duty0 <= X"00000000";
					pwm_duty1 <= X"00000000";
					pwm_duty2 <= X"00000000";
					pwm_duty3 <= X"00000000";
				elsif (csi_clk'event and csi_clk = '1') then
					if avs_s1_write = '1' then
						case avs_s1_address(1 downto 0) is
							when "00" => pwm_duty0 <= avs_s1_writedata;
							when "01" => pwm_duty1 <= avs_s1_writedata;
							when "10" => pwm_duty2 <= avs_s1_writedata;
							when "11" => pwm_duty3 <= avs_s1_writedata;
						end case;
					end if;
				end if;
		end process;
	
		process(csi_clk, csi_reset_n)
			begin
				if (csi_reset_n = '0') then
					avs_s1_readdata <= X"00000000";
				elsif (csi_clk'event and csi_clk = '1') then
					if avs_s1_read = '1' then
						case avs_s1_address(2 downto 0) is
							when "000" => avs_s1_readdata <= pwm_duty0;
							when "001" => avs_s1_readdata <= pwm_duty1;
							when "010" => avs_s1_readdata <= pwm_duty2;
							when "011" => avs_s1_readdata <= pwm_duty3;
							when "100" => avs_s1_readdata <= X"0000" & pwm_step_max0;
							when "101" => avs_s1_readdata <= X"0000" & pwm_step_max1;
							when "110" => avs_s1_readdata <= X"0000" & pwm_step_max2;
							when "111" => avs_s1_readdata <= X"0000" & pwm_step_max3;
						end case;
					end if;
				end if;
		end process;
		
		PWM_OUT(0) <= '1' when pwm_counter0 > pwm_duty0(15 downto 0) else '0';
		PWM_OUT(1) <= '1' when pwm_counter1 > pwm_duty1(15 downto 0) else '0';
		PWM_OUT(2) <= '1' when pwm_counter2 > pwm_duty2(15 downto 0) else '0';
		PWM_OUT(3) <= '1' when pwm_counter3 > pwm_duty3(15 downto 0) else '0';
end architecture structural;