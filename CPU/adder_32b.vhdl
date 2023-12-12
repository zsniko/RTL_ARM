LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY add_32b IS
    PORT (
        A: in std_logic_vector(31 downto 0);
        B: in std_logic_vector(31 downto 0);
        Cin: in std_logic;
        S: out std_logic_vector(31 downto 0);
        Cout: out std_logic
    );
END ENTITY add_32b;

ARCHITECTURE behavior OF add_32b IS
    COMPONENT add_4b
        PORT (
            A: in std_logic_vector(3 downto 0);
            B: in std_logic_vector(3 downto 0);
            Cin: in std_logic;
            S: out std_logic_vector(3 downto 0);
            Cout: out std_logic
        );
    END COMPONENT;

    signal c1,c2,c3,c4,c5,c6,c7: std_logic;  

BEGIN
    -- Create 4 instances of the 4-bit adder and connect them accordingly
    add_4bit_0: add_4b PORT MAP (A=>A(3 downto 0), B=>B(3 downto 0), Cin=>Cin, S=>S(3 downto 0), Cout=>c1);
    add_4bit_1: add_4b PORT MAP (A=>A(7 downto 4), B=>B(7 downto 4), Cin=>c1, S=>S(7 downto 4), Cout=>c2);
    add_4bit_2: add_4b PORT MAP (A=>A(11 downto 8), B=>B(11 downto 8), Cin=>c2, S=>S(11 downto 8), Cout=>c3);
    add_4bit_3: add_4b PORT MAP (A=>A(15 downto 12), B=>B(15 downto 12), Cin=>c3, S=>S(15 downto 12), Cout=>c4);
    add_4bit_4: add_4b PORT MAP (A=>A(19 downto 16), B=>B(19 downto 16), Cin=>c4, S=>S(19 downto 16), Cout=>c5);
    add_4bit_5: add_4b PORT MAP (A=>A(23 downto 20), B=>B(23 downto 20), Cin=>c5, S=>S(23 downto 20), Cout=>c6);
    add_4bit_6: add_4b PORT MAP (A=>A(27 downto 24), B=>B(27 downto 24), Cin=>c6, S=>S(27 downto 24), Cout=>c7);
    add_4bit_7: add_4b PORT MAP (A=>A(31 downto 28), B=>B(31 downto 28), Cin=>c7, S=>S(31 downto 28), Cout=>Cout);

END ARCHITECTURE behavior;

