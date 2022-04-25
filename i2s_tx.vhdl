library ieee;
use ieee.std_logic_1164.all;

entity i2s_tx is
    port (
        i_word : in std_logic_vector(31 downto 0);
        o_load : out std_logic;

        i_sck : in std_logic;
        i_ws : in std_logic;
        o_sd : out std_logic
    );
end entity i2s_tx;

architecture rtl of i2s_tx is
    
    signal r_reg : std_logic_vector(31 downto 0);
    signal r_ws_d1 : std_logic;
    signal r_ws_d2 : std_logic;
    signal r_load : std_logic;

begin
    
    r_load <= r_ws_d2 and not r_ws_d1;
    
    o_load <= r_load;

    o_sd <= r_reg(r_reg'high);

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
            if r_load = '1' then
                -- load
                r_reg <= i_word;
            else
                -- shift out MSB
                r_reg <= r_reg(r_reg'high - 1 downto r_reg'low) & '0';
            end if;
        end if;
    end process p_reg;
    
end architecture rtl;
