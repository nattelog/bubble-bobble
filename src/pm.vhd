-- Programmemory

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PM is
  Port (tb, fb : in STD_LOGIC_VECTOR(2 downto 0);
        adr : in STD_LOGIC_VECTOR(15 downto 0);
        datain : in STD_LOGIC_VECTOR(31 downto 0);
        dataout : out STD_LOGIC_VECTOR(31 downto 0))
end PM;

architecture behavioral of PM is
  type memtype is array(0 to 65535) of STD_LOGIC_VECTOR(31 downto 0);
  signal mem : memtype;
begin

  process (clk)
  begin
    if rising_edge(clk) then

      if (fb = "010" and not tb = "010") then
        mem(CONV_INTEGER(adr)) <= datain;

      elsif (not fb = "010" and tb = "010") then
        dataout <= mem(CONV_INTEGER(adr));
        
      end if;
      
    end if;
  end process;
  
end behavioral;
