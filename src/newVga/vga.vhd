library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 

entity vga is

  port  ( clk,rst : in  STD_LOGIC;
        vga_red : out STD_LOGIC_VECTOR(2 downto 0);
        vga_green : out STD_LOGIC_VECTOR(2 downto 0);
    	   vga_blue : out STD_LOGIC_VECTOR(2 downto 1);
    	   h_sync : out STD_LOGIC;
    	   v_sync : out STD_LOGIC
        );

end vga;

architecture behavioral of vga is

-- ************
-- **  VGA   ** 
-- ************
    type tile_t is array(0 to 15) of STD_LOGIC_VECTOR(0 to 127);
    signal xctr, yctr : integer := 0;                     -- 40 ns per pixel/count
    signal pixel : std_logic_vector (1 downto 0) := "00"; -- Our clock is 100 MHz => Wait 4
    signal hs : std_logic := '1';
    signal vs : std_logic := '1';
    
-- *************
-- ** PLAYER  **    
-- *************

    signal player_move : std_logic_vector ( 1 downto 0) := "00"; -- 00 Still, 10 Left, 01 Right
    signal player_x : integer := 100;
    signal player_y : integer := 430;
    signal sprite_changer : boolean := false;
    signal sprite_changer_delay : integer := 0;
    
    signal tile_player_still : tile_t := (
      "00000000000000000000000000000000000000000000000000000000000000000000000000000000111000000000000000000000000000000000000000000000",
      "00000000000000000000000000000000111000001110000011100000000000000000000011100000111000001110000000000000000000000000000000000000",
      "00000000000000000000000000000000000000001110000011100000111000000001110000011100000111000001110000000000000000000000000000000000",
      "00000000000000000000000000000000000000000000000011100000000111000001110000011100000111000001110000011100000000000000000000000000",
      "00000000000000000000000011100000111000001110000011100000000111000001110011111111000111001111111100011100000111000000000000000000",
      "00000000000000000000000000000000111000001110000000011100000111001111111100000000000111000000000011111111000111000001110000000000",      
      "00000000000000000000000000000000000000000001110000011100000111001111111100000000000111000000000011111111000111000001110000000000",
      "00000000000000000000000011100000111000000001110000011100000111001111111100000000000111000000000011111111000111000001110000000000",
      "00000000000000000000000000000000111000000001110000011100111000001110000011111111000111001111111111100000111000000001110000000000",
      "00000000000000000000000000000000000000000001110000011100000000001110000011100000111111111110000011100000000111000000000000000000",
      "00011100000000000000000000000000000000000001110000011100000000110000000000000000000111000000000000000000000000000000000000000000",
      "00011100000111001110000011100000111000000000001100000011000000110000001100011100000111000001110000011100000111000000000000000000",      
      "00000000000111000001110011100000111000000000001100000011000000110001110000011100000111001111111111111111111111110000000000000000",
      "00000000000000000001110000011100000111000001110000000011000111000001110000011100111111111111111111111111111111111111111100000000",
      "00000000000000000000000000011100000111000001110000011100000111000001110000000011000000111111111111111111111111111111111100000000",
      "00000000000000000000000000000000000111000001110000011100000111000000001100000011000000110000001111111111111111110000001100000011"
    );
    
    signal tile_player_move : tile_t := (
      "00000000000000000000000000000000000000000000000000000000000000000000000000000000111000000000000000000000000000000000000000000000",
      "00000000000000000000000000000000111000001110000011100000000000000000000011100000111000001110000000000000000000000000000000000000",
      "00000000000000000000000000000000000000001110000011100000111000000001110000011100000111000001110000000000000000000000000000000000",
      "00000000000000000000000000000000000000000000000011100000000111000001110000011100000111000001110000011100000000000000000000000000",
      "00000000000000000000000011100000111000001110000011100000000111000001110011111111000111001111111100011100000111000000000000000000",
      "00000000000000000000000000000000111000001110000000011100000111001111111100000000000111000000000011111111000111000001110000000000",
      "00000000000000000000000000000000000000000001110000011100000111001111111100000000000111000000000011111111000111000001110000000000",
      "00000000000000000000000011100000111000000001110000011100000111001111111100000000000111000000000011111111000111000001110000000000",
      "00000000000000000000000000000000111000000001110000011100111000001110000011111111000111001111111111100000111000000001110000000000",
      "00000000000000000000000000000000000000000001110000011100000000001110000011100000111111111110000011100000000111000000000000000000",
      "00000000000000000000000000000000000000000001110000011100000000110000000000000000000111000000000000000000000000000000000000000000",
      "00000000000000001110000011100000111000000000001100000011000000110000001100011100000111000001110000011100000111000000000000000000",
      "00000000000111000001110011100000111000000000001100000011000000110001110000011100000111001111111111111111111111110000000000000000",
      "00011100000111000001110000011100000111000001110000000011000111000001110000011100111111111111111111111111111111111111111100000000",
      "00000000000000000000000000011100000111000001110000011100000111000000001100000011111111111111111111111111111111111111111100000000",
      "00000000000000000000000000000000000111000001110000011100000000110000001100000011000000111111111111111111000000110000001100000000"
      );
    signal tile_bubble : tile_t := (
      "00000000000000000000000000000000001000000010000000100000001000000010000000100000001000000010000000000000000000000000000000000000",
      "00000000000000000000000000100000000000000110000001100000011000000110000001100000011000000110000000100000000000000000000000000000",
      "00000000000000000010000000000000011000000110000001100000011000000110000001100000111000000110000001100000001000000000000000000000",
      "00000000001000000000000001100000011000000110000001100000011000000110000001100000011000001110000001100000011000000010000000000000",
      "00100000000000000110000001100000011000000110000001100000011000000110000001100000111000000110000011100000011000000110000000100000",
      "00100000011000000110000001100000011000000110000001100000011000000110000001100000011000001110000001100000011000000110000000100000",
      "00100000011000000110000001100000011000000110000001100000011000000110000001100000111000000110000011100000011000000110000000100000",
      "00100000011000000110000001100000011000000110000001100000011000000110000001100000011000001110000001100000011000000110000000100000",
      "00100000011000000110000001100000011000000110000001100000011000000110000001100000111000000110000011100000011000000110000000100000",
      "00100000011000000110000001100000011000000110000001100000011000000110000001100000011000001110000001100000011000000110000000100000",
      "00100000011000000110000001100000011000000110000001100000011000000110000001100000111000000110000011100000011000000110000000100000",
      "00100000000000000110000001100000011000000110000001100000011000000110000001100000011000001110000001100000011000000110000000100000",
      "00000000001000000000000001100000011000000110000001100000011000000110000001100000111000000110000001100000011000000010000000000000",
      "00000000000000000010000000000000011000000110000001100000011000000110000001100000011000000110000001100000001000000000000000000000",
      "00000000000000000000000000100000000000000110000001100000011000000110000001100000011000000110000000100000000000000000000000000000",
      "00000000000000000000000000000000001000000010000000100000001000000010000000100000001000000010000000000000000000000000000000000000");      
    
    
-- ************
-- **  GMEM  **
-- ************
    
  
    signal tile_block : tile_t  := (
      "11100000111000001110000011100000111111111111111111111111111111111110000011100000111000001110000011111111111111111111111111111111",
      "11100000111000001110000011111111111111111111111111111111111000001110000011100000111000001111111111111111111111111111111111100000",
      "11100000111000001111111111111111111111111111111111100000111000001110000011100000111111111111111111111111111111111110000011100000",
      "11100000111111111111111111111111111111111110000011100000111000001110000011111111111111111111111111111111111000001110000011100000",
      "11111111111111111111111111111111111000001110000011100000111000001111111111111111111111111111111111100000111000001110000011100000",
      "11111111111111111111111111100000111000001110000011100000111111111111111111111111111111111110000011100000111000001110000011111111",
      "11111111111111111110000011100000111000001110000011111111111111111111111111111111111000001110000011100000111000001111111111111111",
      "11111111111000001110000011100000111000001111111111111111111111111111111111100000111000001110000011100000111111111111111111111111",
      "11100000111000001110000011100000111111111111111111111111111111111110000011100000111000001110000011111111111111111111111111111111",
      "11100000111000001110000011111111111111111111111111111111111000001110000011100000111000001111111111111111111111111111111111100000",
      "11100000111000001111111111111111111111111111111111100000111000001110000011100000111111111111111111111111111111111110000011100000",
      "11100000111111111111111111111111111111111110000011100000111000001110000011111111111111111111111111111111111000001110000011100000",
      "11111111111111111111111111111111111000001110000011100000111000001111111111111111111111111111111111100000111000001110000011100000",
      "11111111111111111111111111100000111000001110000011100000111111111111111111111111111111111110000011100000111000001110000011111111",
      "11111111111111111110000011100000111000001110000011111111111111111111111111111111111000001110000011100000111000001111111111111111",
      "11111111111000001110000011100000111000001111111111111111111111111111111111100000111000001110000011100000111111111111111111111111"
    );
    
    
signal tile_player : tile_t := tile_block;
-- *******************
-- ** SPRITES & MAP **
-- *******************
    
    type map_t is array(0 to 29) of STD_LOGIC_VECTOR(0 to 39);
    signal game_map : map_t := (
    "1111111111111100011111100011111111111111",
    "1111111111111100011111100011111111111111",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1111111111111100000000000011111111111111",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000111111111111111111110000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100011111111000000000000001111111100011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000111111111111111111110000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1111111111111100011111100011111111111111",
    "1111111111111100011111100011111111111111");

begin

  
-- **************
-- **   MUX    **
-- **************
process(clk) begin
  if rising_edge(clk) then
    if sprite_changer = false then
      tile_player <= tile_player_still;
    else
      tile_player <= tile_player_move;
    end if;

    if pixel = 3 then
      sprite_changer_delay <= sprite_changer_delay + 1;
    end if;

    if sprite_changer_delay = 8000 then
      sprite_changer_delay <= 0;
      if sprite_changer = false then
        sprite_changer <= true;
      else
        sprite_changer <= false;
      end if;
    end if;
    
  end if;
end process;

-- **************
-- **   VGA    **
-- **************

process(clk) begin -- Counts clockcycels mod 4
  if rising_edge(clk) then
    if rst='1' then
      pixel <= "00";
    else
      pixel <= pixel + 1;
    end if;
  end if;
end process;

process(clk) begin -- hs
  if rising_edge(clk) then
    if rst = '1' then
      xctr <= 0;
    elsif pixel = 3 then
      if xctr = 799 then
        xctr <= 0;
      else
        xctr <= xctr + 1;
      end if;
    end if;
    --
    if xctr = 656 then
      hs <= '0';
    elsif xctr = 752 then
      hs <= '1';
    end if;
  end if;
end process;

process(clk) begin -- vs
  if rising_edge(clk) then
    if rst='1' then
      yctr <= 0;
    elsif xctr = 799 and pixel = 0 then
      if yctr = 520 then
        yctr <= 0;
      else
        yctr <= yctr + 1;
      end if;
      --
      if yctr = 490 then
        vs <= '0';
      elsif yctr = 492 then
        vs <= '1';
      end if;
    end if;
  end if;
end process;

h_sync <= hs;
v_sync <= vs;

-- *****************
-- **     MAP     **
-- *****************

process(clk) begin
  if rising_edge(clk) then
    if yctr < 479 and xctr < 639 then -- In bounds
      if game_map(yctr/16)(xctr/16) = '1' then -- Map tile
        vga_red <= tile_bubble(yctr mod 16)(((xctr mod 16)*8) to ((xctr mod 16)*8 + 2));
        vga_green <= tile_bubble(yctr mod 16)(((xctr mod 16)*8 + 3) to ((xctr mod 16)*8 + 5));
        vga_blue <= tile_bubble(yctr mod 16)(((xctr mod 16*8) + 6) to ((xctr mod 16)*8+7));
      elsif ((yctr - player_y) > -1) and ((yctr - player_y) < 16) and ((xctr - player_x) > -1) and ((xctr - player_x) < 16) then
        vga_red <= tile_player(yctr - player_y)((xctr - player_x)*8 to ((xctr-player_x)*8+2));
        vga_green <= tile_player(yctr - player_y)(((xctr - player_x)*8 + 3) to (((xctr - player_x)*8 + 5)));
        vga_blue <= tile_player(yctr - player_y)(((xctr - player_x)*8 + 6) to (((xctr - player_x)*8 + 7)));
      else
        vga_red <= "000";
        vga_green <= "000";
        vga_blue <= "00";
      end if;
    else
      vga_red <= "000";
      vga_green <= "000";
      vga_blue <= "00";
    end if;
  end if;
end process;

-- *****************
-- **  ANIMATION  **
-- *****************

--process(clk) begin
--  if rising_edge(clk) then
--    if rst = '1' then
      

end;
