library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity MAC is
    port (clk  : in std_logic;
          rst : in std_logic;
          mac_init : in std_logic;
          rom_out : in std_logic_vector (7 downto 0);
          ram_out : in std_logic_vector (7 downto 0);
          y : out STD_LOGIC_VECTOR (18 downto 0);
          valid_out: out std_logic := '0'
          );
end MAC;


architecture Behavioral of MAC is
        signal a : STD_LOGIC_VECTOR (18 downto 0) := (others => '0');
begin

    process(clk,rst)
    begin
        if rst='1' then
            a <= (others => '0');
            y <= (others => '0');
            valid_out <= '0';
        elsif clk'event and clk = '1' then       
            if mac_init='1' then 
                y <= a;
                valid_out <= '1';
                a <= "000" & (ram_out * rom_out);
            else 
                a <= a + ("000"&(ram_out*rom_out));  
                valid_out <= '0';
            end if;
        end if;
    end process;
end Behavioral;
                        