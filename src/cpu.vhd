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

  -- ******************
  -- ** MAIN SIGNALS **
  -- ******************
  
  signal buss, DR, GR : STD_LOGIC_VECTOR(15 downto 0);
  signal ASR : STD_LOGIC_VECTOR(15 downto 0);

  
  -- *****************
  -- ** MEMORY UNIT **
  -- *****************
  
  signal pm_write : STD_LOGIC;
  
  type pm_t is array(0 to 255) of STD_LOGIC_VECTOR(15 downto 0);
  
  signal prim_mem : pm_t := (
    X"FF00",
    X"00FF",
    others => X"0000"
    );

  alias dr_op : STD_LOGIC_VECTOR(3 downto 0) is DR(15 downto 12);
  alias dr_grx : STD_LOGIC_VECTOR(3 downto 0) is DR(11 downto 8);
  alias dr_m : STD_LOGIC_VECTOR(1 downto 0) is DR(7 downto 6);

  
  -- ******************
  -- ** CONTROL UNIT **
  -- ******************
  
  signal mPC, suPC, k1, k2 : STD_LOGIC_VECTOR(6 downto 0);
  signal CONTROLWORD : STD_LOGIC_VECTOR(0 to 23);
  signal LC : STD_LOGIC_VECTOR(7 downto 0);
  
  component micro_memory is
    port (clk, rst : in STD_LOGIC;
          adr : in STD_LOGIC_VECTOR(6 downto 0);
          controlword : out STD_LOGIC_VECTOR(0 to 23));
  end component;

  -- Signals from controlword
  alias alu_op : STD_LOGIC_VECTOR(3 downto 0) is controlword(0 to 3);
  alias tb : STD_LOGIC_VECTOR(2 downto 0) is CONTROLWORD(4 to 6);
  alias fb : STD_LOGIC_VECTOR(2 downto 0) is CONTROLWORD(7 to 9);
  alias p : STD_LOGIC is controlword(10);
  alias loop_c : STD_LOGIC_VECTOR(1 downto 0) is controlword(11 to 12);
  alias seq : STD_LOGIC_VECTOR(3 downto 0) is controlword(13 to 16);
  alias madr : STD_LOGIC_VECTOR(6 downto 0) is controlword(17 to 23);

  -- K-registers
  type k_t is array(0 to 15) of STD_LOGIC_VECTOR(6 downto 0);

  constant k1_reg : k_t := (
    "1100110",
    others => (others => '0')
    );

  constant k2_reg : k_t := (
    "1100110",
    others => (others => '0')
    );


  -- ***************************
  -- ** ARITHMETIC LOGIC UNIT **
  -- ***************************

  -- Flags
  signal Z, N, O, C, L : STD_LOGIC;

  -- General registers
  type gr_t is array(0 to 15) of STD_LOGIC_VECTOR(15 downto 0);
  signal gen_reg : gr_t;
  signal gr_write : STD_LOGIC;

  
begin

  -- **********
  -- ** BUSS **
  -- **********

  buss <= DR when tb = "010" else
          GR when tb = "110" else
          (others => '0') when tb = "000";

  
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
        suPC <= (others => '0');

      else
        case seq is

          when "0000" =>
            mPC <= mPC + 1;

          when "0001" =>
            mPC <= k1;

          when "0010" =>
            mPC <= k2;

          when "0011" =>
            mPC <= (others => '0');

          when "0100" =>
            if (Z = '0') then
              mPC <= madr;
            else
              mPC <= mPC + 1;
            end if;

          when "0101" =>
            mPC <= madr;

          when "0110" =>
            suPC <= mPC + 1;
            mPC <= madr;

          when "0111" =>
            mPC <= suPC;

          when "1000" =>
            if (Z = '1') then
              mPC <= madr;
            else
              mPC <= mPC + 1;
            end if;

          when "1001" =>
            if (N = '1') then
              mPC <= madr;
            else
              mPC <= mPC + 1;
            end if;

          when "1010" =>
            if (C = '1') then
              mPC <= madr;
            else
              mPC <= mPC + 1;
            end if;

          when "1011" =>
            if (O = '1') then
              mPC <= madr;
            else
              mPC <= mPC + 1;
            end if;

          when "1100" =>
            if (L = '1') then
              mPC <= madr;
            else
              mPC <= mPC + 1;
            end if;

          when "1101" =>
            if (C = '0') then
              mPC <= madr;
            else
              mPC <= mPC + 1;
            end if;

          when "1110" =>
            if (O = '0') then
              mPC <= madr;
            else
              mPC <= mPC + 1;
            end if;

          when "1111" =>
            mPC <= (others => '0');
            -- Should HALT here

          when others =>
            mPC <= mPC;
          
        end case;
      end if;
    end if;
  end process;

  loop_counter : process (clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        LC <= (others => '0');

      else
        case loop_c is

          when "01" =>
            LC <= LC - 1;

          when "10" =>
            LC <= buss(7 downto 0);

          when "11" =>
            LC(6 downto 0) <= madr;
            LC(7) <= '0';

          when others =>
            LC <= LC;
          
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

  flags : process (clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        Z <= '0';
        N <= '0';
        O <= '0';
        C <= '0';
        L <= '0';

      else
        if (LC = 0) then
          L <= '1';
        end if;
        
      end if;
    end if;
  end process;

  general_register : process (clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        GR <= (others => '0');
        gen_reg <= (others => (others => '0'));
        gr_write <= '0';

      else
        if (fb = "110") then
          GR <= buss;
          gr_write <= '1';

        elsif (tb = "110") then
          GR <= gen_reg(CONV_INTEGER(dr_grx));
          gr_write <= '0';

        else
          gr_write <= '0';
          GR <= GR;

        end if;
        
        if (gr_write = '1') then
          gen_reg(CONV_INTEGER(dr_grx)) <= GR;
          
        end if;
      end if;
    end if;
  end process;
  
end behavioral;
