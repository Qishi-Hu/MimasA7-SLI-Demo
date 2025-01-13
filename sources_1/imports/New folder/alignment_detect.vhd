-- Engineer: Qihsi Hu 
-- Create Date: 12/05/2024 08:04:50 PM
-- Design Name: 
-- Description: Manage the dealy and bitslipping of the SERDES based on invald words

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alignment_detect is
    Port ( clk            : in  STD_LOGIC;
           invalid_symbol : in  STD_LOGIC;
           delay_count    : out std_logic_vector(4 downto 0);
           delay_ce       : out STD_LOGIC;
           bitslip        : out STD_LOGIC;
           symbol_sync    : out STD_LOGIC);
end alignment_detect;

architecture Behavioral of alignment_detect is
    --------------------------------------
    -- Signals for controlling the bitslip 
    -- and delay so we can sync symbols
    --------------------------------------
    signal count          : unsigned(19 downto 0) := (others => '0');
    signal signal_quality : unsigned(27 downto 0) := (others => '0');
    signal holdoff        : unsigned(9 downto 0)  := (others => '0');
    signal error_seen     : std_logic := '0';
    signal idelay_ce      : std_logic                    := '0';
    signal idelay_count   : std_logic_vector(4 downto 0) := (others => '0');
    signal symbol_sync_i  : std_logic                    := '0';

begin
    delay_count <= idelay_count;
    delay_ce    <= idelay_ce;
 
detect_alignment_proc: process(clk)
    begin
        -------------------------------------------------------------
        -- If there are a dozen or so symbol errors in at a rate of 
        -- greater than 1 in a million then advance the delay and
        -- if that wraps then assert the bitslip signal
        -------------------------------------------------------------
        if rising_edge(clk) then
            -----------------------------------
            -- See if an error has been seen
            --
            -- Holdoff gives a few cycles for 
            -- bitslips and delay changes to 
            -- take effect.
            -----------------------------------
            error_seen <= '0';
            if holdoff = 0 then
                if invalid_symbol = '1' then
                    error_seen <= '1';
                end if;
            else 
                holdoff <= holdoff-1;
            end if;
            ---------------------------------------------
            -- Keep track of valid symbol count vs errors
            -- 
            -- Each error increase the count by a million, 
            -- each valid sysmbol decreases the count by 
            -- one. So after 12 errors it will cause us to
            -- change bitslip or delay settings, but it will
            -- take 7 million cycles until the high four 
            -- bits are zeros (and the link considered OK)
            -----------------------------------------------
            bitslip <= '0';
            idelay_ce <= '0';
            if error_seen = '1' then
                if signal_quality(27 downto 24) = x"F" then
                    ------------------------------------------
                    -- Enough errors to cause us to loose sync 
                    -- (if we had it!) 
                    ------------------------------------------
                    symbol_sync_i         <= '0';
                    --------------------------------------                    
                    -- Hold off acting on any more errors
                    -- while we adjust the delay or bitslip
                    --------------------------------------                    
                    holdoff <= (others => '1');                    
                    -----------------------
                    -- Bitslip if required
                    -----------------------
                    if unsigned(idelay_count) = 31 then   
                        bitslip <= '1';
                    end if;
                    -------------------------------------------------------------------
                    -- And adjust the delay setting (will wrap to 0 when bitslipping)
                    -------------------------------------------------------------------
                    idelay_count  <= std_logic_vector(unsigned(idelay_count)+1);
                    idelay_ce <= '1';   
                    -------------------------------------------------------------------
                    -- It will need 4M good symbols to avoid adjusting the timing again 
                    -------------------------------------------------------------------
                    signal_quality(27 downto 24) <= x"4";
                else
                    signal_quality <= signal_quality + x"100000";   -- add a million if there is a symbol error
                end if;
            else 
                -----------------------------------------------
                -- Count down by one, as we are one symbol 
                -- closer to having a valid stream
                -----------------------------------------------
                if signal_quality(27 downto 24) > 0 then
                    signal_quality <= signal_quality - 1;   -- add a million if there is a symvole error;
                end if;        
            end if;
            ------------------------------------
            -- if we have counted down about 3M
            -- symbols without any symbol errors
            -- being seen then we are in sync
            ------------------------------------
            if signal_quality(27 downto 24) = "0000" then 
                symbol_sync <= '1';
            end if;
        end if;        
    end process;

end Behavioral;
