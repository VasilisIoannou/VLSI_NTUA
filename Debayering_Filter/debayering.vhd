library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all; 

entity Debayering_Filter is 
generic(
    size : integer := 1024
);
port(
    new_image      : in std_logic;
    valid_in       : in std_logic;
    clk            : in std_logic;
    rst_n          : in std_logic;
    pixel          : in std_logic_vector(7 downto 0);
    image_finished : out std_logic;
    valid_out      : out std_logic;
    R              : out std_logic_vector(7 downto 0);
    G              : out std_logic_vector(7 downto 0);
    B              : out std_logic_vector(7 downto 0)
);
end entity;

architecture Deb_arch of Debayering_Filter is

    function log2_ceil(n : integer) return integer is
        variable res : integer := 0;
    begin
        while (2**res < n) loop res := res + 1; end loop;
        return res;
    end function;

    component window_3x3 is
    generic( N : integer := size );
    port (
        clk      : in  std_logic;
        rst_n    : in  std_logic;
        en       : in  std_logic;
        pixel_in : in  std_logic_vector(7 downto 0);
        win_00, win_01, win_02 : out std_logic_vector(7 downto 0);
        win_10, win_11, win_12 : out std_logic_vector(7 downto 0);
        win_20, win_21, win_22 : out std_logic_vector(7 downto 0)
    );
    end component;

    signal win_en: std_logic; 
    
    signal win_00, win_01, win_02 : std_logic_vector(7 downto 0);
    signal win_10, win_11, win_12 : std_logic_vector(7 downto 0);
    signal win_20, win_21, win_22 : std_logic_vector(7 downto 0);

    signal m_win_00, m_win_01, m_win_02 : unsigned(7 downto 0);
    signal m_win_10, m_win_11, m_win_12 : unsigned(7 downto 0);
    signal m_win_20, m_win_21, m_win_22 : unsigned(7 downto 0);

    constant ADDR_WIDTH : integer := log2_ceil(size);
    signal col_cnt : unsigned(ADDR_WIDTH-1 downto 0) := (others => '0');
    signal row_cnt : unsigned(ADDR_WIDTH-1 downto 0) := (others => '0');
    signal col_cnt_out : unsigned(ADDR_WIDTH-1 downto 0) := (others => '0');
    signal row_cnt_out : unsigned(ADDR_WIDTH-1 downto 0) := (others => '0');
    
    signal start_output_sig : std_logic := '0';
    
    signal valid_in_delay: std_logic := '0';

begin

    -- window enable when valid_in
    win_en <= valid_in;

    StP: window_3x3 generic map( N => size ) 
    port map (
        clk => clk, rst_n => rst_n, en => win_en, pixel_in => pixel,
        win_00 => win_00, win_01 => win_01, win_02 => win_02,
        win_10 => win_10, win_11 => win_11, win_12 => win_12,
        win_20 => win_20, win_21 => win_21, win_22 => win_22
    );

    -- Zero Padding Logic
    m_win_00 <= unsigned(win_00) when (col_cnt_out > 0 and row_cnt_out < size-1) else (others => '0');
    m_win_01 <= unsigned(win_01) when (row_cnt_out < size-1) else (others => '0');
    m_win_02 <= unsigned(win_02) when (col_cnt_out < size-1 and row_cnt_out < size-1) else (others => '0');
    m_win_10 <= unsigned(win_10) when (col_cnt_out > 0) else (others => '0');
    m_win_11 <= unsigned(win_11);
    m_win_12 <= unsigned(win_12) when (col_cnt_out < size-1) else (others => '0');
    m_win_20 <= unsigned(win_20) when (col_cnt_out > 0 and row_cnt_out > 0) else (others => '0');
    m_win_21 <= unsigned(win_21) when (row_cnt_out > 0) else (others => '0');
    m_win_22 <= unsigned(win_22) when (col_cnt_out < size-1 and row_cnt_out > 0) else (others => '0');

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            col_cnt <= (others => '0');
            row_cnt <= (others => '0');
            col_cnt_out <= (others => '0');
            row_cnt_out <= (others => '0');
            start_output_sig <= '0';
            valid_out <= '0';
            valid_in_delay <= '0';
            image_finished <= '0';
            R <= (others => '0'); G <= (others => '0'); B <= (others => '0');
            
        elsif rising_edge(clk) then
            valid_in_delay <= valid_in;
            
            if new_image = '1' then
                col_cnt <= (others => '0'); row_cnt <= (others => '0');
                col_cnt_out <= (others => '0'); row_cnt_out <= (others => '0');
                start_output_sig <= '0'; valid_out <= '0'; image_finished <= '0';
            end if;

            if valid_in = '1' then
                -- Input Counters
                if col_cnt = size-1 then
                    col_cnt <= (others => '0');
                    if row_cnt = size-1 then row_cnt <= (others => '0');
                    else row_cnt <= row_cnt + 1; end if;
                else col_cnt <= col_cnt + 1; end if;

                -- Latency Trigger (2N + 2 cycles)
                if (row_cnt = 2 and col_cnt = 1) then
                    start_output_sig <= '1';
                end if;

                if start_output_sig = '1' then
                    valid_out <= '1';
                    -- RGB Calculation Logic
                    --A-A = GB, A-P = B , P-A = R , P-P = GR
                    if row_cnt_out(0) = '0' then
                        if col_cnt_out(0) = '0' then -- PIXEL_GB
                            G <= std_logic_vector(m_win_11);
                            B <= std_logic_vector(resize(shift_right(resize(m_win_10, 10) + resize(m_win_12, 10), 1), 8));
                            R <= std_logic_vector(resize(shift_right(resize(m_win_01, 10) + resize(m_win_21, 10), 1), 8));
                        else -- PIXEL_B
                            B <= std_logic_vector(m_win_11);
                            G <= std_logic_vector(resize(shift_right(resize(m_win_01, 10) + resize(m_win_10, 10) + resize(m_win_12, 10) + resize(m_win_21, 10), 2), 8));
                            R <= std_logic_vector(resize(shift_right(resize(m_win_00, 10) + resize(m_win_02, 10) + resize(m_win_20, 10) + resize(m_win_22, 10), 2), 8));
                        end if;
                    else
                        if col_cnt_out(0) = '0' then -- PIXEL_R
                            R <= std_logic_vector(m_win_11);
                            G <= std_logic_vector(resize(shift_right(resize(m_win_01, 10) + resize(m_win_10, 10) + resize(m_win_12, 10) + resize(m_win_21, 10), 2), 8));
                            B <= std_logic_vector(resize(shift_right(resize(m_win_00, 10) + resize(m_win_02, 10) + resize(m_win_20, 10) + resize(m_win_22, 10), 2), 8));
                        else -- PIXEL_GR
                            G <= std_logic_vector(m_win_11);
                            R <= std_logic_vector(resize(shift_right(resize(m_win_10, 10) + resize(m_win_12, 10), 1), 8));
                            B <= std_logic_vector(resize(shift_right(resize(m_win_01, 10) + resize(m_win_21, 10), 1), 8));
                        end if;
                    end if;

                    -- Output Counters
                    if col_cnt_out = size-1 then
                        col_cnt_out <= (others => '0');
                        if row_cnt_out = size-1 then
                            row_cnt_out <= (others => '0');
                            start_output_sig <= '0';
                            image_finished <= '1';
                        else row_cnt_out <= row_cnt_out + 1; end if;
                    else col_cnt_out <= col_cnt_out + 1; end if;
                else
                    valid_out <= '0'; image_finished <= '0';
                end if;
            else
                valid_out <= '0';
            end if;
        end if;
    end process;
end Deb_arch;
