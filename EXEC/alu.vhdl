library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Alu is
    port (
        op1  : in  Std_Logic_Vector(31 downto 0);   -- Premiere operande (32 bits)
        op2  : in  Std_Logic_Vector(31 downto 0);   -- Deuxieme operande (32 bits)
        cin  : in  Std_Logic;                       -- Retenue d'entree
        cmd  : in  Std_Logic_Vector(1 downto 0);    -- Commande (2 bits) : 00:ADD, 01:AND, 10:OR, 11:XOR
        res  : out Std_Logic_Vector(31 downto 0);   -- Resultat (32 bits)
        cout : out Std_Logic;                       -- Retenue de sortie
        z    : out Std_Logic;                       -- Flag Zero
        n    : out Std_Logic;                       -- Flag Negatif
        v    : out Std_Logic;                       -- Flag de Debordement
        vdd  : in  bit;                             -- Alimentation VDD
        vss  : in  bit                              -- Alimentation VSS
    );
end Alu;

architecture Behavioral of Alu is

    COMPONENT add_32b
        PORT (
            A: in std_logic_vector(31 downto 0);
            B: in std_logic_vector(31 downto 0);
            Cin: in std_logic;
            S: out std_logic_vector(31 downto 0);
            Cout: out std_logic
        );
    end COMPONENT;

    signal res_temp : std_logic_vector(31 downto 0);
	signal S_temp : Std_Logic_Vector(31 downto 0); -- Variable temporaire pour les calculs
    signal cout_temp: std_logic;

begin
    add_32b_inst: add_32b PORT MAP (A=>op1, B=>op2, Cin=>cin, S=>S_temp, Cout=>cout_temp);

    res_temp <= op1 and op2 when cmd = "01" 
            else op1 or op2 when cmd = "10"
            else op1 xor op2 when cmd = "11"
            else S_temp when cmd = "00";

	-- Flags
    z <= '1' when res_temp = x"00000000" else '0';            -- Le drapeau Zero est defini si le resultat est zero
    n <= '1' when res_temp(31) = '1' and cmd = "00" else '0'; -- Le drapeau Negatif est le bit de poids fort du resultat
    
    v <= '1' when (((S_temp(31)='1' and op1(31)='0' and op2(31)='0') or (S_temp(31)='0' and op1(31)='1' and op2(31)='1')) and cmd = "00") else '0';

    res <= res_temp; 
    cout <= cout_temp when cmd = "00" else '0';


end Behavioral;
