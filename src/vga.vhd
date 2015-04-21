-- The VGA-controller

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 

entity vga is
    Port ( clk,rst : in  STD_LOGIC;
        vgaRed : out STD_LOGIC_VECTOR(2 downto 0);
        vgaGreen : out STD_LOGIC_VECTOR(2 downto 0);
    	vgaBlue : out STD_LOGIC_VECTOR(1 downto 0);
    	Hsync : out STD_LOGIC;
    	Vsync : out STD_LOGIC
    );
end vga;



architecture behavioral of vga is
  component gm
    port( adress : in STD_LOGIC_VECTOR(15 downto 0);
          data : out STD_LOGIC_VECTOR(31 downto 0)
          );
  end component;
  signal a : out STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";
  signal d : in STD_LOGIC_VECTOR(31 downto 0);
  variable countPixel : integer := 0; -- För att kunna dela upp vectorn i gm i 4.
  variable clkCnt : integer := 0; --räknar 0-3 varje klockcykel, för att tima
                                  --med skärm
  variable waitRow : integer := 0; --räknar väntetiden mellan rader
  variable waitCol : integer := 0; --räknar väntetiden efter alla rader
  variable pixelSent : integer := 0; --Räknar pixlar man skickat per rad
  variable RGB : boolean =  true; --är true om vi håller på att ta in/skickar pixlar
  variable rowCnt : integer := 0; -- räknar antal rader vi skrivit
                                
begin
  process(clk) begin   
           if rising_edge(clk) then
             Vsync <= 0 when 50000<waitRow<56400 else 1; 
             if waitCol = 161300 then
               waitCol = 0;
             end if     
             if rowCnt = 480 then
               waitCol++;
             else
               Hsync <= 0 when 64 < waitRow < 444 else 1;
               if RGB = true  and clkCnt = 3 then
                 vgaRed <= d((31-8*countPixel) downto (29-8*countPixel));
                 vgaGreen <= d((28-8*countPixel) downto (26-8*countPixel));
                 vgaBlue <= d((25-8*countPixel) downto (24-8*countPixel));
                 countPixel++;
                 pixelSent++;
                 if a = "1111111111111111" then
                   a = "0000000000000000"
                 endif
                 if countPixel = 4 then -- Vi har hämtat de fyra pixlarna från vectorn 
                   a <= a + "0000000000000001"; --adderar adressen med 1
                   countPixel = 0;
                 end if;
                 
                 if pixelSent = 640 then --Vi har skickar ut 640 pixlar/1 rad
                   RGB = false;
                 end if
                   clkCnt = 0;
               elsif RGB = false then --väntetid mellan rader
                 waitRow++;
                 clkCnt++;
                 if waitRow = 634 then
                   rowCnt++;
                   RGB = true;
                   waitRow = 0;
                 end if
               else -- Vi kan bara skicka ut en pixel var fjärde cykel;
                 clkCnt++;
               end if;
             end if;
             if rst = 1 then -- nollställning
               rowCnt = 0;
               RGB = true;
               pixelSent = 0;
               clkCnt = 0;
               waitRow = 0;
               waitCol = 0;
               countPixel = 0;
               a <= "0000000000000000";
             end if;          
  end process;
  
  gm0: gm port map(a, d);
end behavioral;
