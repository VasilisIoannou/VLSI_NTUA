library ieee;
use ieee.std_logic_1164.all;

entity reg3bit is 
    port(
        clk_reg3    : in  std_logic;
        input_reg3  : in  std_logic;
        output_reg3 : out std_logic
    );
end entity reg3bit;

architecture reg3bit_beh of reg3bit is
    signal shift_reg3 : std_logic_vector(2 downto 0) := "000";
begin

    process(clk_reg3)
    begin
        if rising_edge(clk_reg3) then
            shift_reg3 <= shift_reg3(1 downto 0) & input_reg3;
        end if;
    end process;

    output_reg3 <= shift_reg3(2);

end architecture reg3bit_beh;
