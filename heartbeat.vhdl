library ieee;
use ieee.std_logic_1164.all;

entity heartbeat is
    port (
        o_clk : out std_logic
    );
end entity heartbeat;

architecture behav of heartbeat is
    constant c_clk_period : time := 10 ns;
begin
   p_clk : process is
   begin
       o_clk <= '0';
       wait for c_clk_period / 2;
       o_clk <= '1';
       wait for c_clk_period / 2;
   end process p_clk;
end architecture behav;
