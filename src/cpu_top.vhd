library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================
-- CPU Top Level (Debug Version)
-- ============================
-- Single-cycle RISC-V CPU
-- IF -> ID -> EX -> MEM -> WB
-- Debug outputs added for simulation / report
-- ============================

entity cpu_top is
    port (
        clk        : in  std_logic;

        -- Debug outputs
        dbg_pc     : out std_logic_vector(31 downto 0);
        dbg_npc    : out std_logic_vector(31 downto 0);
        dbg_instr  : out std_logic_vector(31 downto 0);
        dbg_alu    : out std_logic_vector(31 downto 0);
        dbg_wb     : out std_logic_vector(31 downto 0)
    );
end cpu_top;

architecture Structural of cpu_top is

    -- ============================
    -- IF signals
    -- ============================
    signal pc_in       : std_logic_vector(31 downto 0) := (others => '0');
    signal curr_pc     : std_logic_vector(31 downto 0);
    signal next_pc     : std_logic_vector(31 downto 0);
    signal instr       : std_logic_vector(31 downto 0);
    signal pc_load_en  : std_logic := '1';

    -- ============================
    -- ID signals
    -- ============================
    signal op_class    : std_logic_vector(5 downto 0);
    signal funct3      : std_logic_vector(2 downto 0);
    signal funct7      : std_logic_vector(6 downto 0);
    signal a_sel       : std_logic;
    signal b_sel       : std_logic;
    signal cond_opcode : std_logic_vector(2 downto 0);
    signal rs1_value   : std_logic_vector(31 downto 0);
    signal rs2_value   : std_logic_vector(31 downto 0);
    signal imm_se      : std_logic_vector(31 downto 0);
    signal rd_addr     : std_logic_vector(4 downto 0);

    -- ============================
    -- EX signals
    -- ============================
    signal alu_result  : std_logic_vector(31 downto 0);
    signal branch_cond : std_logic;

    -- ============================
    -- MEM signals
    -- ============================
    signal mem_out     : std_logic_vector(31 downto 0);

    -- ============================
    -- WB signals
    -- ============================
    signal rd_write_en : std_logic;
    signal rd_value    : std_logic_vector(31 downto 0);
    signal pc_out      : std_logic_vector(31 downto 0);

begin

    -- ============================
    -- Instruction Fetch
    -- ============================
    if_inst : entity work.if_stage
        port map (
            clk         => clk,
            pc_load_en  => pc_load_en,
            pc_in       => pc_in,
            next_pc     => next_pc,
            curr_pc     => curr_pc,
            instr       => instr
        );

    -- ============================
    -- Instruction Decode
    -- ============================
    id_inst : entity work.id_stage
        port map (
            clk         => clk,
            instr       => instr,
            rd_write_en => rd_write_en,
            rd_value    => rd_value,
            rd_addr_in  => rd_addr,
            op_class    => op_class,
            funct3      => funct3,
            funct7      => funct7,
            a_sel       => a_sel,
            b_sel       => b_sel,
            cond_opcode => cond_opcode,
            rd_addr_out => rd_addr,
            rs1_value   => rs1_value,
            rs2_value   => rs2_value,
            imm_se      => imm_se
        );

    -- ============================
    -- Execute
    -- ============================
    ex_inst : entity work.ex_stage
        port map (
            a_sel       => a_sel,
            b_sel       => b_sel,
            rs1_value   => rs1_value,
            rs2_value   => rs2_value,
            imm_se      => imm_se,
            curr_pc     => curr_pc,
            cond_opcode => cond_opcode,
            funct3      => funct3,
            funct7      => funct7,
            op_class    => op_class,
            branch_cond => branch_cond,
            alu_result  => alu_result
        );

    -- ============================
    -- Memory
    -- ============================
    mem_inst : entity work.mem_stage
        port map (
            clk         => clk,
            op_class    => op_class,
            funct3      => funct3,
            rs2_value   => rs2_value,
            alu_result  => alu_result,
            mem_out     => mem_out
        );

    -- ============================
    -- Write Back
    -- ============================
    wb_inst : entity work.wb_stage
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

    -- ============================
    -- PC update
    -- ============================
    pc_in <= pc_out;

    -- ============================
    -- Debug connections
    -- ============================
    dbg_pc    <= curr_pc;
    dbg_npc   <= next_pc;
    dbg_instr <= instr;
    dbg_alu   <= alu_result;
    dbg_wb    <= rd_value;

end Structural;
