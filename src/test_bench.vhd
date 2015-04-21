-- Test bench

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_bench is
end test_bench;

architecture behavioral of test_bench is

  component memory_unit
    port (clk, rst : in STD_LOGIC;
          controlword : in STD_LOGIC_VECTOR(0 to 23);
          bussin : in STD_LOGIC_VECTOR(31 downto 0);
          bussout : out STD_LOGIC_VECTOR(31 downto 0));
  end component;

  signal clk : STD_LOGIC := '0';
  signal rst : STD_LOGIC := '0';
  signal controlword : STD_LOGIC_VECTOR(0 to 23) := (others => '0');
  signal buss : STD_LOGIC_VECTOR(31 downto 0);
  signal tb_running : boolean := true;

  alias tb : STD_LOGIC_VECTOR(2 downto 0) is controlword(4 to 6);
  alias fb : STD_LOGIC_VECTOR(2 downto 0) is controlword(7 to 9);
  alias p : STD_LOGIC is controlword(10);

  constant PM_TO_BUS : STD_LOGIC_VECTOR(2 downto 0) := "010";
  constant PM_FROM_BUS : STD_LOGIC_VECTOR(2 downto 0) := "010";
  constant PC_TO_BUS : STD_LOGIC_VECTOR(2 downto 0) := "011";
  constant PC_FROM_BUS : STD_LOGIC_VECTOR(2 downto 0) := "011";
  constant ASR_FROM_BUS : STD_LOGIC_VECTOR(2 downto 0) := "111";
  constant PC_INCR : STD_LOGIC := '1';
  
begin

  test : memory_unit port map(clk, rst, controlword, buss, buss);

  clk_gen : process
  begin
    while tb_running loop
      clk <= '0';
      wait for 5 ns;
      clk <= '1';
      wait for 5 ns;
    end loop;
    wait;
  end process;

  sim : process
  begin

    rst <= '1';
    wait for 500 ns;

    wait until rising_edge(clk);

    rst <= '0';
    wait for 1 us;

  end process;

end behavioral;
