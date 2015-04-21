-- Programmemory

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity primary_memory is
  Port (wr : in STD_LOGIC;
        adr : in STD_LOGIC_VECTOR(15 downto 0);
        datain : in STD_LOGIC_VECTOR(31 downto 0);
        dataout : out STD_LOGIC_VECTOR(31 downto 0));
end primary_memory;

architecture behavioral of primary_memory is
  
  type memtype is array(0 to 65535) of STD_LOGIC_VECTOR(31 downto 0);
  constant mem : memtype := (
    X"11001100",
    X"00110011",
    others => X"00000000"
    );
  
begin

  -- write: wr = 1
  -- read: wr = 0
  
  --mem(CONV_INTEGER(adr)) <= datain when wr = '1';

  dataout <= mem(CONV_INTEGER(adr)) when wr = '0';
  
end behavioral;