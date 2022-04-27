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

        i_sck : in std_logic;
        i_ws : in std_logic;
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

    -- input 1
    signal r_rx_1_ready : std_logic;
    signal r_rx_1_word : std_logic_vector(31 downto 0);
    signal r_rx_1_word_buf : std_logic_vector(31 downto 0);
    -- tx clock synchronized buffer
    signal r_rx_1_word_buf_tx : std_logic_vector(31 downto 0);

    -- input 2
    signal r_rx_2_ready : std_logic;
    signal r_rx_2_word : std_logic_vector(31 downto 0);
    signal r_rx_2_word_buf : std_logic_vector(31 downto 0);
    -- tx clock synchronized buffer
    signal r_rx_2_word_buf_tx : std_logic_vector(31 downto 0);
    
    -- output
    signal r_tx_load : std_logic;
    signal r_tx_word : std_logic_vector(31 downto 0);
    signal r_tx_word_buf : std_logic_vector(31 downto 0);

    -- mixer
    signal r_rx_1_left : signed(15 downto 0);
    signal r_rx_1_right : signed(15 downto 0);
    signal r_rx_2_left : signed(15 downto 0);
    signal r_rx_2_right : signed(15 downto 0);
    signal r_tx_left : signed(15 downto 0);
    signal r_tx_right : signed(15 downto 0);

begin

    i2s_rx_1 : i2s_rx
        port map (
            o_word => r_rx_1_word,
            o_ready => r_rx_1_ready,
            -- clocked from input 1
            i_sck => i_sck1,
            i_ws => i_ws1,
            i_sd => i_sd1
        );

    i2s_rx_2 : i2s_rx
        port map (
            o_word => r_rx_2_word,
            o_ready => r_rx_2_ready,
            -- clocked from input 2        
            i_sck => i_sck2,
            i_ws => i_ws2,
            i_sd => i_sd2
        );

    i2s_tx_1 : i2s_tx
        port map (
            -- loaded from tx synchronized buffer
            i_word => r_tx_word_buf,
            o_load => r_tx_load,
            -- clocked from output
            i_sck => i_sck,
            i_ws => i_ws,
            o_sd => o_sd
        );

    -- store latest word from input 1
    p_rx_1 : process (i_sck1) is
    begin
        if rising_edge(i_sck1) then
            if r_rx_1_ready = '1' then
                r_rx_1_word_buf <= r_rx_1_word;
            end if;
        end if;
    end process p_rx_1;

    -- store latest word from input 2
    p_rx_2 : process (i_sck2) is
    begin
        if rising_edge(i_sck2) then
            if r_rx_2_ready = '1' then
                r_rx_2_word_buf <= r_rx_2_word;
            end if;
        end if;
    end process p_rx_2;

    -- synchronize buffers with tx clock
    p_tx_sync : process (i_sck) is
    begin
        if rising_edge(i_sck) then
            r_rx_1_word_buf_tx <= r_rx_1_word_buf;
            r_rx_2_word_buf_tx <= r_rx_2_word_buf;
        end if;
    end process p_tx_sync;

    -- channel extraction
    r_rx_1_left <= signed(r_rx_1_word_buf_tx(31 downto 16));
    r_rx_1_right <= signed(r_rx_1_word_buf_tx(15 downto 0));
    r_rx_2_left <= signed(r_rx_2_word_buf_tx(31 downto 16));
    r_rx_2_right <= signed(r_rx_2_word_buf_tx(15 downto 0));

    -- average
    r_tx_left <= resize(
        shift_right(
            resize(r_rx_1_left, 17) +
            resize(r_rx_2_left, 17),
            1
        ),
        16
    );
    r_tx_right <= resize(
        shift_right(
            resize(r_rx_1_right, 17) +
            resize(r_rx_2_right, 17),
            1
        ),
        16
    );

    -- combine
    r_tx_word <=
        std_logic_vector(r_tx_left)
        &
        std_logic_vector(r_tx_right);

    -- load new mixed word
    p_tx : process (i_sck) is
    begin
        if rising_edge(i_sck) then
            if r_tx_load = '1' then
                r_tx_word_buf <= r_tx_word;
            end if;
        end if;
    end process p_tx;
    
end architecture rtl;
