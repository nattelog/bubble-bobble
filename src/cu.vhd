-- Controlunit

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CU is
  Port (clk, rst : in STD_LOGIC;
        FLAGS : in STD_LOGIC;
        IR, BUSS : in STD_LOGIC_VECTOR(31 downto 0);
        PC : out STD_LOGIC_VECTOR(15 downto 0);
        controlword : out STD_LOGIC_VECTOR(0 to 23));
end CU;

architecture behavioral of CU is

  component MM is
    port (adr : in STD_LOGIC_VECTOR(6 downto 0)
          data : out STD_LOGIC_VECTOR(0 to 23));
  end component;

  component K1 is
    Port (adr : in STD_LOGIC_VECTOR(3 downto 0);
          data : out STD_LOGIC_VECTOR(6 downto 0))
  end component;

  component K2 is
    Port (adr : in STD_LOGIC_VECTOR(1 downto 0);
          data : out STD_LOGIC_VECTOR(6 downto 0))
  end component;

  signal mPC, suPC : STD_LOGIC_VECTOR(6 downto 0);
  signal microword : STD_LOGIC_VECTOR(0 to 23);
  signal k1, k2 : STD_LOGIC_VECTOR(6 downto 0);

  -- Flags
  alias Z : STD_LOGIC is FLAGS(4);
  alias N : STD_LOGIC is FLAGS(3);
  alias C : STD_LOGIC is FLAGS(2);
  alias O : STD_LOGIC is FLAGS(1);

  -- Loopcounter
  signal L : STD_LOGIC;
  signal lc : STD_LOGIC_VECTOR(7 downto 0);

  -- Signals from controlword
  --alias alu : STD_LOGIC_VECTOR(3 downto 0) is microword(0 to 3);
  --alias tb : STD_LOGIC_VECTOR(2 downto 0) is microword(4 to 6);
  --alias fb : STD_LOGIC_VECTOR(2 downto 0) is microword(7 to 9);
  alias p : STD_LOGIC is microword(10);
  alias lc : STD_LOGIC_VECTOR(1 downto 0) is microword(11 to 12);
  alias seq : STD_LOGIC_VECTOR(3 downto 0) is microword(13 to 16);
  alias madr : STD_LOGIC_VECTOR(6 downto 0) is microword(17 to 23);

  -- Signals from IR
  alias op : STD_LOGIC_VECTOR(3 downto 0) is IR(31 downto 28);
  --alias grx : STD_LOGIC_VECTOR(3 downto 0) is IR(27 downto 24);
  alias m : STD_LOGIC_VECTOR(1 downto 0) is IR(23 downto 22);
  --alias padr : STD_LOGIC_VECTOR(15 downto 0) is IR(15 downto 0);
  
begin

  L <= '1' when lc = 0 else '0';

  process (clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        mPC <= 0;
        suPC <= 0;
        microword <= 0;
        k1 <= 0;
        k2 <= 0;
        L <= 0;
        lc <= 0;

      else

        controlword <= microword;
        
        -- P FIELD
        case p is

          when '1' =>
            PC <= PC + 1;

          when others =>
            PC <= PC;
          
        end case;
        
        -- LC FIELD
        case lc is

            -- LC--
          when "01" =>
            lc <= lc - 1;

            -- LC := buss(7 downto 0)
          when "10" =>
            lc <= BUSS(7 downto 0);

            -- LC(6 downto 0) := madr, LC(7) := 0
          when "11" =>
            lc(7) <= '0';
            lc(6 downto 0) <= madr;

            -- LC stays the same
          when others =>
            lc <= lc;
          
        end case;

        -- SEQ FIELD
        case seq is

          -- mPC++
          when "0000" =>
            mPC <= mPC + 1;

            -- mPC := K1
          when "0001" =>
            mPC <= k1;
            
            -- mPC := K2
          when "0010" =>
            mPC <= k2;

            -- mPC = 0
          when "0011" =>
            mPC <= 0;

            -- mPC := madr if Z = 0, else mPC++
          when "0100" =>
            if (Z = '0') then
              mPC <= madr;

            else
              mPC <= mPC + 1;
              
            end if;
            
            -- mPC := madr
          when "0101" =>
            mPC <= madr;

            -- suPC := mPC+1, mPC := madr
          when "0110" =>
            suPC <= mPC + 1;
            mPC <= madr;

            -- mPC := suPC
          when "0111" =>
            mPC <= suPC;

            -- mPC := madr if Z = 1, else mPC++
          when "1000" =>
            if (Z = '1') then
              mPC <= madr;

            else
              mPC <= mPC + 1;
              
            end if;

          -- jmp ADR if N == 1, else microPC++
          when "1001" =>
            if (N = '1') then
              mPC <= madr;

            else
              mPC <= mPC + 1;
              
            end if;
          
            -- jmp ADR if C == 1, else microPC++
          when "1010" =>
            if (C = '1') then
              mPC <= madr;

            else
              mPC <= mPC + 1;
              
            end if;
          
            -- jmp ADR if O == 1, else microPC++
          when "1011" =>
            if (O = '1') then
              mPC <= madr;

            else
              mPC <= mPC + 1;
              
            end if;
          
            -- jmp ADR if L == 1, else microPC++
          when "1100" =>      
            if (L = '1') then
              mPC <= madr;

            else
              mPC <= mPC + 1;
              
            end if;
          
            -- jmp ADR if C == 0, else microPC++
          when "1100" =>      
            if (C = '0') then
              mPC <= madr;

            else
              mPC <= mPC + 1;
              
            end if;
          
            -- jmp ADR if O == 0, else microPC++
          when "1110" =>      
            if (O = '0') then
              mPC <= madr;

            else
              mPC <= mPC + 1;
              
            end if;

            -- reset mPC and HALT
          when "1111" =>
            mPC <= 0;

          when others =>
            
          
        end case;
        
      end if;
    end if;
  end process;

  MM port map (mPC, microword);

  K1 port map (op, k1);

  K2 port map (m, k2);
  
end behavioral;
