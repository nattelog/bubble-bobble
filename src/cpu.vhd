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

  -- Main signals
  signal BUSS, DR : STD_LOGIC_VECTOR(15 downto 0);
  signal ASR : STD_LOGIC_VECTOR(15 downto 0);

  -- Memory Unit
  type pm_t is array(0 to 255) of STD_LOGIC_VECTOR(15 downto 0);
  signal PM : pm_t;

  -- Signals from programword
  --alias op : STD_LOGIC_VECTOR(3 downto 0) is PM(31 downto 28);
  --alias gradr : STD_LOGIC_VECTOR(3 downto 0) is PR(27 downto 24);
  --alias m : STD_LOGIC_VECTOR(1 downto 0) is PM(23 downto 22);
  --alias padr : STD_LOGIC_VECTOR(15 downto 0) is PM(15 downto 0);

  -- Control Unit
  signal mPC : STD_LOGIC_VECTOR(6 downto 0);
  signal CONTROLWORD : STD_LOGIC_VECTOR(0 to 23);
  
  type mm_t is array(0 to 127) of STD_LOGIC_VECTOR(0 to 23);
  
  constant MM : mm_t := (
    X"111000",
    others => X"000000"
    );

  -- Signals from controlword
  --alias operation : STD_LOGIC_VECTOR(3 downto 0) is controlword(0 to 3);
  alias tb : STD_LOGIC_VECTOR(2 downto 0) is CONTROLWORD(4 to 6);
  alias fb : STD_LOGIC_VECTOR(2 downto 0) is CONTROLWORD(7 to 9);
  --alias p : STD_LOGIC is controlword(10);
  --alias lc : STD_LOGIC_VECTOR(1 downto 0) is controlword(11 to 12);
  --alias seq : STD_LOGIC_VECTOR(3 downto 0) is controlword(13 to 16);
  --alias madr : STD_LOGIC_VECTOR(6 downto 0) is controlword(17 to 23);
  
begin

  -- **********
  -- ** BUSS **
  -- **********

  BUSS <= DR when tb = "010" else
          (others => '0');

  
  -- ******************
  -- ** CONTROL UNIT **
  -- ******************

  micro_memory : process (clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        CONTROLWORD <= (others => '0');
        mPC <= (others => '0');

      else
        CONTROLWORD <= MM(CONV_INTEGER(mPC));
        
      end if;
    end if;
  end process;
  
  
  -- *****************
  -- ** MEMORY UNIT **
  -- *****************

  

  -- ***************************
  -- ** ARITHMETIC LOGIC UNIT **
  -- ***************************

end behavioral;
