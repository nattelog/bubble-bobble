library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.all;             

entity uart is
  Port ( clk,rst,rx : in  STD_LOGIC;
	 uart_data_o : out STD_LOGIC_VECTOR (31 downto 0); -- Uart data out
	 uart_line_c : out STD_LOGIC := '0';     -- Uart line complete
	 uart_reading : out STD_LOGIC := '0'     -- Set to one when reading starts
        );
end uart;

architecture behavioral of uart is
  signal sreg : STD_LOGIC_VECTOR(9 downto 0) := B"0_00000000_0";  -- 10 bit shift register
  signal read_line : STD_LOGIC_VECTOR(31 downto 0) := X"00000000";  -- Bitcode line
  signal rx1,rx2 : STD_LOGIC;         -- Flip flops on signal in
  signal sp : STD_LOGIC;              -- Shift pulse
  signal lp : STD_LOGIC;              -- Load pulse
  signal t_pos : STD_LOGIC_VECTOR(1 downto 0) := "00"; -- Current byte on line (32 bits / 8)
  signal wp : STD_LOGIC;              -- Write pulse

  
begin
  
  -- *****************************
  -- * SYNCHRONIZATION FLIP FLOP *
  -- *****************************

  process(clk, rst)
  begin
    if rst = '1' then
      rx1 <= '1';
      rx2 <= '1';
    else
      rx1 <= rx;
      rx2 <= rx1;
    end if;
  end process;
  

  -- *****************************
  -- *       CONTROL UNIT        *
  -- *****************************

  process(clk, rst, rx1 ,rx2)
    variable shift : boolean := false;
    variable clkcnt : integer := 0;
    variable sftcnt : integer := 0;     -- Counts number of bytes in shift register
  begin
    if rising_edge(clk) then
      sp <= '0';
      lp <= '0';
      if rst = '1' then
        lp <= '0';
        sp <= '0';
        shift := false;
        clkcnt := 0;
        sftcnt := 0;
        uart_reading <= '0';
      elsif shift = false then
        if rx1 = '0' then              
          shift := true;              -- Start shifting
	  uart_reading <= '1';
        end if;
      else
        clkcnt := clkcnt + 1;
        if clkcnt = 434 then
          sp <= '1';                    
          sftcnt := sftcnt + 1;
        elsif clkcnt = 868 then
          clkcnt := 0;
        else
          if sftcnt = 10 then         -- Byte read, send load pulse
            lp <= '1';
            clkcnt := 0;
            sftcnt := 0;
            shift := false;
          end if;
        end if;
      end if;
    end if;
  end process;
  
  -- *****************************
  -- *   10 BIT SHIFT REGISTER   *
  -- *****************************

  process(clk, rst, sp, sreg)
  begin 
    if rising_edge(clk) then
      if rst = '1' then
        sreg <= "0000000000";
      elsif sp = '1' then
        sreg <= sreg(8 downto 0) & rx2;
      end if;
    end if;
  end process;

  -- *****************************
  -- *      2 BIT REGISTER       *
  -- *****************************

  process(clk, rst, lp)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        t_pos <= "00";
      elsif lp = '1' then
        t_pos <= t_pos + 1;
      end if;
    end if;
  end process;
  
  -- *****************************
  -- *     16 BIT REGISTER       *
  -- *****************************

  process(clk, rst, lp, t_pos)                           
  begin
    if rising_edge(clk) then        
      if rst = '1' then
        read_line <= X"00000000";
      elsif lp = '1' then
        case t_pos is
          when "00"  => read_line(31 downto 24) <= sreg(8 downto 1);
          when "01"  => read_line(23 downto 16) <= sreg(8 downto 1);
          when "10"  => read_line(15 downto 8) <= sreg(8 downto 1);
          when "11"  => read_line(7 downto 0) <= sreg(8 downto 1); 
          when others => null;
        end case;
      end if;
    end if;
  end process;		  

  -- *********************
  -- *     DATA OUT      *
  -- *********************

  process(clk, rst, lp, t_pos) -- Generate writepulse
  begin
    if rising_edge(clk) then
      if rst = '1' then
        wp <= '0';
      elsif (lp = '1') and (t_pos = "11") then
        wp <= '1';
      else
        wp <= '0';
      end if;
    end if;
  end process;

  process(clk, wp, read_line) -- Set data out
  begin
    if rising_edge(clk) then
      if rst = '1'  then
	uart_line_c <= '0';
	uart_data_o <= X"00000000";
      elsif wp = '1' then
	uart_data_o <= read_line;
	uart_line_c <= '1';
      else
	uart_line_c <= '0';
      end if;
    end if;
  end process;

  end;
