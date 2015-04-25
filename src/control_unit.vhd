-- The micromemory

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity control_unit is
  Port (clk, rst, rx : in STD_LOGIC;
        adr : in STD_LOGIC_VECTOR(6 downto 0);
        controlword : out STD_LOGIC_VECTOR(0 to 23);
        uart_data : out STD_LOGIC_VECTOR(31 downto 0));
end control_unit;

architecture behavioral of control_unit is

  signal halt, uart_line_c, uart_reading, uart_begin, uart_reset_pc_count : STD_LOGIC;
  signal uart_idle_count : STD_LOGIC_VECTOR(6 downto 0);

  component uart is
    Port ( clk,rst,rx : in  STD_LOGIC;
           uart_data_o : out STD_LOGIC_VECTOR (31 downto 0); -- Uart data out
           uart_line_c : out STD_LOGIC := '0';     -- Uart line complete
           uart_reading : out STD_LOGIC := '0'     -- Set to one when reading starts
           );
  end component;

  type mm_t is array(0 to 256) of STD_LOGIC_VECTOR(0 to 23);

  -- ***********************
  -- ** MICROINSTRUCTIONS **
  -- ***********************
 
  constant EMPTY : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');

  -- Each row must follow the order below
  
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
  constant TB_PC : STD_LOGIC_VECTOR(2 downto 0) := "011";
  constant TB_AR : STD_LOGIC_VECTOR(2 downto 0) := "100";
  constant TB_GR : STD_LOGIC_VECTOR(2 downto 0) := "110";

  -- 3: from bus, 3 bits (fb)
  constant FB : STD_LOGIC_VECTOR(2 downto 0) := "000";
  constant FB_IR : STD_LOGIC_VECTOR(2 downto 0) := "001";
  constant FB_DR : STD_LOGIC_VECTOR(2 downto 0) := "010";
  constant FB_PC : STD_LOGIC_VECTOR(2 downto 0) := "011";
  constant FB_GR : STD_LOGIC_VECTOR(2 downto 0) := "110";
  constant FB_ASR : STD_LOGIC_VECTOR(2 downto 0) := "111";

  -- 4: programcounter, 1 bit (p)
  constant P : STD_LOGIC := '0';
  constant P_INC : STD_LOGIC := '1';
  
  -- 5: loopcounter-operation, 2 bits (loop_c)
  constant LC : STD_LOGIC_VECTOR(1 downto 0) := "00";
  constant LC_DEC : STD_LOGIC_VECTOR(1 downto 0) := "01";
  constant LC_FB : STD_LOGIC_VECTOR(1 downto 0) := "10";
  constant LC_MADR : STD_LOGIC_VECTOR(1 downto 0) := "11";
  
  -- 6: sequencecontroller, 4 bits (seq)
  constant SEQ : STD_LOGIC_VECTOR(3 downto 0) := "0000";
  constant SEQ_K1 : STD_LOGIC_VECTOR(3 downto 0) := "0001";
  constant SEQ_K2 : STD_LOGIC_VECTOR(3 downto 0) := "0010";
  constant SEQ_RES : STD_LOGIC_VECTOR(3 downto 0) := "0011";
  constant SEQ_JMP_NOT_Z : STD_LOGIC_VECTOR(3 downto 0) := "0100";
  constant SEQ_JMP : STD_LOGIC_VECTOR(3 downto 0) := "0101";
  constant SEQ_JSR : STD_LOGIC_VECTOR(3 downto 0) := "0110";
  constant SEQ_RTS : STD_LOGIC_VECTOR(3 downto 0) := "0111";
  constant SEQ_JMP_Z : STD_LOGIC_VECTOR(3 downto 0) := "1000";
  constant SEQ_JMP_N : STD_LOGIC_VECTOR(3 downto 0) := "1001";
  constant SEQ_JMP_C : STD_LOGIC_VECTOR(3 downto 0) := "1010";
  constant SEQ_JMP_O : STD_LOGIC_VECTOR(3 downto 0) := "1011";
  constant SEQ_JMP_L : STD_LOGIC_VECTOR(3 downto 0) := "1100";
  constant SEQ_JMP_NOT_C : STD_LOGIC_VECTOR(3 downto 0) := "1101";
  constant SEQ_JMP_NOT_O : STD_LOGIC_VECTOR(3 downto 0) := "1110";
  constant SEQ_HALT : STD_LOGIC_VECTOR(3 downto 0) := "1111";

  -- 7: microaddress, 7 bit (madr)
  constant MADR : STD_LOGIC_VECTOR(6 downto 0) := "0000000";

  -- Short line for HALT
  constant HALT : STD_LOGIC_VECTOR(23 downto 0) := ALU & TB & FB & P & LC & SEQ_RES & MADR;;


  -- *****************
  -- ** MICROMEMORY **
  -- *****************
  
  constant MM : mm_t := (
    ALU & TB_DR & FB_GR & P_INC & LC & SEQ & MADR,
    ALU & TB_PC & FB_ASR & P & LC & SEQ & MADR,
    ALU & TB_DR & FB_GR & P & LC & SEQ & MADR,
    ALU_LSR & TB & FB & P & LC & SEQ_HALT & MADR,
    others => EMPTY
    );
  
begin

  uart_c : uart port map(clk, rst, rx, uart_data, uart_line_c, uart_reading); 

  control_process : process (clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        controlword <= (others => '0');
        halt <= '0';
        uart_begin <= '1';
        uart_reset_pc_count <= '0';
        uart_idle_count <= (others => '0');

      -- UART reading
      elsif (uart_reading = '1') then

        -- reset PC
        if (uart_begin = '1') then
          if (uart_reset_pc_count = '0') then
            controlword <= ALU_RES & TB & FB & P & SEQ_RES & MADR;
            uart_reset_pc_count <= '1';
            
          else
            controlword <= ALU & TB_AR & FB_PC & P & SEQ_RES & MADR;
            uart_reset_pc_count <= '0';
            uart_begin <= '0';
            
          end if;

        -- line ready
        elsif (uart_line_c = '1') then
          controlword <= EMPTY;

        else
          controlword <= EMPTY;
          
        end if;
        
      -- CPU should halt
      elsif (MM(CONV_INTEGER(adr))(13 to 16) = "1111") then
        halt <= '1';
        controlword <= HALT;

      -- CPU should read from micromemory
      elsif (halt = '0') then
        controlword <= MM(CONV_INTEGER(adr));

      else
        controlword <= HALT;

      end if;
    end if;
  end process;

end behavioral;
