-- The micromemory

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity micro_memory is
  Port (clk : in STD_LOGIC;
        adr : in STD_LOGIC_VECTOR(6 downto 0);
        controlword : out STD_LOGIC_VECTOR(0 to 23));
end micro_memory;

architecture behavioral of micro_memory is

  type mm_t is array(0 to 127) of STD_LOGIC_VECTOR(0 to 23);
  
  constant MM : mm_t := (
    X"111000",
    others => X"000000"
    );
  
begin

  process (clk)
  begin
    if rising_edge(clk) then
      controlword <= MM(CONV_INTEGER(adr));
    end if;
  end process;

end behavioral;
