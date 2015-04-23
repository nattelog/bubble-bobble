-- Test bench

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_bench is
end test_bench;

architecture behavioral of test_bench is

  component cpu
    port (clk, rst : in STD_LOGIC);
  end component;

  signal clk : STD_LOGIC := '0';
  signal rst : STD_LOGIC := '0';
  signal tb_running : boolean := true;
  
begin

  test : cpu port map(clk, rst);

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

    wait until rising_edge(clk);

    wait for 500 ns;

    tb_running <= false;

  end process;

end behavioral;
