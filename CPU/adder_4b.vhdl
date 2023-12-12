
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;


-- Additionneur 4 bit
ENTITY add_4b IS 
	PORT (A: in std_logic_vector(3 downto 0);
	      B: in std_logic_vector(3 downto 0);
	      Cin: in std_logic; 
	      S: out std_logic_vector(3 downto 0);
	      Cout: out std_logic);
END; 

ARCHITECTURE behav of add_4b IS 

COMPONENT add_1b IS 
	PORT (A: in std_logic; 
	      B: in std_logic;
	      Cin: in std_logic;
	      S: out std_logic; 
	      Cout: out std_logic);
END COMPONENT;

SIGNAL c1,c2,c3: std_logic;

BEGIN 	
	FA1: add_1b PORT MAP (A=>A(0), B=>B(0), Cin=>Cin, S=>S(0), Cout=>c1);
	FA2: add_1b PORT MAP (A=>A(1), B=>B(1), Cin=>c1, S=>S(1), Cout=>c2);
	FA3: add_1b PORT MAP (A=>A(2), B=>B(2), Cin=>c2, S=>S(2), Cout=>c3);
	FA4: add_1b PORT MAP (A=>A(3), B=>B(3), Cin=>c3, S=>S(3), Cout=>Cout);
END behav; 


