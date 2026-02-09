library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- =========================================
-- Debounce + Pulse Generator for Pushbuttons
-- =========================================
-- This module:
--  - Debounces a mechanical pushbutton
--  - Generates a single-clock pulse on rising edge
--
-- Input:
--   clk       : system clock (e.g. 100 MHz)
--   reset     : synchronous reset
--   btn_in    : raw pushbutton input (active high)
--
-- Output:
--   pulse_out : one-clock-wide pulse on button press
--   level_out : debounced button level (optional use)
--
-- Typical use:
--   Connect pulse_out to 'start' of CORDIC wrapper
-- =========================================

entity debounce_pulse is
    generic (
        -- Number of clock cycles for debounce window.
        -- For 100 MHz clock:
        --   2_000_000 cycles ≈ 20 ms debounce
        DEBOUNCE_COUNT : integer := 2_000_000
    );
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        btn_in    : in  std_logic;

        pulse_out : out std_logic;
        level_out : out std_logic
    );
end debounce_pulse;

architecture RTL of debounce_pulse is

    -- =========================================
    -- Synchronizer for asynchronous button input
    -- =========================================
    signal btn_sync_0 : std_logic := '0';
    signal btn_sync_1 : std_logic := '0';

    -- =========================================
    -- Debounce counter and stable value
    -- =========================================
    signal stable_btn : std_logic := '0';
    signal cnt        : integer range 0 to DEBOUNCE_COUNT := 0;

    -- =========================================
    -- Edge detect
    -- =========================================
    signal stable_btn_d : std_logic := '0';

begin

    -- =========================================
    -- Input synchronization (2 FFs)
    -- =========================================
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                btn_sync_0 <= '0';
                btn_sync_1 <= '0';
            else
                btn_sync_0 <= btn_in;
                btn_sync_1 <= btn_sync_0;
            end if;
        end if;
    end process;

    -- =========================================
    -- Debounce logic
    -- =========================================
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                cnt        <= 0;
                stable_btn <= '0';
            else
                if btn_sync_1 = stable_btn then
                    cnt <= 0;  -- input matches stable value
                else
                    if cnt = DEBOUNCE_COUNT - 1 then
                        stable_btn <= btn_sync_1;  -- accept new stable value
                        cnt        <= 0;
                    else
                        cnt <= cnt + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    level_out <= stable_btn;

    -- =========================================
    -- Rising edge detection -> single-cycle pulse
    -- =========================================
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                stable_btn_d <= '0';
                pulse_out   <= '0';
            else
                stable_btn_d <= stable_btn;
                pulse_out   <= stable_btn and not stable_btn_d;
            end if;
        end if;
    end process;

end RTL;
