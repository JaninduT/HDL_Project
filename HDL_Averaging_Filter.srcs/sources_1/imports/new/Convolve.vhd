----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/11/2020 07:36:10 AM
-- Design Name: 
-- Module Name: Convolve - Behavioral
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Convolution is
    Generic (addr_bit_size : INTEGER := 9;   -- image has less than 1024 pixels.
             data_bit_size : INTEGER := 7;   -- value range of a pixel (0-255) 
             total_bit_size : INTEGER :=11); -- addition of 9 pixel values (0-2295)
             
    Port ( clk  : in STD_LOGIC; -- clock
           rst_n :in STD_LOGIC; -- reset signal
           -- data in bus from the padded image ram.
           data_a_in : in STD_LOGIC_VECTOR(data_bit_size DOWNTO 0);
           -- data out bus to final output image ram.
           data_a_out : out STD_LOGIC_VECTOR(data_bit_size DOWNTO 0) := std_logic_vector(to_unsigned(0, data_bit_size+1));
           -- address bus to the padded image ram (to read a pixel value).
           read_addr_out : out STD_LOGIC_VECTOR(addr_bit_size DOWNTO 0) := std_logic_vector(to_unsigned(0, addr_bit_size+1)); 
           -- address bus to the final output image ram (to write a pixel value). 
           write_addr_out : out STD_LOGIC_VECTOR(addr_bit_size DOWNTO 0) := std_logic_vector(to_unsigned(0, addr_bit_size+1));
           -- enable pin to the output ram (will be 1 when data_a_out is ready). 
           write_en_a_out : out STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
           -- enable pin to the padded image ram. 
           write_en_p_out : out STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
           -- signal notifying the padding is done.
           paddone_in : in STD_LOGIC;
           -- signal notifying the concolution is done.
           convdone_out : out STD_LOGIC := '0');  
end Convolution;

architecture Behavioral of Convolution is

begin

 convolve : process ( clk, rst_n, data_a_in, paddone_in )
     constant col_row_c      : INTEGER := 27;  --number of rows/columns
     variable cur_opixel_v   : INTEGER := 0;   --pixel address where the convolved value is going to be placed.
     variable cur_ipixel_v   : INTEGER := col_row_c+1; -- corresponding pixel address in the padded image ram.
     variable cur_col_v      : INTEGER := 1;     --column number
     variable ctrl_tick_v    : INTEGER := 0; -- variable to control teh first and last values
     variable total_v        : unsigned (total_bit_size downto 0) := "000000000000"; 
     variable cur_pix_kern_v :INTEGER :=0; --current iteration of a single kernal*window (0-9)
    begin
        if (rst_n = '0') then
            cur_opixel_v := 0;
            cur_ipixel_v := col_row_c+1;
            cur_col_v    := 1;
            ctrl_tick_v  := 0;
            total_v      := "000000000000";
            cur_pix_kern_v := 0;
            convdone_out <= '0';
            write_en_p_out <= "0";
        elsif ( clk 'event and clk = '1' ) then
            if paddone_in = '1' then
                write_en_p_out <= "0";
                if (ctrl_tick_v=0 or ctrl_tick_v=1) then  -- behavior in the first 2 ticks.
                    read_addr_out<=std_logic_vector(to_unsigned(ctrl_tick_v,read_addr_out'length)); -- assign the reading address 
                    ctrl_tick_v:=ctrl_tick_v+1;
                    cur_pix_kern_v:=cur_pix_kern_v+1;
                elsif ctrl_tick_v=2 then  -- behavior of the ticks from 2 to last pixel of the image. 
                    total_v:= total_v+resize(unsigned(data_a_in),total_v'length);   -- add the data_a_in value to total
                    case cur_pix_kern_v IS  -- for earch iteration of calculating the total, corresponding read_addr_out will be set using  cur_ipixel_v, col_row_c &
                        when 0 =>                    
                            read_addr_out<=std_logic_vector(to_unsigned(cur_ipixel_v-(col_row_c+1),read_addr_out'length));
                        when 1 =>
                            read_addr_out<=std_logic_vector(to_unsigned(cur_ipixel_v-col_row_c,read_addr_out'length));
                        when 2 =>
                            if cur_ipixel_v > col_row_c + 1 then 
                                write_addr_out<=std_logic_vector(to_unsigned(cur_opixel_v,write_addr_out'length)); -- assign the write address of the current pixel of final image ram
                                data_a_out<=std_logic_vector(resize(total_v/9,data_a_out'length)); -- assign the averaged value to data_a_out
                                write_en_a_out<= "1"; -- enable the write_en_a_out.
                                cur_opixel_v:=cur_opixel_v+1; -- increase cur_opixel_v by 1.
                            end if;
                            total_v:= "000000000000";   -- make the total 0 after the output 
                            read_addr_out<=std_logic_vector(to_unsigned(cur_ipixel_v-(col_row_c-1),read_addr_out'length));
                        when 3 =>                    
                            read_addr_out<=std_logic_vector(to_unsigned(cur_ipixel_v-1,read_addr_out'length));
                            write_en_a_out<= "0";
                        when 4 =>                    
                            read_addr_out<=std_logic_vector(to_unsigned(cur_ipixel_v,read_addr_out'length));
                        when 5 =>                    
                            read_addr_out<=std_logic_vector(to_unsigned(cur_ipixel_v+1,read_addr_out'length));
                        when 6 =>                    
                            read_addr_out<=std_logic_vector(to_unsigned(cur_ipixel_v+(col_row_c-1),read_addr_out'length));
                        when 7 =>                    
                            read_addr_out<=std_logic_vector(to_unsigned(cur_ipixel_v+col_row_c,read_addr_out'length));
                        when 8 =>                    
                            read_addr_out<=std_logic_vector(to_unsigned(cur_ipixel_v+(col_row_c+1),read_addr_out'length));
                        when others =>
                    end case;                                                                                                                                                                                                                                  
                    if cur_pix_kern_v =8 then -- operation when a single window is done.
                        cur_pix_kern_v:=0;  -- assign cur_pix_kern_v 0
                        if cur_col_v=col_row_c-2 then -- check whether the current column is the second last one.
                            if cur_ipixel_v=(col_row_c*col_row_c-(col_row_c+2)) then  -- check whether the pixel is the last pixel.
                                ctrl_tick_v:=3;  -- assign ctrl_tick_v 3. 
                            else
                                cur_ipixel_v:=cur_ipixel_v+3;   -- move to the next pixel
                                cur_col_v:=1; -- make cur_col_v 1.
                            end if;
                        else
                            cur_ipixel_v:=cur_ipixel_v+1; -- inccrease cur_ipixel_v by 1. 
                            cur_col_v:=cur_col_v+1;  -- increase cur_col_v by 1.
                        end if;
                    else
                        cur_pix_kern_v:=cur_pix_kern_v+1; -- increase cur_pix_kern_v by 1
                    end if;
                elsif ctrl_tick_v=3 or ctrl_tick_v=4 or ctrl_tick_v=5 then
                    total_v:=total_v+resize(unsigned(data_a_in),total_v'length);
                    ctrl_tick_v:=ctrl_tick_v+1;
                elsif ctrl_tick_v=6 then
                    write_addr_out<=std_logic_vector(to_unsigned(cur_opixel_v,write_addr_out'length)); 
                    data_a_out<=std_logic_vector(resize(total_v/9,data_a_out'length));
                    write_en_a_out<="1";
                    ctrl_tick_v:=ctrl_tick_v+1;
                elsif ctrl_tick_v=7 then
                    write_en_a_out <= "0";
                    convdone_out<='1';
                    ctrl_tick_v:=8;
                end if;
            end if;         
        end if;
end process;

end Behavioral;
