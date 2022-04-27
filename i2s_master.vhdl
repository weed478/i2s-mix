library ieee;
use ieee.std_logic_1164.all;

entity i2s_master is
    generic (
        c_clk_divider : natural
    );
    port (
        i_clk : in std_logic;
        o_sck : out std_logic;
        o_ws : out std_logic
    );
end entity i2s_master;

architecture rtl of i2s_master is
    
    constant c_sck_divider : natural := 32;

    constant c_sck_max : natural := c_clk_divider / 2 - 1;
    constant c_ws_max : natural := c_sck_divider / 2 - 1;

    signal r_sck_count : natural range 0 to c_sck_max := 0;
    signal r_ws_count : natural range 0 to c_ws_max := 0;

    signal r_sck : std_logic := '0';
    signal r_ws : std_logic := '0';

begin

    o_sck <= r_sck;
    o_ws <= r_ws;

    p_divider : process (i_clk) is
    begin
        if rising_edge(i_clk) then
            if r_sck_count = c_sck_max then -- sck edge
                r_sck_count <= 0;
                r_sck <= not r_sck;

                if r_sck = '1' then -- sck falling edge
                    if r_ws_count = c_ws_max then -- ws change
                        r_ws_count <= 0;
                        r_ws <= not r_ws;
                    else
                        r_ws_count <= r_ws_count + 1;
                    end if;
                end if;
            else
                r_sck_count <= r_sck_count + 1;
            end if;
        end if;
    end process p_divider;

end architecture rtl;
