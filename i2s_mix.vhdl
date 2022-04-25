library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_mix is
    port (
        i_sck1 : in std_logic;
        i_ws1 : in std_logic;
        i_sd1 : in std_logic;

        i_sck2 : in std_logic;
        i_ws2 : in std_logic;
        i_sd2 : in std_logic;

        o_sck : out std_logic;
        o_ws : out std_logic;
        o_sd : out std_logic
    );
end entity i2s_mix;

architecture rtl of i2s_mix is
    
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

    signal r_sck : std_logic;
    signal r_ws : std_logic;

    signal r_rx_1_word : std_logic_vector(31 downto 0);
    signal r_rx_1_ready : std_logic;

    signal r_rx_2_word : std_logic_vector(31 downto 0);
    signal r_rx_2_ready : std_logic;

    signal r_tx_word : std_logic_vector(31 downto 0) := (others => '0');
    signal r_tx_load : std_logic;

begin

    i2s_rx_1 : i2s_rx
        port map (
            o_word => r_rx_1_word,
            o_ready => r_rx_1_ready,
            
            i_sck => i_sck1,
            i_ws => i_ws1,
            i_sd => i_sd1
        );

    i2s_rx_2 : i2s_rx
        port map (
            o_word => r_rx_2_word,
            o_ready => r_rx_2_ready,
            
            i_sck => i_sck2,
            i_ws => i_ws2,
            i_sd => i_sd2
        );

    i2s_tx_1 : i2s_tx
        port map (
            i_word => r_tx_word,
            o_load => r_tx_load,
            i_sck => r_sck,
            i_ws => r_ws,
            o_sd => o_sd
        );
    
    -- input 1 is master
    r_sck <= i_sck1;
    r_ws <= i_ws1;

    -- send out master clock
    o_sck <= r_sck;
    o_ws <= r_ws;

    process (r_sck) is
    begin
        if rising_edge(r_sck) then
            if r_rx_1_ready = '1' and r_rx_2_ready = '1' then
                -- sum both words
                r_tx_word <= std_logic_vector(
                    signed(r_rx_1_word) + signed(r_rx_2_word)
                );
            elsif r_rx_1_ready = '1' then
                -- input 1 is set first
                r_tx_word <= r_rx_1_word;
            elsif r_rx_2_ready = '1' then
                -- input 2 is added to input 1
                r_tx_word <= std_logic_vector(
                    signed(r_tx_word) + signed(r_rx_2_word)
                );
            end if;
        end if;
    end process;
    
end architecture rtl;
