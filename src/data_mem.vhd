library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_mem is
    port(
        clka  : in std_logic;
        wea   : in std_logic_vector(3 downto 0);
        dina  : in std_logic_vector(31 downto 0);
        addra : in std_logic_vector(11 downto 0);
        douta : out std_logic_vector(31 downto 0)
    );
end data_mem;

architecture Behavioral of data_mem is
    type mem_array is array (0 to 4095) of std_logic_vector(31 downto 0);
    signal ram : mem_array := (others => (others => '0'));
begin

    process(clka)
    begin
        if rising_edge(clka) then
            -- Write
            if wea(0) = '1' then
                ram(to_integer(unsigned(addra))) <= dina;
            end if;

            -- Read (sync)
            douta <= ram(to_integer(unsigned(addra)));
        end if;
    end process;

end Behavioral;
