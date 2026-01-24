library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================
-- Arithmetic Logic Unit (ALU)
-- ============================
-- Supports RV32I operations:
--  - Arithmetic and logic ops
--  - Address calculation
--  - Branch / jump target computation
-- ============================

entity alu is
    port (
        first_operand   : in std_logic_vector(31 downto 0);
        second_operand  : in std_logic_vector(31 downto 0);
        funct3          : in std_logic_vector(2 downto 0);
        funct7          : in std_logic_vector(6 downto 0);
        op_class        : in std_logic_vector(5 downto 0);

        alu_result      : out std_logic_vector(31 downto 0)
    );
end alu;

architecture Behavioral of alu is
begin

    process(op_class, funct3, funct7, first_operand, second_operand)
    begin
        alu_result <= (others => '0');

        case op_class is

            -- =================================
            -- OP / OP-IMM
            -- =================================
            when "000001" | "000010" =>

                case funct3 is

                    -- ADD / ADDI / SUB
                    when "000" =>
                        if funct7(5) = '1' and op_class = "000001" then
                            alu_result <= std_logic_vector(
                                signed(first_operand) - signed(second_operand)
                            );
                        else
                            alu_result <= std_logic_vector(
                                signed(first_operand) + signed(second_operand)
                            );
                        end if;

                    -- SLL / SLLI
                    when "001" =>
                        alu_result <= std_logic_vector(
                            shift_left(
                                unsigned(first_operand),
                                to_integer(unsigned(second_operand(4 downto 0)))
                            )
                        );

                    -- SLT / SLTI (signed)
                    when "010" =>
                        if signed(first_operand) < signed(second_operand) then
                            alu_result <= (31 downto 1 => '0', 0 => '1');
                        else
                            alu_result <= (others => '0');
                        end if;

                    -- SLTU / SLTIU (unsigned)
                    when "011" =>
                        if unsigned(first_operand) < unsigned(second_operand) then
                            alu_result <= (31 downto 1 => '0', 0 => '1');
                        else
                            alu_result <= (others => '0');
                        end if;

                    -- XOR / XORI
                    when "100" =>
                        alu_result <= first_operand xor second_operand;

                    -- SRL / SRA / SRLI / SRAI
                    when "101" =>
                        if funct7(5) = '1' then
                            -- Arithmetic shift right
                            alu_result <= std_logic_vector(
                                shift_right(
                                    signed(first_operand),
                                    to_integer(unsigned(second_operand(4 downto 0)))
                                )
                            );
                        else
                            -- Logical shift right
                            alu_result <= std_logic_vector(
                                shift_right(
                                    unsigned(first_operand),
                                    to_integer(unsigned(second_operand(4 downto 0)))
                                )
                            );
                        end if;

                    -- OR / ORI
                    when "110" =>
                        alu_result <= first_operand or second_operand;

                    -- AND / ANDI
                    when "111" =>
                        alu_result <= first_operand and second_operand;

                    when others =>
                        alu_result <= (others => '0');

                end case;

            -- =================================
            -- Address / target computation
            -- =================================
            when "000100" |  -- LOAD
                 "001000" |  -- STORE
                 "010010" |  -- AUIPC
                 "010000" |  -- JUMP
                 "100000" => -- BRANCH

                alu_result <= std_logic_vector(
                    signed(first_operand) + signed(second_operand)
                );

            -- =================================
            -- LUI
            -- =================================
            when "000110" =>
                alu_result <= second_operand;

            when others =>
                alu_result <= (others => '0');

        end case;
    end process;

end Behavioral;
