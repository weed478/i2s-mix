entity hello_tb is
end entity hello_tb;

architecture tb of hello_tb is
begin
    p_hello : process is
    begin
        report "Hello world";
        wait;
    end process p_hello;
end architecture tb;
