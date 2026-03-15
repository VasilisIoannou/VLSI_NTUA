library ieee;
use ieee.std_logic_1164.all;

entity reg1bit is 
    port(
        clk_reg1    : in  std_logic;
        input_reg1  : in  std_logic;
        output_reg1 : out std_logic
    );
end entity reg1bit;

architecture reg1bit_beh of reg1bit is
    signal shift_reg1 : std_logic := '0';
begin
    process(clk_reg1)
    begin
        if rising_edge(clk_reg1) then
            shift_reg1 <= input_reg1;
        end if;
    end process;

    output_reg1 <= shift_reg1;

end architecture reg1bit_beh;
