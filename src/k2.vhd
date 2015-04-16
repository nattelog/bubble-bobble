-- K2-register

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity K2 is
  Port (adr : in STD_LOGIC_VECTOR(1 downto 0);
        data : out STD_LOGIC_VECTOR(6 downto 0))
end K2;

architecture behavioral of K2 is
  type memtype is array(0 to 3) of data;

  -- Content of K2
  constant mem : memtype := (
    X"00",      -- 0x0 : Direct
    X"00",      -- 0x1 : Constant
    X"00",      -- 0x2 : Indirect
    X"00",      -- 0x3 : Indexed
    );
  
begin

  data <= mem(CONV_INTEGER(adr));
  
end behavioral;
