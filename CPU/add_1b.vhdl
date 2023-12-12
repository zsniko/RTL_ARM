
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

-- Additionneur 1 bit
ENTITY add_1b IS 
	PORT (A: in std_logic; 
	      B: in std_logic;
	      Cin: in std_logic;
	      S: out std_logic; 
	      Cout: out std_logic);
END add_1b; 

ARCHITECTURE behavior of add_1b IS 
BEGIN 	
	S <= (A xor B) xor Cin;
	Cout <= (Cin and (A xor B)) or (A and B);
END behavior; 


