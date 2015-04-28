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
      read_x <= 0;
      read_y <= 0;
    else
      read_byte <= read_mem(read_y)(7 + read_x * 8 downto read_x * 8); 
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
