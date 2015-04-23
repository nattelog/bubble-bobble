-- The micromemory

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity micro_memory is
  Port (clk, rst : in STD_LOGIC;
        adr : in STD_LOGIC_VECTOR(6 downto 0);
        controlword : out STD_LOGIC_VECTOR(0 to 23));
end micro_memory;

architecture behavioral of micro_memory is

  type mm_t is array(0 to 256) of STD_LOGIC_VECTOR(0 to 23);


  -- Example microinstructions
  --
  --

  constant DR_TB : STD_LOGIC_VECTOR(2 downto 0) := "010";
  
  constant MM : mm_t := (
    "0000" & DR_TB & "00000000000000000",
    others => (others => '0')
    );
  
begin

  process (clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        controlword <= (others => '0');

      else
        controlword <= MM(CONV_INTEGER(adr));

      end if;
    end if;
  end process;

end behavioral;
