-- K1-register

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity k1_register is
  Port (adr : in STD_LOGIC_VECTOR(3 downto 0);
        data : out STD_LOGIC_VECTOR(6 downto 0))
end k1_register;

architecture behavioral of k1_register is
  type k1_t is array(0 to 15) of STD_LOGIC_VECTOR(6 downto 0);

  -- Content of K1
  constant k1 : k1_t := (
    X"00",      -- 0x0 : LDA
    X"00",      -- 0x1 : STR
    X"00",      -- 0x2 : ADD
    X"00",      -- 0x3 : SUB
    X"00",      -- 0x4 : CMP
    X"00",      -- 0x5 : AND
    X"00",      -- 0x6 : OR
    X"00",      -- 0x7 : LSR
    X"00",      -- 0x8 : LSL
    X"00",      -- 0x9 : BRA
    X"00",      -- 0xa : BRG
    X"00",      -- 0xb : BNE
    X"00",      -- 0xc : BRE
    X"00",      -- 0xd : BRC
    X"00",      -- 0xe : JSR
    X"00"       -- 0xf : RTS
    );
  
begin

  data <= k1(CONV_INTEGER(adr));
  
end behavioral;
