library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- The Idea Here is that each cell holds 4 bits:
-- A3*Bi A2*Bi A1*Bi A0*Bi

entity mult_cell is port(
    inputA_mc: in std_logic_vector(3 downto 0);
    inputBi_mc: in std_logic;
    output_mc: out std_logic_vector(3 downto 0) );
end mult_cell;

architecture mult_cell_arch of mult_cell is
begin
   output_mc <= (inputA_mc(3) AND inputBi_mc) & 
                 (inputA_mc(2) AND inputBi_mc) & 
                 (inputA_mc(1) AND inputBi_mc) & 
                 (inputA_mc(0) AND inputBi_mc);
end mult_cell_arch;
