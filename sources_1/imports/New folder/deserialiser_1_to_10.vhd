-- Company: 
-- Engineer: Qihsi Hu 
-- Create Date: 12/05/2024 08:04:50 PM
-- Design Name: 
-- Description: A 10-to-1 deserialiser using ISERDESE2 with dealy control

library IEEE;
use IEEE.std_logic_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity deserialiser_1_to_10 is
    Port ( clk_mgmt    : in  std_logic;
           delay_ce    : in  std_logic;
           delay_count : in  std_logic_vector (4 downto 0);
           
           ce          : in  STD_LOGIC;
           clk         : in  std_logic;
           clk_x1      : in  std_logic;
           bitslip     : in  std_logic;
           clk_x5      : in  std_logic;
           serial      : in  std_logic;
           reset       : in  std_logic;
           data        : out std_logic_vector (9 downto 0));
end deserialiser_1_to_10;

architecture Behavioral of deserialiser_1_to_10 is
    signal delayed : std_logic := '0';
    signal shift1  : std_logic := '0';
    signal shift2  : std_logic := '0';
    signal clkb    : std_logic := '1';
    signal ce_slave    : std_logic ;
    signal ce_buf : std_logic ;
    attribute IODELAY_GROUP : STRING;
    attribute IODELAY_GROUP of IDELAYE2_inst: label is "idelay_group";

begin
--process(clk)
--begin
--    if rising_edge(clk) then        
--        ce_buf <= ce;
--        ce_slave <= ce_buf;
--    end if;
--end process;

IDELAYE2_inst : IDELAYE2
    generic map (
          CINVCTRL_SEL          => "FALSE",
          DELAY_SRC             => "DATAIN",
          HIGH_PERFORMANCE_MODE => "TRUE",
          IDELAY_TYPE           => "VAR_LOAD",
          IDELAY_VALUE          => 0,
          PIPE_SEL              => "FALSE",
          REFCLK_FREQUENCY      => 200.0,
          SIGNAL_PATTERN        => "DATA"
    )
    port map (
          DATAIN      => serial,
          IDATAIN     => '0',
          DATAOUT     => delayed,
          --
          CNTVALUEOUT => open,
          C           => clk,
          CE          => delay_ce,
          CINVCTRL    => '0',
          CNTVALUEIN  => delay_count,
          INC         => '0',
          LD          => '1',
          LDPIPEEN    => '0',
          REGRST      => '0'
    );
    clkb <= not clk_x5;

ISERDESE2_master : ISERDESE2
   generic map (
      DATA_RATE         => "DDR",
      DATA_WIDTH        => 10,
      DYN_CLKDIV_INV_EN => "FALSE",
      DYN_CLK_INV_EN    => "FALSE",
      INIT_Q1 => '0', INIT_Q2 => '0', INIT_Q3 => '0', INIT_Q4 => '0',
      INTERFACE_TYPE    => "NETWORKING",
      IOBDELAY          => "IFD",
      NUM_CE            => 1,
      OFB_USED          => "FALSE",
      SERDES_MODE       => "MASTER",
      SRVAL_Q1 => '0', SRVAL_Q2 => '0', SRVAL_Q3 => '0', SRVAL_Q4 => '0' 
   )
   port map (
      O => open,
      Q1 => data(9), Q2 => data(8), Q3 => data(7), Q4 => data(6),
      Q5 => data(5), Q6 => data(4), Q7 => data(3), Q8 => data(2),
      SHIFTOUT1 => shift1, SHIFTOUT2 => shift2,
      BITSLIP   => bitslip,
      CE1 => ce, 
      --CE1 => '1',
      CE2 => '1',
      CLKDIVP      => '0',
      CLK          => clk_x5,
      CLKB         => clkb,
      CLKDIV       => clk_x1,
      OCLK         => '0', 
      DYNCLKDIVSEL => '0',
      DYNCLKSEL    => '0',
      D            => '0',
      DDLY         => delayed,
      OFB          => '0',
      OCLKB        => '0',
      RST          => reset,
      SHIFTIN1     => '0',
      SHIFTIN2     => '0' 
   );
               
ISERDESE2_slave : ISERDESE2
   generic map (
      DATA_RATE         => "DDR",
      DATA_WIDTH        => 10,
      DYN_CLKDIV_INV_EN => "FALSE",
      DYN_CLK_INV_EN    => "FALSE",
      INIT_Q1 => '0', INIT_Q2 => '0', INIT_Q3 => '0', INIT_Q4 => '0',
      INTERFACE_TYPE    => "NETWORKING",
      IOBDELAY          => "IFD",
      NUM_CE            => 1,
      OFB_USED          => "FALSE",
      SERDES_MODE       => "SLAVE",  
      SRVAL_Q1 => '0', SRVAL_Q2 => '0', SRVAL_Q3 => '0', SRVAL_Q4 => '0' 
   )
   port map (
      O => open,
      Q1 => open, Q2 => open, Q3 => data(1), Q4 => data(0),
      Q5 => open, Q6 => open, Q7 => open,    Q8 => open,
      SHIFTOUT1 => open, SHIFTOUT2 => open,
      BITSLIP   => bitslip,
      CE1 => ce, 
     --CE1 => '1',
      CE2 => '1',
      CLKDIVP      => '0',
      CLK          => CLK_x5,
      CLKB         => clkb,
      CLKDIV       => clk_x1,
      OCLK         => '0', 
      DYNCLKDIVSEL => '0',
      DYNCLKSEL    => '0',
      D            => '0',
      DDLY         => '0',
      OFB          => '0',
      OCLKB        => '0',
      RST          => reset,
      SHIFTIN1     => shift1,
      SHIFTIN2     => shift2 
   );
end Behavioral;