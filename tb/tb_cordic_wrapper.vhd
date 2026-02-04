library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

-- =========================================
-- CORDIC Wrapper Testbench
-- =========================================

entity tb_cordic_wrapper is
end tb_cordic_wrapper;

architecture Behavioral of tb_cordic_wrapper is

    constant WIDTH      : integer := 16;
    constant ITERATIONS : integer := 16;
    constant CLK_PERIOD : time := 10 ns;

    -- DUT signals
    signal clk       : std_logic := '0';
    signal start     : std_logic := '0';
    signal angle_deg : unsigned(8 downto 0) := (others => '0');

    signal busy      : std_logic;
    signal done      : std_logic;
    signal cos_out   : signed(WIDTH-1 downto 0);
    signal sin_out   : signed(WIDTH-1 downto 0);

    -- Debug real values
    signal cos_real  : real;
    signal sin_real  : real;

begin

    -- =========================================
    -- DUT instantiation
    -- =========================================
    dut : entity work.cordic_wrapper
        generic map (
            WIDTH      => WIDTH,
            ITERATIONS => ITERATIONS
        )
        port map (
            clk       => clk,
            start     => start,
            angle_deg => angle_deg,
            busy      => busy,
            done      => done,
            cos_out   => cos_out,
            sin_out   => sin_out
        );

    -- =========================================
    -- Fixed-point -> real conversion
    -- Q1.(WIDTH-1)
    -- =========================================
    cos_real <= real(to_integer(cos_out)) / real(2**(WIDTH-1));
    sin_real <= real(to_integer(sin_out)) / real(2**(WIDTH-1));

    -- =========================================
    -- Clock generation
    -- =========================================
    clk <= not clk after CLK_PERIOD / 2;

    -- =========================================
    -- Stimulus process
    -- =========================================
    stim_proc : process

        procedure run_angle(deg : integer) is
            variable cos_ref : real;
            variable sin_ref : real;
            constant EPS    : real := 0.01;  -- tolerated error
        begin
            angle_deg <= to_unsigned(deg, angle_deg'length);

            -- start aligned to clock
            start <= '1';
            wait until rising_edge(clk);
            start <= '0';

            -- wait core to start
            wait until busy = '1';

            -- wait for clean done pulse
            wait until done = '1';
            wait until rising_edge(clk);

            cos_ref := cos(real(deg) * math_pi / 180.0);
            sin_ref := sin(real(deg) * math_pi / 180.0);

            report
                "Angle " & integer'image(deg) &
                " -> cos = " & real'image(cos_real) &
                " (ref=" & real'image(cos_ref) & ")" &
                " , sin = " & real'image(sin_real) &
                " (ref=" & real'image(sin_ref) & ")";

            -- =========================================
            -- Automatic error check
            -- =========================================
            assert abs(cos_real - cos_ref) < EPS
                report "COS error too large at angle " & integer'image(deg)
                severity warning;

            assert abs(sin_real - sin_ref) < EPS
                report "SIN error too large at angle " & integer'image(deg)
                severity warning;
        end procedure;

    begin
        wait for 20 ns;

        run_angle(15);
        run_angle(30);
        run_angle(45);
        run_angle(60);
        
        wait for 200 ns;

        assert false
            report "End of CORDIC wrapper simulation"
            severity failure;
    end process;

end Behavioral;
