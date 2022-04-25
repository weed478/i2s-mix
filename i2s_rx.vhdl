library ieee;
use ieee.std_logic_1164.all;

entity i2s_rx is
    port (
        o_word : out std_logic_vector(31 downto 0);
        o_ready : out std_logic;

        i_sck : in std_logic;
        i_ws : in std_logic;
        i_sd : in std_logic
    );
end entity i2s_rx;

architecture rtl of i2s_rx is

    signal r_reg : std_logic_vector(31 downto 0);
    signal r_ws_d1 : std_logic;
    signal r_ws_d2 : std_logic;
    
begin

    o_word <= r_reg;

    o_ready <= r_ws_d2 and not r_ws_d1;
    
    p_delay_ws : process (i_sck) is
    begin
        if rising_edge(i_sck) then
            r_ws_d1 <= i_ws;
            r_ws_d2 <= r_ws_d1;
        end if;
    end process p_delay_ws;

    p_shift : process (i_sck) is
    begin
        if rising_edge(i_sck) then
            -- shift in LSB
            r_reg <= r_reg(r_reg'high - 1 downto r_reg'low) & i_sd;
        end if;
    end process p_shift;
    
end architecture rtl;
