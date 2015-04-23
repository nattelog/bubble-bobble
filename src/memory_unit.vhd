-- Memory Unit

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity memory_unit is
  Port (clk, rst : in STD_LOGIC;
        controlword : in STD_LOGIC_VECTOR(0 to 23);
        frombus : in STD_LOGIC_VECTOR(31 downto 0);
        tobus : out STD_LOGIC_VECTOR(31 downto 0));
end memory_unit;

architecture behavioral of memory_unit is

  type ram_t is array(0 to 255) of STD_LOGIC_VECTOR(15 downto 0);
  signal PM : ram_t;

  signal ASR : STD_LOGIC_VECTOR(15 downto 0);
  signal DR : STD_LOGIC_VECTOR(31 downto 0);
  signal wr : STD_LOGIC;

  alias tb : STD_LOGIC_VECTOR(2 downto 0) is controlword(4 to 6);
  alias fb : STD_LOGIC_VECTOR(2 downto 0) is controlword(7 to 9);

begin

  pm_logic : process(clk)
  begin
    if rising_edge(clk) then
      
      -- Read from PM
      if (wr = '0') then
        DR <= PM(CONV_INTEGER(ASR));

      -- Write to PM
      else
        PM(CONV_INTEGER(ASR)) <= DR;

      end if;
    end if;
  end process;
  
  mu_logic: process (clk)
  begin
    if rising_edge(clk) then

      if (rst = '1') then
        ASR <= (others => '0');
        DR <= (others => '0');
        wr <= '0';

      else

        if (tb = "011") then
          wr <= '0';
          tobus <= DR;
          
        end if;

        case fb is

          when "010" =>
            WR <= '0';
            PMin <= bussin;

          when "011" =>
            PC <= bussin(15 downto 0);

          when "111" =>
            ASR <= bussin(15 downto 0);

          when others =>
            ASR <= ASR;
          
        end case;

        case p is

          when '1' =>
            PC <= PC + 1;

          when others =>
            PC <= PC;
          
        end case;

      end if;
  
    end if;
  end process;

  mem : primary_memory port map (clk, rst, WR, ASR, PMin, PMout);
  
end behavioral;
