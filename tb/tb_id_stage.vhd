library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================
-- Instruction Decode Testbench
-- ============================
-- Purpose:
--  - Verify correct decoding of RV32 instructions
--  - Validate immediate generation for different instruction formats
--  - Test register file read and write-back behavior
--  - Ensure correct propagation of decoded control signals
-- ============================

entity tb_id_stage is
end tb_id_stage;

architecture Behavioral of tb_id_stage is

    constant clk_period : time := 100 ns;

    signal clk : std_logic := '0';

    -- Instruction input
    signal instr : std_logic_vector(31 downto 0) := (others => '0');

    -- Write-back interface
    signal rd_write_en : std_logic := '0';
    signal rd_value    : std_logic_vector(31 downto 0) := (others => '0');
    signal rd_addr_in  : std_logic_vector(4 downto 0)  := (others => '0');

    -- Decode outputs
    signal op_class    : std_logic_vector(5 downto 0);
    signal funct3      : std_logic_vector(2 downto 0);
    signal funct7      : std_logic_vector(6 downto 0);
    signal a_sel       : std_logic;
    signal b_sel       : std_logic;
    signal cond_opcode : std_logic_vector(2 downto 0);
    signal rd_addr_out : std_logic_vector(4 downto 0);
    signal rs1_value   : std_logic_vector(31 downto 0);
    signal rs2_value   : std_logic_vector(31 downto 0);
    signal imm_se      : std_logic_vector(31 downto 0);

    component id_stage
        port (
            clk         : in  std_logic;
            instr       : in  std_logic_vector(31 downto 0);

            rd_write_en : in  std_logic;
            rd_value    : in  std_logic_vector(31 downto 0);
            rd_addr_in  : in  std_logic_vector(4 downto 0);

            op_class    : out std_logic_vector(5 downto 0);
            funct3      : out std_logic_vector(2 downto 0);
            funct7      : out std_logic_vector(6 downto 0);
            a_sel       : out std_logic;
            b_sel       : out std_logic;
            cond_opcode : out std_logic_vector(2 downto 0);
            rd_addr_out : out std_logic_vector(4 downto 0);

            rs1_value   : out std_logic_vector(31 downto 0);
            rs2_value   : out std_logic_vector(31 downto 0);
            imm_se      : out std_logic_vector(31 downto 0)
        );
    end component;

begin

    -- DUT
    id_inst : id_stage
        port map (
            clk         => clk,
            instr       => instr,
            rd_write_en => rd_write_en,
            rd_value    => rd_value,
            rd_addr_in  => rd_addr_in,
            op_class    => op_class,
            funct3      => funct3,
            funct7      => funct7,
            a_sel       => a_sel,
            b_sel       => b_sel,
            cond_opcode => cond_opcode,
            rd_addr_out => rd_addr_out,
            rs1_value   => rs1_value,
            rs2_value   => rs2_value,
            imm_se      => imm_se
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
        -- ===================================
        -- Write x1 = 0x00000010
        -- ===================================
        rd_write_en <= '1';
        rd_addr_in  <= "00001";
        rd_value    <= x"00000010";
        wait for clk_period;
        rd_write_en <= '0';

        -- ===================================
        -- ADDI x2, x1, 4
        -- ===================================
        instr <= x"00408113"; -- addi x2, x1, 4
        wait for clk_period;

        -- ===================================
        -- ADD x3, x1, x2
        -- ===================================
        instr <= x"002081B3"; -- add x3, x1, x2
        wait for clk_period;

        wait;
    end process;

end Behavioral;
