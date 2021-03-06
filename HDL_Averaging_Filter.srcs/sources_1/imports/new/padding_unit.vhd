----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/09/2020 07:55:16 PM
-- Design Name: 
-- Module Name: padding_unit - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: This module fills the padded ram using the input/output ram.
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- steps, content of the padded ram is shown.
--  -abcde-         aabcdee
--  -abcde-         aabcdee
--  aabcdee         aabcdee
--  aabcdee   ==>   aabcdee
--  aabcdee         aabcdee
--  -abcde-         aabcdee
--  -abcde-         aabcdee
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity padding_unit is
    Generic (addr_length_g         : Integer := 10; --size of the memory address(10bits)
             data_size_g           : Integer := 8; --size of the pixel data (8bits)
             base_val_g            : Integer := 0; --generic to store base initialization value.
             input_image_length_g  : Integer := 25; --length of the input image
             output_image_length_g : Integer := 27); --length of the output image(input_length+2)
             
    Port ( clk            : in STD_LOGIC;
           rst_n          : in STD_LOGIC;
           --gets start signal for the padding process
           start_in       : in STD_LOGIC;
           --outputs finish siganl of padding process
           finished_out   : out STD_LOGIC := '0';
           --write enable signal for input/output ram
           ioi_wea_out    : out STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
           --address for input/output ram 
           ioi_addra_out  : out STD_LOGIC_VECTOR(addr_length_g -1 DOWNTO 0) := std_logic_vector(to_unsigned(base_val_g, addr_length_g));
           --data out bus from input/output ram
           ioi_douta_in   : in STD_LOGIC_VECTOR(data_size_g -1 DOWNTO 0);
           --write enable signal for padding ram port a
           padi_wea_out   : out STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
           --address for padding ram port a
           padi_addra_out : out STD_LOGIC_VECTOR(addr_length_g -1 DOWNTO 0) := std_logic_vector(to_unsigned(base_val_g, addr_length_g));
           --data in bus for padding ram port a
           padi_dina_out  : out STD_LOGIC_VECTOR(data_size_g -1 DOWNTO 0) := std_logic_vector(to_unsigned(base_val_g, data_size_g));
           --write enable signal for padding ram port b
           padi_web_out   : out STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
           --address for padding ram port b
           padi_addrb_out : out STD_LOGIC_VECTOR(addr_length_g -1 DOWNTO 0) := std_logic_vector(to_unsigned(base_val_g, addr_length_g));
           --data in bus for padding ram port b
           padi_dinb_out  : out STD_LOGIC_VECTOR(data_size_g -1 DOWNTO 0) := std_logic_vector(to_unsigned(base_val_g, data_size_g)));
end padding_unit;

architecture Behavioral of padding_unit is

begin
    process ( clk, rst_n )
        --keep read_wait - write_wait >= 3
        --specify time to wait to read after setting read address.
        constant read_wait : integer := 6;
        --specify time to wait after setting write enable signal.
        constant write_wait : integer := 3;
        --holds the current row number.
        variable row : integer := 0;
        --holds the current column number.
        variable column : integer := 0;
        --holds time left to read.
        variable wait_to_read : integer := read_wait;
        --holds time left wait after write enable.
        variable wait_after_write : integer := write_wait;
        --mark the current corner to pad.
        variable corner : integer := 1;
        --holds the started state of the padding process.
        variable started : STD_LOGIC := '0';
        --specify the need to write through the port b of padded ram.
        variable write_to_b : STD_LOGIC := '0';
        --specify base address of input/output ram.
        variable ioi_base : unsigned (addr_length_g -1 downto 0):= "0000000000";
        --specify base address of padding ram.
        variable padi_base : unsigned (addr_length_g -1 downto 0) := "0000000000";
        --holds pixel value read from input/output ram.
        variable input_value : STD_LOGIC_VECTOR (data_size_g -1 downto 0) := "00000000";
        --holds top left corner pixel value.
        variable top_left : STD_LOGIC_VECTOR (data_size_g -1 downto 0) := "00000000";
        --holds top right corner pixel value.
        variable top_right : STD_LOGIC_VECTOR (data_size_g -1 downto 0) := "00000000";
        --holds bottom left corner pixel value.
        variable bottom_left : STD_LOGIC_VECTOR (data_size_g -1 downto 0) := "00000000";
        --holds bottom right corner pixel value.
        variable bottom_right : STD_LOGIC_VECTOR (data_size_g -1 downto 0) := "00000000";
        begin
            --active low reset. resets control and temporary data variables.
            if ( rst_n = '0' ) then
                row := 0;
                column := 0;
                wait_to_read := read_wait;
                wait_after_write := write_wait;
                corner := 1;
                started := '0';
                write_to_b := '0';
                ioi_base := "0000000000";
                padi_base := "0000000000";
                input_value := "00000000";
                top_left := "00000000";
                top_right := "00000000";
                bottom_left := "00000000";
                bottom_right := "00000000";
                ioi_wea_out <= "0";
                finished_out <= '0';
            elsif (clk 'event and clk = '1') then
                if (start_in = '1' and started = '0') then
                    --mark started state as 1 upone receiving start signal.
                    started := '1';
                    ioi_wea_out <= "0";
                    finished_out <= '0';
                elsif (started = '1') then
                    --traverse from row 0 to 24
                    if (row /= input_image_length_g) then
                        --traverse from column 0 to 24
                        if (column /= input_image_length_g) then
                            if (wait_to_read = read_wait) then
                                --set the next memory location address to
                                --input/output ram and start coutdown to read.
                                ioi_addra_out <= STD_LOGIC_VECTOR(ioi_base + (row * input_image_length_g) + column);
                                wait_to_read := wait_to_read - 1;
                            elsif (wait_to_read = 0) then
                                --read from input/output ram when the read countdown is 0.
                                input_value := ioi_douta_in;
                                ----wait_to_read := read_wait;
                                --set next address and data to be written into padded ram.
                                padi_addra_out <= STD_LOGIC_VECTOR(padi_base + ((row + 1) * output_image_length_g) + column + 1);
                                padi_dina_out <= input_value;
                                if (row = 0) then
                                    --if this is the first row of input image
                                    --duplicate it to pad the top edge by
                                    --setting corresponding address and data to
                                    --port b of padded ram.
                                    padi_addrb_out <= STD_LOGIC_VECTOR(padi_base + column + 1);
                                    padi_dinb_out <= input_value;
                                    write_to_b := '1';
                                    if (column = 0) then
                                        --if this is top left corner, save the value.
                                        top_left := input_value;
                                    elsif (column = input_image_length_g - 1) then
                                        --if this is top right corner, save the value.
                                        top_right := input_value;
                                    end if;
                                elsif (row = input_image_length_g - 1) then
                                    --if this is the last row of input image
                                    --duplicate it to pad the bottom edge by
                                    --setting corresponding address and data to
                                    --port b of padded ram.
                                    padi_addrb_out <= STD_LOGIC_VECTOR(padi_base + ((row + 2) * output_image_length_g) + column + 1);
                                    padi_dinb_out <= input_value;
                                    write_to_b := '1';
                                    if (column = 0) then
                                        --if this is bottom left corner,
                                        --save the value.
                                        bottom_left := input_value;
                                    elsif (column = input_image_length_g - 1) then
                                        --if this is bottom right corner,
                                        --save the value.
                                        bottom_right := input_value;
                                    end if;
                                elsif (column = 0) then
                                    --if this is the first column of input image
                                    --duplicate it to pad the left edge by
                                    --setting corresponding address and data to
                                    --port b of padded ram.
                                    padi_addrb_out <= STD_LOGIC_VECTOR(padi_base + ((row + 1) * output_image_length_g) + column);
                                    padi_dinb_out <= input_value;
                                    write_to_b := '1';
                                elsif (column = input_image_length_g - 1) then
                                    --if this is the last column of input image
                                    --duplicate it to pad the right edge by
                                    --setting corresponding address and data to
                                    --port b of padded ram.
                                    padi_addrb_out <= STD_LOGIC_VECTOR(padi_base + ((row + 1) * output_image_length_g) + column + 2);
                                    padi_dinb_out <= input_value;
                                    write_to_b := '1';
                                end if;
                                if (wait_after_write = write_wait) then
                                    --set write enable signals to
                                    --corresponding padded ram ports.
                                    padi_wea_out <= "1";
                                    if (write_to_b = '1') then
                                        padi_web_out <= "1";
                                        write_to_b := '0';
                                    end if;
                                    wait_after_write := wait_after_write - 1;
                                    ----column := column + 1;
                                elsif (wait_after_write = 0) then
                                    --if waiting after the write is over,
                                    --start processing next column.
                                    wait_after_write := write_wait;
                                    column := column + 1;
                                    wait_to_read := read_wait;
                                else
                                    --keep reducing wait after write counter.
                                    wait_after_write := wait_after_write - 1;
                                    if (wait_after_write = 0) then
                                        --disable write enable signals after
                                        --write operation.
                                        padi_wea_out <= "0";
                                        padi_web_out <= "0";
                                    end if;
                                end if;
                            else
                                --keep reducing wait to read counter.
                                wait_to_read := wait_to_read - 1;
                            end if;
                        else
                            --if processing of row is over, move to next row.
                            column := 0;
                            row := row + 1;
                        end if;
                    else
                        --if all rows are copied, copy corner pixels.
                        if (wait_after_write = write_wait) then
                            if (corner = 1) then
                                padi_addra_out <= "0000000000";
                                padi_dina_out <= top_left;
                                padi_addrb_out <= "0000011011";
                                padi_dinb_out <= top_left;
                            elsif (corner = 2) then
                                padi_addra_out <= "0000011010";
                                padi_dina_out <= top_right;
                                padi_addrb_out <= "0000110101";
                                padi_dinb_out <= top_right;
                            elsif (corner = 3) then
                                padi_addra_out <= "1010100011";
                                padi_dina_out <= bottom_left;
                                padi_addrb_out <= "1010111110";
                                padi_dinb_out <= bottom_left;
                            elsif (corner = 4) then
                                padi_addra_out <= "1010111101";
                                padi_dina_out <= bottom_right;
                                padi_addrb_out <= "1011011000";
                                padi_dinb_out <= bottom_right;
                            end if;
                            padi_wea_out <= "1";
                            padi_web_out <= "1";
                            wait_after_write := wait_after_write - 1;
                        elsif (wait_after_write = 0) then
                            wait_after_write := write_wait;
                            if (corner = 4) then
                                --set finish signal when all process is over.
                                --set statred state to 0.
                                finished_out <= '1';
                                started := '0';
                            else
                                corner := corner + 1;
                            end if;
                        else
                            wait_after_write := wait_after_write - 1;
                            padi_wea_out <= "0";
                            padi_web_out <= "0";
                        end if;
                    end if;
                end if;
            end if;
    end process;
end Behavioral;
