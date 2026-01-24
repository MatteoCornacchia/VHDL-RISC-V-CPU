library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================
-- Memory Data + Write Back Testbench
-- ============================
-- Purpose:
--  - Verify load/store operations
--  - Verify data alignment and sign extension
--  - Verify write-back data selection
-- ============================

entity tb_mem_wb_stage is
end tb_mem_wb_stage;

architecture Behavioral of tb_mem_wb_stage is

    constant clk_period : time := 100 ns;
    signal clk : std_logic := '0';

    -- MEM inputs
    signal op_class    : std_logic_vector(5 downto 0) := (others => '0');
    signal funct3      : std_logic_vector(2 downto 0) := (others => '0');
    signal rs2_value   : std_logic_vector(31 downto 0) := (others => '0');
    signal alu_result  : std_logic_vector(31 downto 0) := (others => '0');

    -- WB inputs
    signal branch_cond : std_logic := '0';
    signal next_pc     : std_logic_vector(31 downto 0) := x"00000004";

    -- Outputs
    signal mem_out     : std_logic_vector(31 downto 0);
    signal rd_value    : std_logic_vector(31 downto 0);
    signal rd_write_en : std_logic;
    signal pc_out      : std_logic_vector(31 downto 0);

    component mem_stage
        port ( 
            clk         : in std_logic;
            op_class    : in std_logic_vector(5 downto 0);
            funct3      : in std_logic_vector(2 downto 0);
            rs2_value   : in std_logic_vector(31 downto 0);
            alu_result  : in std_logic_vector(31 downto 0);
            mem_out     : out std_logic_vector(31 downto 0)
        );
    end component;

    component wb_stage
        port ( 
            branch_cond : in std_logic;
            op_class    : in std_logic_vector(5 downto 0);
            mem_out     : in std_logic_vector(31 downto 0);
            next_pc     : in std_logic_vector(31 downto 0);
            alu_result  : in std_logic_vector(31 downto 0);
            rd_write_en : out std_logic;
            pc_out      : out std_logic_vector(31 downto 0);
            rd_value    : out std_logic_vector(31 downto 0)
        );
    end component;

begin

    mem_inst : mem_stage
        port map (
            clk        => clk,
            op_class   => op_class,
            funct3     => funct3,
            rs2_value  => rs2_value,
            alu_result => alu_result,
            mem_out    => mem_out
        );

    wb_inst : wb_stage
        port map (
            branch_cond => branch_cond,
            op_class    => op_class,
            mem_out     => mem_out,
            next_pc     => next_pc,
            alu_result  => alu_result,
            rd_write_en => rd_write_en,
            pc_out      => pc_out,
            rd_value    => rd_value
        );

    -- Clock generation
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Stimulus
    stim_proc : process
    begin
        -- =================================
        -- SW: store word
        -- =================================
        op_class   <= "001000"; -- STORE
        funct3     <= "010";    -- SW
        alu_result <= x"00000000";
        rs2_value  <= x"DEADBEEF";
        wait for clk_period;

        -- =================================
        -- LW: load word
        -- =================================
        op_class   <= "000100"; -- LOAD
        funct3     <= "010";    -- LW
        alu_result <= x"00000000";
        wait for clk_period;

        -- =================================
        -- LB (signed)
        -- =================================
        funct3     <= "000";
        alu_result <= x"00000000";
        wait for clk_period;

        -- =================================
        -- LBU (unsigned)
        -- =================================
        funct3     <= "100";
        wait for clk_period;

        wait;
    end process;

end Behavioral;
