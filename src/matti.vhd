-- The VGA-controller
-- Used the timing values on page 7; http://lslwww.epfl.ch/pages/teaching/cours_lsl/ca_es/VGA.pdf
-- This site gives slight different values? http://martin.hinner.info/vga/timing.html ie sync pulse 2

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 

entity matti is

  port  ( clk,rst : in  STD_LOGIC;
        vga_red : out STD_LOGIC_VECTOR(2 downto 0);
        vga_green : out STD_LOGIC_VECTOR(2 downto 0);
    	   vga_blue : out STD_LOGIC_VECTOR(1 downto 0);
    	   h_sync : out STD_LOGIC;
    	   v_sync : out STD_LOGIC
        );

end matti;

architecture behavioral of matti is

-- ************
-- **  VGA   ** 
-- ************

    signal xctr, yctr : std_logic_vector(9 downto 0) := "0000000000";-- 40 ns per pixel/count
    signal pixel : std_logic_vector (1 downto 0) := "00"; -- Our clock is 100 MHz => Wait 4
    signal hs : std_logic := '1';
    signal vs : std_logic := '1';
    
-- ************
-- **  GMEM  **
-- ************

    type gm_t is array(0 to 479) of STD_LOGIC_VECTOR(3839 downto 0);
  
    type tile_t is array(0 to 15) of STD_LOGIC_VECTOR(15 downto 0);
    
    signal vga_mem0 : gm_t := (
      others => (others => '1')
    );

    signal vga_mem1 : gm_t := (
      others => (others => '1')
    );
    
    signal write_mem : gm_t := (
      others => (others => '1')
    );
    
    signal read_mem : gm_t  := (
      others => (others => '1')
    );
    
    signal tile_mem : tile_t  := (
      others => (others => '1')
    );
    
    signal tile_block : tile_t  := (
      others => (others => '0')
    );

    signal g_mux : std_logic;
    signal read_y : std_logic_vector(9 downto 0);
    signal read_x : std_logic_vector(9 downto 0);
    signal read_byte : std_logic_vector(7 downto 0);
    signal write_y : integer range 0 to 639;
    signal write_x : integer range 0 to 479;
    signal write_byte : std_logic_vector(7 downto 0);
    signal paint_step : std_logic;
    
    signal x_pos : integer range 0 to 639;
    signal y_pos : integer range 0 to 479;
    

-- *******************
-- ** SPRITES & MAP **
-- *******************
    type map_t is array(0 to 29) of STD_LOGIC_VECTOR(39 downto 0);
    signal game_map : map_t := (
    "1111111111111110001111111000111111111111",
    "1111111111111110001111111000111111111111",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1100000000000000000000000000000000000011",
    "1111111111111110001111111000111111110111",
    "1111111111111110001111111000111111110111");

begin

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
      xctr <= "0000000000";
    elsif pixel = 3 then
      if xctr = 799 then
        xctr <= "0000000000";
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
      yctr <= "0000000000";
    elsif xctr = 799 and pixel = 0 then
      if yctr = 520 then
        yctr <= "0000000000";
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

process(clk) begin
  if yctr < 100 and xctr < 100 and pixel = 3 then
    read_x <= xctr;
    read_y <= yctr;
  end if;
end process;

process(clk) begin -- Byte out
  if rising_edge(clk) then
    if pixel = 3 then
      if yctr < 480 and xctr < 640 then
        vga_red <= read_byte(7 downto 5);
        vga_green <= read_byte(4 downto 2);
        vga_blue <= read_byte(1 downto 0);
      else
        vga_red <= "000";
        vga_green <= "000";
        vga_blue <= "00";
      end if;
    end if;
  end if;
end process;

-- **************
-- **   GMEM   **
-- **************

process(clk, rst, g_mux) -- Mux memory
begin
  if rising_edge(clk) then
    if rst = '1' then
      -- reset
    elsif g_mux = '0' then
      read_mem <= vga_mem0;
      vga_mem1 <= write_mem;
    elsif g_mux = '1' then
      read_mem <= vga_mem1;
      vga_mem0 <= write_mem;
    end if;
  end if;
end process;

process(clk, rst, read_x, read_y) -- Read byte on coordinate
begin
  if rising_edge(clk) then
    if rst = '1' then
      read_byte <= "00000000";
    else
      read_byte <= read_mem(conv_integer(read_y))(7 + conv_integer(read_x) * 8 downto conv_integer(read_x) * 8); 
    end if;
  end if;
end process;

process(clk, rst, write_x, write_y, write_byte) -- Write byte on coordinate
begin
  if rising_edge(clk) then
    if rst = '1' then
      write_byte <= X"FF";
    else
      write_mem(write_y)(7 + write_x * 8 downto write_x * 8) <= write_byte;
    end if;
  end if;
end process;

process(clk, rst, x_pos, y_pos, tile_mem) -- Write tile on position
variable x : integer := 0;
variable y : integer := 0;
begin
  if rising_edge(clk) then
    if rst='1' then
      -- reset
    else
      write_byte <= tile_mem(y)(7 + 8*x downto x*8);
      write_x <= x_pos + x;
      write_y <= y_pos + y;
      if x < 16 then
        x := x + 1;
      elsif y < 16 then
        x := 0;
        y := y + 1;
      else
        x := 0;
        y := 0;
      end if;
    end if;
  end if;
end process; 
      
end;
