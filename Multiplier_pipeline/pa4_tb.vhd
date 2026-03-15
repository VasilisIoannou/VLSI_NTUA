library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pa4_tb is
end entity pa4_tb;

architecture FourBitTB_Arch of pa4_tb is

    component Adder4_pipeline is port(
        clk_a4: in std_logic;
        inputA_a4: in std_logic_vector(3 downto 0);
        inputB_a4: in std_logic_vector(3 downto 0);
        cin_a4: in std_logic;
        Sout_a4: out std_logic_vector(3 downto 0);
        Cout_a4: out std_logic );
    end component;

signal A,B,Sum : std_logic_vector (3 downto 0) := "0000";
signal Cin,Clock,Carry : std_logic := '0';
-- signal Reset: std_logic := 0;
constant Clk : time := 10ns;

begin

    DUT : Adder4_pipeline
 port map (
        clk_a4 => Clock,
        inputA_a4 => A,
        inputB_a4 => B,
        cin_a4 => Cin, 
        Sout_a4 => Sum, 
        cout_a4 => Carry
    );
    
    Clock_Gen : process
    begin
        Clock <= '1';
        wait for (Clk/2);
        Clock <= '0';
        wait for (Clk/2);
    end process Clock_Gen;

    STIMULUS : process
    begin
        wait for (3*Clk);

        -- Reset <= '1';
        Cin <= '0';
        
        for i in 0 to 15 loop
            for j in 0 to 15 loop
                    A <= std_logic_vector(to_unsigned(i,4));
                    B <= std_logic_vector(to_unsigned(j,4));
                wait for (Clk);
            end loop;
        end loop;
            
        Cin <= '1';
        for i in 0 to 15 loop
            for j in 0 to 15 loop
                A <= std_logic_vector(to_unsigned(i,4));
                B <= std_logic_vector(to_unsigned(j,4));
                wait for (Clk);
            end loop;
        end loop;
        -- Reset <= '0';
        wait;
    end process STIMULUS;

end architecture FourBitTB_Arch;
