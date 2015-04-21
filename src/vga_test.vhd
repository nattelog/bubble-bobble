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
  
  variable clkCnt : integer := 0; --räknar 0-3 varje klockcykel, för att tima
                                 --med skärm
  variable waitRow : integer := 0; --räknar väntetiden mellan rader
  variable waitCol : integer := 0; --räknar väntetiden efter alla rader
  variable pixelSent : integer := 0; --Räknar pixlar man skickat per rad
  variable RGB : boolean :=  true; --är true om vi håller på att ta in/skickar pixlar
  variable rowCnt : integer := 0; -- räknar antal rader vi skrivit
                                
begin
  process(clk) begin   
         if rising_edge(clk) then
           if waitCol < 56400 and waitCol > 50000 then
             Vsync <= '0';
           else
             Vsync <= '1';
           end if;
           if waitCol = 161300 then
             waitCol := 0;
           end if;     
           if rowCnt = 480 then
             waitCol:=waitCol+1;
           else
             if waitRow < 444 and waitRow > 64 then
               Hsync <= '0';
             else
               Hsync <= '1';
             end if;
             if (RGB = true  and clkCnt = 3) then
               vgaRed <= "101";
               vgaGreen <= "010";
               vgaBlue <= "11";
               pixelSent:=pixelSent+1;
               if pixelSent = 640 then --Vi har skickar ut 640 pixlar/1 rad
                 RGB := false;
               end if;
               clkCnt := 0;
             elsif RGB = false then --väntetid mellan rader
               waitRow:=waitRow+1;
               clkCnt:=clkCnt+1;
               if waitRow = 634 then
                 rowCnt:=rowCnt+1;
                 RGB := true;
                 waitRow := 0;
               end if;
             else -- Vi kan bara skicka ut en pixel var fjärde cykel;
               clkCnt:=clkCnt+1;
             end if;
           end if;
           if rst = '1' then -- nollställning
             rowCnt := 0;
             RGB := true;
             pixelSent := 0;
             clkCnt := 0;
             waitRow := 0;
             waitCol := 0;
           end if;
         end if;      
  end process;
end behavioral;
