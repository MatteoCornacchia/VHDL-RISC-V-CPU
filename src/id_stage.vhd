library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================
-- Instruction Decode Stage
-- ============================
-- Responsibilities:
--  - Decode instruction fields
--  - Read source registers (rs1, rs2)
--  - Generate immediate value
--  - Forward writeback data to register file
-- ============================

entity id_stage is
    port (
        clk         : in std_logic;
        instr       : in std_logic_vector(31 downto 0);

        -- Writeback interface (from MEM/WB stage)
        rd_write_en : in std_logic;
        rd_value    : in std_logic_vector(31 downto 0);
        rd_addr_in  : in std_logic_vector(4 downto 0);

        -- Decoded instruction information
        op_class    : out std_logic_vector(5 downto 0);
        funct3      : out std_logic_vector(2 downto 0);
        funct7      : out std_logic_vector(6 downto 0);
        a_sel       : out std_logic;
        b_sel       : out std_logic;
        cond_opcode : out std_logic_vector(2 downto 0);
        rd_addr_out : out std_logic_vector(4 downto 0);

        -- Operand values and immediate
        rs1_value   : out std_logic_vector(31 downto 0);
        rs2_value   : out std_logic_vector(31 downto 0);
        imm_se      : out std_logic_vector(31 downto 0)
    );
end id_stage;

architecture Structural of id_stage is

    -- Register file component
    -- Provides two read ports and one write port
    component register_file is
        port ( 
            clk     : in std_logic;
            da      : in std_logic_vector(4 downto 0);  -- rs1 address
            pda     : in std_logic_vector(4 downto 0);  -- rs2 address
            dina    : in std_logic_vector(4 downto 0);  -- rd address
            din     : in std_logic_vector(31 downto 0); -- writeback data
            we      : in std_logic;

            rso     : out std_logic_vector(31 downto 0); -- rs1 value
            prso    : out std_logic_vector(31 downto 0)  -- rs2 value
        );
    end component;

    -- Instruction decoder
    -- Extracts control signals and immediate value
    component decoder is
        port(
            instr       : in std_logic_vector(31 downto 0);
            op_class    : out std_logic_vector(5 downto 0);
            funct3      : out std_logic_vector(2 downto 0);
            funct7      : out std_logic_vector(6 downto 0);
            a_sel       : out std_logic;
            b_sel       : out std_logic;
            cond_opcode : out std_logic_vector(2 downto 0);
            imm_se      : out std_logic_vector(31 downto 0)
        );
    end component;

begin

    -- ============================
    -- Register File Instance
    -- ============================
    -- Reads rs1 and rs2 from instruction
    -- Writes rd from writeback stage
    reg : register_file
        port map(
            clk     => clk,
            da      => instr(19 downto 15),  -- rs1
            pda     => instr(24 downto 20),  -- rs2
            dina    => rd_addr_in,           -- rd (writeback)
            din     => rd_value,
            we      => rd_write_en,
            rso     => rs1_value,
            prso    => rs2_value
        );

    -- ============================
    -- Instruction Decoder Instance
    -- ============================
    dec : decoder
        port map(
            instr       => instr,
            op_class    => op_class,
            funct3      => funct3,
            funct7      => funct7,
            a_sel       => a_sel,
            b_sel       => b_sel,
            cond_opcode => cond_opcode,
            imm_se      => imm_se
        );

    -- Destination register address extraction
    rd_addr_out <= instr(11 downto 7);

end Structural;
