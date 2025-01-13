----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- Modified By; Qishi Hu
-- Create Date: 30.07.2015 23:11:34
-- Module Name: input_channel - Behavioral
--
-- Description: Receiving one of the three HDMI input channels. and decoding 
-- 


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity input_channel is
    Port ( clk_mgmt        : in STD_LOGIC;
           clk             : in  STD_LOGIC;
           clk_x1          : in  STD_LOGIC;
           clk_x5          : in  STD_LOGIC;
           serial          : in  STD_LOGIC;
           reset           : in  std_logic;
           ce              : in  STD_LOGIC;
           invalid_symbol  : out std_logic;
           symbol          : out std_logic_vector (9 downto 0);
           ctl_valid       : out std_logic;
           ctl             : out std_logic_vector (1 downto 0);
           terc4_valid     : out std_logic;
           terc4           : out std_logic_vector (3 downto 0);
           guardband_valid : out std_logic;
           guardband       : out std_logic_vector (0 downto 0);
           data_valid      : out std_logic;
           data            : out std_logic_vector (7 downto 0);
           symbol_sync     : out STD_LOGIC);
end input_channel;

architecture Behavioral of input_channel is
    component deserialiser_1_to_10 is
    Port ( clk_mgmt    : in  std_logic;
           delay_ce    : in std_logic;
           delay_count : in std_logic_vector (4 downto 0);
           ce          : in  STD_LOGIC;
           clk         : in std_logic;
           clk_x1      : in std_logic;
           bitslip     : in std_logic;
           clk_x5      : in std_logic;
           reset       : in std_logic;
           serial      : in std_logic;
           data        : out std_logic_vector (9 downto 0));
    end component;
    
    component TMDS_decoder is
    Port ( clk             : in  std_logic;
           symbol          : in  std_logic_vector (9 downto 0);
           invalid_symbol  : out std_logic;
           ctl_valid       : out std_logic;
           ctl             : out std_logic_vector (1 downto 0);
           terc4_valid     : out std_logic;
           terc4           : out std_logic_vector (3 downto 0);
           guardband_valid : out std_logic;
           guardband       : out std_logic_vector (0 downto 0);
           data_valid      : out std_logic;
           data            : out std_logic_vector (7 downto 0));
    end component;
    
    component alignment_detect is
        Port ( clk            : in STD_LOGIC;
               invalid_symbol : in STD_LOGIC;
               delay_count    : out STD_LOGIC_VECTOR(4 downto 0);
               delay_ce       : out STD_LOGIC;
               bitslip        : out STD_LOGIC;
               symbol_sync    : out STD_LOGIC);
    end component;

    signal delay_count     : std_logic_vector (4 downto 0);
    signal delay_ce        : STD_LOGIC;
    signal bitslip         : STD_LOGIC;
    signal symbol_sync_i   : STD_LOGIC;
    signal symbol_i        : std_logic_vector (9 downto 0);
    signal invalid_symbol_i: STD_LOGIC;

begin
    symbol <= symbol_i;

i_deser: deserialiser_1_to_10 port map (
        clk_mgmt    => clk_mgmt,
        delay_ce    => delay_ce,
        delay_count => delay_count,
        ce          => ce,
        clk         => clk,
        clk_x1      => clk_x1,
        bitslip     => bitslip,
        clk_x5      => clk_x5,
        reset       => reset,
        serial      => serial,
        data        => symbol_i);

i_decoder: tmds_decoder port map (
        clk             => clk,
        symbol          => symbol_i,
        invalid_symbol  => invalid_symbol_i,
        ctl_valid       => ctl_valid,
        ctl             => ctl,
        terc4_valid     => terc4_valid,
        terc4           => terc4,
        guardband_valid => guardband_valid,
        guardband       => guardband,
        data_valid      => data_valid,
        data            => data
    );
    
    invalid_symbol <= invalid_symbol_i;
     
i_alignment_detect: alignment_detect port map (
           clk            => clk,
           invalid_symbol => invalid_symbol_i,
           delay_count    => delay_count,
           delay_ce       => delay_ce,
           bitslip        => bitslip,
           symbol_sync    => symbol_sync);

end Behavioral;
