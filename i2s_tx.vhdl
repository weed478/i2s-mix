library ieee;
use ieee.std_logic_1164.all;

entity i2s_tx is
    port (
        i_left : in std_logic_vector(15 downto 0);
        i_right : in std_logic_vector(15 downto 0);

        i_sck : in std_logic;
        i_ws : in std_logic;
        o_sd : out std_logic
    );
end entity i2s_tx;

architecture rtl of i2s_tx is
    
    signal r_shift_reg : std_logic_vector(15 downto 0);
    signal r_ws_d1 : std_logic;
    signal r_ws_d2 : std_logic;
    signal r_ws_edge : std_logic;

begin
    
    r_ws_edge <= r_ws_d1 xor r_ws_d2;

    o_sd <= r_shift_reg(r_shift_reg'high);

    p_delay_ws : process (i_sck) is
    begin
        if rising_edge(i_sck) then
            r_ws_d1 <= i_ws;
            r_ws_d2 <= r_ws_d1;
        end if;
    end process p_delay_ws;

    p_reg : process (i_sck) is
    begin
        if falling_edge(i_sck) then
            if r_ws_edge = '1' then
                -- load
                if r_ws_d1 = '1' then
                    r_shift_reg <= i_right;
                else
                    r_shift_reg <= i_left;
                end if;
            else
                -- shift out MSB
                r_shift_reg <=
                    r_shift_reg(
                        r_shift_reg'high - 1 
                        downto
                        r_shift_reg'low
                    ) & '0';
            end if;
        end if;
    end process p_reg;
    
end architecture rtl;
