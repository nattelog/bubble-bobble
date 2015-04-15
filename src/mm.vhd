-- Micromemory

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mm is
  Port (clk : in STD_LOGIC;
        adr : in STD_LOGIC_VECTOR(6 downto 0);
        data : out STD_LOGIC_VECTOR(0 to 23))
end mm;

architecture behavioral of mm is
  type memtype is array(0 to 127) of data;
  constant mem : memtype := (
    others => X"00"
    );
begin

  process (clk)
  begin
    if rising_edge(clk) then
      data <= mem(CONV_INTEGER(adr));
    end if;
  end process;
  
end behavioral;
