-- The micromemory

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity micro_memory is
  Port (clk, rst : in STD_LOGIC;
        adr : in STD_LOGIC_VECTOR(6 downto 0);
        controlword : out STD_LOGIC_VECTOR(0 to 23));
end micro_memory;

architecture behavioral of micro_memory is

  type mm_t is array(0 to 256) of STD_LOGIC_VECTOR(0 to 23);

  -- ***********************
  -- ** MICROINSTRUCTIONS **
  -- ***********************
  
  -- Each row must follow the order below
  constant EMPTY : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
  
  -- 1: alu-operation, 4 bits (alu_op)
  constant ALU : STD_LOGIC_VECTOR(3 downto 0) := "0000";
  constant ALU_FB : STD_LOGIC_VECTOR(3 downto 0) := "0001";
  constant ALU_RES : STD_LOGIC_VECTOR(3 downto 0) := "0011";
  constant ALU_ADD : STD_LOGIC_VECTOR(3 downto 0) := "0100";
  constant ALU_SUB : STD_LOGIC_VECTOR(3 downto 0) := "0101";
  constant ALU_AND : STD_LOGIC_VECTOR(3 downto 0) := "0110";
  constant ALU_OR : STD_LOGIC_VECTOR(3 downto 0) := "0111";
  constant ALU_LSL : STD_LOGIC_VECTOR(3 downto 0) := "1001";
  constant ALU_LSR : STD_LOGIC_VECTOR(3 downto 0) := "1101";
  constant ALU_ROL : STD_LOGIC_VECTOR(3 downto 0) := "1110";

  -- 2: to bus, 3 bits (tb)
  constant TB : STD_LOGIC_VECTOR(2 downto 0) := "000";
  constant TB_IR : STD_LOGIC_VECTOR(2 downto 0) := "001";
  constant TB_DR : STD_LOGIC_VECTOR(2 downto 0) := "010";
  constant TB_AR : STD_LOGIC_VECTOR(2 downto 0) := "100";
  constant TB_GR : STD_LOGIC_VECTOR(2 downto 0) := "110";

  -- 3: from bus, 3 bits (fb)
  constant FB : STD_LOGIC_VECTOR(2 downto 0) := "000";
  constant FB_IR : STD_LOGIC_VECTOR(2 downto 0) := "001";
  constant FB_DR : STD_LOGIC_VECTOR(2 downto 0) := "010";
  constant FB_GR : STD_LOGIC_VECTOR(2 downto 0) := "110";
  constant FB_ASR : STD_LOGIC_VECTOR(2 downto 0) := "111";

  -- 4: programcounter, 1 bit (p)
  constant P : STD_LOGIC := '0';

  -- 5: loopcounter-operation, 2 bits (loop_c)
  constant LC : STD_LOGIC_VECTOR(1 downto 0) := "00";

  -- 6: sequencecontroller, 4 bits (seq)
  constant SEQ : STD_LOGIC_VECTOR(3 downto 0) := "0000";

  -- 7: microaddress, 7 bit (madr)
  constant MADR : STD_LOGIC_VECTOR(6 downto 0) := "0000000";


  -- *****************
  -- ** MICROMEMORY **
  -- *****************
  
  constant MM : mm_t := (
    ALU_FB & TB_DR & FB_GR & P & LC & SEQ & MADR,
    ALU_ADD & TB_AR & FB & P & LC & SEQ & MADR,
    others => EMPTY
    );
  
begin

  process (clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        controlword <= (others => '0');

      else
        controlword <= MM(CONV_INTEGER(adr));

      end if;
    end if;
  end process;

end behavioral;
