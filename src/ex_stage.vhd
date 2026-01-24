library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================
-- Instruction Execute Stage
-- ============================
-- Responsibilities:
--  - Select ALU operands
--  - Perform arithmetic / logic operations
--  - Evaluate branch conditions
-- ============================

entity ex_stage is
    port (
        -- Control signals
        a_sel           : in std_logic;  -- 0 = PC,  1 = rs1
        b_sel           : in std_logic;  -- 0 = imm, 1 = rs2

        -- Data inputs
        rs1_value       : in std_logic_vector(31 downto 0);
        rs2_value       : in std_logic_vector(31 downto 0);
        imm_se          : in std_logic_vector(31 downto 0);
        curr_pc         : in std_logic_vector(31 downto 0);

        -- Decode information
        cond_opcode     : in std_logic_vector(2 downto 0);
        funct3          : in std_logic_vector(2 downto 0);
        funct7          : in std_logic_vector(6 downto 0);
        op_class        : in std_logic_vector(5 downto 0);

        -- Outputs
        branch_cond     : out std_logic;
        alu_result      : out std_logic_vector(31 downto 0)
    );
end ex_stage;

architecture Structural of ex_stage is

    -- ALU operand muxes
    signal alu_mux_a : std_logic_vector(31 downto 0);
    signal alu_mux_b : std_logic_vector(31 downto 0);

    -- Arithmetic Logic Unit
    component ALU is
        port (
            first_operand   : in std_logic_vector(31 downto 0);
            second_operand  : in std_logic_vector(31 downto 0);
            funct3          : in std_logic_vector(2 downto 0);
            funct7          : in std_logic_vector(6 downto 0);
            op_class        : in std_logic_vector(5 downto 0);

            alu_result      : out std_logic_vector(31 downto 0)
        );
    end component;

    -- Branch comparator
    component comparator is
        port ( 
            first_operand   : in std_logic_vector(31 downto 0);
            second_operand  : in std_logic_vector(31 downto 0);
            cond_opcode     : in std_logic_vector(2 downto 0);

            branch_cond     : out std_logic
        );
    end component;

begin

    -- ============================
    -- Operand selection
    -- ============================
    alu_mux_a <= rs1_value when a_sel = '1' else curr_pc;
    alu_mux_b <= rs2_value when b_sel = '1' else imm_se;

    -- ============================
    -- ALU instance
    -- ============================
    alu_inst : ALU
        port map(
            first_operand   => alu_mux_a,
            second_operand  => alu_mux_b,
            funct3          => funct3,
            funct7          => funct7,
            op_class        => op_class,
            alu_result      => alu_result
        );

    -- ============================
    -- Branch comparator
    -- ============================
    -- Note: branch_cond is valid only for branch instructions
    comp_inst : comparator
        port map(
            first_operand   => rs1_value,
            second_operand  => rs2_value,
            cond_opcode     => cond_opcode,
            branch_cond     => branch_cond
        );

end Structural;
