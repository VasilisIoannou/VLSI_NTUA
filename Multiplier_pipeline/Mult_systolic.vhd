library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity four_bit_multiplier is Port ( 
    clk_mult: in STD_LOGIC;
    inputA_mult : in  STD_LOGIC_VECTOR (3 downto 0);
    inputB_mult : in  STD_LOGIC_VECTOR (3 downto 0);
    output_mult   : out  STD_LOGIC_VECTOR (7 downto 0));
end four_bit_multiplier;


architecture mult4_systolic of four_bit_multiplier is

    component systolic_pe is port (
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


    type arr_outA is array(0 to 3) of std_logic_vector(3 downto 0);
    signal outA : arr_outA; -- Partial Products
    
    type arr_outB is array(0 to 3) of std_logic_vector(3 downto 0);
    signal outB : arr_outB; -- Partial Products
    
    type arr_outS is array(0 to 3) of std_logic_vector(3 downto 0);
    signal outS : arr_outS; -- Partial Products
    
    type arr_outC is array(0 to 3) of std_logic_vector(3 downto 0);
    signal outC : arr_outC; -- Partial Products

    signal inputA_delay,inputB_delay: std_logic_vector(3 downto 0);
    signal C_delay: std_logic_vector(3 downto 0);

begin

    gen_matrix: for i in 0 to 3 generate
        gen_row: for j in 0 to 3 generate
            signal local_inA, local_inB, local_inS, local_inC : std_logic;
        begin
            -- Handle Input A (Top-down flow)
            top_row: if i = 0 generate
                local_inA <= inputA_delay(j);
            end generate top_row;

            other_rows: if i > 0 generate
                local_inA <= outA(i-1)(j);
            end generate other_rows;

            -- Handle Input B (Left-to-right flow)
            left_col: if j = 0 generate
                local_inB <= inputB_delay(i);
                local_inC <= '0'; -- Initial carry is 0
            end generate left_col;

            other_cols: if j > 0 generate
                local_inB <= outB(i)(j-1);
                local_inC <= outC(i)(j-1);
            end generate other_cols;

            -- Handle Sum (Diagonal flow)
            -- Each row is shifted relative to the previous one
            sum_top: if i = 0 generate
                local_inS <= '0';
            end generate sum_top;
            sum_other: if i > 0 generate
                sum_edge: if j = 3 generate
                    local_inS <= c_delay(i-1);
                end generate sum_edge;
                sum_internal: if j < 3 generate
                    local_inS <= outS(i-1)(j+1);
                end generate sum_internal;
            end generate sum_other;

            SPE_ij: systolic_pe port map(
                clk_spe  => clk_mult,
                inA_spe  => local_inA,
                inB_spe  => local_inB, 
                inS_spe  => local_inS,   
                inC_spe  => local_inC,
                outA_spe => outA(i)(j),
                outB_spe => outB(i)(j),
                outS_spe => outS(i)(j),
                outC_spe => outC(i)(j)
            );
        end generate gen_row;
    end generate gen_matrix;

    gen_registers_output_2: for k in 4 to 5 generate
    begin
        Reg_Pk: reg_generic 
            generic map( 
                BITS  => 1, 
                DELAY => 6 - k )
            port map( 
                clk_rg    => clk_mult,
                input_rg(0)  => outS(3)(k-3), 
                output_rg(0) => output_mult(k)
            );
    end generate gen_registers_output_2; 

    gen_registers_output_1: for k in 0 to 3 generate
    begin
        Reg_Pk: reg_generic 
            generic map( 
                BITS  => 1, 
                DELAY => 9 - k*2)
            port map( 
                clk_rg    => clk_mult,
                input_rg(0)  => outS(k)(0), 
                output_rg(0) => output_mult(k)
            );
    end generate gen_registers_output_1; 

    gen_registers_input_A: for k in 1 to 3 generate
    begin
        Reg_Pk: reg_generic 
            generic map( 
                BITS  => 1, 
                DELAY => k 
            )
            port map( 
                clk_rg    => clk_mult,
                input_rg(0)  => inputA_mult(k), 
                output_rg(0) => inputA_delay(k)
            );
    end generate gen_registers_input_A; 

    gen_registers_input_B: for k in 1 to 3 generate
    begin
        Reg_Pk: reg_generic 
            generic map( 
                BITS  => 1, 
                DELAY => k*2
            )
            port map( 
                clk_rg    => clk_mult,
                input_rg(0)  => inputB_mult(k), 
                output_rg(0) => inputB_delay(k)
            );
    end generate gen_registers_input_B;

    inputA_delay(0) <= inputA_mult(0);
    inputB_delay(0) <= inputB_mult(0);
    
    output_mult(6) <= outS(3)(3);
    output_mult(7) <= outC(3)(3);

    c_del: process(clk_mult)
    begin
        if rising_edge(clk_mult) then
            C_delay(0) <= outC(0)(3);
            C_delay(1) <= outC(1)(3);
            C_delay(2) <= outC(2)(3);
            C_delay(3) <= outC(3)(3);
        end if;  
    end process;

    

end mult4_systolic;