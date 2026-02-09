library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- =========================================
-- Top level for Nexys4 DDR + CORDIC demo
-- =========================================
-- This module connects:
--  - Nexys4 DDR switches to CORDIC angle input
--  - Nexys4 DDR pushbutton to CORDIC start
--  - Switch to select sin / cos
--  - 7-segment display to show result
--
-- User interaction:
--  SW[8:0]  -> angle in degrees (0..359, binary)
--  BTN0     -> start computation (debounced, 1-pulse)
--  SW9      -> 0 = show cos, 1 = show sin
--  LED0     -> sign of result (1 = negative)
--  LED1     -> CORDIC busy
--  LED2     -> CORDIC done
-- =========================================

entity top_nexys is
    generic (
        WIDTH      : integer := 16;
        ITERATIONS : integer := 16
    );
    port (
        -- Clock from Nexys4 DDR (100 MHz)
        clk100mhz : in  std_logic;

        -- User inputs
        sw  : in  std_logic_vector(15 downto 0);  -- switches
        btn : in  std_logic_vector(4 downto 0);   -- pushbuttons

        -- User outputs
        led : out std_logic_vector(15 downto 0);  -- LEDs
        an  : out std_logic_vector(7 downto 0);   -- 7-seg anodes (active low)
        seg : out std_logic_vector(6 downto 0)    -- 7-seg segments (g..a, active low)
    );
end top_nexys;

architecture RTL of top_nexys is

    -- =========================================
    -- Clocking
    -- =========================================
    signal clk_sys   : std_logic;  -- main system clock (100 MHz)

    -- =========================================
    -- User control signals
    -- =========================================
    signal angle_deg   : unsigned(8 downto 0); -- 0..359 from switches
    signal start_pulse : std_logic;            -- debounced start pulse
    signal sel_sin     : std_logic;            -- 1 = sin, 0 = cos

    -- =========================================
    -- CORDIC interface
    -- =========================================
    signal cordic_busy : std_logic;
    signal cordic_done : std_logic;
    signal cos_val     : signed(WIDTH-1 downto 0);
    signal sin_val     : signed(WIDTH-1 downto 0);

    -- =========================================
    -- Display path
    -- =========================================
    signal result_sel : signed(WIDTH-1 downto 0);     -- selected sin/cos
    signal result_abs : unsigned(WIDTH-1 downto 0);   -- absolute value
    signal result_neg : std_logic;                    -- sign flag

    -- Decimal value x1000 (0..1000)
    signal disp_value : unsigned(15 downto 0);

    -- Decimal digits for 7-seg display
    signal digit0 : unsigned(3 downto 0); -- units
    signal digit1 : unsigned(3 downto 0); -- tens
    signal digit2 : unsigned(3 downto 0); -- hundreds
    signal digit3 : unsigned(3 downto 0); -- thousands

begin

    -- =========================================
    -- Clock assignments
    -- =========================================
    clk_sys <= clk100mhz;

    -- =========================================
    -- User input mapping
    -- =========================================
    angle_deg <= unsigned(sw(8 downto 0));  -- SW[8:0] = angle
    sel_sin   <= sw(9);                     -- SW9 selects sin/cos

    -- =========================================
    -- Debounce + pulse for start button (BTN0)
    -- =========================================
    debounce_inst : entity work.debounce_pulse
        generic map (
            DEBOUNCE_COUNT => 2_000_000
        )
        port map (
            clk       => clk_sys,
            reset     => '0',
            btn_in    => btn(0),
            pulse_out => start_pulse,
            level_out => open
        );

    -- =========================================
    -- CORDIC wrapper instance
    -- =========================================
    cordic_inst : entity work.cordic_wrapper
        generic map (
            WIDTH      => WIDTH,
            ITERATIONS => ITERATIONS
        )
        port map (
            clk       => clk_sys,
            start     => start_pulse,
            angle_deg => angle_deg,
            busy      => cordic_busy,
            done      => cordic_done,
            cos_out   => cos_val,
            sin_out   => sin_val
        );

    -- =========================================
    -- Select sin or cos for display
    -- =========================================
    result_sel <= sin_val when sel_sin = '1' else cos_val;

    -- =========================================
    -- Extract sign and absolute value
    -- =========================================
    result_neg <= result_sel(WIDTH-1);

    process(result_sel)
    begin
        if result_sel(WIDTH-1) = '1' then
            result_abs <= unsigned(-result_sel);
        else
            result_abs <= unsigned(result_sel);
        end if;
    end process;

    -- =========================================
    -- Fixed-point -> decimal *1000 conversion
    -- Q1.(WIDTH-1) -> integer in range 0..1000
    -- =========================================
    process(result_abs)
        variable mult_var : unsigned((2*WIDTH)-1 downto 0);
        variable scaled   : unsigned((2*WIDTH)-1 downto 0);
    begin
        mult_var := result_abs * to_unsigned(1000, WIDTH);
        scaled   := shift_right(mult_var, WIDTH-1);
        disp_value <= resize(scaled, 16);
    end process;

    -- =========================================
    -- Extract decimal digits
    -- =========================================
    process(disp_value)
        variable tmp : integer;
    begin
        tmp := to_integer(disp_value);

        if tmp > 9999 then
            tmp := 9999; -- safety clamp
        end if;

        digit0 <= to_unsigned(tmp mod 10, 4);
        digit1 <= to_unsigned((tmp / 10) mod 10, 4);
        digit2 <= to_unsigned((tmp / 100) mod 10, 4);
        digit3 <= to_unsigned((tmp / 1000) mod 10, 4);
    end process;

    -- =========================================
    -- LEDs (debug / sign)
    -- =========================================
    led(0)  <= result_neg;     -- sign
    led(1)  <= cordic_busy;   -- busy
    led(2)  <= cordic_done;   -- done
    led(15 downto 3) <= (others => '0');

    -- =========================================
    -- 7-segment display driver (decimal)
    -- =========================================
    sevenseg_inst : entity work.seven_seg_driver
        port map (
            clk    => clk100mhz,
            digit0 => digit0,
            digit1 => digit1,
            digit2 => digit2,
            digit3 => digit3,
            an     => an,
            seg    => seg
        );

end RTL;
