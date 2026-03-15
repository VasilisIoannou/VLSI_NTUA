library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FA is port(
    clk_fa: in std_logic;
    inputA_fa: in std_logic;
    inputB_fa: in std_logic;
    cin_fa:in std_logic;
    cout_fa: out std_logic;
    Sout_fa: out std_logic);
end FA;

architecture FA_behaivoral of FA is
    
begin
    add: process(clk_fa) is
    begin
        if(rising_edge(clk_fa)) then
            Sout_fa <= inputA_fa XOR inputB_fa XOR Cin_fa;
            Cout_fa <= ( inputA_fa AND inputB_fa ) OR ( Cin_fa AND (inputA_fa XOR inputB_fa));
        end if;
    end process add;

end FA_behaivoral;
