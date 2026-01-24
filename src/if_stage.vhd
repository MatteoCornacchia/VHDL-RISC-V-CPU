library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================
-- Instruction Fetch Stage
-- ============================
-- Manages:
--  - Program Counter (PC)
--  - Instruction fetch from instruction memory
--  - Calculation of PC + 4
--
-- Single-cycle architecture:
-- The PC is updated only if pc_load_en = '1'
-- ============================

entity if_stage is
    port (
        clk         : in std_logic;
        pc_load_en  : in std_logic;                      -- enables PC loading
        pc_in       : in std_logic_vector(31 downto 0); -- value to load into PC

        next_pc     : out std_logic_vector(31 downto 0); -- PC + 4
        curr_pc     : out std_logic_vector(31 downto 0); -- current PC
        instr       : out std_logic_vector(31 downto 0)  -- fetched instruction
    );
end if_stage;

architecture Structural of if_stage is

    -- Internal Program Counter
    -- Used as unsigned to simplify arithmetic operations
    signal pc_reg : unsigned(31 downto 0) := (others => '0');

    -- Instruction Memory
    -- Word addressing:
    -- uses bits [13:2] of PC (4-byte aligned)
    component instruction_memory
        port (
            clka    : in std_logic;
            wea     : in std_logic;                       -- always disabled (ROM)
            addra   : in std_logic_vector(13 downto 2);  -- word address
            dina    : in std_logic_vector(31 downto 0);  -- unused
            douta   : out std_logic_vector(31 downto 0)  -- read instruction
        );
    end component;

begin

    -- ============================
    -- Instruction Memory Instance
    -- ============================
    instr_mem : instruction_memory
        port map(
            clka  => clk,
            wea   => '0',                                -- read-only memory
            dina  => (others => '0'),
            addra => std_logic_vector(pc_reg(13 downto 2)),
            douta => instr
        );

    -- ============================
    -- Program Counter Register
    -- ============================
    -- Updated only if pc_load_en = '1'
    -- The loaded value can be:
    --  - PC + 4
    --  - branch/jump target
    process (clk)
    begin
        if rising_edge(clk) then
            if pc_load_en = '1' then
                pc_reg <= unsigned(pc_in);
            end if;
        end if;
    end process;

    -- ============================
    -- Combinatorial Outputs
    -- ============================
    -- next_pc: calculated value (PC + 4)
    -- curr_pc: current PC, exposed to other stages
    next_pc <= std_logic_vector(pc_reg + 4);
    curr_pc <= std_logic_vector(pc_reg);

end Structural;
