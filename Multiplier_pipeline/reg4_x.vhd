library ieee;
use ieee.std_logic_1164.all;

entity reg_generic is 
    generic (
        BITS  : integer;  -- Width of the vector (default 4)
        DELAY : integer   -- Number of clock cycles (default 3)
    );
    port (
        clk_rg    : in  std_logic;
        input_rg  : in  std_logic_vector(BITS-1 downto 0);
        output_rg : out std_logic_vector(BITS-1 downto 0)
    );
end entity reg_generic;

architecture Behavioral of reg_generic is
    -- We need DELAY stages of registers
    type shift_reg_type is array (0 to DELAY-1) of std_logic_vector(BITS-1 downto 0);
    signal shift_reg : shift_reg_type;
begin
    process(clk_rg)
    begin
        if rising_edge(clk_rg) then
            -- Shift the data through the stages
            shift_reg(0) <= input_rg;
            for i in 1 to DELAY-1 loop
                shift_reg(i) <= shift_reg(i-1);
            end loop;
        end if;
    end process;

    -- The output is the very last stage
    output_rg <= shift_reg(DELAY-1);
end architecture Behavioral;
