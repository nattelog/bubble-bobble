-- K2-register

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity k2_register is
  Port (adr : in STD_LOGIC_VECTOR(1 downto 0);
        data : out STD_LOGIC_VECTOR(6 downto 0))
end k2_register;

architecture behavioral of K2 is
  type k2_t is array(0 to 3) of STD_LOGIC_VECTOR(6 downto 0);

  -- Content of K2
  constant k2 : k2_t := (
    X"00",      -- 0x0 : Direct
    X"00",      -- 0x1 : Constant
    X"00",      -- 0x2 : Indirect
    X"00",      -- 0x3 : Indexed
    );
  
begin

  data <= k2(CONV_INTEGER(adr));
  
end behavioral;
