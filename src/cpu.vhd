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
  
  signal buss, DR, GR, IR, AR : STD_LOGIC_VECTOR(15 downto 0);
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

  -- Instructionregister parts
  alias ir_op : STD_LOGIC_VECTOR(3 downto 0) is IR(15 downto 12);
  alias ir_grx : STD_LOGIC_VECTOR(3 downto 0) is IR(11 downto 8);
  alias ir_m : STD_LOGIC_VECTOR(1 downto 0) is IR(7 downto 6);

  signal helpreg : STD_LOGIC_VECTOR(16 downto 0);

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

  buss <= IR when tb = "001" else
          DR when tb = "010" else
          AR when tb = "100" else
          GR when tb = "110" else
          (others => '0') when rst = '1' else
          buss;

  
  -- ******************
  -- ** CONTROL UNIT **
  -- ******************

  mm : micro_memory port map(clk, rst, mPC, CONTROLWORD);

  instruction_register : process (clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        IR <= (others => '0');

      elsif (fb = "001") then
        IR <= buss;
        
      end if;
    end if;
  end process;

  -- K registers
  k_registers : process (clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        k1 <= (others => '0');
        k2 <= (others => '0');

      else
        k1 <= k1_reg(CONV_INTEGER(ir_op));
        k2 <= k2_reg(CONV_INTEGER(ir_m));
        
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

        elsif (pm_write = '0') then
          DR <= prim_mem(CONV_INTEGER(ASR));
          
        end if;

        if (pm_write = '1') then
          prim_mem(CONV_INTEGER(ASR)) <= DR;
          pm_write <= '0';
       
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

        elsif (gr_write = '0') then
          GR <= gen_reg(CONV_INTEGER(ir_grx));

        end if;
        
        if (gr_write = '1') then
          gen_reg(CONV_INTEGER(ir_grx)) <= GR;
          gr_write <= '0';
          
        end if;
      end if;
    end if;
  end process;

  -- ALU OPERATIONS
  helpreg <= (AR(15) & AR) + (buss(15) & buss) when alu_op = "0100" else
             (AR(15) & AR) - (buss(15) & buss) when alu_op = "0101" else
             '0' & (AR and buss) when alu_op = "0110" else
             '0' & (AR or buss) when alu_op = "0111" else
             AR & '0' when alu_op = "1001" else -- LSL
             AR(0) & '0' & AR(15 downto 1) when alu_op = "1101" else -- LSR
             AR(0) & AR(0) & AR(15 downto 1) when alu_op = "1110" else -- ROL
             (others => '0') when rst = '1' else
             (others => '0');

  alu : process (clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        AR <= (others => '0');
        helpreg <= (others => '0');

      else
        if (alu_op = "0001") then
          AR <= buss;

          if (buss = 0) then
            Z <= '1';
          else
            Z <= '0';
          end if;

          N <= buss(15);

        elsif (alu_op = "0011") then
          AR <= (others => '0');
          Z <= '0';
          N <= '0';

        else
          AR <= helpreg(15 downto 0);

          if (helpreg(15 downto 0) = 0) then
            Z <= '1';
          else
            Z <= '0';
          end if;

          N <= helpreg(15);

        end if;

        C <= helpreg(16);
        O <= helpreg(16) xor helpreg(15);
        
      end if;
    end if;
  end process;
  
end behavioral;
