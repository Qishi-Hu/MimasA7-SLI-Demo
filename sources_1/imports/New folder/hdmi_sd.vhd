-- Company: 
-- Engineer: Qihsi Hu 
-- Create Date: 12/05/2024 08:04:50 PM
-- Design Name: 
-- Module Name: hdmi_design
-- Description: top moudle

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity hdmi_sd is
    Port ( 
        clk100    : in STD_LOGIC;
        led           : out   std_logic_vector(7 downto 0) :=(others => '0');
        sw            : in    std_logic_vector(7 downto 0) :=(others => '0');
        en : out    std_logic_vector(3 downto 0) :=(others => '1'); -- 7 seg enable
        seg : out    std_logic_vector(7 downto 0) :=(others => '1');
        BTNL: in std_logic; --left button; toggle pass-through/SD mode
        BTNT: in std_logic; --top button; toggle noraml/slow-motion for SD pattern gen
        BTNR: in std_logic; --right button; reset hdmi_out
        -- four-line handsake signals for two camera interfaces
        C1_out : out    std_logic_vector(1 downto 0);
        C1_in : in    std_logic_vector(1 downto 0);
        C2_out : out    std_logic_vector(1 downto 0);
        C2_in : in    std_logic_vector(1 downto 0);
       -- VS    : out STD_LOGIC;
       -- fg : out STD_LOGIC;
       
       -- Micro SD
       sd_clk: out   std_logic;
       sd_cs: out   std_logic;
       sd_mosi: out   std_logic;
       sd_miso: in   std_logic;
        --HDMI input signals
        hdmi_rx_cec   : inout std_logic;
        hdmi_rx_hpa   : out   std_logic;
        hdmi_rx_scl   : in    std_logic;
        hdmi_rx_sda   : inout std_logic;
        hdmi_rx_clk_n : in    std_logic;
        hdmi_rx_clk_p : in    std_logic;
        hdmi_rx_n     : in    std_logic_vector(2 downto 0);
        hdmi_rx_p     : in    std_logic_vector(2 downto 0);

        --- HDMI out
--        hdmi_tx_cec   : inout std_logic;
        hdmi_tx_clk_n : out   std_logic;
        hdmi_tx_clk_p : out   std_logic;
--        hdmi_tx_hpd   : in    std_logic;
--        hdmi_tx_rscl  : inout std_logic;
--        hdmi_tx_rsda  : inout std_logic;
        hdmi_tx_p     : out   std_logic_vector(2 downto 0);
        hdmi_tx_n     : out   std_logic_vector(2 downto 0)     
    );
end hdmi_sd;

architecture Behavioral of hdmi_sd is
    -- sd signals
    signal file_found : std_logic;
    signal sd_cs_buf: std_logic;
    signal sd_clk_buf: std_logic;
    component ref_clk is
    Port (
        clk_in    : in STD_LOGIC;    
        clk_out : out STD_LOGIC;
        clk10 : out STD_LOGIC;
        clk75 : out STD_LOGIC;
        clk375 : out STD_LOGIC
    );
    end component;
    component hdmi_io is
    Port ( 
        clk100    : in STD_LOGIC;
        clk200    : in STD_LOGIC;
        clk75 : in STD_LOGIC;
        clk375 : in STD_LOGIC;
        -------------------------------
        -- Control signals
        -------------------------------
        clock_locked  : out std_logic;
        data_synced   : out std_logic;
        debug         : out std_logic_vector(7 downto 0);  
        sel : out std_logic;     BTNR: in std_logic;  
        -------------------------------
        --HDMI input signals
        -------------------------------
        hdmi_rx_cec   : inout std_logic;
        hdmi_rx_hpa   : out   std_logic;
        hdmi_rx_scl   : in    std_logic;
        hdmi_rx_sda   : inout std_logic;
        hdmi_rx_clk_n : in    std_logic;
        hdmi_rx_clk_p : in    std_logic;
        hdmi_rx_n     : in    std_logic_vector(2 downto 0);
        hdmi_rx_p     : in    std_logic_vector(2 downto 0);

        -------------
        -- HDMI out
        -------------
       -- hdmi_tx_cec   : inout std_logic;
        hdmi_tx_clk_n : out   std_logic;
        hdmi_tx_clk_p : out   std_logic;
       -- hdmi_tx_hpd   : in    std_logic;
       -- hdmi_tx_rscl  : inout std_logic;
       -- hdmi_tx_rsda  : inout std_logic;
        hdmi_tx_p     : out   std_logic_vector(2 downto 0);
        hdmi_tx_n     : out   std_logic_vector(2 downto 0);

        pixel_clk     : out std_logic;
        -------------------------------
        -- VGA data recovered from HDMI
        -------------------------------
        in_hdmi_detected : out std_logic;
        in_blank        : out std_logic;
        in_hsync        : out std_logic;
        in_vsync        : out std_logic;
        in_red          : out std_logic_vector(7 downto 0);
        in_green        : out std_logic_vector(7 downto 0);
        in_blue         : out std_logic_vector(7 downto 0);
        is_interlaced   : out std_logic;
        is_second_field : out std_logic;
            
        -------------------------------------
        -- Audio Levels
        -------------------------------------
        audio_channel : out std_logic_vector(2 downto 0);
        audio_de      : out std_logic;
        audio_sample  : out std_logic_vector(23 downto 0);
        
        -----------------------------------
        -- VGA data to be converted to HDMI
        -----------------------------------
        out_blank     : in  std_logic;
        out_hsync     : in  std_logic;
        out_vsync     : in  std_logic;
        out_red       : in  std_logic_vector(7 downto 0);
        out_green     : in  std_logic_vector(7 downto 0);
        out_blue      : in  std_logic_vector(7 downto 0);
        -----------------------------------
        -- For symbol dump or retransmit
        -----------------------------------
        symbol_sync  : out std_logic; -- indicates a fixed reference point in the frame.
        symbol_ch0   : out std_logic_vector(9 downto 0);
        symbol_ch1   : out std_logic_vector(9 downto 0);
        symbol_ch2   : out std_logic_vector(9 downto 0)
    );
    end component;
    signal clk200  : std_logic;
    signal clk10  : std_logic;
    signal clk75  : std_logic;
    signal clk375  : std_logic;
    signal local_pclk  : std_logic;
    signal local_pclkx5 : std_logic;
    signal local : std_logic := '0';
    signal symbol_sync  : std_logic;
    signal symbol_ch0   : std_logic_vector(9 downto 0);
    signal symbol_ch1   : std_logic_vector(9 downto 0);
    signal symbol_ch2   : std_logic_vector(9 downto 0);
    signal debug_pmod    :   std_logic_vector(7 downto 0) :=(others => '0');
    
    
    signal sel: std_logic;
    
    component pixel_pipe is
        Port ( clk : in STD_LOGIC;  clk10 : in STD_LOGIC; 
        bt : in std_logic_vector(1 downto 0); -- push button 
         en : out    std_logic_vector(3 downto 0); -- 7 seg enable
        seg : out    std_logic_vector(7 downto 0);
        trig    : out STD_LOGIC;
            ------------------
            in_blank  : in std_logic;
            in_hsync  : in std_logic;
            in_vsync  : in std_logic;
            in_red    : in std_logic_vector(7 downto 0);
            in_green  : in std_logic_vector(7 downto 0);
            in_blue   : in std_logic_vector(7 downto 0);

            -------------------
            out_blank : out std_logic;
            out_hsync : out std_logic;
            out_vsync : out std_logic;
            out_red   : out std_logic_vector(7 downto 0);
            out_green : out std_logic_vector(7 downto 0);
            out_blue  : out std_logic_vector(7 downto 0);
            ---SD signals--
            sd_clk: out   std_logic;
            sd_cs: out   std_logic;
            sd_mosi: out   std_logic;
            sd_miso: in   std_logic;
            file_found: out   std_logic
            
    );
    end component;


    signal pixel_clk : std_logic;
    signal in_blank  : std_logic;
    signal in_hsync  : std_logic;
    signal in_vsync  : std_logic;
    signal in_red    : std_logic_vector(7 downto 0);
    signal in_green  : std_logic_vector(7 downto 0);
    signal in_blue   : std_logic_vector(7 downto 0);
    signal is_interlaced   : std_logic;
    signal is_second_field : std_logic;
    signal out_blank : std_logic;
    signal out_hsync : std_logic;
    signal out_vsync : std_logic;
    signal out_red   : std_logic_vector(7 downto 0);
    signal out_green : std_logic_vector(7 downto 0);
    signal out_blue  : std_logic_vector(7 downto 0);

    signal audio_channel : std_logic_vector(2 downto 0);
    signal audio_de      : std_logic;
    signal audio_sample  : std_logic_vector(23 downto 0);
    signal trig : std_logic;
    signal debug : std_logic_vector(7 downto 0);
begin
    debug_pmod <= debug;    
    led  (7 downto 6)      <= debug (7 downto 6);
    -- for test GPIO input pins
    --led (5)   <= C1_in(1);    led (4)   <= C1_in(0);     led (3)   <= C2_in(1);    led (2)   <= C2_in(0);
    -- verify clock selector
    led (5)   <= '0';    led (4)   <= '0';     led (3)   <= '0';    led (2)   <= sel;
    
    -- for SD debugging
    led (1) <= file_found; 
        
    -- for GPIO output pins, we tie them all to trigers

    C1_out(0)  <= trig; C1_out(1)  <= '0';

    
    C2_out(0)  <= trig; C2_out(1)  <= '0';
    led (0)   <= trig;
 

    
i_hdmi_io: hdmi_io port map ( 
        clk100        => clk100,
         clk200        => clk200,
         clk75        => clk75,
         clk375        => clk375,
        ---------------------
        -- Control signals
        ---------------------
        clock_locked     => open,
        data_synced      => open,
        debug            => debug,
        sel => sel, BTNR => BTNR,
        ---------------------
        -- HDMI input signals
        ---------------------
        hdmi_rx_cec   => hdmi_rx_cec,
        hdmi_rx_hpa   => hdmi_rx_hpa,
        hdmi_rx_scl   => hdmi_rx_scl,
        hdmi_rx_sda   => hdmi_rx_sda,
        hdmi_rx_clk_n => hdmi_rx_clk_n,
        hdmi_rx_clk_p => hdmi_rx_clk_p,
        hdmi_rx_p     => hdmi_rx_p,
        hdmi_rx_n     => hdmi_rx_n,

        ----------------------
        -- HDMI output signals
        ----------------------
     --   hdmi_tx_cec   => hdmi_tx_cec,
        hdmi_tx_clk_n => hdmi_tx_clk_n,
        hdmi_tx_clk_p => hdmi_tx_clk_p,
--        hdmi_tx_hpd   => hdmi_tx_hpd,
--        hdmi_tx_rscl  => hdmi_tx_rscl,
--        hdmi_tx_rsda  => hdmi_tx_rsda,
        hdmi_tx_p     => hdmi_tx_p,
        hdmi_tx_n     => hdmi_tx_n,     

        
        pixel_clk => pixel_clk,
        -------------------------------
        -- VGA data recovered from HDMI
        -------------------------------
        in_blank        => in_blank,
        in_hsync        => in_hsync,
        in_vsync        => in_vsync,
        in_red          => in_red,
        in_green        => in_green,
        in_blue         => in_blue,
        is_interlaced   => is_interlaced,
        is_second_field => is_second_field,

        -----------------------------------
        -- For symbol dump or retransmit
        -----------------------------------
        audio_channel => audio_channel,
        audio_de      => audio_de,
        audio_sample  => audio_sample,
        
        -----------------------------------
        -- VGA data to be converted to HDMI
        -----------------------------------
        out_blank => out_blank,
        out_hsync => out_hsync,
        out_vsync => out_vsync,
        out_red   => out_red,
        out_green => out_green,
        out_blue  => out_blue,
        
        symbol_sync  => symbol_sync, 
        symbol_ch0   => symbol_ch0,
        symbol_ch1   => symbol_ch1,
        symbol_ch2   => symbol_ch2
    );
 --------------------------------------------
  --   a 200MHz clock for the IDELAY reference
 --------------------------------------------
ref_clk_pll : ref_clk
    port map (
        clk_in  => clk100,    
        clk_out => clk200,
        clk75 => clk75, clk375 => clk375,
        clk10 => clk10
    );
sd_cs <= sd_cs_buf; 
sd_clk <= sd_clk_buf;


i_processing: pixel_pipe Port map ( 
        clk => pixel_clk, clk10 => clk10,
        en  =>  en, seg => seg, trig =>trig,
        bt => BTNT & BTNL,
        --SD signals
        sd_clk=> sd_clk_buf, sd_cs =>sd_cs_buf,
        sd_mosi=>sd_mosi, sd_miso=>sd_miso, file_found=>file_found,        
        --
        in_blank        => in_blank,
        in_hsync        => in_hsync,
        in_vsync        => in_vsync,
        in_red          => in_red,
        in_green        => in_green,
        in_blue         => in_blue,    
        out_blank => out_blank,
        out_hsync => out_hsync,
        out_vsync => out_vsync,
        out_red   => out_red,
        out_green => out_green,
        out_blue  => out_blue
    );
--Vs  <= out_vsync; 
    -- Swap to this if you want to capture the HDMI symbols
    -- and send them up the RS232 port
    --rs232_tx <= '1';   
    
end Behavioral;