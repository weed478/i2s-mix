library ieee;
use ieee.std_logic_1164.all;

entity i2s_passthrough is
    port (
        i_sck : in std_logic;
        i_ws : in std_logic;
        i_sd : in std_logic;
        
        o_sck : out std_logic;
        o_ws : out std_logic;
        o_sd : out std_logic
    );
end entity i2s_passthrough;

architecture rtl of i2s_passthrough is
    
    component i2s_tx
        port (
            i_word : in std_logic_vector(31 downto 0);
            o_load : out std_logic;

            i_sck : in std_logic;
            i_ws : in std_logic;
            o_sd : out std_logic
        );
    end component i2s_tx;

    component i2s_rx
        port (
            o_word : out std_logic_vector(31 downto 0);
            o_ready : out std_logic;

            i_sck : in std_logic;
            i_ws : in std_logic;
            i_sd : in std_logic
        );
    end component i2s_rx;

    signal r_word_rx : std_logic_vector(31 downto 0);
    signal r_word_tx : std_logic_vector(31 downto 0);
    signal r_rx_ready : std_logic;

begin
    
    o_sck <= i_sck;
    o_ws <= i_ws;

    i2s_rx_1 : i2s_rx
        port map (
            o_word => r_word_rx,
            o_ready => r_rx_ready,
            i_sck => i_sck,
            i_ws => i_ws,
            i_sd => i_sd
        );

    i2s_tx_1 : i2s_tx
        port map (
            i_word => r_word_tx,
            i_sck => i_sck,
            i_ws => i_ws,
            o_sd => o_sd
        );

    p_rx : process (i_sck) is
    begin
        if rising_edge(i_sck) then
            if r_rx_ready = '1' then
                r_word_tx <= r_word_rx;
            end if;
        end if;
    end process p_rx;
    
end architecture rtl;
