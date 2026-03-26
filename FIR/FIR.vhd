library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity FIR is
    port (
        clk : in std_logic;
        rst : in std_logic;
        valid_in : in std_logic;
        x : in std_logic_vector(7 downto 0);
        valid_out : out std_logic;
        y : out std_logic_vector(18 downto 0)
    );
end entity FIR;

architecture FIR_Arch of FIR is

    component mlab_ram
        generic (
            data_width : integer := 8
        );
        port (
            clk : in std_logic;
            we : in std_logic;
            rst : in std_logic;
            en : in std_logic;
            addr : in std_logic_vector(2 downto 0);
            di : in std_logic_vector(data_width-1 downto 0);
            do : out std_logic_vector(data_width-1 downto 0)
        );
    end component mlab_ram;
    
    component mlab_rom
        generic (
            coeff_width : integer := 8
        );
        port ( 
            clk : in STD_LOGIC;
            en : in STD_LOGIC;
            addr : in STD_LOGIC_VECTOR (2 downto 0);
            rom_out : out STD_LOGIC_VECTOR (coeff_width-1 downto 0)
        );
    end component mlab_rom;
    
    component Control_Unit
        port ( 
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            valid_in : in STD_LOGIC;
            rom_address : out STD_LOGIC_VECTOR (2 downto 0);
            ram_address : out STD_LOGIC_VECTOR (2 downto 0);
            mac_init : out STD_LOGIC
        );
    end component Control_Unit;
    
    component MAC
        port (
            clk : in std_logic;
            rst : in std_logic;
            mac_init : in std_logic;
            rom_out : in std_logic_vector (7 downto 0);
            ram_out : in std_logic_vector (7 downto 0);
            y : out STD_LOGIC_VECTOR (18 downto 0);
            valid_out: out std_logic
        );
    end component MAC;

    signal rom_address_wire : STD_LOGIC_VECTOR (2 downto 0);
    signal ram_address_wire : STD_LOGIC_VECTOR (2 downto 0);
    signal mac_init_wire    : STD_LOGIC;
    signal rom_out_wire     : STD_LOGIC_VECTOR (7 downto 0);
    signal ram_out_wire     : STD_LOGIC_VECTOR (7 downto 0);

begin

    CONTROL_UNIT_INSTANCE : Control_Unit
    port map (
        clk => clk,
        rst => rst,
        valid_in => valid_in,
        rom_address => rom_address_wire,
        ram_address => ram_address_wire,
        mac_init => mac_init_wire
    );
    
    ROM_INSTANCE : mlab_rom
    port map ( 
        clk => clk,
        en => '1',
        addr => rom_address_wire,
        rom_out => rom_out_wire
    );
    
    RAM_INSTANCE : mlab_ram
    port map (
        clk => clk,
        we => valid_in,
        rst => rst, 
        en => '1',
        addr => ram_address_wire,
        di => x,
        do => ram_out_wire
    );
          
    MAC_INSTANCE : MAC
    port map (
        clk => clk,
        rst => rst,
        mac_init => mac_init_wire,
        rom_out => rom_out_wire,
        ram_out => ram_out_wire,
        y => y,
        valid_out => valid_out
    );
        
end architecture FIR_Arch;