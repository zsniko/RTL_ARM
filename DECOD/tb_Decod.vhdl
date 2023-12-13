library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_decod is 
end entity;

architecture simu_decod of tb_decod is
    -- Exec  operands
    signal	dec_op1			: Std_Logic_Vector(31 downto 0); -- first alu input
    signal 	dec_op2			: Std_Logic_Vector(31 downto 0); -- shifter input
    signal	dec_exe_dest	        : Std_Logic_Vector(3 downto 0); -- Rd destination
    signal	dec_exe_wb		: Std_Logic; -- Rd destination write back
    signal	dec_flag_wb		: Std_Logic; -- CSPR modifiy

    -- Decod to mem [via exec]
    signal	dec_mem_data	: Std_Logic_Vector(31 downto 0); -- data to MEM
    signal	dec_mem_dest	: Std_Logic_Vector(3 downto 0); -- Rd destination
    signal	dec_pre_index 	: Std_logic; 
    signal      dec_mem_lw      : Std_Logic; -- load word
    signal      dec_mem_lb      : Std_Logic; -- load byte
    signal      dec_mem_sw      : Std_Logic; -- store word
    signal      dec_mem_sb      : Std_Logic; -- store byte

    -- Shifter command
    signal      dec_shift_lsl   : Std_Logic; -- logical shift left
    signal      dec_shift_lsr   : Std_Logic; -- logical shift right
    signal      dec_shift_asr   : Std_Logic; -- arithmetic shift right
    signal      dec_shift_ror   : Std_Logic; -- rotate right
    signal      dec_shift_rrx   : Std_Logic; -- rotate right with extend
    signal      dec_shift_val   : Std_Logic_Vector(4 downto 0); -- shift value
    signal      dec_cy          : Std_Logic; -- shifter carry

    -- Alu operand selection
    signal      dec_comp_op1    : Std_Logic; -- complement op1 control
    signal      dec_comp_op2    : Std_Logic; -- complement op2 control
    signal      dec_alu_cy      : Std_Logic; -- alu carry

    -- Exec Synchro
    signal      dec2exe_empty   : Std_Logic;
    signal      exe_pop         : Std_logic;

    -- Alu command
    signal      dec_alu_cmd     : Std_Logic_Vector(1 downto 0); -- alu command

    -- Exe Write Back to reg
    signal      exe_res         : Std_Logic_Vector(31 downto 0); -- alu result

    signal      exe_c           : Std_Logic; -- carry
    signal      exe_v           : Std_Logic; -- overflow
    signal      exe_n           : Std_Logic; -- negative
    signal      exe_z           : Std_Logic; -- zero

    signal      exe_dest        : Std_Logic_Vector(3 downto 0); -- Rd destination
    signal      exe_wb          : Std_Logic; -- Rd destination write back
    signal      exe_flag_wb     : Std_Logic; -- CSPR modifiy

    -- Ifetch interface
    signal      dec_pc          : Std_Logic_Vector(31 downto 0) ; -- PC
    signal      if_ir           : Std_Logic_Vector(31 downto 0) ; -- 32 bits instruction to decode

    -- Ifetch synchro
    signal      dec2if_empty    : Std_Logic; -- whether the FIFO which fetches the PC is empty
    signal      if_pop          : Std_Logic; -- pop the dec2if FIFO

    signal      if2dec_empty    : Std_Logic; -- whether the FIFO which sends the instruction to decode is empty
    signal      dec_pop         : Std_Logic; -- pop the if2dec FIFO

    -- Mem Write back to reg
    signal      mem_res         : Std_Logic_Vector(31 downto 0); -- data from MEM
    signal      mem_dest        : Std_Logic_Vector(3 downto 0); -- Rd destination
    signal      mem_wb          : Std_Logic; -- write back

    -- global interface
    signal      ck              : Std_Logic;
    signal      reset_n         : Std_Logic;
    signal      vdd             : bit;
    signal      vss             : bit;

component Decod is 
    port(
        -- Exec  operands
                dec_op1			: out Std_Logic_Vector(31 downto 0); -- first alu input
                dec_op2			: out Std_Logic_Vector(31 downto 0); -- shifter input
                dec_exe_dest	: out Std_Logic_Vector(3 downto 0); -- Rd destination
                dec_exe_wb		: out Std_Logic; -- Rd destination write back
                dec_flag_wb		: out Std_Logic; -- CSPR modifiy
    
        -- Decod to mem [via exec]
                dec_mem_data	: out Std_Logic_Vector(31 downto 0); -- data to MEM
                dec_mem_dest	: out Std_Logic_Vector(3 downto 0); -- Rd destination
                dec_pre_index 	: out Std_logic; 
    
                dec_mem_lw		: out Std_Logic; -- load word
                dec_mem_lb		: out Std_Logic; -- load byte
                dec_mem_sw		: out Std_Logic; -- store word
                dec_mem_sb		: out Std_Logic; -- store byte
    
        -- Shifter command
                dec_shift_lsl	: out Std_Logic; -- logical shift left
                dec_shift_lsr	: out Std_Logic; -- logical shift right
                dec_shift_asr	: out Std_Logic; -- arithmetic shift right
                dec_shift_ror	: out Std_Logic; -- rotate right
                dec_shift_rrx	: out Std_Logic; -- rotate right with extend
                dec_shift_val	: out Std_Logic_Vector(4 downto 0); -- shift value
                dec_cy			: out Std_Logic; -- shifter carry 
    
        -- Alu operand selection
                dec_comp_op1	: out Std_Logic; -- complement op1 control
                dec_comp_op2	: out Std_Logic; -- complement op2 control
                dec_alu_cy 		: out Std_Logic; -- alu carry 
    
        -- Exec Synchro
                dec2exe_empty	: out Std_Logic; 
                exe_pop			: in Std_logic;
    
        -- Alu command
                dec_alu_cmd		: out Std_Logic_Vector(1 downto 0); -- alu command
    
        -- Exe Write Back to reg
                exe_res			: in Std_Logic_Vector(31 downto 0); -- alu result
    
                exe_c			: in Std_Logic; -- carry
                exe_v			: in Std_Logic; -- overflow
                exe_n			: in Std_Logic; -- negative
                exe_z			: in Std_Logic; -- zero
    
                exe_dest		: in Std_Logic_Vector(3 downto 0); -- Rd destination
                exe_wb			: in Std_Logic; -- Rd destination write back
                exe_flag_wb		: in Std_Logic; -- CSPR modifiy
    
        -- Ifetch interface
                dec_pc			: out Std_Logic_Vector(31 downto 0) ; -- PC
                if_ir			: in Std_Logic_Vector(31 downto 0) ; -- 32 bits instruction to decode 
    
        -- Ifetch synchro
                dec2if_empty	: out Std_Logic; -- whether the FIFO which fetches the PC is empty
                if_pop			: in Std_Logic; -- pop the dec2if FIFO
    
                if2dec_empty	: in Std_Logic; -- whether the FIFO which sends the instruction to decode is empty
                dec_pop			: out Std_Logic; -- pop the if2dec FIFO
    
        -- Mem Write back to reg
                mem_res			: in Std_Logic_Vector(31 downto 0); -- data from MEM
                mem_dest		: in Std_Logic_Vector(3 downto 0); -- Rd destination
                mem_wb			: in Std_Logic; -- write back
                
        -- global interface
                ck				: in Std_Logic;
                reset_n			: in Std_Logic;
                vdd				: in bit;
                vss				: in bit);
    end component;

begin 

decodsim: Decod port map 
    (
        dec_op1         => dec_op1,
        dec_op2         => dec_op2,
        dec_exe_dest    => dec_exe_dest,
        dec_exe_wb      => dec_exe_wb,
        dec_flag_wb     => dec_flag_wb,

        dec_mem_data    => dec_mem_data,
        dec_mem_dest    => dec_mem_dest,
        dec_pre_index   => dec_pre_index,
        
        dec_mem_lw      => dec_mem_lw,
        dec_mem_lb      => dec_mem_lb,
        dec_mem_sw      => dec_mem_sw,
        dec_mem_sb      => dec_mem_sb,

        dec_shift_lsl   => dec_shift_lsl,
        dec_shift_lsr   => dec_shift_lsr,
        dec_shift_asr   => dec_shift_asr,
        dec_shift_ror   => dec_shift_ror,
        dec_shift_rrx   => dec_shift_rrx,
        dec_shift_val   => dec_shift_val,
        dec_cy          => dec_cy,

        dec_comp_op1    => dec_comp_op1,
        dec_comp_op2    => dec_comp_op2,
        dec_alu_cy      => dec_alu_cy,

        dec2exe_empty   => dec2exe_empty,
        exe_pop         => exe_pop,
        
        dec_alu_cmd     => dec_alu_cmd,

        exe_res         => exe_res,

        exe_c           => exe_c,
        exe_v           => exe_v,
        exe_n           => exe_n,
        exe_z           => exe_z,

        exe_dest        => exe_dest,
        exe_wb          => exe_wb,
        exe_flag_wb     => exe_flag_wb,

        dec_pc          => dec_pc,
        if_ir           => if_ir,

        dec2if_empty    => dec2if_empty,
        if_pop          => if_pop,

        if2dec_empty    => if2dec_empty,
        dec_pop         => dec_pop,

        mem_res         => mem_res,
        mem_dest        => mem_dest,
        mem_wb          => mem_wb,

        ck              => ck,
        reset_n         => reset_n,
        vdd             => vdd,
        vss             => vss
    );
    
clock: process
    begin 
        ck <= '0';
        wait for 10 ns;
        ck <= '1';
        wait for 10 ns;
    end process;

--tb: process
    --begin 
        --if rising_edge(ck) then 
            -- ADD r1,r4,r7,asr r6 ; ADD r1,r1,2; 
                reset_n<='0' after 10 ns, '1' after 35 ns;
                if_ir <= X"e0841657" after 50 ns, X"e0811657" after 70 ns, X"e2811002" after 90 ns, X"ea000003" after 110 ns, X"e28f1002" after 130 ns; 

                exe_pop <= '1' after 20 ns;
                exe_c <= '0'    after 20 ns;
                exe_v <= '0'   after 20 ns;
                exe_n <= '0'    after 20 ns;
                exe_z <= '0'    after 20 ns;
                exe_res <= X"00000111" after 50 ns, X"0000005f" after 90 ns, X"01100055" after 110 ns ; -- supposition 
                exe_dest <= "0001" after 50 ns, "1111" after 110 ns, "0010" after 170 ns ;
                exe_wb <= '1'           after 20 ns;
                exe_flag_wb <= '0'      after 20 ns;


                if_pop <= '1'   after 20 ns;
                if2dec_empty <= '0'     after 20 ns;

                mem_res	<= X"00000000"  after 20 ns;
                mem_dest	<= X"0"       after 20 ns;
                mem_wb		<= '0'     after 20 ns;

        --wait for 20 ns;
        --end if;

    --end process;

end architecture;


    

