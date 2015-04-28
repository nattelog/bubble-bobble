-- The VGA-controller
-- Used the timing values on page 7; http://lslwww.epfl.ch/pages/teaching/cours_lsl/ca_es/VGA.pdf
-- This site gives slight different values? http://martin.hinner.info/vga/timing.html ie sync pulse 2

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 

entity vga is

  port  ( clk,rst : in  STD_LOGIC;
        vga_red : out STD_LOGIC_VECTOR(2 downto 0);
        vga_green : out STD_LOGIC_VECTOR(2 downto 0);
    	vga_blue : out STD_LOGIC_VECTOR(1 downto 0);
    	h_sync : out STD_LOGIC;
    	v_sync : out STD_LOGIC
        );

end vga;

architecture behavioral of vga is

-- ************
-- **  VGA   ** 
-- ************

    signal h_count : integer range 0 to 799; -- 40 ns per pixel/count
    signal v_count : integer range 0 to 524; -- 25 MHz has period of 40 ns
    signal clk_timer : integer range 0 to 3; -- Our clock is 100 MHz => Wait 4
                                             -- ticks

-- ************
-- **  GMEM  **
-- ************

    type gm_t is array(0 to 479) of STD_LOGIC_VECTOR(3839 downto 0);
  
    signal vga_mem0 : gm_t := (
      others => (others => '1')
    );

    signal vga_mem1 : gm_t := (
      others => (others => '1')
    );

    signal gmux : std_logic;
    signal read_y : integer range 0 to 639;
    signal read_x : integer range 0 to 479;
    signal pixel : std_logic_vector(7 downto 0);
    signal paint_step : std_logic;

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

process (clk, rst, clk_timer) -- Timer
begin
  if rising_edge(clk) then
    if rst = '1' or clk_timer = 3 then
      clk_timer <= 0;
    else
      clk_timer <= clk_timer + 1;
    end if;
  end if;
end process;

process (clk, rst, h_count, v_count, clk_timer)  -- Counter v_count, h_count
begin
  if rising_edge(clk) then
    if rst = '1' then
      h_count <= 0;
      v_count <= 0;
    elsif v_count < 480 and clk_timer = 3 then
      if h_count < 799 then
        h_count <= h_count + 1;
      else
        h_count <= 0;
	v_count <= v_count + 1;
      end if;
    elsif v_count = 524 and clk_timer = 3 then
	v_count <= 0;
    elsif clk_timer = 3 then
        v_count <= v_count + 1;
    end if;
  end if;
end process;

process (clk, rst, h_count) -- Generate horizontal sync pulse
begin
  if rising_edge(clk) then
    if rst = '1' then
      h_sync <= '0';
    elsif h_count = 658 and clk_timer = 3 then
      h_sync <= '1';
    elsif h_count = 754 and clk_timer = 3 then
      h_sync <= '0';
    end if;
  end if;
end process;

process (clk, rst, v_count) -- Generate vertical sync pulse
begin
  if rising_edge(clk) then
    if rst = '1' then
      v_sync <= '0';
    elsif v_count = 493 and clk_timer = 3 then
      v_sync <= '1';
    elsif v_count = 494 and clk_timer = 3 then
      v_sync <= '0';
    end if;
  end if;
end process;

process(clk, rst)
begin
  if rising_edge(clk) then
    if rst = '1' then
      vga_red <= "000";
      vga_green <= "000";
      vga_blue <= "00";
    elsif v_count < 479 and h_count < 639 and clk_timer = 3 then
      vga_red <= pixel(7 downto 5);
      vga_green <= pixel(4 downto 2);
      vga_blue <= pixel(1 downto 0);
    end if;
  end if;
end process;


-- **************
-- **   GMEM   **
-- **************

process(clk, rst, gmux, read_x, read_y) -- Set pixel
begin
  if rising_edge(clk) then
    if rst = '1' then
      gmux <= '0';
    elsif gmux <= '0' and h_count < 639 and v_count < 439 and clk_timer = 0 then
      pixel <= vga_mem0(v_count)(h_count+7 downto 0);
    elsif gmux <= '1' and h_count < 639 and v_count < 439 and clk_timer = 0 then
      pixel <= vga_mem1(v_count)(h_count+7 downto 0);
    elsif h_count > 639 or v_count > 439 then
      pixel <= "00000000";
    end if;
  end if;
end process;

process(clk, rst, gmux) -- Paint map
  variable y : integer := 0;
  variable x : integer := 0;
begin
  if rising_edge(clk) then
    if rst = '1' then   
    --  vga_mem0 <= others => (others => '1');
     -- vga_mem1 <= others => (others => '1');
    else if paint_step = '0' then
      if game_map(y/16)(x/16) = '1' then
        if gmux = '1' then
          vga_mem0(y to y+15)(x+15 downto x) <= X"FFFF";
        else
          vga_mem1(y to y+15)(x+15 downto x) <= X"FFFF";
        end if;
      else
        if gmux = 1 then
          vga_mem0(y to y+15)(x+15 downto x) <= X"0000";
        else
          vga_mem1(y to y+15)(x+15 downto x) <= X"0000";
        end if;
      end if;
    end if;
  end if;
end;