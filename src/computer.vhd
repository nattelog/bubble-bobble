-- The main file for our computer

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity computer is
    Port ( clk : in  STD_LOGIC
    );
end computer;

architecture behavioral of computer is
begin

process (clk) begin
	if rising_edge(clk) then
	end if;
end process;

end behavioral;