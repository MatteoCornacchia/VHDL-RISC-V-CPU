library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================
-- CPU Top Testbench (Debug)
-- ============================
-- Purpose:
--  - Observe PC progression
--  - Observe instruction fetch
--  - Observe ALU result
--  - Observe write-back data
-- ============================

entity tb_cpu_top is
end tb_cpu_top;

architecture Behavioral of tb_cpu_top is

    constant clk_period : time := 20 ns;
    signal clk          : std_logic := '0';

    -- Debug signals from DUT
    signal dbg_pc     : std_logic_vector(31 downto 0);
    signal dbg_npc    : std_logic_vector(31 downto 0);
    signal dbg_instr  : std_logic_vector(31 downto 0);
    signal dbg_alu    : std_logic_vector(31 downto 0);
    signal dbg_wb     : std_logic_vector(31 downto 0);

begin

    -- ============================
    -- DUT instantiation
    -- ============================
    dut : entity work.cpu_top
        port map (
            clk        => clk,
            dbg_pc     => dbg_pc,
            dbg_npc    => dbg_npc,
            dbg_instr  => dbg_instr,
            dbg_alu    => dbg_alu,
            dbg_wb     => dbg_wb
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
        -- Run CPU for many cycles (es. 50 cicli)
        wait for 1000 ns;

        assert false
            report "End of CPU simulation"
            severity failure;
    end process;

end Behavioral;
