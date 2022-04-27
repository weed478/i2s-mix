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

        -- master clock select btns
        i_master_sel_0 : in std_logic;
        i_master_sel_1 : in std_logic;

        -- input select btns
        i_src_sel_none : in std_logic;
        i_src_sel_0 : in std_logic;
        i_src_sel_1 : in std_logic;
        i_src_sel_01 : in std_logic;

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
    
    -- current clock master (in0 or in1)
    signal r_master : natural range 0 to 1 := 0;

    -- input enables
    signal r_src_en_0 : std_logic := '0';
    signal r_src_en_1 : std_logic := '0';

    -- master clock
    signal r_sck : std_logic;
    signal r_ws : std_logic;

    -- gated data signals
    signal r_sd0 : std_logic;
    signal r_sd1 : std_logic;

begin

    -- LEDs
    o_master_0 <= '1' when r_master = 0 else '0';
    o_master_1 <= '1' when r_master = 1 else '0';
    o_src_0 <= r_src_en_0;
    o_src_1 <= r_src_en_1;
    
    -- master clock select latches
    p_master_sel : process (i_master_sel_0, i_master_sel_1) is
    begin
        if i_master_sel_0 = '0' then
            r_master <= 0;
        elsif i_master_sel_1 = '0' then
            r_master <= 1;
        end if;
    end process p_master_sel;

    -- connect master clock
    with r_master select r_sck <=
        i_sck0 when 0,
        i_sck1 when 1;
    with r_master select r_ws <=
        i_ws0 when 0,
        i_ws1 when 1;

    -- output master clock
    o_sck <= r_sck;
    o_ws <= r_ws;

    -- input enable latches
    p_src_sel : process
        (i_src_sel_none, i_src_sel_0, i_src_sel_1, i_src_sel_01)
    is
    begin
        if i_src_sel_none = '0' then
            r_src_en_0 <= '0';
            r_src_en_1 <= '0';
        elsif i_src_sel_0 = '0' then
            r_src_en_0 <= '1';
            r_src_en_1 <= '0';
        elsif i_src_sel_1 = '0' then
            r_src_en_0 <= '0';
            r_src_en_1 <= '1';
        elsif i_src_sel_01 = '0' then
            r_src_en_0 <= '1';
            r_src_en_1 <= '1';
        end if;
    end process p_src_sel;

    -- gated data signals
    r_sd0 <= i_sd0 and r_src_en_0;
    r_sd1 <= i_sd1 and r_src_en_1;

    i2s_mix_1 : i2s_mix
        port map (
            i_sck1 => i_sck0,
            i_ws1 => i_ws0,
            i_sd1 => r_sd0,

            i_sck2 => i_sck1,
            i_ws2 => i_ws1,
            i_sd2 => r_sd1,

            i_sck => r_sck,
            i_ws => r_ws,
            o_sd => o_sd
        );
    
end architecture rtl;
