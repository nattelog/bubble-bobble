-- The VGA-controller

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity vga_test_new is
    Port ( clk,rst : in  STD_LOGIC;
        vgaRed : out STD_LOGIC_VECTOR(2 downto 0);
        vgaGreen : out STD_LOGIC_VECTOR(2 downto 0);
    	vgaBlue : out STD_LOGIC_VECTOR(2 downto 1);
    	Hsync : out STD_LOGIC;
    	Vsync : out STD_LOGIC
    );
end vga_test_new;

architecture behavioral of vga_test_new is

                                
begin
  process(clk)
    variable clkCnt : integer := 0; --räknar varje klockcykel
    variable clkCntMod : integer := 0; --modar clk för att anpassa till skärm
    variable rowCnt : integer := 0;
    begin
      if rising_edge(clk) then
        --moddar upp clk
        if clkCnt = 3 then
          clkCntMod := clkCntMod+1;
          clkCnt := 0;
        end if;
        if rowCnt < 480 then
        -- kollar om vi skickat ut en rad
          if clkCntMod < 640 then
            vgaRed(2 downto 0) <= "101";
            vgaGreen(2 downto 0) <= "010";
            vgaBlue(2 downto 1) <= "10";
          end if;
          
          if clkCntMod >= 688 and clkCntMod < 784 then
            Hsync <= '0';  
          else
            Hsync <= '1';
          end if;
        end if;
        if clkCntMod = 800 then
          rowCnt := rowCnt + 1;
          clkCntMod := 0;
        end if;

        if rowCnt >= 509 and rowCnt <=511 then
          Vsync <= '0';
        else
          Vsync <= '1';  
        end if;

       if rowCnt = 521 then
         rowCnt := 0;
         clkCntMod := 0;
       end if;

       clkCnt := clkCnt + 1;
      end if;



  end process;
end behavioral;


      
