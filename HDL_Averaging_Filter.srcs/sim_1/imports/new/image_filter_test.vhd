----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/07/2020 09:59:20 AM
-- Design Name: 
-- Module Name: image_filter_test - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: This test file is designed to run befor the integration of
-- UART communication unit. Hence this testbench will not work now.
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.textio.all;
use IEEE.std_logic_textio.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity image_filter_test is
--  Port ( );
end image_filter_test;

architecture Behavioral of image_filter_test is

component image_filter is
    Port ( clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           start_in : in STD_LOGIC;
           --wea_to_ioi : inout STD_LOGIC_VECTOR(0 DOWNTO 0);
           --dina_to_ioi : inout STD_LOGIC_VECTOR(7 DOWNTO 0);
           --addra_to_ioi : inout STD_LOGIC_VECTOR (9 DOWNTO 0);
           finished_out : out STD_LOGIC );
end component;

signal clk : STD_LOGIC := '0';
signal rst_n :STD_LOGIC;
signal start_in : STD_LOGIC;
signal finished_out : STD_LOGIC;
--signal wea_to_ioi : STD_LOGIC_VECTOR(0 DOWNTO 0);
--signal dina_to_ioi : STD_LOGIC_VECTOR(7 DOWNTO 0);
--signal addra_to_ioi : STD_LOGIC_VECTOR (9 DOWNTO 0);

begin

uut1 : image_filter
    port map(clk => clk,
            rst_n => rst_n,
            start_in => start_in,
            --wea_to_ioi => wea_to_ioi,
            --dina_to_ioi => dina_to_ioi,
            --addra_to_ioi => addra_to_ioi,
            finished_out => finished_out);

clk <= not clk after 5ns;

stimuli : process
    begin
        rst_n <= '1';
        start_in <= '0';
        wait for 5ns;
        start_in <= '1';
        wait for 10ns;
        start_in <= '0';
        wait;
    end process;

--dump_to_text : process (clk)
--    variable out_value : line;
--    file convolved_ram : text is out "convolved_ram.txt";
--    begin
--        if ( clk 'event and clk = '1' ) then
--            if ( wea_to_ioi = "1" ) then
--                write(out_value, to_integer(unsigned(addra_to_ioi)), left, 3);
--                write(out_value, string'(","));
--                write(out_value, to_integer(unsigned(dina_to_ioi)), left, 3);
--                writeline(convolved_ram, out_value);
--            end if;
--            if ( finished_out = '1' ) then
--                file_close(convolved_ram);
--            end if;
--        end if;
--    end process;

end Behavioral;
