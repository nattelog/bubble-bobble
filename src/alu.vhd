-- ALU

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEE.NUMERIC_STD;

entity alu is
  Port (clk, rst : in STD_LOGIC;
        operation : in STD_LOGIC_VECTOR(0 to 3);
        buss, arin : in STD_LOGIC_VECTOR(31 downto 0);
        arout : out STD_LOGIC_VECTOR(31 downto 0);
        flags : out STD_LOGIC_VECTOR(4 downto 0));
end alu;

architecture behavioral of alu is
  signal helpreg : STD_LOGIC_VECTOR(32 downto 0);
  alias helpreg_small : STD_LOGIC_VECTOR(31 downto 0) is helpreg(31 downto 0);

  alias z : STD_LOGIC is flags(4);
  alias n : STD_LOGIC is flags(3);
  alias c : STD_LOGIC is flags(2);
  alias o : STD_LOGIC is flags(1);
  alias l : STD_LOGIC is flags(0);
begin

  process (clk)
  begin

    if rising_edge(clk) then

      if (rst = '1') then
        arout <= (others => '0');
        flags <= (others => '0');
        
      else
        case operation is

          -- AR := buss
          when "0001" =>
            arout <= buss;

            -- AR := buss'
            -- not done yet
            
          -- AR := 0
          when "0011" =>
            arout <= 0;
            
          -- AR := AR+buss
          when "0100" =>
            helpreg <= arin + buss;
            arout <= helpreg_small;
            
          -- AR := AR-buss
          when "0101" =>
            helpreg <= arin - buss;
            arout <= helpreg_small;
            
          -- AR := AR AND buss
          when "0110" =>
            helpreg <= arin and buss;
            arout <= helpreg_small;
            
          -- AR := AR OR buss
          when "0111" =>
            helpreg <= arin or buss;
            arout <= helpreg_small;
            
            -- AR := AR+buss (doesn't affect flags)
            -- not done yet
            
          -- LSL(AR)
          when "1001" =>
            helpreg <= arin sll 1;
            arout <= helpreg_small;

          -- LSR (AR)
          when "1101" =>
            helpreg <= arin srl 1;
            arout <= helpreg_small;
            
          -- ROL
          when "1110" =>
            arout <= arin rol 1;
            helpreg <= 0;

          -- Nothing
          when others =>
            arout <= arin;
            helpreg <= 0;

        end case;

        -- set the flags
        c <= helpreg(32);
        z <= '1' when arout = 0 else '0';
        n <= arout(31);
        o <= helpreg(32) xor helpreg(31);

    end if;

  end process;
  
end behavioral;
