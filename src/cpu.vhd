-- MAIN FILE FOR OUR CPU

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cpu is
    Port ( clk,rst : in  STD_LOGIC;
    	vgaRed : out STD_LOGIC_VECTOR(2 downto 0);
        vgaGreen : out STD_LOGIC_VECTOR(2 downto 0);
    	vgaBlue : out STD_LOGIC_VECTOR(1 downto 0);
    	Hsync : out STD_LOGIC;
    	Vsync : out STD_LOGIC;
    );
end cpu;

architecture behavioral of cpu is
begin

-- *******
-- * CPU *
-- *******



-- ******************
-- * VGA CONTROLLER * 
-- ******************

end behavioral;