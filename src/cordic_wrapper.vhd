library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

-- =========================================
-- CORDIC Wrapper
-- =========================================
-- Accepts angle in degrees (0..359)
-- Maps angle to [0..90] for CORDIC core
-- Drives CORDIC core
-- Fixes output signs based on quadrant
-- =========================================

entity cordic_wrapper is
    generic (
        WIDTH      : integer := 16;
        ITERATIONS : integer := 16
    );
    port (
        clk       : in  std_logic;
        start     : in  std_logic;
        angle_deg : in  unsigned(8 downto 0); -- 0..359

        busy      : out std_logic;
        done      : out std_logic;

        cos_out   : out signed(WIDTH-1 downto 0);
        sin_out   : out signed(WIDTH-1 downto 0)
    );
end cordic_wrapper;

architecture RTL of cordic_wrapper is

    -- =========================================
    -- Core interface
    -- =========================================
    signal core_start : std_logic;
    signal core_busy  : std_logic;
    signal core_done  : std_logic;

    signal core_angle : signed(WIDTH-1 downto 0); -- Q2.(WIDTH-2)
    signal cos_core   : signed(WIDTH-1 downto 0); -- Q1.(WIDTH-1)
    signal sin_core   : signed(WIDTH-1 downto 0); -- Q1.(WIDTH-1)

    -- Latched normalization
    signal quadrant_r  : unsigned(1 downto 0);
    signal angle_deg_r : integer range 0 to 90;

    -- start delayed (avoid race)
    signal start_d : std_logic;

    constant SCALE : integer := 2 ** (WIDTH-2);  -- Q2.(WIDTH-2)

    -- =========================================
    -- Degrees -> fixed-point radians
    -- Q2.(WIDTH-2)
    -- =========================================
    function deg_to_rad_fixed(deg : integer) return signed is
        variable rad_real  : real;
        variable rad_fixed : integer;
    begin
        rad_real  := real(deg) * math_pi / 180.0;
        rad_fixed := integer(rad_real * real(SCALE));
        return to_signed(rad_fixed, WIDTH);
    end function;

begin

    -- =========================================
    -- Latch angle and quadrant on start
    -- (only when core is idle to avoid quadrant glitches)
    -- =========================================
    process(clk)
        variable a : integer;
        variable ang_norm : integer;
    begin
        if rising_edge(clk) then
            if start = '1' and core_busy = '0' then
                a := to_integer(angle_deg);

                if a < 90 then
                    quadrant_r  <= "00"; -- Q1
                    ang_norm    := a;

                elsif a < 180 then
                    quadrant_r  <= "01"; -- Q2
                    ang_norm    := 180 - a;

                elsif a < 270 then
                    quadrant_r  <= "10"; -- Q3
                    ang_norm    := a - 180;

                else
                    quadrant_r  <= "11"; -- Q4
                    ang_norm    := 360 - a;
                end if;

                -- Optional safety clamp to avoid 90° exact (CORDIC edge case)
                -- if ang_norm > 89 then
                --     ang_norm := 89;
                -- end if;

                angle_deg_r <= ang_norm;
            end if;
        end if;
    end process;

    -- =========================================
    -- Delay start by 1 clock
    -- =========================================
    process(clk)
    begin
        if rising_edge(clk) then
            start_d <= start;
        end if;
    end process;

    core_start <= start_d;
    core_angle <= deg_to_rad_fixed(angle_deg_r);

    -- =========================================
    -- CORDIC core
    -- =========================================
    cordic_i : entity work.cordic_core
        generic map (
            WIDTH      => WIDTH,
            ITERATIONS => ITERATIONS
        )
        port map (
            clk     => clk,
            start   => core_start,
            angle   => core_angle,
            busy    => core_busy,
            done    => core_done,
            cos_out => cos_core,
            sin_out => sin_core
        );

    -- =========================================
    -- Quadrant sign correction
    -- (quadrant_r is stable for the whole computation)
    -- =========================================
    process(cos_core, sin_core, quadrant_r)
    begin
        case quadrant_r is
            when "00" => -- Q1 (0° .. 90°)
                cos_out <=  cos_core;
                sin_out <=  sin_core;

            when "01" => -- Q2 (90° .. 180°)
                cos_out <= -cos_core;
                sin_out <=  sin_core;

            when "10" => -- Q3 (180° .. 270°)
                cos_out <= -cos_core;
                sin_out <= -sin_core;

            when others => -- Q4 (270° .. 360°)
                cos_out <=  cos_core;
                sin_out <= -sin_core;
        end case;
    end process;

    busy <= core_busy;
    done <= core_done;

end RTL;
