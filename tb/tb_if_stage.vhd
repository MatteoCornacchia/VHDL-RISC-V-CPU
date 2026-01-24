library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================
-- Instruction Fetch Testbench
-- ============================
-- Tests:
--  - PC update
--  - PC + 4 behavior
-- ============================

entity tb_if_stage is
end tb_if_stage;

architecture Behavioral of tb_if_stage is

    constant clk_period : time := 20 ns;

    signal clk        : std_logic := '0';
    signal pc_load_en : std_logic := '0';
    signal pc_in      : std_logic_vector(31 downto 0) := (others => '0');

    signal next_pc    : std_logic_vector(31 downto 0);
    signal curr_pc    : std_logic_vector(31 downto 0);
    signal instr      : std_logic_vector(31 downto 0);

    component if_stage
        port ( 
            clk         : in std_logic;
            pc_load_en  : in std_logic;
            pc_in       : in std_logic_vector(31 downto 0);
            next_pc     : out std_logic_vector(31 downto 0);
            curr_pc     : out std_logic_vector(31 downto 0);
            instr       : out std_logic_vector(31 downto 0)
        );
    end component;

begin

    -- ============================
    -- DUT instance
    -- ============================
    if_inst : if_stage
        port map (
            clk         => clk,
            pc_load_en  => pc_load_en,
            pc_in       => pc_in,
            next_pc     => next_pc,
            curr_pc     => curr_pc,
            instr       => instr
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
    -- Stimulus process
    -- ============================
    stim_proc : process
    begin
        -- Initial state
        pc_load_en <= '0';
        pc_in      <= (others => '0');
        wait for clk_period;

        -- Enable PC update: PC should start incrementing by 4
        pc_load_en <= '1';

        -- Feed back next_pc to pc_in (sequential execution)
        for i in 0 to 5 loop
            pc_in <= next_pc;
            wait for clk_period;
        end loop;

        -- Stop PC update
        pc_load_en <= '0';
        wait for clk_period;

        wait;
    end process;

end Behavioral;
