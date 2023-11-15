LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY EXec IS
	PORT(
	-- Decode interface synchro
			dec2exe_empty	: in Std_logic;  -- 
			exe_pop			: out Std_logic; -- 

	-- Decode interface operands
			dec_op1			: in Std_Logic_Vector(31 downto 0); -- first alu input -- Op1
			dec_op2			: in Std_Logic_Vector(31 downto 0); -- shifter input   -- Op2 
			dec_exe_dest	: in Std_Logic_Vector(3 downto 0); -- Rd destination  -- Direct Copy  
			dec_exe_wb		: in Std_Logic; -- Rd destination write back -- Direct Copy
			dec_flag_wb		: in Std_Logic; -- CSPR modifiy  -- Direct Copy

	-- Decode to mem interface 
			dec_mem_data	: in Std_Logic_Vector(31 downto 0); -- data to MEM W   (FIFO)    
			dec_mem_dest	: in Std_Logic_Vector(3 downto 0); -- Destination MEM R  (FIFO)
			dec_pre_index 	: in Std_logic;   -- Select alu_res or op1 for mem_adr

			dec_mem_lw		: in Std_Logic;  -- FIFO Input
			dec_mem_lb		: in Std_Logic;  -- FIFO Input
			dec_mem_sw		: in Std_Logic;  -- FIFO Input
			dec_mem_sb		: in Std_Logic;  -- FIFO Input

	-- Shifter command
			dec_shift_lsl	: in Std_Logic;  -- Logical Shift Left
			dec_shift_lsr	: in Std_Logic;  -- Logical Shift Right
			dec_shift_asr	: in Std_Logic;  -- Arithmetic Shift Right
			dec_shift_ror	: in Std_Logic;  -- Rotate Right
			dec_shift_rrx	: in Std_Logic;	 -- RRX
			dec_shift_val	: in Std_Logic_Vector(4 downto 0); -- Shift value
			dec_cy			: in Std_Logic;  -- Carry in (Shifter)

	-- Alu operand selection
			dec_comp_op1	: in Std_Logic; -- dec_op1 ou NOT dec_op1
			dec_comp_op2	: in Std_Logic; -- dec_op2 ou NOT dec_op2
			dec_alu_cy 		: in Std_Logic; -- Carry in (ALU)

	-- Alu command
			dec_alu_cmd		: in Std_Logic_Vector(1 downto 0); -- ALU command (ADD, AND, OR, XOR)

	-- Exe bypass to decod
			exe_res			: out Std_Logic_Vector(31 downto 0); -- alu_res -> exe_res 

			exe_c			: out Std_Logic; -- Carry out (EXEC)
			exe_v			: out Std_Logic; -- Overflow (EXEC)
			exe_n			: out Std_Logic; -- Negative (EXEC)
			exe_z			: out Std_Logic; -- Zero (EXEC)

			exe_dest		: out Std_Logic_Vector(3 downto 0); -- Rd destination -- Copy dec_exe_dest
			exe_wb			: out Std_Logic; -- Rd destination write back -- Copy dec_exe_wb
			exe_flag_wb		: out Std_Logic; -- CSPR modifiy -- Copy dec_exe_flag_wb

	-- Mem interface
			exe_mem_adr		: out Std_Logic_Vector(31 downto 0); -- FIFO Output, Rd address 
			exe_mem_data	: out Std_Logic_Vector(31 downto 0); -- FIFO Output, Rd data
			exe_mem_dest	: out Std_Logic_Vector(3 downto 0); -- FIFO Output, Rd destination

			exe_mem_lw		: out Std_Logic;-- FIFO Output, Rd command
			exe_mem_lb		: out Std_Logic;-- FIFO Output, Rd command
			exe_mem_sw		: out Std_Logic;-- FIFO Output, Rd command
			exe_mem_sb		: out Std_Logic;-- FIFO Output, Rd command

			exe2mem_empty	: out Std_logic;-- FIFO Output, empty
			mem_pop			: in Std_logic; -- FIFO Input, pop

	-- global interface
			ck				: in Std_logic; -- clock
			reset_n			: in Std_logic;	-- reset
			vdd				: in bit;		-- power
			vss				: in bit);		-- ground
END EXec;

----------------------------------------------------------------------

ARCHITECTURE Behavior OF EXec IS

COMPONENT shifter
	PORT(
		shift_lsl	: in Std_Logic;
		shift_lsr	: in Std_Logic;
		shift_asr	: in Std_Logic;
		shift_ror	: in Std_Logic;
		shift_rrx	: in Std_Logic;
		shift_val	: in Std_Logic_Vector(4 downto 0);

		din			: in Std_Logic_Vector(31 downto 0);
		cin			: in Std_Logic;

		dout		: out Std_Logic_Vector(31 downto 0);
		cout		: out Std_Logic;

		vdd			: in bit;
		vss			: in bit);
END COMPONENT;

COMPONENT alu
	PORT (
		op1			: in Std_Logic_Vector(31 downto 0);
		op2			: in Std_Logic_Vector(31 downto 0);
		cin			: in Std_Logic;
		
		cmd			: in Std_Logic_Vector(1 downto 0);
		
		res			: out Std_Logic_Vector(31 downto 0);
		cout		: out Std_Logic;
		z			: out Std_Logic;
		n			: out Std_Logic;
		v			: out Std_Logic;
		
		vdd			: in bit;
		vss			: in bit);
END COMPONENT;

COMPONENT fifo
	GENERIC ( WIDTH: INTEGER := 72 );
	PORT(
		din			: in std_logic_vector(71 downto 0);
		dout		: out std_logic_vector(71 downto 0);

		-- commands
		push		: in std_logic;
		pop			: in std_logic;

		-- flags
		full		: out std_logic;
		empty		: out std_logic;

		reset_n		: in std_logic;
		ck			: in std_logic;
		vdd			: in bit;
		vss			: in bit);
END COMPONENT;


signal shift_c 	    : std_logic; -- shifter carry
signal alu_c 		: std_logic; -- ALU carry

signal op2			: std_logic_vector(31 downto 0); --
signal op2_shift	: std_logic_vector(31 downto 0); --
signal op1			: std_logic_vector(31 downto 0); --


signal alu_res		: std_logic_vector(31 downto 0); --
signal res_reg		: std_logic_vector(31 downto 0); 
signal mem_adr		: std_logic_vector(31 downto 0); --

signal exe_push 	: std_logic;
signal exe2mem_full	: std_logic;
signal mem_acces	: std_logic; -- 

BEGIN

--  Component instantiation.
	shifter_inst : shifter
	PORT MAP (	shift_lsl	=> dec_shift_lsl,
				shift_lsr	=> dec_shift_lsr,
				shift_asr	=> dec_shift_asr,
                shift_ror	=> dec_shift_ror,
				shift_rrx	=> dec_shift_rrx,
                shift_val	=> dec_shift_val,

				din			=> dec_op2,
				cin			=> dec_cy,

				dout		=> op2_shift,    -- signal 
                cout		=> shift_c,      -- signal 
				vdd			=> vdd,
				vss			=> vss);

	alu_inst : alu
	PORT MAP (	op1		    => op1,
				op2		    => op2,
				cin		    => dec_alu_cy,

				cmd		    => dec_alu_cmd,

				res		    => alu_res,
				cout	    => alu_c,
				z			=> exe_z,
				n			=> exe_n,
				v			=> exe_v,

				vdd		    => vdd,
				vss		    => vss);

	exec2mem : fifo
	GENERIC MAP ( WIDTH => 72 )
	PORT MAP (	din(71)	 => dec_mem_lw,
				din(70)	 => dec_mem_lb,
				din(69)	 => dec_mem_sw,
				din(68)	 => dec_mem_sb,

				din(67 downto 64) => dec_mem_dest,
				din(63 downto 32) => dec_mem_data,
				din(31 downto 0)  => mem_adr,

				dout(71)	 => exe_mem_lw,
				dout(70)	 => exe_mem_lb,
				dout(69)	 => exe_mem_sw,
				dout(68)	 => exe_mem_sb,

				dout(67 downto 64) => exe_mem_dest,
				dout(63 downto 32) => exe_mem_data,
				dout(31 downto 0)  => exe_mem_adr,

				push	 => exe_push,
				pop		 => mem_pop,

				empty    => exe2mem_empty,
				full     => exe2mem_full,

				reset_n	 => reset_n,
				ck	     => ck,
				vdd		 => vdd,
				vss		 => vss);

-- synchro
	exe_res <= alu_res;
	mem_adr <= alu_res when dec_pre_index = '1' else dec_op1;
	mem_acces <= dec_mem_lw or dec_mem_lb or dec_mem_sw or dec_mem_sb;
	exe_push <= mem_acces and (not exe2mem_full) and (not dec2exe_empty);
	exe_pop <= (not exe2mem_full) and (not dec2exe_empty);

-- cout
	exe_c <= alu_c when dec_alu_cmd = "00" else shift_c;

-- ALU opearandes
	op1 <= dec_op1 when dec_comp_op1 = '1' else NOT dec_op1;
	op2 <= op2_shift when dec_comp_op2 = '1' else NOT op2_shift;

-- Loop dec 

	exe_dest <= dec_exe_dest;	-- Rd destination
	exe_wb <= dec_exe_wb;	    -- Rd destination write back
	exe_flag_wb <= dec_flag_wb; -- CSPR modifiy 
	

END Behavior;