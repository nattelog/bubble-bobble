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

  -- Microinstructions
  -- Each row must follow the order below

  constant EMPTY : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
  
  -- alu-operation, 4 bits (alu_op)
  constant ALU : STD_LOGIC_VECTOR(3 downto 0) := "0000";

  -- to bus, 3 bits (tb)
  constant TB : STD_LOGIC_VECTOR(2 downto 0) := "000";
  constant TB_DR : STD_LOGIC_VECTOR(2 downto 0) := "010";

  -- from bus, 3 bits (fb)
  constant FB : STD_LOGIC_VECTOR(2 downto 0) := "000";
  constant FB_GR : STD_LOGIC_VECTOR(2 downto 0) := "110";

  -- programcounter, 1 bit (p)
  constant P : STD_LOGIC := '0';

  -- loopcounter-operation, 2 bits (loop_c)
  constant LC : STD_LOGIC_VECTOR(1 downto 0) := "00";

  -- sequencecontroller, 4 bits (seq)
  constant SEQ : STD_LOGIC_VECTOR(3 downto 0) := "0000";

  -- microaddress, 7 bit (madr)
  constant MADR : STD_LOGIC_VECTOR(6 downto 0) := "0000000";


  -- The whole micromemory containing microinstructions
  -- for the CPU
  constant MM : mm_t := (
    ALU & TB_DR & FB_GR & P & LC & SEQ & MADR,
    EMPTY,
    others => (others => '0')
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
