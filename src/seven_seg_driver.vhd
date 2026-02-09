library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- =========================================
-- Seven Segment Display Driver (Nexys4 DDR)
-- =========================================
-- Drives the 8-digit 7-segment display on Nexys4 DDR
-- Uses internal clock divider from 100 MHz
-- Displays 4 decimal digits (BCD)
-- Active-low segments and anodes
--
-- NOTE:
--   seg(6 downto 0) = g f e d c b a   (active low)
--   Digits 4..7 are kept blank
-- =========================================

entity seven_seg_driver is
    generic (
        COUNTER_BITS : integer := 20  -- 100 MHz / 2^20 ? 95 Hz per digit
    );
    port (
        clk    : in  std_logic;                -- use 100 MHz clock

        digit0 : in  unsigned(3 downto 0);     -- least significant digit (units)
        digit1 : in  unsigned(3 downto 0);     -- tens
        digit2 : in  unsigned(3 downto 0);     -- hundreds
        digit3 : in  unsigned(3 downto 0);     -- thousands

        an     : out std_logic_vector(7 downto 0);  -- active low
        seg    : out std_logic_vector(6 downto 0)   -- active low (g..a)
    );
end seven_seg_driver;

architecture RTL of seven_seg_driver is

    -- Refresh counter for multiplexing
    signal flick_counter : unsigned(COUNTER_BITS-1 downto 0) := (others => '0');

    -- Digit selector (0..7)
    signal digit_sel : unsigned(2 downto 0);

    -- Current 4-bit digit to display
    signal digit : unsigned(3 downto 0);

    -- Internal segment and anode buses
    signal seg_int : std_logic_vector(6 downto 0);
    signal an_int  : std_logic_vector(7 downto 0);

begin

    -- =========================================
    -- Clock divider / refresh counter
    -- =========================================
    process(clk)
    begin
        if rising_edge(clk) then
            flick_counter <= flick_counter + 1;
        end if;
    end process;

    digit_sel <= flick_counter(COUNTER_BITS-1 downto COUNTER_BITS-3);

    -- =========================================
    -- Select which decimal digit to display
    -- Only digits 0..3 are used
    -- =========================================
    with digit_sel select
        digit <=
            digit0 when "000",
            digit1 when "001",
            digit2 when "010",
            digit3 when "011",
            "1111" when others; -- blank for digits 4..7

    -- =========================================
    -- Decimal (0..9) to 7-seg encoding (active low)
    -- seg(6 downto 0) = g f e d c b a
    -- =========================================
    with digit select
        seg_int <=
            "1000000" when "0000", -- 0
            "1111001" when "0001", -- 1
            "0100100" when "0010", -- 2
            "0110000" when "0011", -- 3
            "0011001" when "0100", -- 4
            "0010010" when "0101", -- 5
            "0000010" when "0110", -- 6
            "1111000" when "0111", -- 7
            "0000000" when "1000", -- 8
            "0010000" when "1001", -- 9
            "1111111" when others; -- blank / invalid

    -- =========================================
    -- Anode selection (active low)
    -- =========================================
    with digit_sel select
        an_int <=
            "11111110" when "000",
            "11111101" when "001",
            "11111011" when "010",
            "11110111" when "011",
            "11111111" when others;  -- digits 4..7 off

    -- =========================================
    -- Registered outputs (avoid glitches)
    -- =========================================
    process(clk)
    begin
        if rising_edge(clk) then
            an  <= an_int;
            seg <= seg_int;
        end if;
    end process;

end RTL;
