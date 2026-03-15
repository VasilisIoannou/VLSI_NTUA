library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Adder4_pipeline is port(
    clk_a4: in std_logic;
    inputA_a4: in std_logic_vector(3 downto 0);
    inputB_a4: in std_logic_vector(3 downto 0);
    cin_a4: in std_logic;
    Sout_a4: out std_logic_vector(3 downto 0);
    Cout_a4: out std_logic );
end Adder4_pipeline;

architecture str_pipeline of Adder4_pipeline is
    component FA port(
        clk_fa: in std_logic; 
        inputA_fa,inputB_fa : in std_logic; 
        cin_fa : in std_logic;    
        Sout_fa : out std_logic;
        Cout_fa: out std_logic );
    end component;
    
    component reg1bit port(
        clk_reg1    : in  std_logic;
        input_reg1  : in  std_logic;
        output_reg1 : out std_logic
    );
    end component;

    component reg2bit port(
        clk_reg2    : in  std_logic;
        input_reg2  : in  std_logic;
        output_reg2 : out std_logic
    );
    end component;
    
    component reg3bit port(
        clk_reg3    : in  std_logic;
        input_reg3  : in  std_logic;
        output_reg3 : out std_logic
    );
    end component;

    signal sout_sig: std_logic_vector(3 downto 0);
    signal cout_sig: std_logic_vector(3 downto 0);    
        
    signal delay_A1, delay_B1: std_logic;
    signal delay_A2, delay_B2: std_logic;
    signal delay_A3, delay_B3: std_logic;

begin

    -- Input Delay(i)+Output Delay(i)= Constant Latency
   
    -- Full Adder 0
    -- FA0 delay = 0 inpout + 3 output  
    FA0: FA port map(
        clk_fa => clk_a4,
        inputA_fa => inputA_a4(0),
        inputB_fa => inputB_a4(0),
        cin_fa => cin_a4,
        Sout_fa => sout_sig(0),
        Cout_fa => cout_sig(0)
    );   

    -- S0 should delay 3 cycles to be synchronised with S3
    Reg_Sout0: reg3bit port map(
        clk_reg3 => clk_a4,
        input_reg3 => sout_sig(0),
        output_reg3 => Sout_a4(0)
    );
    
    -- Full Adder 1
    -- FA1 delay = 1 cycle input + 2 cycle output

    Reg_InputA1: reg1bit port map(
        clk_reg1 => clk_a4,
        input_reg1 => inputA_a4(1),
        output_reg1 => delay_A1
    );

    Reg_InputB1: reg1bit port map(
        clk_reg1 => clk_a4,
        input_reg1 => inputB_a4(1),
        output_reg1 => delay_B1
    );

    
    FA1: FA port map(
        clk_fa => clk_a4,
        inputA_fa=> delay_A1,
        inputB_fa => delay_B1,
        cin_fa => cout_sig(0),
        Sout_fa => sout_sig(1),
        Cout_fa => cout_sig(1)
    );  
   
    Reg_Sout1: reg2bit port map(
        clk_reg2 => clk_a4,
        input_reg2 => sout_sig(1),
        output_reg2 => Sout_a4(1)
    );
    
    -- Full Adder 2
    -- FA2 delay = 2 input + 1 output

    Reg_InputA2: reg2bit port map(
        clk_reg2 => clk_a4,
        input_reg2 => inputA_a4(2),
        output_reg2 => delay_A2
    );

    Reg_InputB2: reg2bit port map(
        clk_reg2 => clk_a4,
        input_reg2 => inputB_a4(2),
        output_reg2 => delay_B2
    );

    FA2: FA port map(
        clk_fa => clk_a4,
        inputA_fa => delay_A2,
        inputB_fa => delay_B2,
        cin_fa => cout_sig(1),
        Sout_fa => sout_sig(2),
        Cout_fa => cout_sig(2)
    );  

    Reg_Sout2: reg1bit port map(
        clk_reg1 => clk_a4,
        input_reg1 => sout_sig(2),
        output_reg1 => Sout_a4(2)
    );

    -- Full Adder 3
    -- FA3 delay = 3 input + 0 output

    Reg_InputA3: reg3bit port map(
        clk_reg3 => clk_a4,
        input_reg3 => inputA_a4(3),
        output_reg3 => delay_A3
    );

    Reg_InputB3: reg3bit port map(
        clk_reg3 => clk_a4,
        input_reg3 => inputB_a4(3),
        output_reg3 => delay_B3
    );

    FA3: FA port map(
        clk_fa => clk_a4,
        inputA_fa => delay_A3,
        inputB_fa => delay_B3,
        cin_fa => cout_sig(2),
        Sout_fa => Sout_a4(3),
        Cout_fa => Cout_a4
    );  


end str_pipeline;
