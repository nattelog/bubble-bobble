-- The CPU

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cpu is
    Port (clk,rst : in  STD_LOGIC);
end cpu;

architecture behavioral of cpu is
  signal buss : STD_LOGIC_VECTOR(31 downto 0);
  signal IR : STD_LOGIC_VECTOR(31 downto 0);
  type mem is array(0 to 128) of STD_LOGIC_VECTOR(0 to 24);
begin

-- ** ASR **

-- ** Programminne **

-- ** IR **

-- ** K1 **

-- ** K2 **

-- ** µPC **

-- ** SuMicroPC

-- ** µM **

-- ** Flaggor (Z, N, C, O, L)

-- ** GR **

-- ** RP (registerpekare) **

-- ** ALU **

-- ** AR **

-- ** PC **

end behavioral;
