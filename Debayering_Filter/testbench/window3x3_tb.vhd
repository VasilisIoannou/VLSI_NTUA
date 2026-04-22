library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- 1. Add TextIO Libraries
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_window_3x3 is
-- Testbenches have no ports
end entity;

architecture sim of tb_window_3x3 is

    -- Component Declaration
    component window_3x3
        generic ( N : integer := 8 ); 
        port (
            clk, rst_n, en : in std_logic;
            pixel_in     : in std_logic_vector(7 downto 0);
            win_00, win_01, win_02 : out std_logic_vector(7 downto 0);
            win_10, win_11, win_12 : out std_logic_vector(7 downto 0);
            win_20, win_21, win_22 : out std_logic_vector(7 downto 0)
        );
    end component;

    -- Internal Signals
    signal clk   : std_logic := '0';
    signal rst_n   : std_logic := '0';
    signal en    : std_logic := '0';
    signal p_in  : std_logic_vector(7 downto 0) := (others => '0');
    
    -- Outputs
    signal w00, w01, w02 : std_logic_vector(7 downto 0);
    signal w10, w11, w12 : std_logic_vector(7 downto 0);
    signal w20, w21, w22 : std_logic_vector(7 downto 0);

    
    -- Simulation constants
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate Unit Under Test (UUT)
    uut: window_3x3
        generic map ( N => 8)
        port map (
            clk => clk, rst_n => rst_n, en => en, pixel_in => p_in,
            win_00 => w00, win_01 => w01, win_02 => w02,
            win_10 => w10, win_11 => w11, win_12 => w12,
            win_20 => w20, win_21 => w21, win_22 => w22
        );

    -- Clock Generation
    clk_process : process
    begin
        while now < 1000 ns loop -- Increased time to accommodate file reading
            clk <= '0'; wait for CLK_PERIOD/2;
            clk <= '1'; wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- 2. Stimulus Process with File I/O
    stim_proc: process
        file input_file      : text;
        variable line_buffer : line;
        variable pixel_val   : integer; -- Temporary variable to hold the integer value
    begin
        -- Open the file (Ensure this file is in your simulation folder)
        file_open(input_file, "/home/vasilis/Desktop/debayering/input.data", read_mode);

        -- Initial Reset
        rst_n <= '0';
        en  <= '0';
        wait for 25 ns;
        rst_n <= '1';
        en  <= '1';
        wait for CLK_PERIOD;

        -- 3. Read Loop
        while not endfile(input_file) loop
            -- Read a line from the file
            readline(input_file, line_buffer);
            -- Extract the integer from the line
            read(line_buffer, pixel_val);
            
            -- Drive the signal
            p_in <= std_logic_vector(to_unsigned(pixel_val, 8));
            
            wait for CLK_PERIOD;
        end loop;

        -- Cleanup
        file_close(input_file);
        en <= '0';
        report "Simulation Finished: All pixels read from file.";
        wait;
    end process;

end architecture;