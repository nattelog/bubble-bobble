-- Micromemory

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MM is
  Port (adr : in STD_LOGIC_VECTOR(6 downto 0);
        data : out STD_LOGIC_VECTOR(0 to 23))
end MM;

architecture behavioral of MM is
  type memtype is array(0 to 127) of data;

  -- Content of micromemory
  constant mem : memtype := (
    others => X"00"
    );
  
begin

  data <= mem(CONV_INTEGER(adr));
  
end behavioral;
