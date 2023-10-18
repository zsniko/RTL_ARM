LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_add_32b IS
END;

ARCHITECTURE behavior OF tb_add_32b IS

    COMPONENT add_32b
        PORT (
            A: in std_logic_vector(31 downto 0);
            B: in std_logic_vector(31 downto 0);
            Cin: in std_logic;
            S: out std_logic_vector(31 downto 0);
            Cout: out std_logic
        );
    END COMPONENT;

    -- Inputs
    SIGNAL A_tb : std_logic_vector(31 downto 0);
    SIGNAL B_tb: std_logic_vector(31 downto 0);
    SIGNAL Cin_tb: std_logic := '0';
    -- Outputs
    SIGNAL S_tb: std_logic_vector(31 downto 0);
    SIGNAL Cout_tb: std_logic;

BEGIN
    UUT: add_32b PORT MAP (A=>A_tb, B=>B_tb, Cin=>Cin_tb, S=>S_tb, Cout=>Cout_tb);

    A_tb <= "00000000000000000000000000001111" after 50 ns, "00000000000000000000000000001111" after 100 ns,
    "00000000000001000000000000001111" after 150 ns, "11111111111111111111111111111111" after 200 ns,
    "11111111111111111111111111111111" after 250 ns, "11111111111111111111111111111111" after 300 ns, 
    "11111111111111111111111111111111" after 350 ns ; 
    B_tb <= "00000000000000000000000000000001" after 50 ns, "00000000000000000000000000001010" after 100 ns,
    "00010000000001000000000000001101" after 150 ns, "00000000000000000000000000000001" after 200 ns,
    "11111111111111111111111111111111" after 250 ns, "11111111111111111111111111111111" after 300 ns,
    "11111111111111111111111111111111" after 350 ns;
    Cin_tb <= '1' after 300 ns; 
END;
