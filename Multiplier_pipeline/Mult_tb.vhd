library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_four_bit_multiplier is
end tb_four_bit_multiplier;

architecture sim of tb_four_bit_multiplier is
    -- Component Declaration
    component four_bit_multiplier
        port (
            clk_mult    : in STD_LOGIC;
            inputA_mult : in STD_LOGIC_VECTOR (3 downto 0);
            inputB_mult : in STD_LOGIC_VECTOR (3 downto 0);
            output_mult : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;

    signal clk   : std_logic := '0';
    signal A, B  : std_logic_vector(3 downto 0) := (others => '0');
    signal res   : std_logic_vector(7 downto 0);

    constant clk_period : time := 10 ns;

begin
    uut: four_bit_multiplier port map (clk, A, B, res);

    -- Clock process
    clk_process : process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;

    -- Stimulus process
    STIMULUS : process
    begin
        wait for (3*Clk_period);

        for i in 1 to 15 loop
            for j in 0 to 15 loop
                A <= std_logic_vector(to_unsigned(i,4));
                B <= std_logic_vector(to_unsigned(j,4));
                wait for (Clk_period);
            end loop;
        end loop;
        
        wait for (15*Clk_period);
        wait;
    end process STIMULUS;
end sim;