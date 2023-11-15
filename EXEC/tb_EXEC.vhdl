LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.math_real.all;

ENTITY tb_exec IS
END tb_exec;

ARCHITECTURE simu of tb_exec IS
COMPONENT EXec
	PORT(
	-- Decode interface synchro
			dec2exe_empty	: in Std_logic;  -- 
			exe_pop		: out Std_logic; -- 

	-- Decode interface operands
			dec_op1		: in Std_Logic_Vector(31 downto 0); -- first alu input -- Op1
			dec_op2		: in Std_Logic_Vector(31 downto 0); -- shifter input   -- Op2 
			dec_exe_dest	: in Std_Logic_Vector(3 downto 0); -- Rd destination  -- Direct Copy  
			dec_exe_wb	: in Std_Logic; -- Rd destination write back -- Direct Copy
			dec_flag_wb	: in Std_Logic; -- CSPR modifiy  -- Direct Copy

	-- Decode to mem interface 
			dec_mem_data	: in Std_Logic_Vector(31 downto 0); -- data to MEM W   (FIFO)    
			dec_mem_dest	: in Std_Logic_Vector(3 downto 0); -- Destination MEM R  (FIFO)
			dec_pre_index 	: in Std_logic;   -- Select alu_res or op1 for mem_adr

			dec_mem_lw	: in Std_Logic;  -- FIFO Input
			dec_mem_lb	: in Std_Logic;  -- FIFO Input
			dec_mem_sw	: in Std_Logic;  -- FIFO Input
			dec_mem_sb	: in Std_Logic;  -- FIFO Input

	-- Shifter command
			dec_shift_lsl	: in Std_Logic;  -- Logical Shift Left
			dec_shift_lsr	: in Std_Logic;  -- Logical Shift Right
			dec_shift_asr	: in Std_Logic;  -- Arithmetic Shift Right
			dec_shift_ror	: in Std_Logic;  -- Rotate Right
			dec_shift_rrx	: in Std_Logic;	 -- RRX
			dec_shift_val	: in Std_Logic_Vector(4 downto 0); -- Shift value
			dec_cy		: in Std_Logic;  -- Carry in (Shifter)

	-- Alu operand selection
			dec_comp_op1	: in Std_Logic; -- dec_op1 ou NOT dec_op1
			dec_comp_op2	: in Std_Logic; -- dec_op2 ou NOT dec_op2
			dec_alu_cy 	: in Std_Logic; -- Carry in (ALU)

	-- Alu command
			dec_alu_cmd	: in Std_Logic_Vector(1 downto 0); -- ALU command (ADD, AND, OR, XOR)

	-- Exe bypass to decod
			exe_res		: out Std_Logic_Vector(31 downto 0); -- alu_res -> exe_res 

			exe_c		: out Std_Logic; -- Carry out (EXEC)
			exe_v		: out Std_Logic; -- Overflow (EXEC)
			exe_n		: out Std_Logic; -- Negative (EXEC)
			exe_z		: out Std_Logic; -- Zero (EXEC)

			exe_dest	: out Std_Logic_Vector(3 downto 0); -- Rd destination -- Copy dec_exe_dest
			exe_wb		: out Std_Logic; -- Rd destination write back -- Copy dec_exe_wb
			exe_flag_wb	: out Std_Logic; -- CSPR modifiy -- Copy dec_exe_flag_wb

	-- Mem interface
			exe_mem_adr	: out Std_Logic_Vector(31 downto 0); -- FIFO Output, Rd address 
			exe_mem_data	: out Std_Logic_Vector(31 downto 0); -- FIFO Output, Rd data
			exe_mem_dest	: out Std_Logic_Vector(3 downto 0); -- FIFO Output, Rd destination

			exe_mem_lw	: out Std_Logic;-- FIFO Output, Rd command
			exe_mem_lb	: out Std_Logic;-- FIFO Output, Rd command
			exe_mem_sw	: out Std_Logic;-- FIFO Output, Rd command
			exe_mem_sb	: out Std_Logic;-- FIFO Output, Rd command

			exe2mem_empty	: out Std_logic;-- FIFO Output, empty
			mem_pop		: in Std_logic; -- FIFO Input, pop

	-- global interface
			ck		: in Std_logic; -- clock
			reset_n	        : in Std_logic;	-- reset
			vdd		: in bit;	-- power
			vss		: in bit);	-- ground
END COMPONENT;

-- Signal Declaration 
-- Decode interface synchro
signal        dec2exe_empty	: Std_logic :='0';  
signal        exe_pop		: Std_logic; 
-- Decode interface operands
signal        dec_op1		: Std_Logic_Vector(31 downto 0); -- first alu input -- Op1
signal        dec_op2		: Std_Logic_Vector(31 downto 0); -- shifter input   -- Op2 
signal        dec_exe_dest	: Std_Logic_Vector(3 downto 0); -- Rd destination  -- Direct Copy  
signal        dec_exe_wb	: Std_Logic; -- Rd destination write back -- Direct Copy
signal        dec_flag_wb	: Std_Logic; -- CSPR modifiy  -- Direct Copy
-- Decode to mem interface
signal        dec_mem_data	: Std_Logic_Vector(31 downto 0) := (others=>'0');  -- data to MEM W   (FIFO)
signal        dec_mem_dest	: Std_Logic_Vector(3 downto 0) := (others=>'0'); -- Destination MEM R  (FIFO)
signal        dec_pre_index 	: Std_logic;   -- Select alu_res or op1 for mem_adr

signal        dec_mem_lw	: Std_Logic :='0';  -- FIFO Input
signal        dec_mem_lb	: Std_Logic :='0';  -- FIFO Input
signal        dec_mem_sw	: Std_Logic :='0';  -- FIFO Input
signal        dec_mem_sb	: Std_Logic :='0';  -- FIFO Input
-- Shifter command
signal        dec_shift_lsl	: Std_Logic;  -- Logical Shift Left
signal        dec_shift_lsr	: Std_Logic;  -- Logical Shift Right
signal        dec_shift_asr	: Std_Logic;  -- Arithmetic Shift Right
signal        dec_shift_ror	: Std_Logic;  -- Rotate Right
signal        dec_shift_rrx	: Std_Logic;  -- RRX
signal        dec_shift_val	: Std_Logic_Vector(4 downto 0); -- Shift value
signal        dec_cy		: Std_Logic;  -- Carry in (Shifter)
-- Alu operand selection
signal        dec_comp_op1	: Std_Logic; -- dec_op1 ou NOT dec_op1
signal        dec_comp_op2	: Std_Logic; -- dec_op2 ou NOT dec_op2
signal        dec_alu_cy 	: Std_Logic; -- Carry in (ALU)
-- Alu command
signal        dec_alu_cmd	: Std_Logic_Vector(1 downto 0); -- ALU command (ADD, AND, OR, XOR)
-- Exe bypass to decod
signal        exe_res		: Std_Logic_Vector(31 downto 0); -- alu_res -> exe_res

signal        exe_c		: Std_Logic; -- Carry out (EXEC)
signal        exe_v		: Std_Logic; -- Overflow (EXEC)
signal        exe_n		: Std_Logic; -- Negative (EXEC)
signal        exe_z		: Std_Logic; -- Zero (EXEC)

signal        exe_dest	        : Std_Logic_Vector(3 downto 0); -- Rd destination -- Copy dec_exe_dest
signal        exe_wb		: Std_Logic; -- Rd destination write back -- Copy dec_exe_wb
signal        exe_flag_wb	: Std_Logic; -- CSPR modifiy -- Copy dec_exe_flag_wb
-- Mem interface
signal        exe_mem_adr	: Std_Logic_Vector(31 downto 0); -- FIFO Output, Rd address
signal        exe_mem_data	: Std_Logic_Vector(31 downto 0); -- FIFO Output, Rd data
signal        exe_mem_dest	: Std_Logic_Vector(3 downto 0); -- FIFO Output, Rd destination

signal        exe_mem_lw	: Std_Logic;-- FIFO Output, Rd command
signal        exe_mem_lb	: Std_Logic;-- FIFO Output, Rd command
signal        exe_mem_sw	: Std_Logic;-- FIFO Output, Rd command
signal        exe_mem_sb	: Std_Logic;-- FIFO Output, Rd command

signal        exe2mem_empty	: Std_logic;-- FIFO Output, empty
signal        mem_pop		: Std_logic; -- FIFO Input, pop
-- global interface
signal        ck		: Std_logic; -- clock
signal        reset_n	        : Std_logic := '0';    -- reset
signal        vdd		: bit;	-- power
signal        vss		: bit;	-- ground

BEGIN 
exec_sim: EXec port map (
        dec2exe_empty => dec2exe_empty,
        exe_pop => exe_pop,
        dec_op1 => dec_op1,
        dec_op2 => dec_op2,
        dec_exe_dest => dec_exe_dest,
        dec_exe_wb => dec_exe_wb,
        dec_flag_wb => dec_flag_wb,
        dec_mem_data => dec_mem_data,
        dec_mem_dest => dec_mem_dest,
        dec_pre_index => dec_pre_index,
        dec_mem_lw => dec_mem_lw,
        dec_mem_lb => dec_mem_lb,
        dec_mem_sw => dec_mem_sw,
        dec_mem_sb => dec_mem_sb,
        dec_shift_lsl => dec_shift_lsl,
        dec_shift_lsr => dec_shift_lsr,
        dec_shift_asr => dec_shift_asr,
        dec_shift_ror => dec_shift_ror,
        dec_shift_rrx => dec_shift_rrx,
        dec_shift_val => dec_shift_val,
        dec_cy => dec_cy,
        dec_comp_op1 => dec_comp_op1,
        dec_comp_op2 => dec_comp_op2,
        dec_alu_cy => dec_alu_cy,
        dec_alu_cmd => dec_alu_cmd,
        exe_res => exe_res,
        exe_c => exe_c,
        exe_v => exe_v,
        exe_n => exe_n,
        exe_z => exe_z,
        exe_dest => exe_dest,
        exe_wb => exe_wb,
        exe_flag_wb => exe_flag_wb,
        exe_mem_adr => exe_mem_adr,
        exe_mem_data => exe_mem_data,
        exe_mem_dest => exe_mem_dest,
        exe_mem_lw => exe_mem_lw,
        exe_mem_lb => exe_mem_lb,
        exe_mem_sw => exe_mem_sw,
        exe_mem_sb => exe_mem_sb,
        exe2mem_empty => exe2mem_empty,
        mem_pop => mem_pop,
        ck => ck,
        reset_n => reset_n,
        vdd => vdd,
        vss => vss
);

-- Clock generation
process
begin
        ck <= '0';
        wait for 10 ns;
        ck <= '1';
        wait for 10 ns;
end process;

-- Reset generation
process
begin
        reset_n <= '0';
        wait for 20 ns;
        reset_n <= '1';
        wait;
end process;

-- Stimulus process
process(ck)
variable seed1, seed2 : integer := 42;
impure FUNCTION rand_slv(len : integer) return std_logic_vector is
        variable r : real;
        variable slv : std_logic_vector(len - 1 downto 0);
        BEGIN
                for i in slv'range loop
                uniform(seed1, seed2, r);
                IF r > 0.5 THEN
                slv(i) := '1';
                ELSE
                slv(i) := '0';
                END IF;
                end loop;
        return slv;
END FUNCTION;
begin
        if rising_edge(ck) then 
                dec_op1 <= rand_slv(32); -- Op1
                dec_op2 <= rand_slv(32); -- Op2

                dec_exe_dest <= rand_slv(4); -- Rd destination
                dec_exe_wb <= rand_slv(1)(0); -- Rd destination write back
                dec_flag_wb <= rand_slv(1)(0); -- CSPR modifiy

                dec_mem_data <= rand_slv(32); -- data to MEM W
                dec_mem_dest <= rand_slv(4); -- Destination MEM R

                dec_pre_index <= '1'; -- Select alu_res or op1 for mem_adr. 1: alu_res, 0: op1

                dec_mem_lw <= '1'; -- FIFO Input 
                dec_mem_lb <= '0'; -- FIFO Input
                dec_mem_sw <= '0'; -- FIFO Input
                dec_mem_sb <= '0'; -- FIFO Input

                dec_shift_lsl <= '1'; -- Logical Shift Left
                dec_shift_lsr <= '0'; -- Logical Shift Right
                dec_shift_asr <= '0'; -- Arithmetic Shift Right
                dec_shift_ror <= '0'; -- Rotate Right
                dec_shift_rrx <= '0'; -- RRX
                dec_shift_val <= (others=>'0'); -- Shift value
                dec_cy <= rand_slv(1)(0); -- Carry in (Shifter)

                dec_comp_op1 <= rand_slv(1)(0); -- dec_op1 ou NOT dec_op1
                dec_comp_op2 <= rand_slv(1)(0); -- dec_op2 ou NOT dec_op2

                dec_alu_cy <= rand_slv(1)(0); -- Carry in (ALU) 
                dec_alu_cmd <= rand_slv(2); -- ALU command (ADD, AND, OR, XOR)

                mem_pop <= rand_slv(1)(0); -- FIFO Input, 
                
        end if;

        
end process;


END simu;