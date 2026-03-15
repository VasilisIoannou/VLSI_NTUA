library ieee;
use ieee.std_logic_1164.all;

entity reg2bit is 
    port(
        clk_reg2    : in  std_logic;
        input_reg2  : in  std_logic;
        output_reg2 : out std_logic );
end entity reg2bit;

architecture reg2bit_beh of reg2bit is
    signal shift_reg2 : std_logic_vector(1 downto 0) := "00";
begin

    process(clk_reg2)
    begin
        if rising_edge(clk_reg2) then
            shift_reg2 <= shift_reg2(0) & input_reg2;
        end if;
    end process;

    output_reg2 <= shift_reg2(1);

end architecture reg2bit_beh;
