library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================
-- Instruction Execute Testbench
-- ============================
-- Purpose:
--  - Verify ALU operations
--  - Verify operand selection logic
--  - Verify branch condition evaluation
-- ============================

entity tb_ex_stage is
end tb_ex_stage;

architecture Behavioral of tb_ex_stage is

    -- Control signals
    signal a_sel       : std_logic := '0';
    signal b_sel       : std_logic := '0';
    signal op_class    : std_logic_vector(5 downto 0) := (others => '0');
    signal funct3      : std_logic_vector(2 downto 0) := (others => '0');
    signal funct7      : std_logic_vector(6 downto 0) := (others => '0');
    signal cond_opcode : std_logic_vector(2 downto 0) := (others => '0');

    -- Data inputs
    signal rs1_value   : std_logic_vector(31 downto 0) := (others => '0');
    signal rs2_value   : std_logic_vector(31 downto 0) := (others => '0');
    signal imm_se      : std_logic_vector(31 downto 0) := (others => '0');
    signal curr_pc     : std_logic_vector(31 downto 0) := (others => '0');

    -- Outputs
    signal alu_result  : std_logic_vector(31 downto 0);
    signal branch_cond : std_logic;

    component ex_stage
        port (
            a_sel       : in std_logic;
            b_sel       : in std_logic;
            rs1_value   : in std_logic_vector(31 downto 0);
            rs2_value   : in std_logic_vector(31 downto 0);
            imm_se      : in std_logic_vector(31 downto 0);
            curr_pc     : in std_logic_vector(31 downto 0);
            cond_opcode : in std_logic_vector(2 downto 0);
            funct3      : in std_logic_vector(2 downto 0);
            funct7      : in std_logic_vector(6 downto 0);
            op_class    : in std_logic_vector(5 downto 0);
            branch_cond : out std_logic;
            alu_result  : out std_logic_vector(31 downto 0)
        );
    end component;

begin

    -- DUT
    dut : ex_stage
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

    -- Stimulus process
    stim_proc : process
    begin
        -- =====================================
        -- ADD: x1 + x2
        -- =====================================
        rs1_value <= x"00000005";
        rs2_value <= x"00000003";
        a_sel     <= '1';
        b_sel     <= '1';
        op_class  <= "000001"; -- OP
        funct3    <= "000";
        funct7    <= "0000000";
        wait for 20 ns;

        -- =====================================
        -- SUB: x1 - x2
        -- =====================================
        funct7 <= "0100000";
        wait for 20 ns;

        -- =====================================
        -- ADDI: x1 + imm
        -- =====================================
        b_sel    <= '0';
        imm_se   <= x"00000004";
        op_class <= "000010"; -- OP-IMM
        funct7  <= "0000000";
        wait for 20 ns;

        -- =====================================
        -- AUIPC: PC + imm
        -- =====================================
        a_sel    <= '0';
        curr_pc <= x"00001000";
        imm_se  <= x"00000010";
        op_class <= "010010";
        wait for 20 ns;

        -- =====================================
        -- BEQ (true)
        -- =====================================
        rs1_value   <= x"0000000A";
        rs2_value   <= x"0000000A";
        cond_opcode <= "000"; -- BEQ
        op_class    <= "100000"; -- BRANCH
        wait for 20 ns;

        -- =====================================
        -- BLT (signed, false)
        -- =====================================
        rs1_value   <= x"00000005";
        rs2_value   <= x"00000002";
        cond_opcode <= "100"; -- BLT
        wait for 20 ns;

        wait;
    end process;

end Behavioral;
