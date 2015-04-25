-- Test bench

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_bench is
end test_bench;

architecture behavioral of test_bench is

  component cpu
    port (clk, rst, rx : in STD_LOGIC);
  end component;

  signal clk : STD_LOGIC := '0';
  signal rst : STD_LOGIC := '0';
  signal rx : STD_LOGIC := '0';
  SIGNAL rxs :  std_logic_vector(0 to 159) := "0010101011001010101100101010110010101011000000000101111111110000000001011111111101010101010101010101010101010101010101010000000001011111111100000000010111111111";
  signal tb_running : boolean := true;
  
begin

  test : cpu port map(clk, rst, rx);

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
    variable i : integer;
    variable y : integer;
    
  begin

    rst <= '1';
    wait for 500 ns;

    wait until rising_edge(clk);

    rst <= '0';
    wait for 1 us;

    for y in 0 to 83 loop
      for i in 0 to 159 loop
      	rx <= rxs(i);
      	wait for 8.68 us;
      end loop;  -- i
    end loop;

    wait for 500 ns;

    tb_running <= false;

  end process;

end behavioral;
