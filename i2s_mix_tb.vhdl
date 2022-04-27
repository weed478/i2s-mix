library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_mix_tb is
end entity i2s_mix_tb;

architecture tb of i2s_mix_tb is

    component i2s_master
        generic (
            c_clk_divider : natural
        );
        port (
            i_clk : in std_logic;
            o_sck : out std_logic;
            o_ws : out std_logic
        );
    end component i2s_master;

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

    component i2s_mix
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
    end component i2s_mix;

    -- input 1

    signal r_clk1 : std_logic := '0';
    signal r_clk1_en : std_logic := '0';
    signal r_tx_1_sck : std_logic;
    signal r_tx_1_ws : std_logic;
    signal r_tx_1_sd : std_logic;
    signal r_tx_1_left : std_logic_vector(15 downto 0) := (0 => '1', others => '0');
    signal r_tx_1_right : std_logic_vector(15 downto 0) := (0 => '1', others => '0');
    signal r_tx_1_word : std_logic_vector(31 downto 0);
    signal r_tx_1_load : std_logic;

    -- input 2

    signal r_clk2 : std_logic := '0';
    signal r_clk2_en : std_logic := '0';
    signal r_tx_2_sck : std_logic;
    signal r_tx_2_ws : std_logic;
    signal r_tx_2_sd : std_logic;
    signal r_tx_2_left : std_logic_vector(15 downto 0) := (0 => '1', others => '0');
    signal r_tx_2_right : std_logic_vector(15 downto 0) := (0 => '1', others => '0');
    signal r_tx_2_word : std_logic_vector(31 downto 0);
    signal r_tx_2_load : std_logic;

    -- output

    signal r_rx_sck : std_logic;
    signal r_rx_ws : std_logic;
    signal r_rx_sd : std_logic;
    signal r_rx_left : std_logic_vector(15 downto 0);
    signal r_rx_right : std_logic_vector(15 downto 0);
    signal r_rx_word : std_logic_vector(31 downto 0);
    signal r_rx_ready : std_logic;

begin

    -- input 1

    r_clk1_en <= '1' after 0 ns;
    
    p_clk1 : process is
    begin
        wait until r_clk1_en = '1';
        loop
            r_clk1 <= not r_clk1;
            wait for 100 ns;
        end loop;
    end process p_clk1;

    i2s_master_1 : i2s_master
        generic map (
            c_clk_divider => 100
        )
        port map (
            i_clk => r_clk1,
            o_sck => r_tx_1_sck,
            o_ws => r_tx_1_ws
        );

    r_tx_1_word <= r_tx_1_left & r_tx_1_right;

    i2s_tx_1 : i2s_tx
        port map (
            i_word => r_tx_1_word,
            o_load => r_tx_1_load,
            i_sck => r_tx_1_sck,
            i_ws => r_tx_1_ws,
            o_sd => r_tx_1_sd
        );




    -- input 2

    -- clk2 phase offset
    r_clk2_en <= '1' after 3333333 ns;
    
    p_clk2 : process is
    begin
        wait until r_clk2_en = '1';
        loop
            r_clk2 <= not r_clk2;
            wait for 100 ns;
        end loop;
    end process p_clk2;

    i2s_master_2 : i2s_master
        generic map (
            -- clk2 freq error 1%
            c_clk_divider => 99
        )
        port map (
            i_clk => r_clk2,
            o_sck => r_tx_2_sck,
            o_ws => r_tx_2_ws
        );

    r_tx_2_word <= r_tx_2_left & r_tx_2_right;

    i2s_tx_2 : i2s_tx
        port map (
            i_word => r_tx_2_word,
            o_load => r_tx_2_load,
            i_sck => r_tx_2_sck,
            i_ws => r_tx_2_ws,
            o_sd =>r_tx_2_sd
        );




    -- mixer

    i2s_mix_1 : i2s_mix
        port map (
            i_sck1 => r_tx_1_sck,
            i_ws1 => r_tx_1_ws,
            i_sd1 => r_tx_1_sd,

            i_sck2 => r_tx_2_sck,
            i_ws2 => r_tx_2_ws,
            i_sd2 => r_tx_2_sd,

            i_sck => r_rx_sck,
            i_ws => r_rx_ws,
            o_sd => r_rx_sd
        );



    -- output

    r_rx_sck <= r_tx_1_sck;
    r_rx_ws <= r_tx_1_ws;

    i2s_rx_1 : i2s_rx
        port map (
            o_word => r_rx_word,
            o_ready => r_rx_ready,
            i_sck => r_rx_sck,
            i_ws => r_rx_ws,
            i_sd => r_rx_sd
        );




    -- loading TXs

    p_load_tx_1 : process (r_tx_1_sck) is
    begin
        if rising_edge(r_tx_1_sck) then
            if r_tx_1_load = '1' then
                r_tx_1_left <= std_logic_vector(unsigned(r_tx_1_left) + 2);
                r_tx_1_right <= std_logic_vector(unsigned(r_tx_1_right) + 2);
            end if;
        end if;
    end process p_load_tx_1;

    p_load_tx_2 : process (r_tx_2_sck) is
    begin
        if rising_edge(r_tx_2_sck) then
            if r_tx_2_load = '1' then
                r_tx_2_left <= std_logic_vector(unsigned(r_tx_2_left) + 2);
                r_tx_2_right <= std_logic_vector(unsigned(r_tx_2_right) + 2);
            end if;
        end if;
    end process p_load_tx_2;


    -- receive mixer output

    p_rx : process (r_rx_sck) is
    begin
        if rising_edge(r_rx_sck) then
            if r_rx_ready = '1' then
                r_rx_left <= r_rx_word(31 downto 16);
                r_rx_right <= r_rx_word(15 downto 0);
            end if;
        end if;
    end process p_rx;
    
end architecture tb;
