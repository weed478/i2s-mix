library ieee;
use ieee.std_logic_1164.all;

entity i2s_tx_tb is
end entity i2s_tx_tb;

architecture tb of i2s_tx_tb is
    
    component i2s_master
        port (
            i_clk : in std_logic;
            o_sck : out std_logic;
            o_ws : out std_logic
        );
    end component i2s_master;

    component i2s_tx
        port (
            i_left : in std_logic_vector(15 downto 0);
            i_right : in std_logic_vector(15 downto 0);

            i_sck : in std_logic;
            i_ws : in std_logic;
            o_sd : out std_logic
        );
    end component i2s_tx;

    signal r_clk : std_logic := '0';
    signal r_sck : std_logic;
    signal r_ws : std_logic;
    signal r_sd : std_logic;

    signal r_left : std_logic_vector(15 downto 0)  := "1111111111111111";
    signal r_right : std_logic_vector(15 downto 0) := "0000000000000000";

begin

    r_clk <= not r_clk after 1 ns;

    i2s_master_1 : i2s_master
        port map (
            i_clk => r_clk,
            o_sck => r_sck,
            o_ws => r_ws
        );

    i2s_tx_1 : i2s_tx
        port map (
            i_sck => r_sck,
            i_ws => r_ws,
            o_sd => r_sd,
            i_left => r_left,
            i_right => r_right
        );
    
end architecture tb;
