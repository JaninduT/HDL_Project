----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/25/2020 12:06:20 PM
-- Design Name: 
-- Module Name: convolve_with_padded_ram_test - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use IEEE.std_logic_textio.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity convolve_with_padded_ram_test is
--  Port ( );
end convolve_with_padded_ram_test;

architecture Behavioral of convolve_with_padded_ram_test is

component Convolution is
    Generic (addr_bit_size : INTEGER := 9;   -- image has less than 1024 pixels.
             data_bit_size : INTEGER := 7;   -- value range of a pixel (0-255) 
             total_bit_size : INTEGER :=11); -- addition of 9 pixel values (0-2295)
             
    Port ( data_a_in : in STD_LOGIC_VECTOR(data_bit_size DOWNTO 0);       -- data in bus from the padded image ram.
           data_a_out : out STD_LOGIC_VECTOR(data_bit_size DOWNTO 0);     -- data out bus to final output image ram.
           clk  : in STD_LOGIC;                                           -- clock
           read_addr_out : out STD_LOGIC_VECTOR(addr_bit_size DOWNTO 0);  -- address bus to the padded image ram (to read a pixel value).  
           write_addr_out : out STD_LOGIC_VECTOR(addr_bit_size DOWNTO 0); -- address bus to the final output image ram (to write a pixel value). 
           write_en_a_out : out STD_LOGIC_VECTOR(0 DOWNTO 0);             -- enable pin to the output ram (will be 1 when data_a_out is ready). 
           write_en_p_out : out STD_LOGIC_VECTOR(0 DOWNTO 0);             -- enable pin to the padded image ram.
           paddone_in : in STD_LOGIC;                                     -- signal notifying the padding is done.
           convdone_out : out STD_LOGIC;                             -- signal notifying the concolution is done.
           rst_n :in STD_LOGIC := '1');                                 -- reset signal
end component;

component padded_image_ram is
  port (clka : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        clkb : IN STD_LOGIC;
        web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        dinb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
end component;

signal dina : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal clock: STD_LOGIC :='0';
signal paddone: STD_LOGIC;
signal douta: STD_LOGIC_VECTOR(7 DOWNTO 0);
signal wea: STD_LOGIC_VECTOR ( 0 downto 0) := "0";
signal wea_to_padded: STD_LOGIC_VECTOR ( 0 downto 0);
signal raddr : STD_LOGIC_VECTOR(9 DOWNTO 0);
signal waddr : STD_LOGIC_VECTOR(9 DOWNTO 0);
signal convdone : STD_LOGIC;
signal doutb_dontcare : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal rst_n : STD_LOGIC;

begin

uut1 : Convolution
    port map(data_a_in=>dina,
             clk=>clock,
             paddone_in=>paddone,
             data_a_out=>douta,
             write_en_a_out=>wea,
             read_addr_out=>raddr,
             write_addr_out=>waddr,
             rst_n=>rst_n,
             write_en_p_out => wea_to_padded,
             convdone_out=>convdone);

uut_3 : padded_image_ram
  port map (clka => clock,
            wea => wea_to_padded,
            addra => raddr,
            dina => "00000000",
            douta => dina,
            clkb => clock,
            web => "0",
            addrb => raddr,
            dinb => "00000000",
            doutb => doutb_dontcare);

clock <= not clock after 5ns;

stimuli : process
    begin
        rst_n <= '1';
        paddone <= '0';
        wea_to_padded <= "0";
        wait for 5ns;
        paddone <= '1';
        wait for 56350ns;  -- time taken to finish the convolution
        
        assert (convdone = '1')
            report "Timeout Error (convdone 0)"
            severity WARNING;
        wait;
    end process;

dump_to_text : process (clock)
    variable out_value : line;
    file convolved_ram : text is out "convolved_ram.txt";
    begin
        if ( clock 'event and clock = '1' ) then
            if ( wea = "1" ) then
                write(out_value, to_integer(unsigned(waddr)), left, 3);
                write(out_value, string'(","));
                write(out_value, to_integer(unsigned(douta)), left, 3);
                writeline(convolved_ram, out_value);
            end if;
            if ( convdone = '1' ) then
                file_close(convolved_ram);
            end if;
        end if;
    end process;
end Behavioral;