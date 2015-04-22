library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lab is
    Port ( clk,rst : in  STD_LOGIC;
           vgaRed, vgaGreen : out  STD_LOGIC_VECTOR (2 downto 0);
           vgaBlue : out  STD_LOGIC_VECTOR (2 downto 1);
           Hsync,Vsync : out  STD_LOGIC);
end lab;

architecture Behavioral of lab is


  signal xctr,yctr : std_logic_vector(9 downto 0) := "0000000000";
  alias rad : std_logic_vector(6 downto 0) is yctr(9 downto 3); -- i bildminnet
  alias kol : std_logic_vector(6 downto 0) is xctr(9 downto 3);  -- i bildminnet
  alias ypix : std_logic_vector(2 downto 0) is yctr(2 downto 0); -- i pixeln
  alias xpix : std_logic_vector(2 downto 0) is xctr(2 downto 0);  -- i pixeln
  signal pixel : std_logic_vector(1 downto 0) := "00";
  signal a,b,c,d : std_logic_vector(0 to 79) := X"00000000000000000000";
  signal a0,a1,a2,b0,b1,b2,c0,c1,c2 : std_logic := '0';
  signal nr : std_logic_vector(3 downto 0) := "0000";
  signal ctr : std_logic_vector(15 downto 0) := X"0000";
  signal hs : std_logic := '1';
  signal vs : std_logic := '1';
  type ram_t is array (0 to 59) of std_logic_vector(0 to 79);

  constant glider : ram_t := ("00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000010000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000001010000000000000000000000000000000000000000000000000000",
                              "00000000000000011000000110000000000001100000000000000000000000000000000000000000",
                              "00000000000000100010000110000000000001100000000000000000000000000000000000000000",
                              "00011000000001000001000110000000000000000000000000000000000000000000000000000000",
                              "00011000000001000101100001010000000000000000000000000000000000000000000000000000",
                              "00000000000001000001000000010000000000000000000000000000000000000000000000000000",
                              "00000000000000100010000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000011000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000001111000000111100001111000000011000000001110000000000000000000000",
                              "00000000000000010000100001000000010000000000100100000001001000000000000000000000",
                              "00000000000000010000100000111000010000000001111110000001110000000000000000000000",
                              "00000000000000010000100000000100010000000010000001000001001000000000000000000000",
                              "00000000000000001111000000111000001111000100000000100001000100000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",                     
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",                     
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000",
                              "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
                              );
  signal bildminne : ram_t := glider;
  signal video : std_logic;
begin
  process(clk) begin
     if rising_edge(clk) then
       if rst='1' then
         pixel <= "00";
       else
         pixel <= pixel + 1;
       end if;
     end if;
  end process;


  process(clk) begin
    if rising_edge(clk) then
      if rst='1' then
         xctr <= "0000000000";
      elsif pixel=3 then
       if xctr=799 then
         xctr <= "0000000000";
       else
         xctr <= xctr + 1;
       end if;
      end if;
      -- 
      if xctr=656 then
        hs <= '0';
      elsif xctr=752 then
        hs <= '1';
      end if;
    end if;
  end process;

  process(clk) begin
    if rising_edge(clk) then
      if rst='1' then
        yctr <= "0000000000";
      elsif xctr=799 and pixel=0 then
       if yctr=520 then
         yctr <= "0000000000";
       else
         yctr <= yctr + 1;
       end if;
       --
       if yctr=490 then
         vs <= '0';
       elsif  yctr=492 then
         vs <= '1';
       end if;
      end if;
    end if;
  end process;
  Hsync <= hs;
  Vsync <= vs;

    -- bildminne
  process(clk) begin
    if rising_edge(clk) then
      if ypix=0 and xpix=0 and pixel=0 then
        if rad<60 then
          if kol=0 then
            a <= b;
            b <= c;
            if rad<59 then
              c <= bildminne(conv_integer(rad) + 1);     
            elsif rad=59 then
              c <= X"00000000000000000000";
            end if;
          elsif kol=80 then
            bildminne(conv_integer(rad)) <= d;     
          end if;     
        end if;
      end if;
    end if;
  end process;


      
  -- video
  -- en ram ritas runt spelplanen
  -- tycks medföra att AUTO funkar som avsett
  process(clk) begin
    if rising_edge(clk) then
      if pixel=3 then
        if xctr=0 or xctr=639 or yctr=0 or yctr=479 then
          video<='1';
        elsif yctr<480 and xctr<640 then
          video <= b(conv_integer(kol));
        else
          video <= '0';
        end if;
      end if;
    end if;
  end process;
  
  vgaRed(2 downto 0) <= (video & video & video);
  vgaGreen(2 downto 0) <= (video & video & video);
  vgaBlue(2 downto 1) <= (video & video);
  
  -- ************************************
  
  process(clk) begin
     if rising_edge(clk) then
       if rst='1' then
         ctr <= X"0000";
       elsif yctr=0 and xctr=0 and pixel=0 then
         ctr <= ctr+1;
       end if;
     end if;
  end process;
       
end Behavioral;

