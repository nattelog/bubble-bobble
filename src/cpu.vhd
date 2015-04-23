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
  signal pm_write : STD_LOGIC;
  type pm_t is array(0 to 255) of STD_LOGIC_VECTOR(15 downto 0);
  signal prim_mem : pm_t := (
    X"1100",
    others => X"0000"
    );

  -- Signals from programword/dataregister
  alias dr_op : STD_LOGIC_VECTOR(3 downto 0) is DR(15 downto 12);
  alias dr_grx : STD_LOGIC_VECTOR(3 downto 0) is DR(11 downto 8);
  alias dr_m : STD_LOGIC_VECTOR(1 downto 0) is DR(7 downto 6);

  -- Control Unit signals
  signal mPC, k1, k2 : STD_LOGIC_VECTOR(7 downto 0);
  signal CONTROLWORD : STD_LOGIC_VECTOR(0 to 23);
  
  component micro_memory is
    port (clk, rst : in STD_LOGIC;
          adr : in STD_LOGIC_VECTOR(7 downto 0);
          controlword : out STD_LOGIC_VECTOR(0 to 23));
  end component;

  -- Signals from controlword
  --alias operation : STD_LOGIC_VECTOR(3 downto 0) is controlword(0 to 3);
  alias tb : STD_LOGIC_VECTOR(2 downto 0) is CONTROLWORD(4 to 6);
  alias fb : STD_LOGIC_VECTOR(2 downto 0) is CONTROLWORD(7 to 9);
  alias p : STD_LOGIC is controlword(10);
  alias lc : STD_LOGIC_VECTOR(1 downto 0) is controlword(11 to 12);
  alias seq : STD_LOGIC_VECTOR(3 downto 0) is controlword(13 to 16);
  alias madr : STD_LOGIC_VECTOR(6 downto 0) is controlword(17 to 23);

  -- K-registers
  type k_t is array(0 to 15) of STD_LOGIC_VECTOR(7 downto 0);

  constant k1_reg : k_t := (
    X"00",
    others => X"00"
    );

  constant k2_reg : k_t := (
    x"00",
    others => X"00"
    );

  -- General registers
  type gr_t is array(0 to 15) of STD_LOGIC_VECTOR(15 downto 0);
  signal gen_reg : gr_t;
  
begin

  -- **********
  -- ** BUSS **
  -- **********

  buss <= DR when tb = "010" else
          (others => '0');

  
  -- ******************
  -- ** CONTROL UNIT **
  -- ******************

  mm : micro_memory port map(clk, rst, mPC, CONTROLWORD);

  -- K registers
  k_registers : process (clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        k1 <= (others => '0');
        k2 <= (others => '0');

      else
        k1 <= k1_reg(CONV_INTEGER(dr_op));
        k2 <= k2_reg(CONV_INTEGER(dr_m));
        
      end if;
    end if;
  end process;

  micro_pc : process (clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        mPC <= (others => '0');

      else
        case seq is

          when "0000" =>
            mPC <= mPC + 1;

          when others =>
            mPC <= mPC;
          
        end case;
      end if;
    end if;
  end process;
  
  
  -- *****************
  -- ** MEMORY UNIT **
  -- *****************

  data_register : process (clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        DR <= (others => '0');
        pm_write <= '0';

      else
        if (fb = "010") then
          DR <= buss;
          pm_write <= '1';

        elsif (tb = "010") then
          DR <= prim_mem(CONV_INTEGER(ASR));
          pm_write <= '0';

        else
          pm_write <= '0';
          DR <= DR;
          
        end if;

        if (pm_write = '1') then
          prim_mem(CONV_INTEGER(ASR)) <= DR;
       
        end if;
      end if;
    end if;
  end process;

  adress_register : process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        ASR <= (others => '0');

      elsif (fb = "111") then
        ASR <= buss;

      else
        ASR <= ASR;
        
      end if;
    end if;
  end process;

  

  -- ***************************
  -- ** ARITHMETIC LOGIC UNIT **
  -- ***************************

end behavioral;
