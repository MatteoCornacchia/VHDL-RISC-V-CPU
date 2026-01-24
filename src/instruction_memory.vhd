library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================
-- Instruction Memory (ROM)
-- ============================
-- Word-addressed
-- Read-only
-- ============================

entity instruction_memory is
    port(
        clka    : in  std_logic;
        wea     : in  std_logic;
        addra   : in  std_logic_vector(13 downto 2);
        dina    : in  std_logic_vector(31 downto 0);
        douta   : out std_logic_vector(31 downto 0)
    );
end instruction_memory;

architecture Behavioral of instruction_memory is

    type rom_t is array (0 to 1023) of std_logic_vector(31 downto 0);

    signal rom : rom_t := (
        -- Simple test program (RV32I)
        0 => x"00500093", -- addi x1, x0, 5
        1 => x"00A00113", -- addi x2, x0, 10
        2 => x"002081B3", -- add  x3, x1, x2
        3 => x"00302023", -- sw   x3, 0(x0)
        4 => x"00002203", -- lw   x4, 0(x0)
        others => (others => '0')
    );

begin

    -- Combinational read
    douta <= rom(to_integer(unsigned(addra)));

end Behavioral;
