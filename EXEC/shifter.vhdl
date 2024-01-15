LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- ARM processor Shifter

ENTITY Shifter IS 
    PORT(
        shift_lsl : in Std_Logic;
        shift_lsr : in Std_Logic;
        shift_asr : in Std_Logic;
        shift_ror : in Std_Logic;
        shift_rrx : in Std_Logic;
        shift_val : in Std_Logic_Vector(4 downto 0);    -- Shift value

        din       : in Std_Logic_Vector(31 downto 0);   -- data in
        cin       : in Std_Logic;                       -- carry in

        dout      : out Std_Logic_Vector(31 downto 0);  -- data out
        cout      : out Std_Logic;                      -- carry out
    
    -- global interface
        vdd       : in bit;
        vss       : in bit
    );
END Shifter;

ARCHITECTURE archi OF Shifter IS 

    signal dout_s1  : Std_Logic_Vector(31 downto 0);     -- Shift 1
    signal cout_s1  : Std_Logic;
    signal dout_s2  : Std_Logic_Vector(31 downto 0);     -- Shift 2
    signal cout_s2  : Std_Logic;
    signal dout_s4  : Std_Logic_Vector(31 downto 0);     -- Shift 4
    signal cout_s4  : Std_Logic;
    signal dout_s8  : Std_Logic_Vector(31 downto 0);     -- Shift 8
    signal cout_s8  : Std_Logic;
    signal dout_s16 : Std_Logic_Vector(31 downto 0);     -- Shift 16
    signal cout_s16 : Std_Logic;

BEGIN 
    ----------------------------------------------------- Shift 1 -----------------------------------------------------
    dout_s1(30 downto 1)    <=  din(31 downto 2)    when ((shift_lsr = '1' or shift_asr = '1' or shift_ror = '1')    -- LSR, ASR, ROR
                                                        and (shift_val(0) = '1')) else 
                                din(29 downto 0)    when ((shift_lsl = '1')                                          -- LSL 
                                                        and (shift_val(0) = '1')) else
                                din(30 downto 1)    when (shift_val(0) = '0');                                      -- No shift 1
    dout_s1(0)              <=  din(1)              when ((shift_lsr = '1' or shift_asr = '1' or shift_ror = '1')    -- LSR, ASR, ROR
                                                        and (shift_val(0) = '1')) else                            
                                '0'                 when ((shift_lsl = '1')                                         -- LSL
                                                        and (shift_val(0) = '1')) else
                                din(0)              when (shift_val(0) = '0');                                      -- No shift 1
    dout_s1(31)             <=  '0'                 when ((shift_lsr = '1')                                          -- LSR
                                                        and (shift_val(0) = '1')) else 
                                din(31)             when ((shift_asr = '1')                                          -- ASR 
                                                        and (shift_val(0) = '1')) else 
                                din(0)              when ((shift_ror = '1')                                          -- ROR
                                                        and (shift_val(0) = '1')) else
                                din(30)             when ((shift_lsl = '1')                                          -- LSL
                                                        and (shift_val(0) = '1')) else 
                                din(31)             when (shift_val(0) = '0');                                      -- No shift 1
    cout_s1                 <=  din(0)              when ((shift_lsr = '1' or shift_asr = '1')                       -- LSR, ASR 
                                                        and (shift_val(0) = '1')) else 
                                din(1)              when ((shift_ror = '1')                                          -- ROR 
                                                        and (shift_val(0) = '1')) else 
                                din(31)             when ((shift_lsl = '1')                                          -- LSL 
                                                        and (shift_val(0) = '1')) else
                                cin                 when (shift_val(0) = '0');                                      -- No shift 1

    ----------------------------------------------------- Shift 2 -----------------------------------------------------
    dout_s2(29 downto 2)    <=  dout_s1(31 downto 4)when ((shift_lsr = '1' or shift_asr = '1' or shift_ror = '1')    -- LSR, ASR, ROR
                                                        and (shift_val(1) = '1')) else 
                                dout_s1(27 downto 0)when ((shift_lsl = '1')                                          -- LSL 
                                                        and (shift_val(1) = '1')) else
                                dout_s1(29 downto 2)when (shift_val(1) = '0');                                      -- No shift 2
    dout_s2(1 downto 0)     <=  dout_s1(3 downto 2) when ((shift_lsr = '1' or shift_asr = '1' or shift_ror = '1')    -- LSR, ASR, ROR
                                                        and (shift_val(1) = '1')) else                            
                                "00"                when ((shift_lsl = '1')                                          -- LSL
                                                        and (shift_val(1) = '1')) else
                                dout_s1(1 downto 0) when (shift_val(1) = '0');                                      -- No shift 2
    dout_s2(31 downto 30)   <=  "00"                when ((shift_lsr = '1')                                          -- LSR
                                                        and (shift_val(1) = '1')) else 
                                dout_s1(31)&dout_s1(31) 
                                                    when ((shift_asr = '1')                                          -- ASR 
                                                        and (shift_val(1) = '1')) else 
                                dout_s1(1 downto 0) when ((shift_ror = '1')                                          -- ROR
                                                        and (shift_val(1) = '1')) else
                                dout_s1(29 downto 28)
                                                    when ((shift_lsl = '1')                                          -- LSL
                                                        and (shift_val(1) = '1')) else 
                                dout_s1(31 downto 30)   
                                                    when (shift_val(1) = '0');                                      -- No shift 2
    cout_s2                 <=  dout_s1(1)          when ((shift_lsr = '1' or shift_asr = '1')                       -- LSR, ASR 
                                                        and (shift_val(1) = '1')) else 
                                dout_s1(2)          when ((shift_ror = '1')                                          -- ROR 
                                                        and (shift_val(1) = '1')) else 
                                dout_s1(30)         when ((shift_lsl = '1')                                          -- LSL 
                                                        and (shift_val(1) = '1')) else
                                cout_s1             when (shift_val(1) = '0');                                      -- No shift 2
    
    ----------------------------------------------------- Shift 4 -----------------------------------------------------
    dout_s4(27 downto 4)    <=  dout_s2(31 downto 8)when ((shift_lsr = '1' or shift_asr = '1' or shift_ror = '1')    -- LSR, ASR, ROR
                                                        and (shift_val(2) = '1')) else 
                                dout_s2(23 downto 0)when ((shift_lsl = '1')                                          -- LSL 
                                                        and (shift_val(2) = '1')) else
                                dout_s2(27 downto 4)when (shift_val(2) = '0');                                      -- No shift 4
    dout_s4(3 downto 0)     <=  dout_s2(7 downto 4) when ((shift_lsr = '1' or shift_asr = '1' or shift_ror = '1')    -- LSR, ASR, ROR
                                                        and (shift_val(2) = '1')) else                            
                                "0000"              when ((shift_lsl = '1')                                          -- LSL
                                                        and (shift_val(2) = '1')) else
                                dout_s2(3 downto 0) when (shift_val(2) = '0');                                      -- No shift 4
    dout_s4(31 downto 28)   <=  "0000"              when ((shift_lsr = '1')                                          -- LSR
                                                        and (shift_val(2) = '1')) else 
                                dout_s2(31)&dout_s2(31)&dout_s2(31)&dout_s2(31)
                                                    when ((shift_asr = '1')                                          -- ASR 
                                                        and (shift_val(2) = '1')) else 
                                dout_s2(3 downto 0) when ((shift_ror = '1')                                          -- ROR
                                                        and (shift_val(2) = '1')) else
                                dout_s2(27 downto 24)   
                                                    when ((shift_lsl = '1')                                          -- LSL
                                                        and (shift_val(2) = '1')) else 
                                dout_s2(31 downto 28)   
                                                    when (shift_val(2) = '0');                                      -- No shift 4
    cout_s4                 <=  dout_s2(3)          when ((shift_lsr = '1' or shift_asr = '1')                       -- LSR, ASR 
                                                        and (shift_val(2) = '1')) else 
                                dout_s2(4)          when ((shift_ror = '1')                                          -- ROR 
                                                        and (shift_val(2) = '1')) else 
                                dout_s2(28)         when ((shift_lsl = '1')                                          -- LSL 
                                                        and (shift_val(2) = '1')) else
                                cout_s2             when (shift_val(2) = '0');                                      -- No shift 4                        
                        
    ----------------------------------------------------- Shift 8 -----------------------------------------------------
    dout_s8(23 downto 8)    <=  dout_s4(31 downto 16)
                                                    when ((shift_lsr = '1' or shift_asr = '1' or shift_ror = '1')    -- LSR, ASR, ROR
                                                        and (shift_val(3) = '1')) else 
                                dout_s4(15 downto 0)when ((shift_lsl = '1')                                          -- LSL 
                                                        and (shift_val(3) = '1')) else
                                dout_s4(23 downto 8)when (shift_val(3) = '0');                                      -- No shift 8
    dout_s8(7 downto 0)     <=  dout_s4(15 downto 8)when ((shift_lsr = '1' or shift_asr = '1' or shift_ror = '1')    -- LSR, ASR, ROR
                                                        and (shift_val(3) = '1')) else                            
                                "00000000"          when ((shift_lsl = '1')                                          -- LSL
                                                        and (shift_val(3) = '1')) else
                                dout_s4(7 downto 0) when (shift_val(3) = '0');                                      -- No shift 8
    dout_s8(31 downto 24)   <=  "00000000"          when ((shift_lsr = '1')                                          -- LSR
                                                        and (shift_val(3) = '1')) else 
                                dout_s4(31)&dout_s4(31)&dout_s4(31)&dout_s4(31)&dout_s4(31)&dout_s4(31)&dout_s4(31)&dout_s4(31)
                                                    when ((shift_asr = '1')                                          -- ASR 
                                                        and (shift_val(3) = '1')) else 
                                dout_s4(7 downto 0) when ((shift_ror = '1')                                          -- ROR
                                                        and (shift_val(3) = '1')) else
                                dout_s4(23 downto 16)   
                                                    when ((shift_lsl = '1')                                          -- LSL
                                                        and (shift_val(3) = '1')) else 
                                dout_s4(31 downto 24)   
                                                    when (shift_val(3) = '0');                                      -- No shift 8
    cout_s8                 <=  dout_s4(7)          when ((shift_lsr = '1' or shift_asr = '1')                       -- LSR, ASR 
                                                        and (shift_val(3) = '1')) else 
                                dout_s4(8)          when ((shift_ror = '1')                                          -- ROR 
                                                        and (shift_val(3) = '1')) else 
                                dout_s4(24)         when ((shift_lsl = '1')                                          -- LSL 
                                                        and (shift_val(3) = '1')) else
                                cout_s4             when (shift_val(3) = '0');                                      -- No shift 8
    
    ----------------------------------------------------- Shift 16 -----------------------------------------------------
    dout_s16(15 downto 0)   <=  dout_s8(31 downto 16)   
                                                    when ((shift_lsr = '1' or shift_asr = '1' or shift_ror = '1')    -- LSR, ASR, ROR
                                                        and (shift_val(4) = '1')) else 
                                "0000000000000000"  when ((shift_lsl = '1')                                          -- LSL 
                                                        and (shift_val(4) = '1')) else
                                dout_s8(15 downto 0)when (shift_val(4) = '0');                                      -- No shift 16
    dout_s16(31 downto 16)  <=  "0000000000000000"  when ((shift_lsr = '1')                                          -- LSR
                                                        and (shift_val(4) = '1')) else 
                                dout_s8(31)&dout_s8(31)&dout_s8(31)&dout_s8(31)&dout_s8(31)&dout_s8(31)&dout_s8(31)&dout_s8(31)&dout_s8(31)&dout_s8(31)&dout_s8(31)&dout_s8(31)&dout_s8(31)&dout_s8(31)&dout_s8(31)&dout_s8(31)
                                                    when ((shift_asr = '1')                                          -- ASR 
                                                        and (shift_val(4) = '1')) else 
                                dout_s8(15 downto 0)when ((shift_ror = '1' or shift_lsl = '1')                       -- ROR, LSL
                                                        and (shift_val(4) = '1')) else
                                dout_s8(31 downto 16)   
                                                    when (shift_val(4) = '0');                                      -- No shift 16
    cout_s16                <=  dout_s8(15)         when ((shift_lsr = '1' or shift_asr = '1')                       -- LSR, ASR 
                                                        and (shift_val(4) = '1')) else 
                                dout_s8(16)         when ((shift_ror = '1')                                          -- ROR 
                                                        and (shift_val(4) = '1')) else 
                                dout_s8(16)         when ((shift_lsl = '1')                                          -- LSL 
                                                        and (shift_val(4) = '1')) else
                                cout_s8             when (shift_val(4) = '0');                                      -- No shift 16
    
    -- Mise a jour des sorties 
    dout <= dout_s16;
    cout <= cout_s16;

END archi;