library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- =========================================================
-- Instruction Decoder
-- =========================================================
-- Decodes instruction opcode and generates:
--  - operation class
--  - funct3 / funct7
--  - operand selection signals
--  - branch condition opcode
--  - sign-extended immediate
-- =========================================================

entity decoder is
    port (
        instr       : in  std_logic_vector(31 downto 0);

        op_class    : out std_logic_vector(5 downto 0);
        funct3      : out std_logic_vector(2 downto 0);
        funct7      : out std_logic_vector(6 downto 0);

        a_sel       : out std_logic; -- 0 = PC,  1 = rs1
        b_sel       : out std_logic; -- 0 = imm, 1 = rs2

        cond_opcode : out std_logic_vector(2 downto 0);
        imm_se      : out std_logic_vector(31 downto 0)
    );
end decoder;

architecture Behavioral of decoder is
begin

    -- Combinational decode logic
    process(instr)
    begin
        -- Default assignments (avoid latches)
        op_class    <= (others => '0');
        funct3      <= (others => '0');
        funct7      <= (others => '0');
        cond_opcode <= (others => '0');
        imm_se      <= (others => '0');
        a_sel       <= '0';
        b_sel       <= '0';

        case instr(6 downto 0) is

            -- ============================
            -- LOAD (I-type)
            -- ============================
            when "0000011" =>
                op_class <= "000100";
                imm_se   <= std_logic_vector(
                                resize(signed(instr(31 downto 20)), 32)
                            );
                a_sel    <= '1'; -- rs1
                b_sel    <= '0'; -- immediate
                funct3   <= instr(14 downto 12);

            -- ============================
            -- OP-IMM (I-type)
            -- ============================
            when "0010011" =>
                op_class <= "000010";
                imm_se   <= std_logic_vector(
                                resize(signed(instr(31 downto 20)), 32)
                            );
                a_sel    <= '1';
                b_sel    <= '0';
                funct3  <= instr(14 downto 12);
                funct7  <= instr(31 downto 25); -- used for shifts

            -- ============================
            -- STORE (S-type)
            -- ============================
            when "0100011" =>
                op_class <= "001000";
                imm_se   <= std_logic_vector(
                                resize(signed(instr(31 downto 25) &
                                             instr(11 downto 7)), 32)
                            );
                a_sel    <= '1';
                b_sel    <= '0';
                funct3  <= instr(14 downto 12);

            -- ============================
            -- OP (R-type)
            -- ============================
            when "0110011" =>
                op_class <= "000001";
                a_sel    <= '1';
                b_sel    <= '1'; -- rs2
                funct3  <= instr(14 downto 12);
                funct7  <= instr(31 downto 25);

            -- ============================
            -- LUI (U-type)
            -- ============================
            when "0110111" =>
                op_class <= "000110";
                imm_se   <= instr(31) & instr(30 downto 20) &
                            instr(19 downto 12) & (11 downto 0 => '0');
                a_sel    <= '0'; -- unused (can be tied to zero in EX)
                b_sel    <= '0';

            -- ============================
            -- AUIPC (U-type)
            -- ============================
            when "0010111" =>
                op_class <= "010010";
                imm_se   <= instr(31) & instr(30 downto 20) &
                            instr(19 downto 12) & (11 downto 0 => '0');
                a_sel    <= '0'; -- PC
                b_sel    <= '0'; -- immediate

            -- ============================
            -- BRANCH (B-type)
            -- ============================
            when "1100011" =>
                op_class    <= "100000";
                imm_se      <= std_logic_vector(
                                   resize(signed(instr(31) & instr(7) &
                                                instr(30 downto 25) &
                                                instr(11 downto 8) & '0'), 32)
                               );
                a_sel       <= '0'; -- PC
                b_sel       <= '0'; -- immediate
                cond_opcode <= instr(14 downto 12);

            -- ============================
            -- JAL (J-type)
            -- ============================
            when "1101111" =>
                op_class <= "010000";
                imm_se   <= std_logic_vector(
                                resize(signed(instr(31) &
                                             instr(19 downto 12) &
                                             instr(20) &
                                             instr(30 downto 21) & '0'), 32)
                            );
                a_sel    <= '0'; -- PC
                b_sel    <= '0';

            -- ============================
            -- JALR (I-type)
            -- ============================
            when "1100111" =>
                op_class <= "010000";
                imm_se   <= std_logic_vector(
                                resize(signed(instr(31 downto 20)), 32)
                            );
                a_sel    <= '1'; -- rs1
                b_sel    <= '0';

            when others =>
                null; -- illegal or unsupported instruction

        end case;
    end process;

end Behavioral;
