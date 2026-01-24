library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================
-- Write Back Stage
-- ============================
-- Responsibilities:
--  - Select data to be written back to register file
--  - Generate register write enable
--  - Select next program counter value
-- ============================

entity wb_stage is
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
end wb_stage;

architecture Behavioral of wb_stage is
begin

    -- Combinational write-back and PC selection logic
    process(op_class, mem_out, alu_result, next_pc, branch_cond)
    begin
        -- Default values
        rd_write_en <= '0';
        rd_value    <= (others => '0');
        pc_out      <= next_pc;

        case op_class is

            -- =================================
            -- OP / OP-IMM
            -- =================================
            when "000001" | "000010" =>
                rd_value    <= alu_result;
                rd_write_en <= '1';

            -- =================================
            -- LOAD
            -- =================================
            when "000100" =>
                rd_value    <= mem_out;
                rd_write_en <= '1';

            -- =================================
            -- LUI
            -- =================================
            when "000110" =>
                rd_value    <= alu_result;
                rd_write_en <= '1';

            -- =================================
            -- AUIPC
            -- =================================
            when "010010" =>
                rd_value    <= alu_result; -- already PC + imm
                rd_write_en <= '1';

            -- =================================
            -- JAL / JALR
            -- =================================
            when "010000" =>
                rd_value    <= next_pc;    -- link address (PC + 4)
                pc_out      <= alu_result; -- jump target
                rd_write_en <= '1';

            -- =================================
            -- BRANCH
            -- =================================
            when "100000" =>
                rd_write_en <= '0';
                if branch_cond = '1' then
                    pc_out <= alu_result; -- branch taken
                else
                    pc_out <= next_pc;    -- branch not taken
                end if;

            when others =>
                rd_write_en <= '0';
                pc_out      <= next_pc;
                rd_value    <= (others => '0');

        end case;
    end process;

end Behavioral;
