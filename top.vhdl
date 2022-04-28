library ieee;
use ieee.std_logic_1164.all;

entity top is
    port (
        -- input 0
        i_sck0 : in std_logic;
        i_ws0 : in std_logic;
        i_sd0 : in std_logic;

        -- input 1
        i_sck1 : in std_logic;
        i_ws1 : in std_logic;
        i_sd1 : in std_logic;

        -- output
        o_sck : out std_logic;
        o_ws : out std_logic;
        o_sd : out std_logic;

        -- master clock select
        i_master_sel : in std_logic;

        -- input enables
        i_src_en_0 : in std_logic;
        i_src_en_1 : in std_logic;

        -- status LEDs
        o_master_0 : out std_logic;
        o_master_1 : out std_logic;
        o_src_0 : out std_logic;
        o_src_1 : out std_logic
    );
end entity top;

architecture rtl of top is

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

    -- tx pins
    signal r_sck : std_logic;
    signal r_ws : std_logic;
    signal r_sd : std_logic;

begin

    -- LEDs
    o_master_0 <= not i_master_sel;
    o_master_1 <= i_master_sel;
    o_src_0 <= i_src_en_0;
    o_src_1 <= i_src_en_1;

    -- connect master clock
    with i_master_sel select
        r_sck <= i_sck0 when '0',
                 i_sck1 when '1',
                 '0' when others;
    with i_master_sel select
        r_ws <= i_ws0 when '0',
                i_ws1 when '1',
                '0' when others;

    i2s_mix_1 : i2s_mix
        port map (
            i_sck1 => i_sck0,
            i_ws1 => i_ws0,
            i_sd1 => i_sd0,

            i_sck2 => i_sck1,
            i_ws2 => i_ws1,
            i_sd2 => i_sd1,

            i_sck => r_sck,
            i_ws => r_ws,
            o_sd => r_sd
        );

    o_sck <= r_sck when (i_src_en_0 and i_src_en_1) = '1' else
             i_sck0 when i_src_en_0 = '1' else
             i_sck1 when i_src_en_1 = '1' else
             '0';
    o_ws <= r_ws when (i_src_en_0 and i_src_en_1) = '1' else
            i_ws0 when i_src_en_0 = '1' else
            i_ws1 when i_src_en_1 = '1' else
            '0';
    o_sd <= r_sd when (i_src_en_0 and i_src_en_1) = '1' else
            i_sd0 when i_src_en_0 = '1' else
            i_sd1 when i_src_en_1 = '1' else
            '0';
    
end architecture rtl;
