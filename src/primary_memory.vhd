-- Programmemory

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity primary_memory is
  Port (clk, rst, wr : in STD_LOGIC;
        adr : in STD_LOGIC_VECTOR(15 downto 0);
        datain : in STD_LOGIC_VECTOR(31 downto 0);
        dataout : out STD_LOGIC_VECTOR(31 downto 0));
end primary_memory;

architecture behavioral of primary_memory is
  
  type memtype is array(0 to 25) of STD_LOGIC_VECTOR(31 downto 0);
  signal mem : memtype := (
    X"11001100",
    others => X"00000000"
    );
  
begin

  -- write: wr = 1
  -- read: wr = 0

  process (clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        dataout <= (others => '0');
      
      elsif (wr = '1') then
        mem(CONV_INTEGER(adr)) <= datain;

      else
        dataout <= mem(CONV_INTEGER(adr));
        
      end if;
    end if;
  end process;
  
end behavioral;