library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity systolic_pe is port (
    clk_spe  : in std_logic;
    -- Data flowing through
    inA_spe  : in std_logic;
    inB_spe  : in std_logic;
    inS_spe  : in std_logic; -- Sum from cell above
    inC_spe  : in std_logic; -- Carry from cell to the left
    
    outA_spe : out std_logic;
    outB_spe : out std_logic;
    outS_spe : out std_logic;
    outC_spe : out std_logic );
end systolic_pe;

architecture Behavioral of systolic_pe is

    component FA is port(
        clk_fa: in std_logic;
        inputA_fa: in std_logic;
        inputB_fa: in std_logic;
        cin_fa:in std_logic;
        cout_fa: out std_logic;
        Sout_fa: out std_logic);
    end component;

    -- 1. Move signals here (Architecture level)
    signal reg_A, reg_B, reg_S, reg_C : std_logic;
    signal reg_A_delay: std_logic;
    signal partial_product : std_logic;

begin
    -- 2. Logic: The "Multiply" part (Combinational)
    partial_product <= inA_spe AND inB_spe;

    -- 3. The Structural Part: Connect the Full Adder (Concurrent)
    -- This FA already has a clock, so it handles its own internal registers
    FA_inst: FA port map(
        clk_fa    => clk_spe,
        inputA_fa => inS_spe,
        inputB_fa => partial_product,
        cin_fa    => inC_spe,
        cout_fa   => outC_spe, -- These go straight out or to registers
        Sout_fa   => outS_spe
    );

    -- 4. The Systolic Part: Register the signals that just "pass through"
    process(clk_spe)
    begin
        if rising_edge(clk_spe) then
            -- Pass-through registers
            reg_A_delay <= inA_spe;
            outA_spe <= reg_A_delay; 
            outB_spe <= inB_spe;
            -- Note: inS and inC are handled by the FA component's clock
        end if;
    end process;

end Behavioral;
