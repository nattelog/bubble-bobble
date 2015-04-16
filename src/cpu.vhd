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

  -- Signal that is high when assembly is being written to programmemory
  signal burn : STD_LOGIC;

  -- Main registers for the CPU
  signal BUSS, IR, PM, GRx, AR : STD_LOGIC_VECTOR(31 downto 0);
  signal ASR, PC : STD_LOGIC_VECTOR(15 downto 0);

  -- General registers
  component GR is
    port (clk, rst : in STD_LOGIC;
          tb, fb : in STD_LOGIC_VECTOR(2 downto 0);
          adr : in STD_LOGIC_VECTOR(3 downto 0);
          datain : in STD_LOGIC_VECTOR(31 downto 0);
          dataout : out STD_LOGIC_VECTOR(31 downto 0));
  end component;

  -- ALU
  component ALU is
    port (clk, rst : in STD_LOGIC;
          operation : in STD_LOGIC_VECTOR(0 to 3);
          buss, arin : in STD_LOGIC_VECTOR(31 downto 0);
          arout : out STD_LOGIC_VECTOR(31 downto 0);
          flags : out STD_LOGIC_VECTOR(4 downto 0));
  end component;

  -- Flags
  signal FLAGS : STD_LOGIC_VECTOR(4 downto 0);

  alias Z : STD_LOGIC is flags(4);
  alias N : STD_LOGIC is flags(3);
  alias C : STD_LOGIC is flags(2);
  alias O : STD_LOGIC is flags(1);
  alias L : STD_LOGIC is flags(0);

  -- Loopcounter
  signal lc : STD_LOGIC_VECTOR(7 downto 0);

  -- Programmemory
  component pm is
    port (tb, fb : in STD_LOGIC_VECTOR(2 downto 0);
          adr : in STD_LOGIC_VECTOR(15 downto 0);
          datain : in STD_LOGIC_VECTOR(31 downto 0);
          dataout : out STD_LOGIC_VECTOR(31 downto 0));
  end component;

  -- Signals from programword
  alias op : STD_LOGIC_VECTOR(3 downto 0) is PM(31 downto 28);
  alias grx : STD_LOGIC_VECTOR(3 downto 0) is PM(27 downto 24);
  alias m : STD_LOGIC_VECTOR(1 downto 0) is PM(23 downto 22);
  alias padr : STD_LOGIC_VECTOR(15 downto 0) is PM(15 downto 0);
  
  -- Micromemory
  signal controlword : STD_LOGIC_VECTOR(0 to 23);
  signal mPC : STD_LOGIC_VECTOR(6 downto 0);
  component mm is
    port (clk : in STD_LOGIC;
          adr : in STD_LOGIC_VECTOR(6 downto 0);
          data : out STD_LOGIC_VECTOR(0 to 23));
  end component;

  -- Signals from controlword
  alias alu : STD_LOGIC_VECTOR(3 downto 0) is controlword(0 to 3);
  alias tb : STD_LOGIC_VECTOR(2 downto 0) is controlword(4 to 6);
  alias fb : STD_LOGIC_VECTOR(2 downto 0) is controlword(7 to 9);
  alias p : STD_LOGIC is controlword(10);
  alias lc : STD_LOGIC_VECTOR(1 downto 0) is controlword(11 to 12);
  alias seq : STD_LOGIC_VECTOR(3 downto 0) is controlword(13 to 16);
  alias madr : STD_LOGIC_VECTOR(6 downto 0) is controlword(17 to 23);

  type kM is array(0 to 15) of STD_LOGIC_VECTOR(6 downto 0); -- K-registers
  signal k1, k2 : STD_LOGIC_VECTOR(6 downto 0);
  
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

  -- ***********
  -- ** RESET **
  -- ***********

  process (clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then

        -- reset BUSS
        BUSS <= (others => '0');

        -- reset flags
        flags <= (others => '0');

        -- reset main registers
        ASR <= (others => '0');
        PM <= (others => '0');
        IR <= (others => '0');
        PC <= (others => '0');
        AR <= (others => '0');
        GRx <= (others => '0');
        -- the entire gr-memory is reset in gr.vhd
        
        -- reset micromemory
        mPC <= (others => '0');
        controlword <= (others => '0');

        -- reset K-registers
        k1 <= (others => '0');
        k2 <= (others => '0');

      end if;
    end if;
  end process;

  -- ** Programmemory **

  pm port map (tb, fb, ASR, PM, PM);

  -- ** GR **

  GR port map (clk, rst, tb, fb, grx, GRx, GRx);

    -- ** Micromemory **

  mm port map (clk, mPC, controlword);

  -- ** UART **

  

  -- ** K-registers **

  k1 <= K1(CONV_INTEGER(op));
  k2 <= K2(CONV_INTEGER(m));

  -- *******************
  -- ** CONTROL LOGIC **
  -- *******************

  -- Controlword has 24 bits
  -- 0 1 2 3 -  4 5 6 - 7 8 9 - 10 - 11 12 - 13 14 15 16 - 17 18 19 20 21 22 23
  --   alu       tb       fb     p    lc         seq              madr

  -- ALU

  ALU port map (clk, rst, alu, BUSS, AR, AR, flags);

  -- ** BUSS LOGIC **
  
  -- to bus

  if (burn = '0') then
  
    case tb is

      -- read from IR
      when "001" =>
        BUSS <= IR;

      -- read from PM
      when "010" =>
        BUSS <= PM;

      -- read from PC 
      when "011" =>
        BUSS(31 downto 16) <= (others => '0');
        BUSS(15 downto 0) <= PC;

      -- read from AR  
      when "100" =>
        BUSS <= AR;

      -- read from GRx
      when "110" =>
        BUSS <= GRx;

      -- do nothing
      when others =>
        BUSS <= (others => '0');
        
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
        BUSS <= (others => '0');
        
    end case;

  end if;
  

end behavioral;
