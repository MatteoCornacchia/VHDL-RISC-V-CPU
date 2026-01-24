library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================
-- Branch Comparator
-- ============================
-- Evaluates branch conditions for RV32I:
--  - BEQ, BNE
--  - BLT, BGE (signed)
--  - BLTU, BGEU (unsigned)
-- ============================

entity comparator is
    port ( 
        first_operand   : in std_logic_vector(31 downto 0);
        second_operand  : in std_logic_vector(31 downto 0);
        cond_opcode     : in std_logic_vector(2 downto 0); -- funct3 field
        
        branch_cond     : out std_logic
    );
end comparator;

architecture Behavioral of comparator is
begin

    -- Combinational comparison logic
    process(cond_opcode, first_operand, second_operand)
    begin
        branch_cond <= '0';

        case cond_opcode is

            -- BEQ
            when "000" =>
                if first_operand = second_operand then
                    branch_cond <= '1';
                end if;

            -- BNE
            when "001" =>
                if first_operand /= second_operand then
                    branch_cond <= '1';
                end if;

            -- BLT (signed)
            when "100" =>
                if signed(first_operand) < signed(second_operand) then
                    branch_cond <= '1';
                end if;

            -- BGE (signed)
            when "101" =>
                if signed(first_operand) >= signed(second_operand) then
                    branch_cond <= '1';
                end if;

            -- BLTU (unsigned)
            when "110" =>
                if unsigned(first_operand) < unsigned(second_operand) then
                    branch_cond <= '1';
                end if;

            -- BGEU (unsigned)
            when "111" =>
                if unsigned(first_operand) >= unsigned(second_operand) then
                    branch_cond <= '1';
                end if;

            when others =>
                branch_cond <= '0';

        end case;
    end process;

end Behavioral;
