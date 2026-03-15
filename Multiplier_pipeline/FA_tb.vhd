library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FA_tb is
end FA_tb;

architecture behaivoral_tb of FA_tb is

    component FA port(
            clk_fa   : in  std_logic;
            inputA_fa: in  std_logic;
            inputB_fa: in  std_logic;
            cin_fa   : in  std_logic;
            cout_fa  : out std_logic;
            Sout_fa  : out std_logic
    );
    end component;

    signal sig_clk: std_logic := '0';
    signal sig_inputA: std_logic:= '0';
    signal sig_inputB: std_logic:= '0';
    signal sig_cin   : std_logic := '0';
    signal sig_cout  : std_logic;
    signal sig_Sout  : std_logic;

    constant clk_period : time := 10 ns;

begin
    
    uut: FA port map(
        clk_fa   => sig_clk,
        inputA_fa => sig_inputA,
        inputB_fa => sig_inputB,
        cin_fa   => sig_cin,
        cout_fa  => sig_cout,
        Sout_fa  => sig_Sout
    );

    clk_process : process
    begin
        sig_clk <= '0';
        wait for clk_period/2;
        sig_clk <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process
    begin
        -- Test all combinations
        for i in 0 to 7 loop
            sig_inputA <= std_logic(to_unsigned(i, 3)(0));
            sig_inputB <= std_logic(to_unsigned(i, 3)(1));
            sig_cin    <= std_logic(to_unsigned(i, 3)(2));
            
            if (i > 3) then
                sig_cin <= '1';
            else
                sig_cin <= '0';
            end if;
            
            wait for clk_period;
        end loop;
        
        wait; -- Wait forever
    end process;

end behaivoral_tb;

