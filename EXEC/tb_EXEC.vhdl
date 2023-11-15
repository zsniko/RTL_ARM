LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_exec IS
END tb_exec;

ARCHITECTURE behavior OF tb_exec IS 
COMPONENT EXec 
    PORT(
        -- Decode interface synchro
                dec2exe_empty	: in Std_logic; 
                exe_pop			: out Std_logic; 

        -- Decode interface operands
                dec_op1			: in Std_Logic_Vector(31 downto 0); -- first alu input       
                dec_op2			: in Std_Logic_Vector(31 downto 0); -- shifter input          
                dec_exe_dest	: in Std_Logic_Vector(3 downto 0); -- Rd destination         
                dec_exe_wb		: in Std_Logic; -- Rd destination write back
                dec_flag_wb		: in Std_Logic; -- CSPR modifiy

        -- Decode to mem interface 
                dec_mem_data	: in Std_Logic_Vector(31 downto 0); -- data to MEM W         
                dec_mem_dest	: in Std_Logic_Vector(3 downto 0); -- Destination MEM R       
                dec_pre_index 	: in Std_logic;   

                dec_mem_lw		: in Std_Logic;  
                dec_mem_lb		: in Std_Logic;  
                dec_mem_sw		: in Std_Logic;  
                dec_mem_sb		: in Std_Logic;  

        -- Shifter command
                dec_shift_lsl	: in Std_Logic; 
                dec_shift_lsr	: in Std_Logic;  
                dec_shift_asr	: in Std_Logic;  
                dec_shift_ror	: in Std_Logic;  
                dec_shift_rrx	: in Std_Logic;	 
                dec_shift_val	: in Std_Logic_Vector(4 downto 0); 
                dec_cy			: in Std_Logic; 

        -- Alu operand selection
                dec_comp_op1	: in Std_Logic; 
                dec_comp_op2	: in Std_Logic; 
                dec_alu_cy 		: in Std_Logic; 

        -- Alu command
                dec_alu_cmd		: in Std_Logic_Vector(1 downto 0); 

        -- Exe bypass to decod
                exe_res			: out Std_Logic_Vector(31 downto 0); 

                exe_c			: out Std_Logic; 
                exe_v			: out Std_Logic; 
                exe_n			: out Std_Logic; 
                exe_z			: out Std_Logic; 

                exe_dest		: out Std_Logic_Vector(3 downto 0); -- Rd destination
                exe_wb			: out Std_Logic; -- Rd destination write back
                exe_flag_wb		: out Std_Logic; -- CSPR modifiy

        -- Mem interface
                exe_mem_adr		: out Std_Logic_Vector(31 downto 0); -- Alu res register 
                exe_mem_data	: out Std_Logic_Vector(31 downto 0); 
                exe_mem_dest	: out Std_Logic_Vector(3 downto 0); 

                exe_mem_lw		: out Std_Logic;
                exe_mem_lb		: out Std_Logic;
                exe_mem_sw		: out Std_Logic;
                exe_mem_sb		: out Std_Logic;

                exe2mem_empty	: out Std_logic;
                mem_pop			: in Std_logic;

        -- global interface
                ck				: in Std_logic; -- clock
                reset_n			: in Std_logic;	-- reset
                vdd				: in bit;		-- power
                vss				: in bit);		-- ground
END COMPONENT;

