-- Test bench

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_bench is
end test_bench;

architecture behavioral of test_bench is

  component cpu
    port (clk, rst, rx : in STD_LOGIC;
          Led : out STD_LOGIC_VECTOR(7 downto 0);
          seg : out STD_LOGIC_VECTOR(7 downto 0);
          an : out STD_LOGIC_VECTOR(3 downto 0);
          sw : in STD_LOGIC_VECTOR(7 downto 0));
  end component;

  signal clk : STD_LOGIC := '0';
  signal rst : STD_LOGIC := '0';
  signal rx : STD_LOGIC := '1';
  signal rxs :  STD_LOGIC_VECTOR(0 to 119) := B"0_00000000_1_0_00010000_1_0_00000000_1_0_11111111_1_0_00000000_1_0_00000000_1_0_00000000_1_0_11111111_1_0_11110000_1_0_00000000_1_0_00000000_1_0_00000000_1";
  signal Led : STD_LOGIC_VECTOR(7 downto 0) := X"FF";
  signal seg : STD_LOGIC_VECTOR(7 downto 0) := X"FF";
  signal an : STD_LOGIC_VECTOR(3 downto 0) := X"0";
  signal sw : STD_LOGIC_VECTOR(7 downto 0) := X"00";
  signal tb_running : boolean := true;
  
begin

  test : cpu port map(clk, rst, rx, Led, seg, an, sw);

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
    
    --for y in 0 to 83 loop
      --for i in 0 to 119 loop
      	--rx <= rxs(i);
      	--wait for 8.68 us;
      --end loop;  -- i
    --end loop;

    rst <= '1';
    wait for 200 ns;

    rst <= '0';
    wait for 1 us;

    tb_running <= false;

  end process;

end behavioral;
