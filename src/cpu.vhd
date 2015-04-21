-- The CPU
-- This architecture follows the same architecture as in
-- Lab 1 in the course TSEA83, except for some modifications.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CPU is
  Port (clk,rst : in STD_LOGIC);
end CPU;

architecture behavioral of CPU is

  -- Signal that is high when assembly is being written to programmemory
  --signal burn : STD_LOGIC;

  -- Main registers for the CPU
  signal BUSS, IR, PR, GRx, AR : STD_LOGIC_VECTOR(31 downto 0);
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

  -- Programmemory
  component PM is
    port (tb, fb : in STD_LOGIC_VECTOR(2 downto 0);
          adr : in STD_LOGIC_VECTOR(15 downto 0);
          datain : in STD_LOGIC_VECTOR(31 downto 0);
          dataout : out STD_LOGIC_VECTOR(31 downto 0));
  end component;

  -- Controlunit
  component CU is
    Port (clk, rst : in STD_LOGIC;
        FLAGS : in STD_LOGIC_VECTOR(4 downto 0);
        IR, BUSS : in STD_LOGIC_VECTOR(31 downto 0);
        PC : out STD_LOGIC_VECTOR(15 downto 0);
        controlword : out STD_LOGIC_VECTOR(0 to 23));
  end component;

  -- Flags
  signal FLAGS : STD_LOGIC_VECTOR(4 downto 0);

  alias Z : STD_LOGIC is flags(4);
  alias N : STD_LOGIC is flags(3);
  alias C : STD_LOGIC is flags(2);
  alias O : STD_LOGIC is flags(1);
  alias L : STD_LOGIC is flags(0);

  -- Signals from programword
  --alias op : STD_LOGIC_VECTOR(3 downto 0) is PM(31 downto 28);
  alias gradr : STD_LOGIC_VECTOR(3 downto 0) is PR(27 downto 24);
  --alias m : STD_LOGIC_VECTOR(1 downto 0) is PM(23 downto 22);
  --alias padr : STD_LOGIC_VECTOR(15 downto 0) is PM(15 downto 0);
  
  -- Micromemory
  signal controlword : STD_LOGIC_VECTOR(0 to 23);

  -- Signals from controlword
  alias operation : STD_LOGIC_VECTOR(3 downto 0) is controlword(0 to 3);
  alias tb : STD_LOGIC_VECTOR(2 downto 0) is controlword(4 to 6);
  alias fb : STD_LOGIC_VECTOR(2 downto 0) is controlword(7 to 9);
  --alias p : STD_LOGIC is controlword(10);
  --alias lc : STD_LOGIC_VECTOR(1 downto 0) is controlword(11 to 12);
  --alias seq : STD_LOGIC_VECTOR(3 downto 0) is controlword(13 to 16);
  --alias madr : STD_LOGIC_VECTOR(6 downto 0) is controlword(17 to 23);
  
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
        PR <= (others => '0');
        IR <= (others => '0');
        PC <= (others => '0');
        AR <= (others => '0');
        GRADR <= (others => '0');
        -- the entire gr-memory is reset in gr.vhd
        
        -- reset micromemory
        controlword <= (others => '0');
        
      end if;
    end if;
  end process;

  -- Programmemory

  primary_memory: PM port map (tb, fb, ASR, PR, PR);

  -- General registers

  general_reqisters: GR port map (clk, rst, tb, fb, gradr, GRx, GRx);

  -- Controlunit

  control_unit: CU port map (clk, rst, flags, IR, BUSS, PC, controlword);

  -- ALU

  arithmetic_logic_unit: ALU port map (clk, rst, operation, BUSS, AR, AR, flags);

  -- UART

  

  -- ** BUSS LOGIC **
  
  -- to bus

  process (clk)
  begin

    if rising_edge(clk) then
  
      case tb is

        -- read from IR
        when "001" =>
          BUSS <= IR;

        -- read from PM
        when "010" =>
          BUSS <= PR;

        -- read from PC 
        when "011" =>
          BUSS(31 downto 16) <= 0;
          BUSS(15 downto 0) <= PC;

        -- read from AR  
        when "100" =>
          BUSS <= AR;

        -- read from GRx
        when "110" =>
          BUSS <= GRx;

        -- do nothing
        when others =>
          BUSS <= 0;
          
      end case;

      -- from bus
      case fb is

        -- write to IR
        when "001" =>
          IR <= BUSS;

        -- write to PM
        when "010" =>
          PR <= BUSS;

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
          BUSS <= 0;
          
      end case;

    end if;
  
  end process;
  

end behavioral;
