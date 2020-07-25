----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/10/2020 09:02:54 PM
-- Design Name: 
-- Module Name: padding_unit_w_in_mem - Behavioral
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

entity padding_unit_w_in_mem is
--  Port ( );
end padding_unit_w_in_mem;

architecture Behavioral of padding_unit_w_in_mem is

component padding_unit is
    Generic (addr_length_g : Integer := 10;
             data_size_g : Integer := 8;
             base_val_g : Integer := 0;
             input_image_length_g : Integer := 25;
             output_image_length_g : Integer := 27);
             
    Port ( clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           start_in : in STD_LOGIC;
           finished_out : out STD_LOGIC := '0';
           ioi_wea_out : out STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
           ioi_addra_out : out STD_LOGIC_VECTOR(addr_length_g -1 DOWNTO 0) := std_logic_vector(to_unsigned(base_val_g, addr_length_g));
           ioi_douta_in : in STD_LOGIC_VECTOR(data_size_g -1 DOWNTO 0);
           padi_wea_out : out STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
           padi_addra_out : out STD_LOGIC_VECTOR(addr_length_g -1 DOWNTO 0) := std_logic_vector(to_unsigned(base_val_g, addr_length_g));
           padi_dina_out : out STD_LOGIC_VECTOR(data_size_g -1 DOWNTO 0) := std_logic_vector(to_unsigned(base_val_g, data_size_g));
           padi_web_out : out STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
           padi_addrb_out : out STD_LOGIC_VECTOR(addr_length_g -1 DOWNTO 0) := std_logic_vector(to_unsigned(base_val_g, addr_length_g));
           padi_dinb_out : out STD_LOGIC_VECTOR(data_size_g -1 DOWNTO 0) := std_logic_vector(to_unsigned(base_val_g, data_size_g)));
end component;

component input_output_ram is
    Port ( clka : IN STD_LOGIC;
           wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
           addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
           dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
           douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
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

signal clk : STD_LOGIC := '0';
signal rst_n : STD_LOGIC;
signal start : STD_LOGIC;
signal finished : STD_LOGIC;
signal ioi_wea : STD_LOGIC_VECTOR(0 DOWNTO 0);
signal ioi_addra : STD_LOGIC_VECTOR(9 DOWNTO 0);
signal ioi_dina_dont_care : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal ioi_douta : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal padi_wea : STD_LOGIC_VECTOR(0 DOWNTO 0);
signal padi_addra : STD_LOGIC_VECTOR(9 DOWNTO 0);
signal padi_dina : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal padi_douta : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal padi_web : STD_LOGIC_VECTOR(0 DOWNTO 0);
signal padi_addrb : STD_LOGIC_VECTOR(9 DOWNTO 0);
signal padi_dinb : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal padi_doutb : STD_LOGIC_VECTOR(7 DOWNTO 0);

begin

uut_1 : padding_unit
    port map (clk => clk,
              rst_n => rst_n,
              start_in =>  start,
              finished_out => finished,
              ioi_wea_out => ioi_wea,
              ioi_addra_out => ioi_addra,
              ioi_douta_in => ioi_douta,
              padi_wea_out => padi_wea,
              padi_addra_out => padi_addra,
              padi_dina_out => padi_dina,
              padi_web_out => padi_web,
              padi_addrb_out => padi_addrb,
              padi_dinb_out => padi_dinb
              );

uut_2 : input_output_ram
    port map (clka => clk,
              wea => ioi_wea,
              addra => ioi_addra,
              dina => ioi_dina_dont_care,
              douta => ioi_douta);

uut_3 : padded_image_ram
  port map (clka => clk,
            wea => padi_wea,
            addra => padi_addra,
            dina => padi_dina,
            douta => padi_douta,
            clkb => clk,
            web => padi_web,
            addrb => padi_addrb,
            dinb => padi_dinb,
            doutb => padi_doutb);

clk <= not clk after 5ns;

stimuli : process
    begin
        rst_n <= '1';
        start <= '0';
        wait for 5ns;
        rst_n <= '0';
        wait for 10ns;
        rst_n <= '1';
        wait for 10ns;
        start <= '1';
        wait for 10ns;
        start <= '0';
        wait;
    end process;

dump_to_text : process (clk)
    variable out_value : line;
    file padded_ram : text is out "padded_ram.txt";
    begin
        if ( clk 'event and clk = '1' ) then
            if ( padi_wea = "1" ) then
                write(out_value, to_integer(unsigned(padi_addra)), left, 3);
                write(out_value, string'(","));
                write(out_value, to_integer(unsigned(padi_dina)), left, 3);
                writeline(padded_ram, out_value);
            end if;
            if ( padi_web = "1" ) then
                write(out_value, to_integer(unsigned(padi_addrb)), left, 3);
                write(out_value, string'(","));
                write(out_value, to_integer(unsigned(padi_dinb)), left, 3);
                writeline(padded_ram, out_value);
            end if;
            if ( finished = '1' ) then
                file_close(padded_ram);
            end if;
        end if;
    end process;

end Behavioral;
