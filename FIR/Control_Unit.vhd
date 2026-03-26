library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;


entity Control_Unit is

    Port ( clk : in  STD_LOGIC;
           rst : in STD_LOGIC;
           valid_in : in STD_LOGIC;
           rom_address : out  STD_LOGIC_VECTOR (2 downto 0);	-- output data
           ram_address : out  STD_LOGIC_VECTOR (2 downto 0);
           mac_init : out  STD_LOGIC
         );
end Control_Unit;

architecture Behavioral of Control_Unit is
    signal counter : STD_LOGIC_VECTOR (2 downto 0) := "000";
begin

    ram_address <= counter;
    rom_address <= counter;
    
    process(clk,rst)
    begin
        if rst='1' then
            counter <= "000";
            mac_init <= '0';
        elsif clk'event and clk = '1' then 
            if valid_in='1' then   
                counter <= "001"; 
                mac_init <= '1';
            else
               counter <= counter + 1;
               mac_init <= '0';
            end if;
        end if;
    end process;
end Behavioral;        