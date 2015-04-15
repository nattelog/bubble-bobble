-- General registers

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity gr is
  Port (tb, fb : in STD_LOGIC_VECTOR(2 downto 0);
        adr : in STD_LOGIC_VECTOR(3 downto 0);
        datain : in STD_LOGIC_VECTOR(31 downto 0);
        dataout : out STD_LOGIC_VECTOR(31 downto 0))
end gr;

architecture behavioral of gr is
  type memtype is array(0 to 15) of STD_LOGIC_VECTOR(31 downto 0);
  signal mem : memtype;
begin

  if (fb = "110" and not tb = "110") then
    mem(CONV_INTEGER(adr)) <= datain;

  elsif (not fb = "110" and tb = "110") then
    dataout <= mem(CONV_INTEGER(adr));
    
  end if;
  
end behavioral;
