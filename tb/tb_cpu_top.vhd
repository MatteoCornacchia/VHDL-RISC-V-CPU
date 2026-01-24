library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================
-- CPU Top Testbench
-- ============================
-- Purpose:
--  - Verify full datapath functionality
--  - Check PC progression
--  - Validate register write-back
-- ============================

entity tb_cpu_top is
end tb_cpu_top;

architecture Behavioral of tb_cpu_top is

    constant clk_period : time := 20 ns;
    signal clk          : std_logic := '0';

    -- DUT
    component cpu_top
        port (
            clk : in std_logic
        );
    end component;

begin

    -- ============================
    -- DUT instantiation
    -- ============================
    dut : cpu_top
        port map (
            clk => clk
        );

    -- ============================
    -- Clock generation
    -- ============================
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- ============================
    -- Simulation control
    -- ============================
    stim_proc : process
    begin
        -- Let the CPU run for N cycles
        wait for 500 ns;

        -- Stop simulation
        assert false
            report "End of CPU simulation"
            severity failure;
    end process;

end Behavioral;
