library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

-- ============================
-- CORDIC Core Testbench
-- ============================
-- Tests the iterative CORDIC core
-- Angles limited to [-90°, +90°]
-- Converts fixed-point outputs to real
-- ============================

entity tb_cordic_core is
end tb_cordic_core;

architecture Behavioral of tb_cordic_core is

    constant WIDTH      : integer := 16;
    constant ITERATIONS : integer := 16;
    constant CLK_PERIOD : time := 10 ns;

    -- ============================
    -- DUT signals
    -- ============================
    signal clk     : std_logic := '0';
    signal start   : std_logic := '0';
    signal angle   : signed(WIDTH-1 downto 0);
    signal busy    : std_logic;
    signal done    : std_logic;
    signal cos_out : signed(WIDTH-1 downto 0);
    signal sin_out : signed(WIDTH-1 downto 0);

    -- ============================
    -- Debug (real values)
    -- ============================
    signal cos_real : real;
    signal sin_real : real;

    -- ============================
    -- Degrees ? fixed-point radians
    -- Q1.(WIDTH-1)
    -- ============================
    function deg_to_rad_fixed(deg : integer) return signed is
        variable real_rad : real;
        variable fixed    : integer;
    begin
        real_rad := real(deg) * math_pi / 180.0;
        fixed    := integer(real_rad * real(2**(WIDTH-1)));
        return to_signed(fixed, WIDTH);
    end function;

begin

    -- ============================
    -- DUT
    -- ============================
    dut : entity work.cordic_core
        generic map (
            WIDTH      => WIDTH,
            ITERATIONS => ITERATIONS
        )
        port map (
            clk     => clk,
            start   => start,
            angle   => angle,
            busy    => busy,
            done    => done,
            cos_out => cos_out,
            sin_out => sin_out
        );

    -- ============================
    -- Fixed-point ? real
    -- ============================
    cos_real <= real(to_integer(cos_out)) / real(2**(WIDTH-1));
    sin_real <= real(to_integer(sin_out)) / real(2**(WIDTH-1));

    -- ============================
    -- Clock
    -- ============================
    clk <= not clk after CLK_PERIOD / 2;

    -- ============================
    -- Stimulus
    -- ============================
    stim_proc : process

        procedure run_angle(deg : integer) is
        begin
            assert (deg >= -90 and deg <= 90)
                report "Angle outside valid CORDIC range!"
                severity failure;

            angle <= deg_to_rad_fixed(deg);
            start <= '1';
            wait for CLK_PERIOD;
            start <= '0';

            -- Wait for computation to finish
            wait until done = '1';
            wait for CLK_PERIOD;

            report "Angle " & integer'image(deg) &
                   " deg -> cos=" & real'image(cos_real) &
                   " sin=" & real'image(sin_real);
        end procedure;

    begin
        -- Initial delay
        wait for 20 ns;

        -- Valid test angles
        run_angle(0);
        run_angle(15);
        run_angle(30);
        run_angle(45);
        
        -- Delay to see all the results
        wait for 150 ns;

        assert false
            report "End of CORDIC core simulation"
            severity failure;
    end process;

end Behavioral;
