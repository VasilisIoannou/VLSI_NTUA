library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity FIR_TB is
end entity FIR_TB;

architecture Behavioral of FIR_tb is

    component FIR
        port (
            clk       : in std_logic;
            rst       : in std_logic;
            valid_in  : in std_logic;
            x         : in std_logic_vector (7 downto 0);
            valid_out : out std_logic;
            y         : out std_logic_vector (18 downto 0)
        );
    end component;

    -- Σήματα με τα σωστά ονόματα και μεγέθη
    signal clk       : std_logic := '0';
    signal rst       : std_logic := '0';
    signal valid_in  : std_logic := '0';
    signal valid_out : std_logic;
    signal x         : std_logic_vector (7 downto 0) := (others => '0');
    signal y         : std_logic_vector (18 downto 0);
    
    constant T_CLK : time := 10 ns; -- Άλλαξα το όνομα σε T_CLK για να μην μπερδεύεται με το σήμα clk

begin

    DUT : FIR
    port map(
        clk       => clk,
        rst       => rst,
        valid_in  => valid_in,
        x         => x,
        valid_out => valid_out,
        y         => y
    );

    ClockGen : process
    begin
        clk <= '1';
        wait for (T_CLK/2);
        clk <= '0';
        wait for (T_CLK/2);
    end process;

    STIMULUS : process
        -- Δημιουργούμε μια Procedure για να στέλνουμε τα δεδομένα πανεύκολα
        procedure send_data(val : integer) is
        begin
            x <= std_logic_vector(to_unsigned(val, 8));
            valid_in <= '1';    -- Ενεργοποιούμε το valid_in
            wait for T_CLK;     -- Για ΑΚΡΙΒΩΣ 1 κύκλο ρολογιού
            valid_in <= '0';    -- Το κατεβάζουμε
            wait for T_CLK*7;   -- Περιμένουμε 7 κύκλους για να ολοκληρωθεί ο υπολογισμός του MAC
        end procedure;

    begin   
        -- Αρχικοποίηση (Active High Reset)
        rst <= '1';
        valid_in <= '0';
        wait for (T_CLK*10); -- Higher wait for post impementation;
        rst <= '0';
        wait for (T_CLK*20);
        
        wait until rising_edge(clk);
        wait for 1 ns;

        -- Χρήση της Procedure για τα δεδομένα σου
        send_data(208);
        send_data(231);
        send_data(32);
        send_data(233);
        send_data(161);
        send_data(24);
        send_data(71);
        send_data(140); -- 8th value
        send_data(245);
        send_data(247);
        
      
        
        -- Test reset 
        --rst <= '1';
        --valid_in <= '0';
        --wait for (T_CLK*10); -- Higher wait for post impementation;
        --rst <= '0';
        --wait for (T_CLK*20);
        
        --wait until rising_edge(clk);
        --wait for 1 ns;
           
        send_data(40); -- 10th value
        send_data(248);
        send_data(245);
        send_data(124);
        send_data(204);
        send_data(36);
        send_data(107);
        send_data(234);
        send_data(202);
        send_data(245);
        
          for i in 0 to 7 loop
            send_data(0);
        end loop;

        wait for (T_CLK*10);
        -- Τέλος προσομοίωσης
        wait;
    end process;

end architecture;