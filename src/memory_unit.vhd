-- Memory Unit

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity memory_unit is
  Port (clk, rst : in STD_LOGIC;
        controlword : in STD_LOGIC_VECTOR(0 to 23);
        bussin : in STD_LOGIC_VECTOR(31 downto 0);
        bussout : out STD_LOGIC_VECTOR(31 downto 0));
end memory_unit;

architecture behavioral of memory_unit is

  component primary_memory is
    port (wr : in STD_LOGIC;
          adr : in STD_LOGIC_VECTOR(15 downto 0);
          datain : in STD_LOGIC_VECTOR(31 downto 0);
          dataout : out STD_LOGIC_VECTOR(31 downto 0));
  end component;

  signal ASR, PC : STD_LOGIC_VECTOR(15 downto 0);
  signal PM : STD_LOGIC_VECTOR(31 downto 0);
  signal WR : STD_LOGIC;

  alias tb : STD_LOGIC_VECTOR(2 downto 0) is controlword(4 to 6);
  alias fb : STD_LOGIC_VECTOR(2 downto 0) is controlword(7 to 9);
  alias p : STD_LOGIC is controlword(10);
    
begin

  process (clk)
  begin
    if rising_edge(clk) then

      if (rst = '1') then
        ASR <= 0;
        PC <= 0;
        PM <= 0;
        WR <= 0;

      else

        case tb is

          when "010" =>
            WR <= '1';
            bussout <= PM;

          when "011" =>
            bussout <= PC;
          
        end case;

        case fb is

          when "010" =>
            WR <= '0';
            PM <= bussin;

          when "011" =>
            PC <= bussin(15 downto 0);

          when "111" =>
            ASR <= bussin(15 downto 0);

          when others =>
            ASR <= ASR;
          
        end case;

        case p is

          when "1" =>
            PC <= PC + 1;

          when others =>
            PC <= PC;
          
        end case;

      end if;
  
    end if;
  end process;

  pm : primary_memory port map (WR, ASR, PM, PM);
  
end behavioral;
