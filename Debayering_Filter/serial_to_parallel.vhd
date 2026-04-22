library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity window_3x3 is
    generic(
        N : integer := 8 -- Width of the image row
    );
    port (
        clk      : in  std_logic;
        rst_n    : in  std_logic;
        en       : in  std_logic;
        pixel_in : in  std_logic_vector(7 downto 0);
        -- 9 pixels for the 3x3 window output
        win_00, win_01, win_02 : out std_logic_vector(7 downto 0);
        win_10, win_11, win_12 : out std_logic_vector(7 downto 0);
        win_20, win_21, win_22 : out std_logic_vector(7 downto 0)
    );
end entity;

architecture bhv of window_3x3 is
    -- RAM for long row storage (Inferred BRAM)
    type ram_type is array (0 to N-1) of std_logic_vector(7 downto 0);
    signal ram1, ram2, ram3 : ram_type := (others => (others => '0'));
    signal addr : integer range 0 to N-1 := 0;

    -- Taps for the window
    signal row1_data, row2_data, row3_data : std_logic_vector(7 downto 0);
    signal pixel_in_reg : std_logic_vector(7 downto 0);

    -- THE MISSING DEFINITION: 3x3 Sliding Window Registers
    type matrix_3x3 is array (0 to 2, 0 to 2) of std_logic_vector(7 downto 0);
    signal pixel_matrix : matrix_3x3 := (others => (others => (others => '0')));

begin

process(clk)
begin
    if rising_edge(clk) then
        if rst_n = '0' then
            addr <= 0;
            addr <= 0;  
            row1_data    <= (others => '0');
            row2_data    <= (others => '0');
            row3_data    <= (others => '0');
            pixel_in_reg <= (others => '0');
            pixel_matrix <= (others => (others => (others => '0')));
        elsif en = '1' then
            pixel_in_reg <= pixel_in;
            
            -- Write to RAM
            ram1(addr) <= pixel_in;
            ram2(addr) <= ram1(addr);
            ram3(addr) <= ram2(addr);

            -- Pointer logic
            if addr = N-1 then
                addr <= 0;
            else
                addr <= addr + 1;
            end if;

            -- Sliding Window Logic
            pixel_matrix(0, 2) <= ram1(addr);
            pixel_matrix(0, 1) <= pixel_matrix(0, 2);
            pixel_matrix(0, 0) <= pixel_matrix(0, 1);
            
            pixel_matrix(1, 2) <= ram2(addr);
            pixel_matrix(1, 1) <= pixel_matrix(1, 2);
            pixel_matrix(1, 0) <= pixel_matrix(1, 1);
            
            pixel_matrix(2, 2) <= ram3(addr);
            pixel_matrix(2, 1) <= pixel_matrix(2, 2);
            pixel_matrix(2, 0) <= pixel_matrix(2, 1);
        end if;
    end if;
end process;

-- Port Mapping (Matrix to Out)
win_00 <= pixel_matrix(0, 0); win_01 <= pixel_matrix(0, 1); win_02 <= pixel_matrix(0, 2);
win_10 <= pixel_matrix(1, 0); win_11 <= pixel_matrix(1, 1); win_12 <= pixel_matrix(1, 2);
win_20 <= pixel_matrix(2, 0); win_21 <= pixel_matrix(2, 1); win_22 <= pixel_matrix(2, 2);

end architecture;
