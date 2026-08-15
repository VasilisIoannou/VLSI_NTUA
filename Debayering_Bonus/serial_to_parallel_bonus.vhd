library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity window_3x3 is
    port (
        clk      : in  std_logic;
        rst_n    : in  std_logic;
        en       : in  std_logic;
        pixel_in : in  std_logic_vector(7 downto 0);
        image_dim: in  std_logic_vector(10 downto 0);

        -- 9 pixels for the 3x3 window output
        win_00, win_01, win_02 : out std_logic_vector(7 downto 0);
        win_10, win_11, win_12 : out std_logic_vector(7 downto 0);
        win_20, win_21, win_22 : out std_logic_vector(7 downto 0)
    );
end entity;

architecture bhv of window_3x3 is
    constant MAX_WIDTH : integer := 1024;
    type ram_type is array (0 to MAX_WIDTH-1) of std_logic_vector(7 downto 0);
    
    signal ram0, ram1 : ram_type := (others => (others => '0'));
    signal addr       : integer range 0 to MAX_WIDTH-1 := 0;

    -- Counter to track valid rows since reset
    signal row_count  : integer range 0 to 3 := 0;

    -- 3x3 Sliding Window Registers
    type matrix_3x3 is array (0 to 2, 0 to 2) of std_logic_vector(7 downto 0);
    signal pixel_matrix : matrix_3x3 := (others => (others => (others => '0')));  

begin

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            addr <= 0;
            row_count <= 0; 
            pixel_matrix <= (others => (others => (others => '0')));
        elsif rising_edge(clk) then
            if en = '1' then
                
                ram0(addr) <= pixel_in;
                ram1(addr) <= ram0(addr); 

                pixel_matrix(0, 2) <= pixel_in;
                pixel_matrix(0, 1) <= pixel_matrix(0, 2);
                pixel_matrix(0, 0) <= pixel_matrix(0, 1);

                if row_count > 0 then
                    pixel_matrix(1, 2) <= ram0(addr);
                else
                    pixel_matrix(1, 2) <= (others => '0');
                end if;
                pixel_matrix(1, 1) <= pixel_matrix(1, 2);
                pixel_matrix(1, 0) <= pixel_matrix(1, 1);

                if row_count > 1 then
                    pixel_matrix(2, 2) <= ram1(addr);
                else
                    pixel_matrix(2, 2) <= (others => '0');
                end if;
                pixel_matrix(2, 1) <= pixel_matrix(2, 2);
                pixel_matrix(2, 0) <= pixel_matrix(2, 1);

                if addr = to_integer(unsigned(image_dim)) - 1 then
                    addr <= 0;
                   
                    if row_count < 3 then
                        row_count <= row_count + 1;
                    end if;
                else
                    addr <= addr + 1;
                end if;

            end if;
        end if;
    end process;

    -- Port Mapping (Matrix to Out)
    win_00 <= pixel_matrix(0, 0); win_01 <= pixel_matrix(0, 1); win_02 <= pixel_matrix(0, 2);
    win_10 <= pixel_matrix(1, 0); win_11 <= pixel_matrix(1, 1); win_12 <= pixel_matrix(1, 2);
    win_20 <= pixel_matrix(2, 0); win_21 <= pixel_matrix(2, 1); win_22 <= pixel_matrix(2, 2);

end architecture;
