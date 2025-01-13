-- Engineer: Qihsi Hu 
-- Create Date: 12/05/2024 08:04:50 PM
-- Design Name: 
-- Description: Convert a stream of pixels into tx output 

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity DVID_output is
    Port ( 
        pixel_clk       : in std_logic;  -- Driven by BUFG
        pixel_io_clk_x1 : in std_logic;  -- Driven by BUFIO
        pixel_io_clk_x5 : in std_logic;  -- Driven by BUFIO
        -- VGA Signals
        vga_blank    : in  std_logic;
        vga_hsync    : in  std_logic;
        vga_vsync    : in  std_logic;
        vga_red      : in  std_logic_vector(7 downto 0);
        vga_blue     : in  std_logic_vector(7 downto 0);
        vga_green    : in  std_logic_vector(7 downto 0);
        data_valid   : in  std_logic;
        
        --- DVI-D out
        outclk_p:  out STD_LOGIC; 
        tmds_out_clk    : out   std_logic;
        tmds_out_ch0    : out   std_logic;
        tmds_out_ch1    : out   std_logic;
        tmds_out_ch2    : out   std_logic
    );
end DVID_output;

architecture Behavioral of DVID_output is
--    component mySerial is
--    Port ( clk : in STD_LOGIC;
--           clk5, nclk5 : in STD_LOGIC;
--            outclk_p : out std_logic;
--           d0, d1, d2 : in STD_LOGIC_VECTOR (9 downto 0);
--           q0,q2,q1,tx_clk: out STD_LOGIC);
--    end component;

   component tmds_encoder is
   Port ( clk     : in  std_logic;
          data    : in  std_logic_vector (7 downto 0);
          c       : in  std_logic_vector (1 downto 0);
          blank   : in  std_logic;
          encoded : out std_logic_vector (9 downto 0));
    end component;

    component serialiser_10_to_1 is
    Port ( clk    : in  std_logic;
           clk_x5 : in  std_logic;
           reset  : in  std_logic;
           data   : in  std_logic_vector (9 downto 0);
           serial : out std_logic);
    end component;
    signal c0_tmds_symbol : std_logic_vector (9 downto 0);
    signal c1_tmds_symbol : std_logic_vector (9 downto 0);
    signal c2_tmds_symbol : std_logic_vector (9 downto 0);

    signal reset_sr       : std_logic_vector (2 downto 0) := (others => '1');
    signal reset          : std_logic := '1';
    
begin
    reset <= reset_sr(0);
process(pixel_clk, data_valid)
    begin
        if data_valid = '0' then
           reset_sr <= (others => '1');
        elsif rising_edge(pixel_clk) then
            reset_sr <= '0' & reset_sr(reset_sr'high downto 1); 
        end if;
    end process;
    ---------------------
    -- TMDS Encoders for packing 10-bit words/symbols
    ---------------------
c0_tmds: tmds_encoder port map (
        clk     => pixel_clk,
        data    => vga_blue,
        c(1)    => vga_vsync,
        c(0)    => vga_hsync,
        blank   => vga_blank,
        encoded => c0_tmds_symbol);

c1_tmds: tmds_encoder port map (
        clk     => pixel_clk,
        data    => vga_green,
        c       => (others => '0'),
        blank   => vga_blank,
        encoded => c1_tmds_symbol);
        
c2_tmds: tmds_encoder port map (
        clk     => pixel_clk,
        data    => vga_red,
        c       => (others => '0'),
        blank   => vga_blank,
        encoded => c2_tmds_symbol);
    ---------------------
    -- Output serializers
    ---------------------
ser_ch0: serialiser_10_to_1 port map ( 
        clk    => pixel_io_clk_x1,
        clk_x5 => pixel_io_clk_x5,
        reset  => reset,
        data   => c0_tmds_symbol,
        serial => tmds_out_ch0);
        
ser_ch1: serialiser_10_to_1 port map ( 
        clk    => pixel_io_clk_x1,
        clk_x5 => pixel_io_clk_x5,
        reset  => reset,
        data   => c1_tmds_symbol,
        serial =>  tmds_out_ch1);

ser_ch2: serialiser_10_to_1 port map (
        clk    => pixel_io_clk_x1,
        clk_x5 => pixel_io_clk_x5,
        reset  => reset,
        data   => c2_tmds_symbol,
        serial => tmds_out_ch2);

--ser_clk: serialiser_10_to_1 Port map (
--        clk    => pixel_io_clk_x1,
--        clk_x5 => pixel_io_clk_x5,
--        reset  => reset,
--        data   => "0000011111",
--        serial => tmds_out_clk);
tmds_out_clk <= pixel_io_clk_x1; 
--tmds_out_clk <= pixel_clk;

--My Serialiser--
--serialiser: mySerial port map(
--    clk => pixel_io_clk_x1,
--    outclk_p => outclk_p,
--    clk5 => pixel_io_clk_x5,
--    nclk5 => pixel_io_nclk_x5,
--    d0=>c0_tmds_symbol, d1=>c1_tmds_symbol, d2=>c2_tmds_symbol,
--    q0 =>  tmds_out_ch0, q1 =>  tmds_out_ch1, q2 =>  tmds_out_ch2,
--    tx_clk => tmds_out_clk
--);

end Behavioral;
