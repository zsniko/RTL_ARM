library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Decod is
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
end Decod;

----------------------------------------------------------------------

architecture Behavior OF Decod is

component reg
	port(
	-- Write Port 1 prioritaire
		wdata1		: in Std_Logic_Vector(31 downto 0); -- Port write data 1
		wadr1		: in Std_Logic_Vector(3 downto 0); -- Register to write 
		wen1		: in Std_Logic; -- Write enable

	-- Write Port 2 non prioritaire
		wdata2		: in Std_Logic_Vector(31 downto 0); -- Port write data 2
		wadr2		: in Std_Logic_Vector(3 downto 0); -- Register to write
		wen2		: in Std_Logic; -- Write enable 

	-- Write CSPR Port
		wcry		: in Std_Logic; -- carry
		wzero		: in Std_Logic;	-- zero
		wneg		: in Std_Logic; -- negative
		wovr		: in Std_Logic; -- overflow
		cspr_wb		: in Std_Logic; -- write enable
		
	-- Read Port 1 32 bits
		reg_rd1		: out Std_Logic_Vector(31 downto 0); -- Value of the read Register
		radr1		: in Std_Logic_Vector(3 downto 0); -- Register read 
		reg_v1		: out Std_Logic; -- Valid bit of the read Register, sent to Decode

	-- Read Port 2 32 bits
		reg_rd2		: out Std_Logic_Vector(31 downto 0); -- Value of the read Register
		radr2		: in Std_Logic_Vector(3 downto 0); -- Register read
		reg_v2		: out Std_Logic; -- Valid bit of the read Register, sent to Decode

	-- Read Port 3 32 bits
		reg_rd3		: out Std_Logic_Vector(31 downto 0); -- Value of the read Register
		radr3		: in Std_Logic_Vector(3 downto 0); -- Register read
		reg_v3		: out Std_Logic; -- Valid bit of the read Register, sent to Decode 

	-- read CSPR Port
		reg_cry		: out Std_Logic;
		reg_zero	: out Std_Logic;
		reg_neg		: out Std_Logic;
		reg_cznv	: out Std_Logic;
		reg_ovr		: out Std_Logic;
		reg_vv		: out Std_Logic;
		
	-- Invalidate Port 
		inval_adr1	: in Std_Logic_Vector(3 downto 0);
		inval1		: in Std_Logic;

		inval_adr2	: in Std_Logic_Vector(3 downto 0);
		inval2		: in Std_Logic;

		inval_czn	: in Std_Logic;
		inval_ovr	: in Std_Logic;

	-- PC
		reg_pc		: out Std_Logic_Vector(31 downto 0);
		reg_pcv		: out Std_Logic;
		inc_pc		: in Std_Logic;
	
	-- global interface
		ck			: in Std_Logic;
		reset_n		: in Std_Logic;
		vdd			: in bit;
		vss			: in bit);
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

signal cond		: Std_Logic; -- predicate true 1 / false 0
signal condv	: Std_Logic; -- cond valid 
signal operv	: Std_Logic; -- 1 when all operands are valid
signal op1v		: Std_Logic; -- op1 valid? (+)
signal op2v		: Std_Logic; -- op2 valid? (+)
signal op3v     : Std_Logic; -- op3 valid? (+)

signal regop_t  : Std_Logic; -- Data processing 
signal mult_t   : Std_Logic; -- multiplication 
signal swap_t   : Std_Logic; -- Data swap
signal trans_t  : Std_Logic; -- Memeory transfert 
signal mtrans_t : Std_Logic; -- Multiple transfert
signal branch_t : Std_Logic; -- Branch

-- regop instructions
signal and_i  : Std_Logic;
signal eor_i  : Std_Logic;
signal sub_i  : Std_Logic;
signal rsb_i  : Std_Logic;
signal add_i  : Std_Logic;
signal adc_i  : Std_Logic;
signal sbc_i  : Std_Logic;
signal rsc_i  : Std_Logic;
signal tst_i  : Std_Logic;
signal teq_i  : Std_Logic;
signal cmp_i  : Std_Logic;
signal cmn_i  : Std_Logic;
signal orr_i  : Std_Logic;
signal mov_i  : Std_Logic;
signal bic_i  : Std_Logic;
signal mvn_i  : Std_Logic;

-- mult instruction
signal mul_i  : Std_Logic;
signal mla_i  : Std_Logic;

-- trans instruction
signal ldr_i  : Std_Logic;
signal str_i  : Std_Logic;
signal ldrb_i : Std_Logic;
signal strb_i : Std_Logic;

-- mtrans instruction
signal ldm_i  : Std_Logic;
signal stm_i  : Std_Logic;

-- branch instruction
signal b_i    : Std_Logic;
signal bl_i   : Std_Logic;

-- link
signal blink    : Std_Logic;

-- Multiple transferts
signal mtrans_shift : Std_Logic;

signal mtrans_mask_shift : Std_Logic_Vector(15 downto 0);
signal mtrans_mask : Std_Logic_Vector(15 downto 0);
signal mtrans_list : Std_Logic_Vector(15 downto 0);
signal mtrans_1un : Std_Logic;
signal mtrans_loop_adr : Std_Logic;
signal mtrans_nbr : Std_Logic_Vector(4 downto 0);
signal mtrans_rd : Std_Logic_Vector(3 downto 0);

-- RF read ports
signal radr1 : Std_Logic_Vector(3 downto 0);
signal rdata1 : Std_Logic_Vector(31 downto 0);
signal rvalid1 : Std_Logic;

signal radr2 : Std_Logic_Vector(3 downto 0);
signal rdata2 : Std_Logic_Vector(31 downto 0);
signal rvalid2 : Std_Logic;

signal radr3 : Std_Logic_Vector(3 downto 0);
signal rdata3 : Std_Logic_Vector(31 downto 0);
signal rvalid3 : Std_Logic;

-- RF inval ports
signal inval_exe_adr : Std_Logic_Vector(3 downto 0);
signal inval_exe : Std_Logic;

signal inval_mem_adr : Std_Logic_Vector(3 downto 0);
signal inval_mem : Std_Logic;

-- Flags
signal cry	: Std_Logic;
signal zero	: Std_Logic;
signal neg	: Std_Logic;
signal ovr	: Std_Logic;

signal reg_cznv : Std_Logic;
signal reg_vv : Std_Logic;

signal inval_czn : Std_Logic;
signal inval_ovr : Std_Logic;

-- PC
signal reg_pc : Std_Logic_Vector(31 downto 0);
signal reg_pcv : Std_Logic;
signal inc_pc : Std_Logic;

-- FIFOs
signal dec2if_full : Std_Logic;
signal dec2if_push : Std_Logic;

signal dec2exe_full : Std_Logic;
signal dec2exe_push : Std_Logic;

signal if2dec_pop : Std_Logic;

-- Exec  operands
signal op1			: Std_Logic_Vector(31 downto 0);
signal op2			: Std_Logic_Vector(31 downto 0);
signal alu_dest		: Std_Logic_Vector(3 downto 0);
signal alu_wb		: Std_Logic;
signal flag_wb		: Std_Logic;

signal offset32		: Std_Logic_Vector(31 downto 0);

-- Decod to mem via exec
signal mem_data		: Std_Logic_Vector(31 downto 0);
signal ld_dest		: Std_Logic_Vector(3 downto 0);
signal pre_index 	: Std_logic;

signal mem_lw		: Std_Logic;
signal mem_lb		: Std_Logic;
signal mem_sw		: Std_Logic;
signal mem_sb		: Std_Logic;

-- Shifter command
signal shift_lsl	: Std_Logic;
signal shift_lsr	: Std_Logic;
signal shift_asr	: Std_Logic;
signal shift_ror	: Std_Logic;
signal shift_rrx	: Std_Logic;
signal shift_val	: Std_Logic_Vector(4 downto 0);
signal cy			: Std_Logic;

-- Alu operand selection
signal comp_op1		: Std_Logic;
signal comp_op2		: Std_Logic;
signal alu_cy 		: Std_Logic;

-- Alu command
signal alu_cmd		: Std_Logic_Vector(1 downto 0);

-- DECOD FSM
type state_type is (FETCH, RUN, BRANCH, LINK, MTRANS);
signal cur_state, next_state : state_type;

signal debug_state : Std_Logic_Vector(3 downto 0) := X"0";

begin

	dec2exec : fifo
	generic map (127)
	port map (		din(126) 				=> pre_index,
					din(125 downto 94) 		=> op1,
					din(93 downto 62)	 	=> op2,
					din(61 downto 58)	 	=> alu_dest,
					din(57)	 				=> alu_wb,
					din(56)	 				=> flag_wb,

					din(55 downto 24)	 	=> rdata3,
					din(23 downto 20)	 	=> ld_dest,
					din(19)	 				=> mem_lw,
					din(18)	 				=> mem_lb,
					din(17)	 				=> mem_sw,
					din(16)	 				=> mem_sb,

					din(15)	 				=> shift_lsl,
					din(14)	 				=> shift_lsr,
					din(13)	 				=> shift_asr,
					din(12)	 				=> shift_ror,
					din(11)	 				=> shift_rrx,
					din(10 downto 6)	 	=> shift_val,
					din(5)	 				=> cry,

					din(4)	 				=> comp_op1,
					din(3)					=> comp_op2,
					din(2)	 				=> alu_cy,

					din(1 downto 0)	 		=> alu_cmd,

					dout(126)	 			=> dec_pre_index,
					dout(125 downto 94)	 	=> dec_op1,
					dout(93 downto 62)	 	=> dec_op2,
					dout(61 downto 58)	 	=> dec_exe_dest,
					dout(57)	 			=> dec_exe_wb,
					dout(56)	 			=> dec_flag_wb,

					dout(55 downto 24)	 	=> dec_mem_data,
					dout(23 downto 20)	 	=> dec_mem_dest,
					dout(19)	 			=> dec_mem_lw,
					dout(18)	 			=> dec_mem_lb,
					dout(17)	 			=> dec_mem_sw,
					dout(16)	 			=> dec_mem_sb,

					dout(15)	 			=> dec_shift_lsl,
					dout(14)	 			=> dec_shift_lsr,
					dout(13)	 			=> dec_shift_asr,
					dout(12)	 			=> dec_shift_ror,
					dout(11)	 			=> dec_shift_rrx,
					dout(10 downto 6)	 	=> dec_shift_val,
					dout(5)	 				=> dec_cy,

					dout(4)	 				=> dec_comp_op1,
					dout(3)	 				=> dec_comp_op2,
					dout(2)					=> dec_alu_cy,

					dout(1 downto 0)	 	=> dec_alu_cmd,

					push	=> dec2exe_push,
					pop		=> exe_pop,

					empty	=> dec2exe_empty,
					full	=> dec2exe_full,

					reset_n	=> reset_n,
					ck		=> ck,
					vdd		=> vdd,
					vss		=> vss);

	dec2if : fifo
	generic map (32)
	port map (		din		=> reg_pc,
					dout	=> dec_pc,

					push	=> dec2if_push, 
					pop		=> if_pop,

					empty	=> dec2if_empty,
					full	=> dec2if_full,

					reset_n	=> reset_n,
					ck		=> ck,
					vdd		=> vdd,
					vss		=> vss);

	reg_inst  : reg
	port map(		wdata1	=> exe_res,
					wadr1	=> exe_dest,
					wen1	=> exe_wb,
                                          
					wdata2	=> mem_res,
					wadr2	=> mem_dest,
					wen2	=> mem_wb,
                                          
					wcry	=> exe_c,
					wzero	=> exe_z,
					wneg	=> exe_n,
					wovr	=> exe_v,
					cspr_wb	=> exe_flag_wb,
					               
					reg_rd1	=> rdata1,
					radr1	=> radr1,
					reg_v1	=> rvalid1,
                                          
					reg_rd2	=> rdata2,
					radr2	=> radr2,
					reg_v2	=> rvalid2,
                                          
					reg_rd3	=> rdata3,
					radr3	=> radr3,
					reg_v3	=> rvalid3,
                                          
					reg_cry	=> cry,
					reg_zero=> zero,
					reg_neg	=> neg,
					reg_ovr	=> ovr,
					               
					reg_cznv	=> reg_cznv,
					reg_vv		=> reg_vv,
                                          
					inval_adr1	=> inval_exe_adr,
					inval1		=> inval_exe,
                                          
					inval_adr2	=> inval_mem_adr,
					inval2		=> inval_mem,
                                          
					inval_czn	=> inval_czn,
					inval_ovr	=> inval_ovr,
                                          
					reg_pc		=> reg_pc,
					reg_pcv		=> reg_pcv,
					inc_pc		=> inc_pc,
				                              
					ck			=> ck,
					reset_n		=> reset_n,
					vdd			=> vdd,
					vss			=> vss);

-- Execution condition

	cond <= '1' when	(if_ir(31 downto 28) = X"0" and zero = '1') or -- EQ, Z set, Equal 
						(if_ir(31 downto 28) = X"1" and zero = '0') or -- NE, Z clear, Not equal
						(if_ir(31 downto 28) = X"2" and cry = '1') or -- CS, C set, unsigned higher or same
						(if_ir(31 downto 28) = X"3" and cry = '0') or -- CC, C clear, unsigned lower
						(if_ir(31 downto 28) = X"4" and neg = '1') or -- MI, N set, negative
						(if_ir(31 downto 28) = X"5" and neg = '0') or -- PL, N clear, positive or zero
						(if_ir(31 downto 28) = X"6" and ovr = '1') or -- VS, V set, overflow
						(if_ir(31 downto 28) = X"7" and ovr = '0') or -- VC, V clear, no overflow
						(if_ir(31 downto 28) = X"8" and (cry = '1' and zero = '0')) or -- HI, C set and Z clear, unsigned higher
						(if_ir(31 downto 28) = X"9" and (cry = '0' or zero = '1')) or -- LS, C clear or Z set, unsigned lower or same
						(if_ir(31 downto 28) = X"A" and (neg = ovr)) or -- GE, N equals V, greater or equal
						(if_ir(31 downto 28) = X"B" and not(neg = ovr)) or -- LT, N not equal to V, less than
						(if_ir(31 downto 28) = X"C" and (zero = '0') and (neg = ovr)) or -- GT, Z clear AND (N equals V), greater than
						(if_ir(31 downto 28) = X"D" and (zero = '1' or not(neg = ovr))) or -- LE, Z set OR (N not equal to V), less than or equal
						(if_ir(31 downto 28) = X"E") -- AL, (ignored), always
						else '0'; 

	-- condv will only be valid if the flag is valid 
	condv <= 		'1'			when if_ir(31 downto 28) = X"E" 	else 	-- AL 
					reg_cznv	when (if_ir(31 downto 28) = X"0" or 		-- EQ 
									if_ir(31 downto 28) = X"1" or 			-- NE
									if_ir(31 downto 28) = X"2" or 			-- CS
									if_ir(31 downto 28) = X"3" or 			-- CC
									if_ir(31 downto 28) = X"4" or 			-- MI
									if_ir(31 downto 28) = X"5" or 			-- PL

									if_ir(31 downto 28) = X"8" or 			-- HI
									if_ir(31 downto 28) = X"9") 	else 	-- LS
					reg_vv      when (if_ir(31 downto 28) = X"6" or 		-- VS
									if_ir(31 downto 28) = X"7")     else 	-- VC
					reg_cznv and reg_vv; 									-- GE, LT, GT, LE

-- decod instruction type
	-- Data processing
	regop_t <= '1' when	if_ir(27 downto 26) = "00" and mult_t = '0' and swap_t = '0' else '0';
	-- Multiply 
	mult_t <= '1' when	if_ir(27 downto 22) = "000000" and if_ir(7 downto 4) = "1001" else '0';
	-- Single Data Swap
	swap_t <= '1' when	if_ir(27 downto 23) = "00010" and if_ir(11 downto 4) = "00001001" else '0';
	-- Single Data Transfer
	trans_t <= '1' when if_ir(27 downto 26) = "01" else '0'; 
	-- Block Data Transfer
	mtrans_t <= '1' when if_ir(27 downto 25) = "100" else '0';
	-- Branch
	branch_t <= '1' when if_ir(27 downto 25) = "101" else '0';

-- decod regop opcode
	and_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"0" else '0';
	eor_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"1" else '0';
	sub_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"2" else '0';
	rsb_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"3" else '0';
	add_i <= '1' when (regop_t = '1' and if_ir(24 downto 21) = X"4") or branch_t = '1' else '0'; 
	adc_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"5" else '0';
	sbc_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"6" else '0';
	rsc_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"7" else '0';
	tst_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"8" else '0';
	teq_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"9" else '0';
	cmp_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"A" else '0';
	cmn_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"B" else '0';
	orr_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"C" else '0';
	mov_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"D" else '0';
	bic_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"E" else '0';
	mvn_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"F" else '0';

-- mult instruction : bit 21 defines if the instruction is a multiply or multiply accumulate
	mul_i <= '1' when mult_t = '1' and if_ir(21) = '0' else '0'; -- MUL
	mla_i <= '1' when mult_t = '1' and if_ir(21) = '1' else '0'; -- MLA

-- trans instruction: bit 22: 0 Word, 1 Byte; bit 20: 0 Store, 1 Load
	ldr_i <= '1' when trans_t = '1' and if_ir(22) = '0' and if_ir(20) = '1' else '0'; -- LDR
	str_i <= '1' when trans_t = '1' and if_ir(22) = '0' and if_ir(20) = '0' else '0'; -- STR
	ldrb_i <= '1' when trans_t = '1' and if_ir(22) = '1' and if_ir(20) = '1' else '0'; -- LDRB
	strb_i <= '1' when trans_t = '1' and if_ir(22) = '1' and if_ir(20) = '0' else '0'; -- STRB
	
-- mtrans instruction: bit 20: 0 Store, 1 Load
	ldm_i <= '1' when mtrans_t = '1' and if_ir(20) = '1' else '0'; -- LDM
	stm_i <= '1' when mtrans_t = '1' and if_ir(20) = '0' else '0'; -- STM

-- branch instruction: bit 24 (Link Bit): 0 Branch, 1 Branch with link 
	b_i <= '1' when branch_t = '1' and if_ir(24) = '0' else '0'; -- B
	bl_i <= '1' when branch_t = '1' and if_ir(24) = '1' else '0'; -- BL

-- Decode interface operands
	op1 <=	reg_pc 		when branch_t = '1' 			else
			exe_res 	when mtrans_loop_adr = '1' 		else 
			X"00000000" when mov_i = '1' or mvn_i = '1' else
			rdata1;
	
	-- In branch instructions, the offset is 24 bits long (23 downto 0), sign extended to 32 bits, and added to the PC
	offset32 <=	X"00" & if_ir(23 downto 0) when if_ir(23) = '0' else -- sign extension, to 32 bits offset
				X"FF" & if_ir(23 downto 0); 

	op2	<=  offset32 						when branch_t = '1' 					else
			X"00000001"						when blink = '1' 						else 
			X"000000" & if_ir(7 downto 0) 	when regop_t = '1' and if_ir(25) = '1' 	else -- bit 25: 0 Op2 Reg, 1 Op2 Imm
			X"00000" & if_ir(11 downto 0)   when trans_t = '1' and if_ir(25) = '0'  else -- bit 25: 0 Imm, 1 Reg
			rdata2;
	-- Rd 
	alu_dest <=	if_ir(15 downto 12) 	when regop_t = '1' 	else		
				X"F"					when branch_t = '1' else -- R15, PC
				X"E"					when blink = '1' 	else -- R14, LR
				if_ir(19 downto 16); -- STR only: to Rn. LDR at Decode to Mem interface
	
	alu_wb	<= 	'1'			when branch_t = '1' 										else 
				'1'			when trans_t = '1' and (if_ir(24) = '0' or if_ir(21) = '1') else -- bit 21: 0 No WB, 1 Write @ into base. bit 24: 0 Post, 1 Pre indexing. Post: systematically WB. 
				'1'			when regop_t = '1' and tst_i = '0' and teq_i = '0' and cmp_i = '0' and cmn_i = '0' else -- TST, TEQ, CMP, CMN do not write the result to Rd 	
				'0';
	-- S 
	flag_wb	<= 	if_ir(20) when regop_t = '1' else 
				'0';

-- reg read
	radr1 <= 	if_ir(19 downto 16); -- Rn Base register, Op1
				
	radr2 <= 	if_ir(3 downto 0) 	when (regop_t = '1' and if_ir(25) = '0') or -- Rm Operand register, Op2 
										 (trans_t = '1' and if_ir(25) = '1'); 

	radr3 <= 	mtrans_rd 			when mtrans_t = '1' else 
				if_ir(15 downto 12) when trans_t = '1' 	else -- Rd in Single Data Transfer mode
			 	if_ir(11 downto 8); -- Rs Shift Register 

-- Reg Invalid -> write

	inval_exe_adr <= 	alu_dest; 

	inval_exe 	  <=	'1'			when branch_t = '1' 																 else 
						'1' 		when regop_t = '1' and (tst_i = '0' and teq_i = '0' and cmp_i = '0' and cmn_i = '0') else -- TST, TEQ, CMP, CMN do not write the result to Rd
						if_ir(21) 	when trans_t = '1' or mtrans_t = '1' 												 else  
						'0'			when dec2exe_push = '0'      														 else -- no write if the instruction is not pushed to the fifo
						'0';

	inval_mem_adr <= 	ld_dest when trans_t = '1' else 
						mtrans_rd when mtrans_t = '1' else
						"0000";

	inval_mem <=	'1'	when mem_lb = '1' or mem_lw = '1'	else
					'0' when dec2exe_push = '0' 			else 
					'0';

	inval_czn <= if_ir(20)  or tst_i  or teq_i  or cmp_i  or cmn_i  when regop_t = '1' else 
				'0';
	
	inval_ovr <= inval_czn;

	
	 --inval_exe <=	'1'	when (cond = '1' and condv = '1') and alu_wb = '1' and dec2exe_push = '1' else '0';

	-- inval_mem <=	'1'	when (cond = '1' and condv = '1') and (ldr_i = '1' or ldrb_i = '1') and dec2exe_push = '1' else '0';

	-- inval_czn <=	'1'	when (cond = '1' and condv = '1') and flag_wb  = '1' and dec2exe_push = '1' else '0'; --?
			


-- operand validite
	
	op1v  <= 	rvalid1 when (regop_t = '1' and mov_i = '0' and mvn_i = '0') or trans_t = '1' or mtrans_t = '1' 	else
				reg_pcv when branch_t = '1' 																	else 
				'1'; 
	
	op2v  <=  	rvalid2 when regop_t = '1' or trans_t = '1' 										else 
				'1' when (regop_t = '1' and if_ir(25) = '1') or (trans_t = '1' and if_ir(25) = '0') else -- Imm
				'1';  
	
	op3v  <=    rvalid3 when regop_t = '1' and if_ir(25) = '0' and if_ir(4) = '1' 	else 
				rvalid3 when trans_t = '1' and (strb_i = '1' or str_i = '1')		else
				'1';

	operv <=	op1v and op2v and op3v; -- all operands valid?
		
-- Decode to mem interface 
	ld_dest <= if_ir(15 downto 12) when trans_t = '1' and if_ir(20) = '1'; -- LDR: Rd
	pre_index <= if_ir(24) when trans_t = '1'; 

	mem_lw <= ldr_i or ldm_i; 
	mem_lb <= ldrb_i;
	mem_sw <= str_i or stm_i;
	mem_sb <= strb_i;

-- Shifter command

	shift_lsl <= '1' when regop_t = '1' and if_ir(25) = '0' and if_ir(6 downto 5) = "00" 	else 
					'1'	when trans_t = '1' and if_ir(25) = '1' and if_ir(6 downto 5) = "00" else 
					'1' when branch_t = '1' 												else 
					'0'; 
	shift_lsr <= '1' when regop_t = '1' and if_ir(25) = '0' and if_ir(6 downto 5) = "01" 	else 
					'1'	when trans_t = '1' and if_ir(25) = '1' and if_ir(6 downto 5) = "01" else
					'0';
	shift_asr <= '1' when regop_t = '1' and if_ir(25) = '0' and if_ir(6 downto 5) = "10"    else 
					'1' when trans_t = '1' and if_ir(25) = '1' and if_ir(6 downto 5) = "10" else
					'0';
	shift_ror <= '1' when regop_t = '1' and if_ir(25) = '0' and if_ir(6 downto 5) = "11" and shift_rrx = '0'	else 
					'1' when trans_t = '1' and if_ir(25) = '1' and if_ir(6 downto 5) = "11" and shift_rrx = '0' else
					'0';
	shift_rrx <= '1' when regop_t = '1' and if_ir(25) = '0' and if_ir(6 downto 5) = "11" and shift_val = "00000" else 
					'1' when trans_t = '1' and if_ir(25) = '1' and if_ir(6 downto 5) = "11" and shift_val="00000" else 
					'0';

	shift_val <=	"00010"					when branch_t = '1'											else 
					if_ir(11 downto 7)      when regop_t = '1' and if_ir(25) = '0' and if_ir(4) = '0' 	else -- bit 4 (Shift by): 0 Rs, 1 Imm
					rdata3(4 downto 0)      when regop_t = '1' and if_ir(25) = '0' and if_ir(4) = '1' 	else
					if_ir(11 downto 8)&'0' 	when regop_t = '1' and if_ir(25) = '1'				 		else -- x2
					"00000";

-- Alu operand selection
	comp_op1	<= 	'1' when rsb_i = '1' or rsc_i = '1' else '0';
	comp_op2	<=	'1' when sub_i = '1' or sbc_i = '1' or cmp_i = '1' or bic_i = '1' or mvn_i = '1' else '0';

	alu_cy 		<=	'1'	when sub_i = '1' or rsb_i = '1' or cmp_i = '1' else 
					cry when adc_i = '1' or sbc_i = '1' or rsc_i = '1' else 
					'0';

-- Alu command
	alu_cmd <=	"11" when eor_i = '1' or teq_i = '1'  				else -- XOR 
				"10" when orr_i = '1' or mov_i = '1' or mvn_i = '1'	else -- OR     MOV: Rd <= Op2 (Op2 OR 0)
				"01" when and_i = '1' or tst_i = '1' or bic_i = '1' else -- AND
				"00";													 -- ADD

-- Mtrans reg list

	process (ck)
	begin
		if (rising_edge(ck)) then
		-- .... 
		end if;
	end process;

	mtrans_mask_shift 	<= 		X"FFFE" when if_ir(0) = '1' and mtrans_mask(0) = '1' else
								X"FFFC" when if_ir(1) = '1' and mtrans_mask(1) = '1' else
								X"FFF8" when if_ir(2) = '1' and mtrans_mask(2) = '1' else
								X"FFF0" when if_ir(3) = '1' and mtrans_mask(3) = '1' else
								X"FFE0" when if_ir(4) = '1' and mtrans_mask(4) = '1' else
								X"FFC0" when if_ir(5) = '1' and mtrans_mask(5) = '1' else
								X"FF80" when if_ir(6) = '1' and mtrans_mask(6) = '1' else
								X"FF00" when if_ir(7) = '1' and mtrans_mask(7) = '1' else
								X"FE00" when if_ir(8) = '1' and mtrans_mask(8) = '1' else
								X"FC00" when if_ir(9) = '1' and mtrans_mask(9) = '1' else
								X"F800" when if_ir(10) = '1' and mtrans_mask(10) = '1' else
								X"F000" when if_ir(11) = '1' and mtrans_mask(11) = '1' else
								X"E000" when if_ir(12) = '1' and mtrans_mask(12) = '1' else
								X"C000" when if_ir(13) = '1' and mtrans_mask(13) = '1' else
								X"8000" when if_ir(14) = '1' and mtrans_mask(14) = '1' else
								X"0000";

	mtrans_list <= if_ir(15 downto 0) and mtrans_mask;

	process (mtrans_list)
	begin
	end process;

	mtrans_1un <= '1' when mtrans_nbr = "00001" else '0';

	mtrans_rd 	<=		X"0" when mtrans_list(0) = '1' else
						X"1" when mtrans_list(1) = '1' else
						X"2" when mtrans_list(2) = '1' else
						X"3" when mtrans_list(3) = '1' else
						X"4" when mtrans_list(4) = '1' else
						X"5" when mtrans_list(5) = '1' else
						X"6" when mtrans_list(6) = '1' else
						X"7" when mtrans_list(7) = '1' else
						X"8" when mtrans_list(8) = '1' else
						X"9" when mtrans_list(9) = '1' else
						X"A" when mtrans_list(10) = '1' else
						X"B" when mtrans_list(11) = '1' else
						X"C" when mtrans_list(12) = '1' else
						X"D" when mtrans_list(13) = '1' else
						X"E" when mtrans_list(14) = '1' else
						X"F";

-- FSM

process (ck)
begin

if (rising_edge(ck)) then
	if (reset_n = '0') then
		cur_state <= FETCH;
	else
		cur_state <= next_state;
	end if;
end if;

end process;

inc_pc <= dec2if_push;

--state machine process.
-- T1_FETCH: fifo vers IFETCH pleine: dec2if_full = '1'
-- T2_FETCH: une 1ere valeur de PC a peu etre ecrite dans dec2if: dec2if_empty = '0'
-- T1_RUN: if2dec vide, dec2exe pleine ou predicat invalide, une nouvelle valeur PC est envoyee vers IFETCH si dec2if n'est pas pleine: if2dec_empty
process (cur_state, dec2if_full, cond, condv, operv, dec2exe_full, if2dec_empty, reg_pcv, bl_i,
			branch_t, and_i, eor_i, sub_i, rsb_i, add_i, adc_i, sbc_i, rsc_i, orr_i, mov_i, bic_i,
			mvn_i, ldr_i, ldrb_i, ldm_i, stm_i, if_ir, mtrans_rd, mtrans_mask_shift)
begin
	case cur_state is

	when FETCH =>

			debug_state <= X"1";
			if2dec_pop <= '0';
			dec2exe_push <= '0';
			blink <= '0';
			mtrans_shift <= '0';
			mtrans_loop_adr <= '0';
			
			-- FETCH - T2 
			if dec2if_full = '0' and reg_pcv = '1' and if2dec_empty = '0' then
				next_state <= RUN;
				dec2if_push <= '1';
			-- FETCH - T1 
			else
				next_state <= FETCH;
				dec2if_push <= '0'; 
			end if;
	
	when RUN => 

			debug_state <= X"2"; 

			-- RUN - T1
			if if2dec_empty = '1' or dec2exe_full = '1' or condv = '0' or operv = '0' then 
				next_state <= RUN; 
				dec2exe_push <= '0';
				if2dec_pop <= '0';
				if dec2if_full = '0' then  
					dec2if_push <= '1';
				else
					dec2if_push <= '0';
				end if;
			-- RUN - T2
			elsif cond = '0' then 
				next_state <= RUN; 
				dec2exe_push <= '0'; 
				if2dec_pop <= '1'; -- cond false: instruction discarded
				if dec2if_full = '0' then
					dec2if_push <= '1';
				else
					dec2if_push <= '0';
				end if;
			-- RUN - T4: Instruction is a Link
			elsif cond = '1' then 
				if bl_i = '1' then 
					next_state <= LINK; 
					blink <= '1';
					dec2exe_push <= '1'; 
					if2dec_pop <= '0'; 
					dec2if_push <= '0'; 
			-- RUN - T5 : Instruction is a branch
				elsif b_i = '1' then 
					next_state <= BRANCH; 
					dec2exe_push <= '1'; 
					if2dec_pop <= '0';
					dec2if_push <= '0';
			-- RUN - T6 
				elsif ldm_i = '1' or stm_i = '1' then 
					next_state <= MTRANS; 
			-- RUN - T3 
				else 
					next_state <= RUN; 
					dec2exe_push <= '1'; 
					if2dec_pop <= '1'; 
					if dec2if_full = '0' then
						dec2if_push <= '1';
					else
						dec2if_push <= '0';
					end if;
				end if;
			end if;
	
	when BRANCH => 
			
			debug_state <= X"3";
			dec2exe_push <= '0';
			-- BRANCH - T1: if2dec est vide
			if if2dec_empty = '1' then 
				next_state <= BRANCH;
				dec2if_push <= '0';
				if2dec_pop <= '0';
			-- BRANCH - T2: if2dec n'est pas vide
			else 
				next_state <= RUN; 
				if2dec_pop <= '1';
				dec2if_push <= '0';
			end if;
	
	when LINK => 

			debug_state <= X"4";
			blink <= '0';
			dec2exe_push <= '1'; 
			if2dec_pop <= '1'; 
			dec2if_push <= '0'; 
			next_state <= BRANCH;
	
	when MTRANS => 
			debug_state <= X"5";

	end case;
end process;

dec_pop <= if2dec_pop;

end Behavior;














-- library ieee;
-- use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;

-- entity Decod is
-- 	port(
-- 	-- Exec  operands
-- 			dec_op1			: out Std_Logic_Vector(31 downto 0); -- first alu input
-- 			dec_op2			: out Std_Logic_Vector(31 downto 0); -- shifter input
-- 			dec_exe_dest	: out Std_Logic_Vector(3 downto 0); -- Rd destination
-- 			dec_exe_wb		: out Std_Logic; -- Rd destination write back
-- 			dec_flag_wb		: out Std_Logic; -- CSPR modifiy

-- 	-- Decod to mem via exec
-- 			dec_mem_data	: out Std_Logic_Vector(31 downto 0); -- data to MEM
-- 			dec_mem_dest	: out Std_Logic_Vector(3 downto 0);
-- 			dec_pre_index 	: out Std_logic;

-- 			dec_mem_lw		: out Std_Logic;
-- 			dec_mem_lb		: out Std_Logic;
-- 			dec_mem_sw		: out Std_Logic;
-- 			dec_mem_sb		: out Std_Logic;

-- 	-- Shifter command
-- 			dec_shift_lsl	: out Std_Logic;
-- 			dec_shift_lsr	: out Std_Logic;
-- 			dec_shift_asr	: out Std_Logic;
-- 			dec_shift_ror	: out Std_Logic;
-- 			dec_shift_rrx	: out Std_Logic;
-- 			dec_shift_val	: out Std_Logic_Vector(4 downto 0);
-- 			dec_cy			: out Std_Logic;

-- 	-- Alu operand selection
-- 			dec_comp_op1	: out Std_Logic;
-- 			dec_comp_op2	: out Std_Logic;
-- 			dec_alu_cy 		: out Std_Logic;

-- 	-- Exec Synchro
-- 			dec2exe_empty	: out Std_Logic;
-- 			exe_pop			: in Std_logic;

-- 	-- Alu command
-- 			dec_alu_cmd		: out Std_Logic_Vector(1 downto 0);

-- 	-- Exe Write Back to reg
-- 			exe_res			: in Std_Logic_Vector(31 downto 0);

-- 			exe_c				: in Std_Logic;
-- 			exe_v				: in Std_Logic;
-- 			exe_n				: in Std_Logic;
-- 			exe_z				: in Std_Logic;

-- 			exe_dest			: in Std_Logic_Vector(3 downto 0); -- Rd destination
-- 			exe_wb			: in Std_Logic; -- Rd destination write back
-- 			exe_flag_wb		: in Std_Logic; -- CSPR modifiy

-- 	-- Ifetch interface
-- 			dec_pc			: out Std_Logic_Vector(31 downto 0) ;
-- 			if_ir				: in Std_Logic_Vector(31 downto 0) ;

-- 	-- Ifetch synchro
-- 			dec2if_empty	: out Std_Logic;
-- 			if_pop			: in Std_Logic;

-- 			if2dec_empty	: in Std_Logic;
-- 			dec_pop			: out Std_Logic;

-- 	-- Mem Write back to reg
-- 			mem_res			: in Std_Logic_Vector(31 downto 0);
-- 			mem_dest			: in Std_Logic_Vector(3 downto 0);
-- 			mem_wb			: in Std_Logic;
			
-- 	-- global interface
-- 			ck					: in Std_Logic;
-- 			reset_n			: in Std_Logic;
-- 			vdd				: in bit;
-- 			vss				: in bit);
-- 			--debug_state			: out Std_Logic_Vector(3 downto 0));
-- end Decod;

-- ----------------------------------------------------------------------

-- architecture Behavior OF Decod is

-- component reg
-- 	port(
-- 	-- Write Port 1 prioritaire
-- 		wdata1		: in Std_Logic_Vector(31 downto 0);
-- 		wadr1			: in Std_Logic_Vector(3 downto 0);
-- 		wen1			: in Std_Logic;

-- 	-- Write Port 2 non prioritaire
-- 		wdata2		: in Std_Logic_Vector(31 downto 0);
-- 		wadr2			: in Std_Logic_Vector(3 downto 0);
-- 		wen2			: in Std_Logic;

-- 	-- Write CSPR Port
-- 		wcry			: in Std_Logic;
-- 		wzero			: in Std_Logic;
-- 		wneg			: in Std_Logic;
-- 		wovr			: in Std_Logic;
-- 		cspr_wb		: in Std_Logic;
		
-- 	-- Read Port 1 32 bits
-- 		reg_rd1		: out Std_Logic_Vector(31 downto 0);
-- 		radr1			: in Std_Logic_Vector(3 downto 0);
-- 		reg_v1		: out Std_Logic;

-- 	-- Read Port 2 32 bits
-- 		reg_rd2		: out Std_Logic_Vector(31 downto 0);
-- 		radr2			: in Std_Logic_Vector(3 downto 0);
-- 		reg_v2		: out Std_Logic;

-- 	-- Read Port 3 32 bits
-- 		reg_rd3		: out Std_Logic_Vector(31 downto 0);
-- 		radr3			: in Std_Logic_Vector(3 downto 0);
-- 		reg_v3		: out Std_Logic;

-- 	-- read CSPR Port
-- 		reg_cry		: out Std_Logic;
-- 		reg_zero		: out Std_Logic;
-- 		reg_neg		: out Std_Logic;
-- 		reg_cznv		: out Std_Logic;
-- 		reg_ovr		: out Std_Logic;
-- 		reg_vv		: out Std_Logic;
		
-- 	-- Invalidate Port 
-- 		inval_adr1	: in Std_Logic_Vector(3 downto 0);
-- 		inval1		: in Std_Logic;

-- 		inval_adr2	: in Std_Logic_Vector(3 downto 0);
-- 		inval2		: in Std_Logic;

-- 		inval_czn	: in Std_Logic;
-- 		inval_ovr	: in Std_Logic;

-- 	-- PC
-- 		reg_pc		: out Std_Logic_Vector(31 downto 0);
-- 		reg_pcv		: out Std_Logic;
-- 		inc_pc		: in Std_Logic;
	
-- 	-- global interface
-- 		ck				: in Std_Logic;
-- 		reset_n		: in Std_Logic;
-- 		vdd			: in bit;
-- 		vss			: in bit);
-- end component;

-- component fifo
-- 	generic(WIDTH: positive);
-- 	PORT(
-- 		din		: in std_logic_vector(WIDTH-1 downto 0);
-- 		dout		: out std_logic_vector(WIDTH-1 downto 0);

-- 		-- commands
-- 		push		: in std_logic;
-- 		pop		: in std_logic;

-- 		-- flags
-- 		full		: out std_logic;
-- 		empty		: out std_logic;

-- 		reset_n	: in std_logic;
-- 		ck			: in std_logic;
-- 		vdd		: in bit;
-- 		vss		: in bit
-- 	);
-- end component;


-- signal cond		: Std_Logic;
-- signal condv	: Std_Logic;
-- signal operv	: Std_Logic;

-- signal regop_t  : Std_Logic;
-- signal mult_t   : Std_Logic;
-- signal swap_t   : Std_Logic;
-- signal trans_t  : Std_Logic;
-- signal mtrans_t : Std_Logic;
-- signal branch_t : Std_Logic;

-- -- regop instructions
-- signal and_i  : Std_Logic;
-- signal eor_i  : Std_Logic;
-- signal sub_i  : Std_Logic;
-- signal rsb_i  : Std_Logic;
-- signal add_i  : Std_Logic;
-- signal adc_i  : Std_Logic;
-- signal sbc_i  : Std_Logic;
-- signal rsc_i  : Std_Logic;
-- signal tst_i  : Std_Logic;
-- signal teq_i  : Std_Logic;
-- signal cmp_i  : Std_Logic;
-- signal cmn_i  : Std_Logic;
-- signal orr_i  : Std_Logic;
-- signal mov_i  : Std_Logic;
-- signal bic_i  : Std_Logic;
-- signal mvn_i  : Std_Logic;

-- -- mult instruction
-- signal mul_i  : Std_Logic;
-- signal mla_i  : Std_Logic;

-- -- trans instruction
-- signal ldr_i  : Std_Logic;
-- signal str_i  : Std_Logic;
-- signal ldrb_i : Std_Logic;
-- signal strb_i : Std_Logic;

-- -- mtrans instruction
-- signal ldm_i  : Std_Logic;
-- signal stm_i  : Std_Logic;

-- -- branch instruction
-- signal b_i    : Std_Logic;
-- signal bl_i   : Std_Logic;

-- -- link
-- signal blink    : Std_Logic;

-- -- Multiple transferts
-- signal mtrans_shift : Std_Logic;

-- signal mtrans_mask_shift : Std_Logic_Vector(15 downto 0);
-- signal mtrans_mask : Std_Logic_Vector(15 downto 0);
-- signal mtrans_list : Std_Logic_Vector(15 downto 0);
-- signal mtrans_1un : Std_Logic;
-- signal mtrans_loop_adr : Std_Logic;
-- signal mtrans_nbr : Std_Logic_Vector(4 downto 0);
-- signal mtrans_rd : Std_Logic_Vector(3 downto 0);

-- -- RF read ports
-- signal radr1 : Std_Logic_Vector(3 downto 0);
-- signal rdata1 : Std_Logic_Vector(31 downto 0);
-- signal rvalid1 : Std_Logic;

-- signal radr2 : Std_Logic_Vector(3 downto 0);
-- signal rdata2 : Std_Logic_Vector(31 downto 0);
-- signal rvalid2 : Std_Logic;

-- signal radr3 : Std_Logic_Vector(3 downto 0);
-- signal rdata3 : Std_Logic_Vector(31 downto 0);
-- signal rvalid3 : Std_Logic;

-- -- RF inval ports
-- signal inval_exe_adr : Std_Logic_Vector(3 downto 0);
-- signal inval_exe : Std_Logic;

-- signal inval_mem_adr : Std_Logic_Vector(3 downto 0);
-- signal inval_mem : Std_Logic;

-- -- Flags
-- signal cry	: Std_Logic;
-- signal zero	: Std_Logic;
-- signal neg	: Std_Logic;
-- signal ovr	: Std_Logic;

-- signal reg_cznv : Std_Logic;
-- signal reg_vv : Std_Logic;

-- signal inval_czn : Std_Logic;
-- signal inval_ovr : Std_Logic;

-- -- PC
-- signal reg_pc : Std_Logic_Vector(31 downto 0);
-- signal reg_pcv : Std_Logic;
-- signal inc_pc : Std_Logic;

-- -- FIFOs
-- signal dec2if_full : Std_Logic;
-- signal dec2if_push : Std_Logic;

-- signal dec2exe_full : Std_Logic;
-- signal dec2exe_push : Std_Logic;

-- signal if2dec_pop : Std_Logic;

-- -- Exec  operands
-- signal op1			: Std_Logic_Vector(31 downto 0);
-- signal op2			: Std_Logic_Vector(31 downto 0);
-- signal alu_dest	: Std_Logic_Vector(3 downto 0);
-- signal alu_wb		: Std_Logic;
-- signal flag_wb		: Std_Logic;

-- signal offset32	: Std_Logic_Vector(31 downto 0);

-- -- Decod to mem via exec
-- signal mem_data	: Std_Logic_Vector(31 downto 0);
-- signal ld_dest		: Std_Logic_Vector(3 downto 0);
-- signal pre_index 	: Std_logic;

-- signal mem_lw		: Std_Logic;
-- signal mem_lb		: Std_Logic;
-- signal mem_sw		: Std_Logic;
-- signal mem_sb		: Std_Logic;

-- -- Shifter command
-- signal shift_lsl	: Std_Logic;
-- signal shift_lsr	: Std_Logic;
-- signal shift_asr	: Std_Logic;
-- signal shift_ror	: Std_Logic;
-- signal shift_rrx	: Std_Logic;
-- signal shift_val	: Std_Logic_Vector(4 downto 0);
-- signal cy			: Std_Logic;

-- -- Alu operand selection
-- signal comp_op1	: Std_Logic;
-- signal comp_op2	: Std_Logic;
-- signal alu_cy 		: Std_Logic;

-- -- Alu command
-- signal alu_cmd		: Std_Logic_Vector(1 downto 0);

-- -- DECOD FSM

-- type state_type is (FETCH, RUN, BRANCH, LINK, MTRANS);
-- signal cur_state, next_state : state_type;

-- signal debug_state : Std_Logic_Vector(3 downto 0) := X"0";

-- begin

-- 	dec2exec : fifo
-- 	generic map (127)
-- 	port map (	din(126) => pre_index,
-- 					din(125 downto 94) => op1,
-- 					din(93 downto 62)	 => op2,
-- 					din(61 downto 58)	 => alu_dest,
-- 					din(57)	 => alu_wb,
-- 					din(56)	 => flag_wb,

-- 					din(55 downto 24)	 => rdata3,
-- 					din(23 downto 20)	 => ld_dest,
-- 					din(19)	 => mem_lw,
-- 					din(18)	 => mem_lb,
-- 					din(17)	 => mem_sw,
-- 					din(16)	 => mem_sb,

-- 					din(15)	 => shift_lsl,
-- 					din(14)	 => shift_lsr,
-- 					din(13)	 => shift_asr,
-- 					din(12)	 => shift_ror,
-- 					din(11)	 => shift_rrx,
-- 					din(10 downto 6)	 => shift_val,
-- 					din(5)	 => cry,

-- 					din(4)	 => comp_op1,
-- 					din(3)	 => comp_op2,
-- 					din(2)	 => alu_cy,

-- 					din(1 downto 0)	 => alu_cmd,

-- 					dout(126)	 => dec_pre_index,
-- 					dout(125 downto 94)	 => dec_op1,
-- 					dout(93 downto 62)	 => dec_op2,
-- 					dout(61 downto 58)	 => dec_exe_dest,
-- 					dout(57)	 => dec_exe_wb,
-- 					dout(56)	 => dec_flag_wb,

-- 					dout(55 downto 24)	 => dec_mem_data,
-- 					dout(23 downto 20)	 => dec_mem_dest,
-- 					dout(19)	 => dec_mem_lw,
-- 					dout(18)	 => dec_mem_lb,
-- 					dout(17)	 => dec_mem_sw,
-- 					dout(16)	 => dec_mem_sb,

-- 					dout(15)	 => dec_shift_lsl,
-- 					dout(14)	 => dec_shift_lsr,
-- 					dout(13)	 => dec_shift_asr,
-- 					dout(12)	 => dec_shift_ror,
-- 					dout(11)	 => dec_shift_rrx,
-- 					dout(10 downto 6)	 => dec_shift_val,
-- 					dout(5)	 => dec_cy,

-- 					dout(4)	 => dec_comp_op1,
-- 					dout(3)	 => dec_comp_op2,
-- 					dout(2)	 => dec_alu_cy,

-- 					dout(1 downto 0)	 => dec_alu_cmd,

-- 					push		 => dec2exe_push,
-- 					pop		 => exe_pop,

-- 					empty		 => dec2exe_empty,
-- 					full		 => dec2exe_full,

-- 					reset_n	 => reset_n,
-- 					ck			 => ck,
-- 					vdd		 => vdd,
-- 					vss		 => vss);

-- 	dec2if : fifo
-- 	generic map (32)
-- 	port map (	din	=> reg_pc,
-- 					dout	=> dec_pc,

-- 					push		 => dec2if_push,
-- 					pop		 => if_pop,

-- 					empty		 => dec2if_empty,
-- 					full		 => dec2if_full,

-- 					reset_n	 => reset_n,
-- 					ck			 => ck,
-- 					vdd		 => vdd,
-- 					vss		 => vss);

-- 	reg_inst  : reg
-- 	port map(	wdata1		=> exe_res,
-- 					wadr1			=> exe_dest,
-- 					wen1			=> exe_wb,
                                          
-- 					wdata2		=> mem_res,
-- 					wadr2			=> mem_dest,
-- 					wen2			=> mem_wb,
                                          
-- 					wcry			=> exe_c,
-- 					wzero			=> exe_z,
-- 					wneg			=> exe_n,
-- 					wovr			=> exe_v,
-- 					cspr_wb		=> exe_flag_wb,
					               
-- 					reg_rd1		=> rdata1,
-- 					radr1			=> radr1,
-- 					reg_v1		=> rvalid1,
                                          
-- 					reg_rd2		=> rdata2,
-- 					radr2			=> radr2,
-- 					reg_v2		=> rvalid2,
                                          
-- 					reg_rd3		=> rdata3,
-- 					radr3			=> radr3,
-- 					reg_v3		=> rvalid3,
                                          
-- 					reg_cry		=> cry,
-- 					reg_zero		=> zero,
-- 					reg_neg		=> neg,
-- 					reg_ovr		=> ovr,
					               
-- 					reg_cznv		=> reg_cznv,
-- 					reg_vv		=> reg_vv,
                                          
-- 					inval_adr1	=> inval_exe_adr,
-- 					inval1		=> inval_exe,
                                          
-- 					inval_adr2	=> inval_mem_adr,
-- 					inval2		=> inval_mem,
                                          
-- 					inval_czn	=> inval_czn,
-- 					inval_ovr	=> inval_ovr,
                                          
-- 					reg_pc		=> reg_pc,
-- 					reg_pcv		=> reg_pcv,
-- 					inc_pc		=> inc_pc,
				                              
-- 					ck				=> ck,
-- 					reset_n		=> reset_n,
-- 					vdd			=> vdd,
-- 					vss			=> vss);

-- -- Execution condition

-- 	cond <= '1' when	(if_ir(31 downto 28) = X"0" and zero = '1') or
-- 				(if_ir(31 downto 28) = X"1" and zero = '0') or
-- 				(if_ir(31 downto 28) = X"2" and cry = '1') or
-- 				(if_ir(31 downto 28) = X"3" and cry = '0') or
-- 				(if_ir(31 downto 28) = X"4" and neg = '1') or
-- 				(if_ir(31 downto 28) = X"5" and neg = '0') or
-- 				(if_ir(31 downto 28) = X"6" and ovr = '1') or
-- 				(if_ir(31 downto 28) = X"7" and ovr = '0') or
-- 				(if_ir(31 downto 28) = X"8" and (cry = '1' and zero = '0')) or
-- 				(if_ir(31 downto 28) = X"9" and (cry = '0' or zero = '1')) or
-- 				(if_ir(31 downto 28) = X"A" and (neg = ovr)) or	--?
-- 				(if_ir(31 downto 28) = X"B" and (neg /= ovr)) or	--?
-- 				(if_ir(31 downto 28) = X"C" and (zero = '0' and neg = ovr )) or	--?
-- 				(if_ir(31 downto 28) = X"D" and (zero = '1' and neg /= ovr)) or --?
-- 				(if_ir(31 downto 28) = X"E") else '0';

-- 	condv <= '1'		when (if_ir(31 downto 28) = X"E") or (if_ir(31 downto 28) = X"F") else
-- 				reg_cznv	when (if_ir(31 downto 28) = X"0") or
-- 						(if_ir(31 downto 28) = X"1") or
-- 						(if_ir(31 downto 28) = X"2") or
-- 						(if_ir(31 downto 28) = X"3") or
-- 						(if_ir(31 downto 28) = X"4") or
-- 						(if_ir(31 downto 28) = X"5") or
-- 						(if_ir(31 downto 28) = X"8") or
-- 						(if_ir(31 downto 28) = X"9") else
-- 				reg_vv		when (if_ir(31 downto 28) = X"6") or
-- 						(if_ir(31 downto 28) = X"7") else
					 
-- 				reg_vv and reg_cznv when (if_ir(31 downto 28) = X"A") or
-- 							 (if_ir(31 downto 28) = X"B") or
-- 							 (if_ir(31 downto 28) = X"C") or
-- 							 (if_ir(31 downto 28) = X"D") else '0';




-- -- decod instruction type

-- 	regop_t <= '1' when	if_ir(27 downto 26) = "00" and mult_t = '0' and swap_t = '0' else '0';

-- 	mult_t <= '1' when	if_ir(27 downto 22) = "000000" and if_ir(7 downto 4) = "1001" else '0';

-- 	swap_t <= '1' when	if_ir(27 downto 23) = "00010" and if_ir(11 downto 4) = "00001001" else '0';

--  	trans_t <= '1' when	if_ir(27 downto 26) = "01" else '0';

--  	mtrans_t <= '1' when	if_ir(27 downto 25) = "100" else '0';

-- 	branch_t <= '1' when	if_ir(27 downto 25) = "101" else '0';


-- -- decod regop opcode

-- 	and_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"0" else '0';
-- 	eor_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"1" else '0';
-- 	sub_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"2" else '0';
-- 	rsb_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"3" else '0';
-- 	add_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"4" else '0';
-- 	adc_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"5" else '0';
-- 	sbc_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"6" else '0';
-- 	rsc_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"7" else '0';
-- 	tst_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"8" else '0';
-- 	teq_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"9" else '0';
-- 	cmp_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"A" else '0';
-- 	cmn_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"B" else '0';
-- 	orr_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"C" else '0';
-- 	mov_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"D" else '0';
-- 	bic_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"E" else '0';
-- 	mvn_i <= '1' when regop_t = '1' and if_ir(24 downto 21) = X"F" else '0';

-- -- mult instruction

-- 	mul_i <= '1' when mult_t = '1' and if_ir(21) = '1' else '0';
-- 	mla_i <= '1' when mult_t = '1' and if_ir(21) = '0' else '0';

-- -- trans instruction

-- 	ldr_i <= '1' when trans_t = '1' and if_ir(20) = '1' and if_ir(22) = '0' else '0';
-- 	str_i <= '1' when trans_t = '1' and if_ir(20) = '0' and if_ir(22) = '0' else '0';
-- 	ldrb_i <= '1' when trans_t = '1' and if_ir(20) = '1' and if_ir(22) = '1' else '0';
-- 	strb_i <= '1' when trans_t = '1' and if_ir(20) = '0' and if_ir(22) = '1' else '0';

-- -- mtrans instruction

-- 	ldm_i <= '1' when mtrans_t = '1' and if_ir(20) = '1' else '0';
-- 	stm_i <= '1' when mtrans_t = '1' and if_ir(20) = '0' else '0';

-- -- branch instruction

-- 	b_i <= '1' when branch_t = '1' and if_ir(24) = '0' else '0';
-- 	bl_i <= '1' when branch_t = '1' and if_ir(24) = '1' else '0';

-- -- Decode interface operands

-- 	op1 <=	reg_pc		when branch_t = '1'					else
-- 		X"00000000"	when mov_i = '1' or  mvn_i = '1'			else
-- 				rdata1;

-- 	offset32 <=  X"FF"    & if_ir(23 downto 0) when if_ir(23)= '1'                    else
-- 		     X"00"    & if_ir(23 downto 0);
	           	

-- 	op2	<=  offset32			  when b_i = '1' or (bl_i = '1' and blink = '0')  else
-- 		    X"000000" & if_ir(7 downto 0) when (regop_t  = '1' and if_ir(25) = '1') 	  else
-- 		    X"00000" & if_ir(11 downto 0) when (trans_t  = '1' and if_ir(25) = '0') 	  else
-- 		    X"00000004" when bl_i = '1' and blink = '1' else
-- 	            rdata2;
	           

-- 	alu_dest <= if_ir(19 downto 16) when mult_t = '1' or trans_t  = '1'  		else 
-- 		    "1111"		when b_i = '1' or (bl_i = '1' and blink = '0')			else
-- 		    "1110"		when (bl_i = '1' and blink = '1')  else
-- 		    mtrans_rd		when mtrans_t = '1'				else
-- 		    if_ir(15 downto 12);


-- 	alu_wb	<= '1'			when branch_t = '1' or	mult_t = '1' or and_i = '1' or eor_i = '1' or sub_i = '1' or rsb_i  = '1' or add_i = '1' or adc_i = '1' or sbc_i = '1' or rsc_i = '1' or 						orr_i = '1' or mov_i = '1' or bic_i = '1' or mvn_i = '1' or (trans_t = '1' and (if_ir(21) = '1'))  else '0';

-- 	flag_wb	<= '1'			when (regop_t = '1' or mult_t = '1') and if_ir(20) = '1' else '0';

-- -- reg read

-- 	radr1 <= if_ir(15 downto 12) when mult_t = '1' else if_ir(19 downto 16); -- Rn
				
-- 	radr2 <= if_ir(3 downto 0); -- Rm

-- 	radr3 <= if_ir(11 downto 8); -- Rs (

-- -- Reg Invalid

-- 	inval_exe_adr <= alu_dest;

-- 	inval_exe 	  <=	'1'			when branch_t = '1' 																 else 
-- 								'1' 		when regop_t = '1' and (tst_i = '0' and teq_i = '0' and cmp_i = '0' and cmn_i = '0') else -- TST, TEQ, CMP, CMN do not write the result to Rd
-- 								if_ir(21) 	when trans_t = '1' or mtrans_t = '1' 												 else  
-- 								'0'			when dec2exe_push = '0'      														 else -- no write if the instruction is not pushed to the fifo
-- 								'0';


-- 	--inval_exe <=	'1'	when (cond = '1' and condv = '1') and alu_wb = '1' and dec2exe_push = '1' else '0';

-- 	inval_mem_adr <= if_ir(15 downto 12) when trans_t = '1'	else mtrans_rd;

-- 	inval_mem <=	'1'	when (cond = '1' and condv = '1') and (ldr_i = '1' or ldrb_i = '1') and dec2exe_push = '1' else '0';

-- 	inval_czn <=	'1'	when (cond = '1' and condv = '1') and flag_wb  = '1' and dec2exe_push = '1' else '0'; --?
			

-- 	inval_ovr <= inval_czn;

-- -- operand validite

-- 	operv <= '1' when  (branch_t = '1' and reg_pcv ='1') or --A modif pour str (rvalid3)...
-- 			   (regop_t = '1' and (((mov_i = '1' or mvn_i = '1') and ((if_ir(25) = '1') or (rvalid2 = '1'))) or ((mov_i = '0' and mvn_i = '0') and (rvalid1 = '1') and ((if_ir(25) = '1' ) or (rvalid2 = '1'))))) or
-- 			   (trans_t = '1' and ((rvalid1 = '1') and ((if_ir(25) = '0' ) or (rvalid2 = '1')))) 		else
-- 			   '0';

-- -- Decode to mem interface 

-- 	ld_dest <= mtrans_rd when mtrans_t = '1' else if_ir(15 downto 12);
-- 	pre_index <= if_ir(24);

-- 	mem_lw <= ldr_i or ldm_i;
-- 	mem_lb <= ldrb_i;
-- 	mem_sw <= str_i or stm_i;
-- 	mem_sb <= strb_i;

-- -- Shifter command

-- 	shift_lsl <= '1' when (regop_t = '1' and if_ir(25) = '0' and if_ir(6 downto 5) = "00") or (trans_t = '1' and if_ir(25) = '1' and if_ir(6 downto 5) = "00") or (branch_t = '1')					else '0';

-- 	shift_lsr <= '1' when (regop_t = '1' and if_ir(25) = '0' and if_ir(6 downto 5) = "01") or (trans_t = '1' and if_ir(25) = '1' and if_ir(6 downto 5) = "01")					else '0';
-- 	shift_asr <= '1' when (regop_t = '1' and if_ir(25) = '0' and if_ir(6 downto 5) = "10") or (trans_t = '1' and if_ir(25) = '1' and if_ir(6 downto 5) = "10")					else '0';
-- 	shift_ror <= '1' when (regop_t = '1' and if_ir(25) = '0' and if_ir(6 downto 5) = "11") or (trans_t = '1' and if_ir(25) = '1' and if_ir(6 downto 5) = "11") or (regop_t = '1' and if_ir(25) = '1')					else '0';
-- 	shift_rrx <= '1' when ((regop_t = '1' and if_ir(25) = '0' and if_ir(6 downto 5) = "00") or (trans_t = '1' and if_ir(25) = '1' and if_ir(6 downto 5) = "00")) and shift_val = "00000"		else '0';

-- 	shift_val <= "00010" 		 	when b_i = '1' or (bl_i = '1' and blink = '0')													  else
-- 		     if_ir(11 downto 7)       	when (regop_t  = '1' and if_ir(25) = '0' and if_ir(4) = '0') or (trans_t  = '1' and if_ir(25) = '1' and if_ir(4) = '0')   else
-- 		     rdata3(4 downto 0)      	when (regop_t  = '1' and if_ir(25) = '0' and if_ir(4) = '1') or (trans_t  = '1' and if_ir(25) = '1' and if_ir(4) = '1')	  else 
-- 		    if_ir(11 downto 8) & '0'	when (regop_t  = '1' and if_ir(25) = '1') 										  else
-- 		    "00000";
		     

-- -- Alu operand selection

-- 	comp_op1	<= '1' when rsb_i = '1' or rsc_i = '1' 							else '0';
-- 	comp_op2	<= '1' when sub_i = '1' or sbc_i = '1' or cmp_i = '1' or bic_i = '1' or mvn_i = '1' or (bl_i = '1' and blink = '1')	else '0'; 

-- 	alu_cy <=	'1' when sub_i = '1' or rsb_i  = '1' or (adc_i = '1' and cry = '1') or (sbc_i = '1' and cry = '1') or (rsc_i = '1' and cry = '1') or cmp_i = '1' or (bl_i = '1' and blink = '1')		else '0'; --?

-- -- Alu command

-- 	alu_cmd <=	"11" when eor_i='1' or teq_i='1'             		 else
-- 			"10" when orr_i='1'                          		 else
-- 	            	"01" when and_i='1' or tst_i='1' or bic_i='1' 		 else
-- 			"00";

-- -- Mtrans reg list

-- 	process (ck)
-- 	begin
-- 		if (rising_edge(ck)) then
-- 		--...
-- 		end if;
-- 	end process;

-- 	mtrans_mask_shift <= X"FFFE" when if_ir(0) = '1' and mtrans_mask(0) = '1' else
-- 								X"FFFC" when if_ir(1) = '1' and mtrans_mask(1) = '1' else
-- 								X"FFF8" when if_ir(2) = '1' and mtrans_mask(2) = '1' else
-- 								X"FFF0" when if_ir(3) = '1' and mtrans_mask(3) = '1' else
-- 								X"FFE0" when if_ir(4) = '1' and mtrans_mask(4) = '1' else
-- 								X"FFC0" when if_ir(5) = '1' and mtrans_mask(5) = '1' else
-- 								X"FF80" when if_ir(6) = '1' and mtrans_mask(6) = '1' else
-- 								X"FF00" when if_ir(7) = '1' and mtrans_mask(7) = '1' else
-- 								X"FE00" when if_ir(8) = '1' and mtrans_mask(8) = '1' else
-- 								X"FC00" when if_ir(9) = '1' and mtrans_mask(9) = '1' else
-- 								X"F800" when if_ir(10) = '1' and mtrans_mask(10) = '1' else
-- 								X"F000" when if_ir(11) = '1' and mtrans_mask(11) = '1' else
-- 								X"E000" when if_ir(12) = '1' and mtrans_mask(12) = '1' else
-- 								X"C000" when if_ir(13) = '1' and mtrans_mask(13) = '1' else
-- 								X"8000" when if_ir(14) = '1' and mtrans_mask(14) = '1' else
-- 								X"0000";

-- 	mtrans_list <= if_ir(15 downto 0) and mtrans_mask;

-- 	process (mtrans_list)
-- 	begin
-- 	end process;

-- 	mtrans_1un <= '1' when mtrans_nbr = "00001" else '0';

-- 	mtrans_rd <=	X"0" when mtrans_list(0) = '1' else
-- 						X"1" when mtrans_list(1) = '1' else
-- 						X"2" when mtrans_list(2) = '1' else
-- 						X"3" when mtrans_list(3) = '1' else
-- 						X"4" when mtrans_list(4) = '1' else
-- 						X"5" when mtrans_list(5) = '1' else
-- 						X"6" when mtrans_list(6) = '1' else
-- 						X"7" when mtrans_list(7) = '1' else
-- 						X"8" when mtrans_list(8) = '1' else
-- 						X"9" when mtrans_list(9) = '1' else
-- 						X"A" when mtrans_list(10) = '1' else
-- 						X"B" when mtrans_list(11) = '1' else
-- 						X"C" when mtrans_list(12) = '1' else
-- 						X"D" when mtrans_list(13) = '1' else
-- 						X"E" when mtrans_list(14) = '1' else
-- 						X"F";

-- -- FSM

-- process (ck)
-- begin

-- if (rising_edge(ck)) then
-- 	if (reset_n = '0') then
-- 		cur_state <= FETCH;
-- 	else
-- 		cur_state <= next_state;
-- 	end if;
-- end if;

-- end process;

-- inc_pc <= dec2if_push;

-- --state machine process.
-- process (cur_state, dec2if_full, cond, condv, operv, dec2exe_full, if2dec_empty, reg_pcv, bl_i,
-- 			branch_t, and_i, eor_i, sub_i, rsb_i, add_i, adc_i, sbc_i, rsc_i, orr_i, mov_i, bic_i,
-- 			mvn_i, ldr_i, ldrb_i, ldm_i, stm_i, if_ir, mtrans_rd, mtrans_mask_shift)
-- begin
-- 	case cur_state is

-- 	when FETCH =>

-- 		debug_state <= X"1";

-- 		if2dec_pop <= '0';
-- 		dec2exe_push <= '0';
-- 		blink <= '0';
-- 		mtrans_shift <= '0';
-- 		mtrans_loop_adr <= '0';

-- 		--T2
-- 		if reg_pcv = '1' and dec2if_full = '0' then
-- 		next_state <= RUN;
-- 		dec2if_push <= '1';

-- 		--T1
-- 		else
-- 		next_state <= FETCH;
-- 		dec2if_push <= '0';
-- 		end if;

-- 	when RUN =>

-- 		debug_state <= X"2";

-- 		--T1
-- 		if if2dec_empty = '1' or dec2exe_full = '1' or condv = '0' or operv = '0' then
--       		next_state <= RUN;
-- 		dec2exe_push <= '0';
-- 		if2dec_pop <= '0';
-- 			if dec2if_full = '0' then
-- 			dec2if_push <= '1';
-- 			else
-- 			dec2if_push <= '0';
-- 			end if;

-- 		--T2	
-- 	    	elsif cond = '0' then
-- 		next_state <= RUN;
-- 		dec2exe_push <= '0';
-- 		if2dec_pop <= '1';

-- 			if dec2if_full = '0' then
-- 			dec2if_push <= '1';
-- 			else
-- 			dec2if_push <= '0';
-- 			end if;

-- 		elsif cond = '1' then

-- 				--T4
-- 				if bl_i = '1' 	     	     then
-- 				next_state <= LINK;

-- 				blink <= '1';

-- 				dec2exe_push <= '1';
-- 				if2dec_pop <= '0';

-- 				dec2if_push <= '0';

-- 				--T5
-- 				elsif b_i = '1' 	     then
-- 				next_state <= BRANCH;

-- 				dec2exe_push <= '1';
-- 				if2dec_pop <= '1';

-- 				dec2if_push <= '0';

-- 				--T6
-- 				elsif ldm_i = '1' or stm_i = '1' then
-- 				next_state <= MTRANS;

-- 				--T3
-- 				else 
-- 				next_state <= RUN;

-- 				dec2exe_push <= '1';
-- 				if2dec_pop <= '1';
				
-- 					if dec2if_full = '0' then
-- 					dec2if_push <= '1';
-- 					else
-- 					dec2if_push <= '0';
-- 					end if;

-- 				end if;
-- 		end if;

-- 	when BRANCH =>

-- 		debug_state <= X"3";
-- 		dec2exe_push <= '0';

-- 		--T1
-- 		if if2dec_empty = '1' then
-- 		next_state <= BRANCH;
-- 		if2dec_pop <= '0';
-- 		dec2if_push <= '0';


-- 		--T2
-- 		elsif reg_pcv = '1' then
-- 		next_state <= RUN;
-- 		if2dec_pop <= '1';
-- 		dec2if_push <= '1';
		
-- 		--T3
-- 		else
-- 		next_state <= FETCH;
-- 		if2dec_pop <= '1';
-- 		dec2if_push <= '0';
-- 		end if;

-- 	when LINK =>

-- 		--T1
-- 		debug_state <= X"4";

-- 		blink <= '0';

-- 		dec2exe_push <= '1';
-- 		if2dec_pop <= '1';
		
-- 		dec2if_push <= '0';

-- 		next_state <= BRANCH;


-- 	when MTRANS =>

-- 		debug_state <= X"5";

-- 	when others => null;

-- 	end case;
-- end process;

-- dec_pop <= if2dec_pop;

-- end Behavior;