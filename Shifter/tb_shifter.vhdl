LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Testbench for ARM Shifter

ENTITY tb_Shifter IS 
END tb_Shifter;

ARCHITECTURE behavior OF tb_Shifter IS 
    COMPONENT Shifter
        PORT(
            shift_lsl : in Std_Logic;
            shift_lsr : in Std_Logic;
            shift_asr : in Std_Logic;
            shift_ror : in Std_Logic;
            shift_rrx : in Std_Logic;
            shift_val : in Std_Logic_Vector(4 downto 0);
            din       : in Std_Logic_Vector(31 downto 0);   -- data in
            cin       : in Std_Logic;                       -- carry in
            dout      : out Std_Logic_Vector(31 downto 0);  -- data out
            cout      : out Std_Logic;                      -- carry out
            vdd       : in bit;
            vss       : in bit
        );
    END COMPONENT;

    signal LSL_tb:          Std_Logic :='0';
    signal LSR_tb:          Std_Logic :='0';
    signal ASR_tb:          Std_Logic :='0';
    signal ROR_tb:          Std_Logic :='0';
    signal RRX_tb:          Std_Logic :='0';
    signal shift_val_tb:    Std_Logic_Vector(4 downto 0):="00000";
    signal din_tb:          Std_Logic_Vector(31 downto 0):="00000011111111110000111110000000";
    signal cin_tb:          Std_Logic :='0';
    signal dout_tb:         Std_Logic_Vector(31 downto 0);
    signal cout_tb:         Std_Logic;
    signal vdd_tb:          bit;
    signal vss_tb:          bit;

BEGIN 
    uut: Shifter PORT MAP(shift_lsl => LSL_tb, shift_lsr => LSR_tb, shift_asr => ASR_tb, shift_ror => ROR_tb, shift_rrx => RRX_tb,
                          shift_val => shift_val_tb, din => din_tb, cin=>cin_tb, 
                          dout => dout_tb, cout => cout_tb,
                          vdd => vdd_tb, vss => vss_tb);
    
    LSL_tb <= '1' after 50 ns, '0' after 100 ns, '0' after 150 ns, '1' after 300 ns, '0' after 350 ns; 
    LSR_tb <= '0' after 50 ns, '1' after 100 ns, '0' after 200 ns;
    ROR_tb <= '1' after 200 ns, '0' after 250 ns;
    ASR_tb <= '1' after 250 ns, '0' after 300 ns;

    din_tb <= dout_tb after 50 ns; 
    shift_val_tb <= "00001" after 50 ns, "00101" after 100 ns, "00100" after 150 ns,
                    "00011" after 200 ns, "01001" after 250 ns, "10011" after 300 ns,
                    "00000" after 350 ns;
                      


END behavior;
    