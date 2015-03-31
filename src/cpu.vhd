-- The CPU

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cpu is
  Port (clk,rst : in  STD_LOGIC);
end cpu;

architecture behavioral of cpu is

  -- Main registers for the CPU
  signal buss, IR, ASR : STD_LOGIC_VECTOR(31 downto 0);

  -- Signals from controlword
  signal mPC : STD_LOGIC_VECTOR(6 downto 0);
  signal alu, seq : STD_LOGIC_VECTOR(3 downto 0);
  signal tb, fb : STD_LOGIC_VECTOR(2 downto 0);
  signal p : STD_LOGIC;
  signal lc : STD_LOGIC_VECTOR(1 downto 0);
  signal madr : STD_LOGIC_VECTOR(6 downto 0);

  type controlword is record
    ALU : STD_LOGIC_VECTOR(3 downto 0);
    TB : STD_LOGIC_VECTOR(2 downto 0);
    FB : STD_LOGIC_VECTOR(2 downto 0);
    P : STD_LOGIC;
    LC : STD_LOGIC_VECTOR(1 downto 0);
    SEQ : STD_LOGIC_VECTOR(3 downto 0);
    mADR : STD_LOGIC_VECTOR(6 downto 0);
  end record;

  type programword is record
    OP : STD_LOGIC_VECTOR(3 downto 0);
    GRx : STD_LOGIC_VECTOR(3 downto 0);
    M : STD_LOGIC_VECTOR(1 downto 0);
    pADR : STD_LOGIC_VECTOR(15 downto 0);
  end record;

  -- Type for micromemoryyes
  type mM is array(0 to 127) of controlword;

  -- Type for primary memory
  type pM is array(0 to 65535) of programword;

  -- Type for K-registers
  type kM is array(0 to 15) of STD_LOGIC_VECTOR(6 downto 0);

  -- Type for general registers
  type gR is array(0 to 15) of STD_LOGIC_VECTOR(31 downto 0);

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

  -- ** Controlregister **

  process (clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        mPC <= (others => '0');
      end if;
    end if;
  end process;
  

  -- ** BUSS **
  
  process (clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        buss <= (others => '0');
      end if;
      
    end if;
  end process;
  
  
  -- ** ASR **    

  -- ** Programminne **

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
