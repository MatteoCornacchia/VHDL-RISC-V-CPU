library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================
-- Register File
-- ============================
-- 32 registers, 32-bit wide
-- Two asynchronous read ports
-- One synchronous write port
-- Register x0 is hardwired to zero
-- ============================

entity register_file is
    port ( 
        clk         : in std_logic;

        -- Read addresses
        da          : in std_logic_vector(4 downto 0);  -- rs1
        pda         : in std_logic_vector(4 downto 0);  -- rs2

        -- Write interface
        dina        : in std_logic_vector(4 downto 0);  -- rd
        din         : in std_logic_vector(31 downto 0);
        we          : in std_logic;

        -- Read data
        rso         : out std_logic_vector(31 downto 0);
        prso        : out std_logic_vector(31 downto 0)

        -- Debug read port
        -- addr_sel    : in std_logic_vector(4 downto 0);
        -- reg_out     : out std_logic_vector(31 downto 0)
    );
end register_file;

architecture Behavioral of register_file is

    type reg_array is array(31 downto 0) of std_logic_vector(31 downto 0);
    signal registers : reg_array := (others => (others => '0'));

begin

    -- ============================
    -- Write port (synchronous)
    -- ============================
    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' and dina /= "00000" then
                registers(to_integer(unsigned(dina))) <= din;
            end if;

            -- Enforce x0 = 0
            registers(0) <= (others => '0');
        end if;
    end process;

    -- ============================
    -- Read ports (asynchronous)
    -- ============================
    rso  <= registers(to_integer(unsigned(da)));
    prso <= registers(to_integer(unsigned(pda)));

    -- ============================
    -- Debug read port
    -- ============================
    -- nreg_out <= registers(to_integer(unsigned(addr_sel)));

end Behavioral;
