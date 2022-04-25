library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_passthrough_tb is
end entity i2s_passthrough_tb;

architecture tb of i2s_passthrough_tb is

    component i2s_master
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

    component i2s_passthrough
        port (
            i_sck : in std_logic;
            i_ws : in std_logic;
            i_sd : in std_logic;
            
            o_sck : out std_logic;
            o_ws : out std_logic;
            o_sd : out std_logic
        );
    end component i2s_passthrough;

    signal r_clk : std_logic := '0';

    signal r_left_tx : std_logic_vector(15 downto 0) := (others => '0');
    signal r_right_tx : std_logic_vector(15 downto 0) := (0 => '1', others => '0');
    signal r_word_tx : std_logic_vector(31 downto 0);
    signal r_load : std_logic;

    signal r_pth_rx_sck : std_logic;
    signal r_pth_rx_ws : std_logic;
    signal r_pth_rx_sd : std_logic;

    signal r_pth_tx_sck : std_logic;
    signal r_pth_tx_ws : std_logic;
    signal r_pth_tx_sd : std_logic;

    signal r_left_rx : std_logic_vector(15 downto 0);
    signal r_right_rx : std_logic_vector(15 downto 0);
    signal r_word_rx : std_logic_vector(31 downto 0);
    signal r_ready : std_logic;

begin

    r_clk <= not r_clk after 1 ns;

    r_word_tx <= r_left_tx & r_right_tx;

    i2s_master_1 : i2s_master
        port map (
            i_clk => r_clk,
            o_sck => r_pth_rx_sck,
            o_ws => r_pth_rx_ws
        );

    i2s_tx_1 : i2s_tx
        port map (
            i_word => r_word_tx,
            o_load => r_load,
            i_sck => r_pth_rx_sck,
            i_ws => r_pth_rx_ws,
            o_sd => r_pth_rx_sd
        );

    i2s_passthrough_1 : i2s_passthrough
            port map (
                i_sck => r_pth_rx_sck,
                i_ws => r_pth_rx_ws,
                i_sd => r_pth_rx_sd,
                o_sck => r_pth_tx_sck,
                o_ws => r_pth_tx_ws,
                o_sd => r_pth_tx_sd
            );

    i2s_rx_1 : i2s_rx
        port map (
            o_word => r_word_rx,
            o_ready => r_ready,
            i_sck => r_pth_tx_sck,
            i_ws => r_pth_tx_ws,
            i_sd => r_pth_tx_sd
        );

    process (r_pth_rx_sck) is
    begin
        if rising_edge(r_pth_rx_sck) then
            if r_load = '1' then
                r_left_tx <= std_logic_vector(unsigned(r_left_tx) + 2);
                r_right_tx <= std_logic_vector(unsigned(r_right_tx) + 2);
            end if;

            if r_ready = '1' then
                r_left_rx <= r_word_rx(31 downto 16);
                r_right_rx <= r_word_rx(15 downto 0);
            end if;
        end if;
    end process;
    
end architecture tb;
