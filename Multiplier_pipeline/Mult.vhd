library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity four_bit_multiplier is Port ( 
    clk_mult: in STD_LOGIC;
    inputA_mult : in  STD_LOGIC_VECTOR (3 downto 0);
    inputB_mult : in  STD_LOGIC_VECTOR (3 downto 0);
    output_mult   : out  STD_LOGIC_VECTOR (7 downto 0));
end four_bit_multiplier;

architecture Behavioral of four_bit_multiplier is

    component Adder4_pipeline is port(
        clk_a4: in std_logic;
        inputA_a4: in std_logic_vector(3 downto 0);
        inputB_a4: in std_logic_vector(3 downto 0);
        cin_a4: in std_logic;
        Sout_a4: out std_logic_vector(3 downto 0);
        Cout_a4: out std_logic );
    end component;

    component mult_cell is port(
        inputA_mc: in std_logic_vector(3 downto 0);
        inputBi_mc: in std_logic;
        output_mc: out std_logic_vector(3 downto 0) );
    end component;

    component reg_generic is
        generic (
            BITS  : integer;
            DELAY : integer );
        port (
            clk_rg    : in  std_logic;
            input_rg  : in  std_logic_vector(BITS-1 downto 0);
            output_rg : out std_logic_vector(BITS-1 downto 0));
    end component;

    type product_array is array(0 to 3) of std_logic_vector(3 downto 0);
    signal p_prod : product_array; -- Partial Products
    
    type sum_array is array(0 to 2) of std_logic_vector(3 downto 0);
    signal s_out : sum_array;      -- Sum outputs from adders
    signal c_out : std_logic_vector(2 downto 0); -- Carry outputs
    
    signal intermediate_sum0 : std_logic_vector(3 downto 0);

    signal p_prod1_delay,p_prod2_delay,p_prod3_delay: std_logic_vector(3 downto 0);
    
    signal inputB1,inputB2 : std_logic_vector(3 downto 0);

begin

    -- 1. Generate Partial Products (ANDing A with each bit of B)
    gen_cells: for i in 0 to 3 generate 
        MultCell_i: mult_cell port map(
            inputA_mc  => inputA_mult,
            inputBi_mc => inputB_mult(i),
            output_mc  => p_prod(i)
        );
    end generate gen_cells;

    -- Prepare the first addition: Shifted first partial product
    intermediate_sum0 <= '0' & p_prod(0)(3 downto 1) ;    
    
    -- ( Each PA has a delay of 4 cycles )

    -- 3. Adder Chain (Shift-and-Add Logic)
    PA0: Adder4_pipeline port map (
        clk_a4    => clk_mult,
        inputA_a4 => p_prod(1),
        inputB_a4 => intermediate_sum0,
        cin_a4    => '0',
        Sout_a4   => s_out(0),
        Cout_a4   => c_out(0)
    );

    -- delay partial product (2) 4 cycles
    Reg_inputB1: reg_generic 
        generic map( BITS => 4, DELAY => 4)
        port map( 
            clk_rg => clk_mult,
            input_rg => p_prod(2),
            output_rg => p_prod2_delay
        );
        

    inputB1 <= c_out(0) & s_out(0)(3 downto 1) ;

    PA1: Adder4_pipeline port map (
        clk_a4    => clk_mult,
        inputA_a4 => p_prod2_delay,
        inputB_a4 => inputB1,
        cin_a4    => '0',
        Sout_a4   => s_out(1),
        Cout_a4   => c_out(1)
    );

    --delay partial product (3) 8 cycles
    Reg_inputB2: reg_generic 
        generic map( BITS => 4, DELAY => 8)
        port map( 
            clk_rg => clk_mult,
            input_rg => p_prod(3),
            output_rg => p_prod3_delay
        );
    
    inputB2 <= c_out(1) & s_out(1)(3 downto 1) ;
    
    PA2: Adder4_pipeline port map (
        clk_a4    => clk_mult,
        inputA_a4 => p_prod3_delay,
        inputB_a4 => inputB2,
        cin_a4    => '0',
        Sout_a4   => s_out(2),
        Cout_a4   => c_out(2)
    );

    -- output_mult(0) <= p_prod(0)(0); with 12 cycles delay
    Reg_Output_MC: reg_generic 
        generic map( BITS => 1, DELAY => 12)
        port map( 
            clk_rg => clk_mult,
            input_rg(0) => p_prod(0)(0),
            output_rg(0) => output_mult(0)
        );

    -- output_mult(1) <= s_out(0)(0); with 8 cycles delay
    Reg_Output_PA0: reg_generic 
        generic map( BITS => 1, DELAY => 8)
        port map( 
            clk_rg => clk_mult,
            input_rg(0) => s_out(0)(0),
            output_rg(0) => output_mult(1)
        );

    -- output_mult(2) <= s_out(1)(0); with 4 cycles delay
    Reg_Output_PA1: reg_generic 
        generic map( BITS => 1, DELAY => 4)
        port map( 
            clk_rg => clk_mult,
            input_rg(0) => s_out(1)(0),
            output_rg(0) => output_mult(2)
        );
    
    -- No delay needed
    output_mult(6 downto 3) <= s_out(2);
    output_mult(7)          <= c_out(2);

end Behavioral;
