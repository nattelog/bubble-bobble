-- The CPU
-- This architecture follows the same architecture as in
-- Lab 1 in the course TSEA83, except for some modifications.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cpu is
  Port (clk,rst : in STD_LOGIC);
end cpu;

architecture behavioral of cpu is

  -- Main registers for the CPU
  signal BUSS, IR, PM, GRx, AR : STD_LOGIC_VECTOR(31 downto 0);
  signal ASR, PC : STD_LOGIC_VECTOR(15 downto 0);

  type gR is array(0 to 15) of GRx; -- General registers

  -- Programmemory
  signal we, re : STD_LOGIC;
  component pm is
    port (we, re : in STD_LOGIC;
          adr : in STD_LOGIC_VECTOR(15 downto 0);
          datain : in STD_LOGIC_VECTOR(31 downto 0);
          dataout : out STD_LOGIC_VECTOR(31 downto 0));
  end component;

  -- Micromemory
  signal controlword : STD_LOGIC_VECTOR(0 to 23);
  signal mPC : STD_LOGIC_VECTOR(6 downto 0);
  component mm is
    port (clk : in STD_LOGIC;
          adr : in STD_LOGIC_VECTOR(6 downto 0);
          data : out STD_LOGIC_VECTOR(0 to 23));
  end component;

  -- Signals from programword
  alias op : STD_LOGIC_VECTOR(3 downto 0) is PM(31 downto 28);
  alias grx : STD_LOGIC_VECTOR(3 downto 0) is PM(27 downto 24);
  alias m : STD_LOGIC_VECTOR(1 downto 0) is PM(23 downto 22);
  alias padr : STD_LOGIC_VECTOR(15 downto 0) is PM(15 downto 0);

  -- Signals from controlword
  alias alu : STD_LOGIC_VECTOR(3 downto 0) is controlword(0 to 3);
  alias tb : STD_LOGIC_VECTOR(2 downto 0) is controlword(4 to 6);
  alias fb : STD_LOGIC_VECTOR(2 downto 0) is controlword(7 to 9);
  alias p : STD_LOGIC is controlword(10);
  alias lc : STD_LOGIC_VECTOR(1 downto 0) is controlword(11 to 12);
  alias seq : STD_LOGIC_VECTOR(3 downto 0) is controlword(13 to 16);
  alias madr : STD_LOGIC_VECTOR(6 downto 0) is controlword(17 to 23);

  type kM is array(0 to 15) of STD_LOGIC_VECTOR(6 downto 0); -- K-registers
  
  -- K1
  constant K1 : kM := (
    X"00",      -- 0x0 : LDA
    X"00",      -- 0x1 : STR
    X"00",      -- 0x2 : ADD
    X"00",      -- 0x3 : SUB
    X"00",      -- 0x4 : CMP
    X"00",      -- 0x5 : AND
    X"00",      -- 0x6 : OR
    X"00",      -- 0x7 : LSR
    X"00",      -- 0x8 : LSL
    X"00",      -- 0x9 : BRA
    X"00",      -- 0xa : BRG
    X"00",      -- 0xb : BNE
    X"00",      -- 0xc : BRE
    X"00",      -- 0xd : BRC
    X"00",      -- 0xe : JSR
    X"00"       -- 0xf : RTS
    );

  -- K2
  constant K2 : kM := (
    X"00",      -- 0x0 : Direct
    X"00",      -- 0x1 : Constant
    X"00",      -- 0x2 : Indirect
    X"00",      -- 0x3 : Indexed
    others => X"00"
    );
  
begin

  -- ** BUSS  **

  process (clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        BUSS <= (others => '0');
      end if;
    end if;
  end process;

  -- to bus
  case tb is

    -- read from IR
    when "001" =>
      BUSS <= IR;

    -- read from PM
    when "010" =>
      BUSS <= PM;

    -- read from PC 
    when "011" =>
      BUSS(31 downto 0) <= (others => '0');
      BUSS(15 downto 0) <= PC;

    -- read from AR  
    when "100" =>
      BUSS <= AR;

    -- read from GRx
    when "110" =>
      BUSS <= GRx;

    -- do nothing
    when others =>
      
  end case;

  -- from bus
  case fb is

    -- write to IR
    when "001" =>
      IR <= BUSS;

    -- write to PM
    when "010" =>
      PM <= BUSS;

    -- write to PC
    when "011" =>
      PC <= BUSS(15 downto 0);

    -- write to GRx
    when "110" =>
      GRx <= BUSS;

    -- write to ASR
    when "111" =>
      ASR <= BUSS(15 downto 0);

    -- do nothing
    when others =>  
    
  end case;

  -- ** Micromemory **

  mm port map (clk, mPC, controlword);

  -- ** Programmemory **

  process (clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        ASR <= (others => '0');
        PM <= (others => '0');

      else
        
        
      end if;
    end if;
  end process;

  pm port map (we, re, ASR, PM, PM);

  -- ** IR **

  -- ** µPC **

  -- ** SuPC

  -- ** Flaggor (Z, N, C, O, L)

  -- ** GR **

  -- ** RP (registerpekare) **

  -- ** ALU **

  -- ** AR **

  -- ** PC **

end behavioral;
