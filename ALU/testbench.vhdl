LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Alu_tb IS
END Alu_tb;

ARCHITECTURE behavior OF Alu_tb IS 
    COMPONENT Alu
        port (
            op1  : in  Std_Logic_Vector(31 downto 0);
            op2  : in  Std_Logic_Vector(31 downto 0);
            cin  : in  Std_Logic;
            cmd  : in  Std_Logic_Vector(1 downto 0);
            res  : out Std_Logic_Vector(31 downto 0);
            cout : out Std_Logic;
            z    : out Std_Logic;
            n    : out Std_Logic;
            v    : out Std_Logic;
            vdd  : in  bit;
            vss  : in  bit
        );
    END COMPONENT;

    signal op1_tb: Std_Logic_Vector(31 downto 0);
    signal op2_tb: Std_Logic_Vector(31 downto 0);
    signal cin_tb: Std_Logic := '0';
    signal cmd_tb: Std_Logic_Vector(1 downto 0) := "00";
    signal res_tb: Std_Logic_Vector(31 downto 0);
    signal cout_tb, z_tb, n_tb, v_tb: Std_Logic;
    signal vdd_tb, vss_tb: bit;

BEGIN
    uut: Alu port map (op1_tb, op2_tb, cin_tb, cmd_tb, res_tb, cout_tb, z_tb, n_tb, v_tb, vdd_tb, vss_tb);

    op1_tb <= "00000000000000000000000000001111" after 50 ns, "00000000000000000000000000001111" after 100 ns,
    "00000000000001000000000000001111" after 150 ns, "11111111111111111111111111111111" after 200 ns,
    "11111111111111111111111111111111" after 250 ns, "11111111111111111111111111111111" after 300 ns, 
    "11111111111111111111111111111111" after 350 ns, "01111111111111111111111111111111" after 400 ns,
    
    "00000000000000000000000000001111" after 450 ns, "00000000000000000000000000001111" after 500 ns,
    "00000000000001000000000000001111" after 550 ns, "11111111111111111111111111111111" after 600 ns,
    "00000000000001000000000000001111" after 650 ns, "11111111111111111111111111111111" after 700 ns;
    
    
    op2_tb <= "00000000000000000000000000000001" after 50 ns, "00000000000000000000000000001010" after 100 ns,
    "00010000000001000000000000001101" after 150 ns, "00000000000000000000000000000001" after 200 ns,
    "11111111111111111111111111111111" after 250 ns, "11111111111111111111111111111111" after 300 ns,
    "11111111111111111111111111111111" after 350 ns, "00000000000000000000000000000001" after 400 ns,
    
    "00000000000000000000000000000001" after 450 ns, "00000000000000000000000000001010" after 500 ns,
    "00000000000000000000000000000001" after 550 ns, "11111111111111111111111111111111" after 600 ns,
    "00000000000000000000000000000001" after 650 ns, "11111111111111111111111111111111" after 700 ns;

    --Cin_tb <= '1' after 300 ns; 

    cmd_tb <= "01" after 420 ns, "10" after 520 ns, "11" after 620 ns;
    

END behavior;

