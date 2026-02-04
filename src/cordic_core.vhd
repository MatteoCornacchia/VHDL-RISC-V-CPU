library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- =========================================
-- CORDIC Core (Rotation Mode)
-- =========================================
-- Computes sin and cos
-- Angle range: [-pi/2, +pi/2]
-- Fixed-point angle: Q2.(WIDTH-2)
-- Fixed-point sin/cos: Q1.(WIDTH-1)
-- =========================================

entity cordic_core is
    generic (
        WIDTH      : integer := 16;
        ITERATIONS : integer := 16
    );
    port (
        clk     : in  std_logic;
        start   : in  std_logic;
        angle   : in  signed(WIDTH-1 downto 0); -- Q2.(WIDTH-2)

        busy    : out std_logic;
        done    : out std_logic;

        cos_out : out signed(WIDTH-1 downto 0); -- Q1.(WIDTH-1)
        sin_out : out signed(WIDTH-1 downto 0)  -- Q1.(WIDTH-1)
    );
end cordic_core;

architecture RTL of cordic_core is

    signal x, y, z : signed(WIDTH-1 downto 0);
    signal iter    : integer range 0 to ITERATIONS;

    signal busy_i  : std_logic := '0';
    signal done_i  : std_logic := '0';

    -- CORDIC gain compensation (0.607252935) in Q1.(WIDTH-1)
    constant K : signed(WIDTH-1 downto 0) :=
        to_signed(integer(0.607252935 * real(2**(WIDTH-1))), WIDTH);

    -- atan(2^-i) scaled to Q2.(WIDTH-2)
    type atan_array is array (0 to ITERATIONS-1) of signed(WIDTH-1 downto 0);
    constant atan_table : atan_array := (
        to_signed(integer(0.7853981633974483 * 2.0 ** (WIDTH-2)), WIDTH), -- atan(2^0)
        to_signed(integer(0.4636476090008061 * 2.0 ** (WIDTH-2)), WIDTH), -- atan(2^-1)
        to_signed(integer(0.2449786631268641 * 2.0 ** (WIDTH-2)), WIDTH), -- atan(2^-2)
        to_signed(integer(0.1243549945467614 * 2.0 ** (WIDTH-2)), WIDTH), -- atan(2^-3)
        to_signed(integer(0.0624188099959574 * 2.0 ** (WIDTH-2)), WIDTH), -- atan(2^-4)
        to_signed(integer(0.0312398334302683 * 2.0 ** (WIDTH-2)), WIDTH), -- atan(2^-5)
        to_signed(integer(0.0156237286204768 * 2.0 ** (WIDTH-2)), WIDTH), -- atan(2^-6)
        to_signed(integer(0.0078123410601011 * 2.0 ** (WIDTH-2)), WIDTH), -- atan(2^-7)
        to_signed(integer(0.0039062301319669 * 2.0 ** (WIDTH-2)), WIDTH), -- atan(2^-8)
        to_signed(integer(0.0019531225164788 * 2.0 ** (WIDTH-2)), WIDTH), -- atan(2^-9)
        to_signed(integer(0.0009765621895593 * 2.0 ** (WIDTH-2)), WIDTH), -- atan(2^-10)
        to_signed(integer(0.0004882812111948 * 2.0 ** (WIDTH-2)), WIDTH), -- atan(2^-11)
        to_signed(integer(0.0002441406201873 * 2.0 ** (WIDTH-2)), WIDTH), -- atan(2^-12)
        to_signed(integer(0.0001220703118936 * 2.0 ** (WIDTH-2)), WIDTH), -- atan(2^-13)
        to_signed(integer(0.0000610351561742 * 2.0 ** (WIDTH-2)), WIDTH), -- atan(2^-14)
        to_signed(integer(0.0000305175781155 * 2.0 ** (WIDTH-2)), WIDTH)  -- atan(2^-15)
    );

begin

    process(clk)
        variable x_shift, y_shift : signed(WIDTH-1 downto 0);
    begin
        if rising_edge(clk) then

            done_i <= '0';

            if start = '1' and busy_i = '0' then
                x      <= K;                -- Q1.(WIDTH-1)
                y      <= (others => '0');  -- Q1.(WIDTH-1)
                z      <= angle;            -- Q2.(WIDTH-2)
                iter   <= 0;
                busy_i <= '1';

            elsif busy_i = '1' then
                if iter < ITERATIONS then
                    x_shift := shift_right(x, iter);
                    y_shift := shift_right(y, iter);

                    if z <= 0 then
                        x <= x + y_shift;
                        y <= y - x_shift;
                        z <= z + atan_table(iter);
                    else
                        x <= x - y_shift;
                        y <= y + x_shift;
                        z <= z - atan_table(iter);
                    end if;

                    iter <= iter + 1;

                else
                    cos_out <= x;
                    sin_out <= y;
                    busy_i  <= '0';
                    done_i  <= '1';
                end if;
            end if;
        end if;
    end process;

    busy <= busy_i;
    done <= done_i;

end RTL;
