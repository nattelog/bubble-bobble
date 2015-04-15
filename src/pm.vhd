library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pm is
  Port (we, re : in STD_LOGIC;
        asr : in STD_LOGIC_VECTOR(15 downto 0);
        datain : in STD_LOGIC_VECTOR(31 downto 0);
        dataout : out STD_LOGIC_VECTOR(31 downto 0))
end pm;

architecture behavioral of pm is
  type memtype is array(0 to 65535) of STD_LOGIC_VECTOR(31 downto 0);
  signal mem : memtype;
begin

  if (we = '1' and re = '0') then
    mem(CONV_INTEGER(asr)) <= datain;

  elsif (we = '0' and re = '1') then
    dataout <= mem(CONV_INTEGER(asr));
    
  end if;
  
end behavioral;
