library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EXec is
	port(
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

			exe_c				: out Std_Logic;
			exe_v				: out Std_Logic;
			exe_n				: out Std_Logic;
			exe_z				: out Std_Logic;

			exe_dest			: out Std_Logic_Vector(3 downto 0); -- Rd destination
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
			ck				: in Std_logic;
			reset_n			: in Std_logic;
			vdd				: in bit;
			vss				: in bit);
end EXec;

----------------------------------------------------------------------

architecture Behavior OF EXec is
	--signaux shifter	
	signal dout_op2_shifter : std_logic_vector(31 downto 0);			--op2 résultat de shifter
	signal dout_op2_shifter_cmp1 : std_logic_vector(31 downto 0);		--op2 complément à 1
	signal cout_shifter : std_logic ;												--

	--signaux alu
	signal op1_alu : std_logic_vector(31 downto 0);
	signal op2_alu : std_logic_vector(31 downto 0);
	signal dec_op1_cmp1 : std_logic_vector(31 downto 0);
	signal dout_alu : std_logic_vector(31 downto 0);
	signal cout_alu : std_logic ;	

	--fifo
	signal mem_adr		: std_logic_vector(31 downto 0);
	signal exe_push 	: std_logic ;
	signal exe2mem_full : std_logic ;
	

component alu
    port ( op1			: in Std_Logic_Vector(31 downto 0);
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
end component;


component shifter
    port ( 	shift_lsl : in  Std_Logic;
			shift_lsr : in  Std_Logic;
			shift_asr : in  Std_Logic;
			shift_ror : in  Std_Logic;
			shift_rrx : in  Std_Logic;
			shift_val : in  Std_Logic_Vector(4 downto 0);
			din       : in  Std_Logic_Vector(31 downto 0);
			cin       : in  Std_Logic;
			dout      : out Std_Logic_Vector(31 downto 0);
			cout      : out Std_Logic;
			-- global interface
			vdd       : in  bit;
			vss       : in  bit );
end component;


component fifo
	generic(WIDTH: positive);
	PORT(
		din		: in std_logic_vector(WIDTH-1 downto 0);
		dout		: out std_logic_vector(WIDTH-1 downto 0);

		-- commands
		push		: in std_logic;
		pop		: in std_logic;

		-- flags
		full		: out std_logic;
		empty		: out std_logic;

		reset_n	: in std_logic;
		ck			: in std_logic;
		vdd		: in bit;
		vss		: in bit
	);
end component;


	begin
--  Component instantiation.
	alu_inst : alu
	port map (		
				op1 => op1_alu,
				op2 => op2_alu,
				cin  => dec_alu_cy,
				cmd => dec_alu_cmd,
				res  => dout_alu,
				cout => cout_alu, --à vérifier
				z  => exe_z,
				n	=> exe_n,
				v   => exe_v,
				vdd   => vdd,
				vss  => vss);


--  Component instantiation.
	shifter_inst : shifter
	port map (		
				shift_lsl => dec_shift_lsl,
				shift_lsr => dec_shift_lsr,
				shift_asr => dec_shift_asr,
				shift_ror => dec_shift_ror,
				shift_rrx => dec_shift_rrx,
				shift_val => dec_shift_val,
				din => dec_op2,
				cin => dec_cy,
				dout => dout_op2_shifter, --à vérifier
				cout => cout_shifter,
				-- global interface
				vdd => vdd,
				vss => vss);

	exe2mem : fifo
	generic map(72)
	port map (	din(71)	 => dec_mem_lw,
				din(70)	 => dec_mem_lb,
				din(69)	 => dec_mem_sw,
				din(68)	 => dec_mem_sb,

				din(67 downto 64) => dec_mem_dest,
				din(63 downto 32) => dec_mem_data,
				din(31 downto 0)	 => mem_adr,

				dout(71)	 => exe_mem_lw,
				dout(70)	 => exe_mem_lb,
				dout(69)	 => exe_mem_sw,
				dout(68)	 => exe_mem_sb,

				dout(67 downto 64) => exe_mem_dest,
				dout(63 downto 32) => exe_mem_data,
				dout(31 downto 0)	 => exe_mem_adr,

				push		 => exe_push,
				pop		 	=> mem_pop,

				empty		 => exe2mem_empty,
				full		 => exe2mem_full,

				reset_n	 => reset_n,
				ck			 => ck,
				vdd		 => vdd,
				vss		 => vss);

		--op2 alu
		dout_op2_shifter_cmp1 <= not(dout_op2_shifter);
		op2_alu <= dout_op2_shifter when dec_comp_op2='0' else dout_op2_shifter_cmp1;

		--op1 alu
		dec_op1_cmp1 <= not(dec_op1);
		op1_alu <= dec_op1 when dec_comp_op1='0' else dec_op1_cmp1;

		--sortie alu
		exe_res <= dout_alu;

		--fifo adr
		mem_adr <= dout_alu when dec_pre_index='1' else dec_op1;

		--fifo
		exe_pop <= not (dec2exe_empty); --à vérifier
		exe_push <= not(exe2mem_full) and not (dec2exe_empty) and ((dec_mem_lw) or (dec_mem_lb) or (dec_mem_sw) or (dec_mem_sb));

		exe_dest <= dec_exe_dest;

		exe_wb <= dec_exe_wb;		--à vérifier
		exe_flag_wb <= dec_flag_wb; --à vérifier

		exe_c <= cout_alu when dec_alu_cmd="00" else cout_shifter; -- à vérifier

end Behavior;
