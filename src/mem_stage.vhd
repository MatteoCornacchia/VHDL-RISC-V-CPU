library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================
-- Data Memory Stage
-- ============================
-- Responsibilities:
--  - Handle load/store operations
--  - Generate byte/halfword/word write enables
--  - Register memory output (BRAM is synchronous)
--  - Perform load data alignment and sign extension
-- ============================

entity mem_stage is
    port ( 
        clk         : in std_logic;
        op_class    : in std_logic_vector(5 downto 0);
        funct3      : in std_logic_vector(2 downto 0);
        rs2_value   : in std_logic_vector(31 downto 0);
        alu_result  : in std_logic_vector(31 downto 0);
        mem_out     : out std_logic_vector(31 downto 0)
    );
end mem_stage;

architecture Behavioral of mem_stage is

    signal mem_out_raw  : std_logic_vector(31 downto 0);
    signal mem_out_reg  : std_logic_vector(31 downto 0);
    signal write_enable : std_logic_vector(3 downto 0);
    signal byte_offset  : std_logic_vector(1 downto 0);

    component data_mem is
        port(
            clka    : in std_logic;
            wea     : in std_logic_vector(3 downto 0);
            dina    : in std_logic_vector(31 downto 0);
            addra   : in std_logic_vector(11 downto 0);
            douta   : out std_logic_vector(31 downto 0)
        );
    end component;

begin

    -- Extract byte offset from address
    byte_offset <= alu_result(1 downto 0);

    -- ============================
    -- Data memory instance (BRAM)
    -- ============================
    dm : data_mem
        port map(
            clka  => clk,
            wea   => write_enable,
            dina  => rs2_value,
            addra => alu_result(13 downto 2),
            douta => mem_out_raw
        );

    -- ============================
    -- Register memory output
    -- ============================
    process(clk)
    begin
        if rising_edge(clk) then
            mem_out_reg <= mem_out_raw;
        end if;
    end process;

    -- ============================
    -- Load / Store control logic
    -- ============================
    process(op_class, funct3, mem_out_reg, byte_offset)
    begin
        -- Default assignments (avoid latches / U values)
        write_enable <= "0000";
        mem_out      <= (others => '0');

        case op_class is

            -- ============================
            -- LOAD instructions
            -- ============================
            when "000100" =>  -- LOAD
                case funct3 is

                    -- LB
                    when "000" =>
                        case byte_offset is
                            when "00" => mem_out <= std_logic_vector(resize(signed(mem_out_reg(7 downto 0)), 32));
                            when "01" => mem_out <= std_logic_vector(resize(signed(mem_out_reg(15 downto 8)), 32));
                            when "10" => mem_out <= std_logic_vector(resize(signed(mem_out_reg(23 downto 16)), 32));
                            when others =>
                                mem_out <= std_logic_vector(resize(signed(mem_out_reg(31 downto 24)), 32));
                        end case;

                    -- LH
                    when "001" =>
                        if byte_offset(1) = '0' then
                            mem_out <= std_logic_vector(resize(signed(mem_out_reg(15 downto 0)), 32));
                        else
                            mem_out <= std_logic_vector(resize(signed(mem_out_reg(31 downto 16)), 32));
                        end if;

                    -- LW
                    when "010" =>
                        mem_out <= mem_out_reg;

                    -- LBU
                    when "100" =>
                        case byte_offset is
                            when "00" => mem_out <= std_logic_vector(resize(unsigned(mem_out_reg(7 downto 0)), 32));
                            when "01" => mem_out <= std_logic_vector(resize(unsigned(mem_out_reg(15 downto 8)), 32));
                            when "10" => mem_out <= std_logic_vector(resize(unsigned(mem_out_reg(23 downto 16)), 32));
                            when others =>
                                mem_out <= std_logic_vector(resize(unsigned(mem_out_reg(31 downto 24)), 32));
                        end case;

                    -- LHU
                    when "101" =>
                        if byte_offset(1) = '0' then
                            mem_out <= std_logic_vector(resize(unsigned(mem_out_reg(15 downto 0)), 32));
                        else
                            mem_out <= std_logic_vector(resize(unsigned(mem_out_reg(31 downto 16)), 32));
                        end if;

                    when others =>
                        null;
                end case;

            -- ============================
            -- STORE instructions
            -- ============================
            when "001000" =>  -- STORE
                case funct3 is

                    -- SB
                    when "000" =>
                        case byte_offset is
                            when "00" => write_enable <= "0001";
                            when "01" => write_enable <= "0010";
                            when "10" => write_enable <= "0100";
                            when others => write_enable <= "1000";
                        end case;

                    -- SH
                    when "001" =>
                        if byte_offset(1) = '0' then
                            write_enable <= "0011";
                        else
                            write_enable <= "1100";
                        end if;

                    -- SW
                    when "010" =>
                        write_enable <= "1111";

                    when others =>
                        null;
                end case;

            when others =>
                null;
        end case;
    end process;

end Behavioral;
