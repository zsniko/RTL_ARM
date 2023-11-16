library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Reg2 is
	port(
	-- Write Port 1 prioritaire 50:50
		wdata1		: in Std_Logic_Vector(31 downto 0);
		wadr1			: in Std_Logic_Vector(3 downto 0);
		wen1			: in Std_Logic;

	-- Write Port 2 non prioritaire
		wdata2		: in Std_Logic_Vector(31 downto 0);
		wadr2			: in Std_Logic_Vector(3 downto 0);
		wen2			: in Std_Logic;

	-- Write CSPR Port
		wcry			: in Std_Logic;
		wzero			: in Std_Logic;
		wneg			: in Std_Logic;
		wovr			: in Std_Logic;
		cspr_wb		: in Std_Logic;
		
	-- Read Port 1 32 bits
		reg_rd1		: out Std_Logic_Vector(31 downto 0);
		radr1			: in Std_Logic_Vector(3 downto 0);
		reg_v1		: out Std_Logic;

	-- Read Port 2 32 bits
		reg_rd2		: out Std_Logic_Vector(31 downto 0);
		radr2			: in Std_Logic_Vector(3 downto 0);
		reg_v2		: out Std_Logic;

	-- Read Port 3 32 bits
		reg_rd3		: out Std_Logic_Vector(31 downto 0);
		radr3			: in Std_Logic_Vector(3 downto 0);
		reg_v3		: out Std_Logic;

	-- read CSPR Port
		reg_cry		: out Std_Logic;
		reg_zero		: out Std_Logic;
		reg_neg		: out Std_Logic;
		reg_cznv		: out Std_Logic;
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
		ck				: in Std_Logic;
		reset_n		: in Std_Logic;
		vdd			: in bit;
		vss			: in bit);
end;

architecture Behavior OF Reg is
-- component entity
	component add_32b
		port ( 	A, B : in std_logic_vector(31 downto 0);
				Cin : in std_logic;
				Cout : out std_logic;
				S : out std_logic_vector(31 downto 0));
	end component;

-- valeurs stockees dans les registres r0-r15
	signal data_r0 : Std_Logic_Vector(31 downto 0);
	signal data_r1 : Std_Logic_Vector(31 downto 0);
	signal data_r2 : Std_Logic_Vector(31 downto 0);
	signal data_r3 : Std_Logic_Vector(31 downto 0);
	signal data_r4 : Std_Logic_Vector(31 downto 0);
	signal data_r5 : Std_Logic_Vector(31 downto 0);
	signal data_r6 : Std_Logic_Vector(31 downto 0);
	signal data_r7 : Std_Logic_Vector(31 downto 0);
	signal data_r8 : Std_Logic_Vector(31 downto 0);
	signal data_r9 : Std_Logic_Vector(31 downto 0);
	signal data_r10 : Std_Logic_Vector(31 downto 0);
	signal data_r11 : Std_Logic_Vector(31 downto 0);
	signal data_r12 : Std_Logic_Vector(31 downto 0);
	signal data_SP : Std_Logic_Vector(31 downto 0);
	signal data_LR : Std_Logic_Vector(31 downto 0);
	signal data_PC : Std_Logic_Vector(31 downto 0);
	signal data_PC_plus4 : Std_Logic_Vector(31 downto 0);
	signal data_PC_plus4_cry : Std_Logic;

-- valitation des registres r0-r15
	signal v_r0 : Std_Logic;
	signal v_r1 : Std_Logic;
	signal v_r2 : Std_Logic;
	signal v_r3 : Std_Logic;
	signal v_r4 : Std_Logic;
	signal v_r5 : Std_Logic;
	signal v_r6 : Std_Logic;
	signal v_r7 : Std_Logic;
	signal v_r8 : Std_Logic;
	signal v_r9 : Std_Logic;
	signal v_r10 : Std_Logic;
	signal v_r11 : Std_Logic;
	signal v_r12 : Std_Logic;
	signal v_SP : Std_Logic;
	signal v_LR : Std_Logic;
	signal v_PC : Std_logic;

-- valeurs stockees dans les registres du CDPR
	signal data_cry : Std_Logic;
	signal data_zero : Std_Logic;
	signal data_neg : Std_Logic;
	signal data_ovr : Std_Logic;

-- vlaitation du CDPR
	signal v_czn : Std_Logic;
	signal v_ovr : Std_Logic;

begin
	
	Add32_pc : add_32b
	port map (	A		 => data_PC,
				B		 => x"00000004",
				Cin		 => '0',
				Cout		 => data_PC_plus4_cry,
				S		 => data_PC_plus4);
	-- R0
		process(ck)
		begin
			if rising_edge(ck) then
				if reset_n = '0' then
					v_r0 <= '1'; -- all the register become valide after reset
					v_r1 <= '1';
					v_r2 <= '1';
					v_r3 <= '1';
					v_r4 <= '1';
					v_r5 <= '1';
					v_r6 <= '1';
					v_r7 <= '1';
					v_r8 <= '1';
					v_r9 <= '1';
					v_r10 <= '1';
					v_r11 <= '1';
					v_r12 <= '1';
					v_SP <= '1';
					v_LR <= '1';
					v_PC <= '1';
					v_czn <= '1';
					v_ovr <= '1';
					data_r0 <= x"00000000";
					data_r1 <= x"00000000";
					data_r2 <= x"00000000";
					data_r3 <= x"00000000";
					data_r4 <= x"00000000";
					data_r5 <= x"00000000";
					data_r6 <= x"00000000";
					data_r7 <= x"00000000";
					data_r8 <= x"00000000";
					data_r9 <= x"00000000";
					data_r10 <= x"00000000";
					data_r11 <= x"00000000";
					data_r12 <= x"00000000";
					data_SP <= x"00000000";
					data_LR <= x"00000000";
					data_PC <= x"00000000";
					data_cry <= '0';
					data_zero <= '0';
					data_neg <= '0';
					data_ovr <= '0';
				else
					
					
					-- CDPR
						if inval_czn = '1' then
							v_czn <= '0';
							if v_czn = '0' and cspr_wb = '1' then
								
								data_cry <= wcry;
								data_zero <= wzero;
								data_neg <= wneg;
									
								
							end if;
						else 
							if v_czn = '0' and cspr_wb = '1' then
								v_czn <= '1';
								data_cry <= wcry;
								data_zero <= wzero;
								data_neg <= wneg;
								
									
							end if;	
						end if;
						
				
					-- overflow
						if inval_ovr = '1' then
							v_ovr <= '0';
							if v_ovr = '0'and cspr_wb = '1' then
								data_ovr <= wovr;
							end if;
						else
							if v_ovr = '0'and cspr_wb = '1' then
								v_ovr <= '1';
								data_ovr <= wovr;
							end if;
						end if;
						

					-- PC registre
						if (inval_adr1 = x"F" and inval1 = '1') or(inval_adr2 = x"F" and inval2 = '1') then
							if wen1 = '1' and wadr1 = x"F" and v_PC = '0' then
								data_pc <= wdata1;
								v_PC <= '0';
							elsif wen2 = '1' and wadr2 = x"F" and v_PC = '0' then
								data_pc <= wdata2;
								v_PC <= '0';
							end if;
							if (v_PC = '1' and inc_pc = '1') then
								data_PC <= data_PC_plus4;
							end if ;
							v_PC <= '0';
						else
							if wen1 = '1' and wadr1 = x"F" and v_PC = '0' then
								data_pc <= wdata1;
								v_PC <= '1';
							elsif wen2 = '1' and wadr2 = x"F" and v_PC = '0' then
								data_pc <= wdata2;
								v_PC <= '1';
							end if;
							if (v_PC = '1' and inc_pc = '1') then
								data_PC <= data_PC_plus4;
							end if ;
						end if;

					-- Registre 0
						if (inval_adr1 = x"0" and inval1 = '1') or(inval_adr2 = x"0" and inval2 = '1') then
							if wen1 = '1' and wadr1 = x"0" and v_r0 = '0' then
								data_r0 <= wdata1;
							elsif wen2 = '1' and wadr2 = x"0" and v_r0 = '0' then
								data_r0 <= wdata2;
							end if;
							v_r0 <= '0';
						else
							if wen1 = '1' and wadr1 = x"0" and v_r0 = '0' then
								data_r0 <= wdata1;
								v_r0 <= '1';
							elsif wen2 = '1' and wadr2 = x"0" and v_r0 = '0' then
								data_r0 <= wdata2;
								v_r0 <= '1';
							end if;
						end if;
						

					-- Registre 1
						if (inval_adr1 = x"1" and inval1 = '1') or(inval_adr2 = x"1" and inval2 = '1') then
							if wen1 = '1' and wadr1 = x"1" and v_r1 = '0' then
								data_r1 <= wdata1;
							elsif wen2 = '1' and wadr2 = x"1" and v_r1 = '0' then
								data_r1 <= wdata2;
							end if;
							v_r1 <= '0';
						else
							if wen1 = '1' and wadr1 = x"1" and v_r1 = '0' then
								data_r1 <= wdata1;
								v_r1 <= '1';
							elsif wen2 = '1' and wadr2 = x"1" and v_r1 = '0' then
								data_r1 <= wdata2;
								v_r1 <= '1';
							end if;
						end if;

					-- Registre 2
						if (inval_adr1 = x"2" and inval1 = '1') or(inval_adr2 = x"2" and inval2 = '1') then
							if wen1 = '1' and wadr1 = x"2" and v_r2 = '0' then
								data_r2 <= wdata1;
							elsif wen2 = '1' and wadr2 = x"2" and v_r2 = '0' then
								data_r2 <= wdata2;
							end if;
							v_r2 <= '0';
						else	
							if wen1 = '1' and wadr1 = x"2" and v_r2 = '0' then
								data_r2 <= wdata1;
								v_r2 <= '1';
							elsif wen2 = '1' and wadr2 = x"2" and v_r2 = '0' then
								data_r2 <= wdata2;
								v_r2 <= '1';
							end if;
						end if;

					-- Registre 3
						if (inval_adr1 = x"3" and inval1 = '1') or(inval_adr2 = x"3" and inval2 = '1') then
							if wen1 = '1' and wadr1 = x"3" and v_r3 = '0' then
								data_r3 <= wdata1;
							elsif wen2 = '1' and wadr2 = x"3" and v_r3 = '0' then
								data_r3 <= wdata2;
							end if;
							v_r3 <= '0';
						else
							if wen1 = '1' and wadr1 = x"3" and v_r3 = '0' then
								data_r3 <= wdata1;
								v_r3 <= '1';
							elsif wen2 = '1' and wadr2 = x"3" and v_r3 = '0' then
								data_r3 <= wdata2;
								v_r3 <= '1';
							end if;
						end if;
					
					-- Registre 4
						if (inval_adr1 = x"4" and inval1 = '1') or(inval_adr2 = x"4" and inval2 = '1') then
							if wen1 = '1' and wadr1 = x"4" and v_r4 = '0' then
								data_r4 <= wdata1;
							elsif wen2 = '1' and wadr2 = x"4" and v_r4 = '0' then
								data_r4 <= wdata2;
							end if;
							v_r4 <= '0';
						else
							if wen1 = '1' and wadr1 = x"4" and v_r4 = '0' then
								data_r4 <= wdata1;
								v_r4 <= '1';
							elsif wen2 = '1' and wadr2 = x"4" and v_r4 = '0' then
								data_r4 <= wdata2;
								v_r4 <= '1';
							end if;
						end if;
						

					-- Registre 5
						if (inval_adr1 = x"5" and inval1 = '1') or(inval_adr2 = x"5" and inval2 = '1') then
							if wen1 = '1' and wadr1 = x"5" and v_r5 = '0' then
								data_r5 <= wdata1;
							elsif wen2 = '1' and wadr2 = x"5" and v_r5 = '0' then
								data_r5 <= wdata2;
							end if;
								v_r5 <= '0';
						else	
							if wen1 = '1' and wadr1 = x"5" and v_r5 = '0' then
								data_r5 <= wdata1;
								v_r5 <= '1';
							elsif wen2 = '1' and wadr2 = x"5" and v_r5 = '0' then
								data_r5 <= wdata2;
								v_r5 <= '1';
							end if;
						end if;

					-- Registre 6
						if (inval_adr1 = x"6" and inval1 = '1') or(inval_adr2 = x"6" and inval2 = '1') then
							if wen1 = '1' and wadr1 = x"6" and v_r6 = '0' then
								data_r6 <= wdata1;
							elsif wen2 = '1' and wadr2 = x"6" and v_r6 = '0' then
								data_r6 <= wdata2;
							end if;
							v_r6 <= '0';
						else
							if wen1 = '1' and wadr1 = x"6" and v_r6 = '0' then
								data_r6 <= wdata1;
								v_r6 <= '1';
							elsif wen2 = '1' and wadr2 = x"6" and v_r6 = '0' then
								data_r6 <= wdata2;
								v_r6 <= '1';
							end if;
						end if;
						

					-- Registre 7
						if (inval_adr1 = x"7" and inval1 = '1') or(inval_adr2 = x"7" and inval2 = '1') then
							if wen1 = '1' and wadr1 = x"7" and v_r7 = '0' then
								data_r7 <= wdata1;
							elsif wen2 = '1' and wadr2 = x"7" and v_r7 = '0' then
								data_r7 <= wdata2;
							end if;
							v_r7 <= '0';
						else
							if wen1 = '1' and wadr1 = x"7" and v_r7 = '0' then
								data_r7 <= wdata1;
								v_r7 <= '1';
							elsif wen2 = '1' and wadr2 = x"7" and v_r7 = '0' then
								data_r7 <= wdata2;
								v_r7 <= '1';
							end if;
						end if;

					-- Registre 8
						if (inval_adr1 = x"8" and inval1 = '1') or(inval_adr2 = x"8" and inval2 = '1') then
							if wen1 = '1' and wadr1 = x"8" and v_r8 = '0' then
								data_r8 <= wdata1;
							elsif wen2 = '1' and wadr2 = x"8" and v_r8 = '0' then
								data_r8 <= wdata2;
							end if;
							v_r8 <= '0';
						else
							if wen1 = '1' and wadr1 = x"8" and v_r8 = '0' then
								data_r8 <= wdata1;
								v_r8 <= '1';
							elsif wen2 = '1' and wadr2 = x"8" and v_r8 = '0' then
								data_r8 <= wdata2;
								v_r8 <= '1';
							end if;
						end if;

					-- Registre 9
						if (inval_adr1 = x"9" and inval1 = '1') or(inval_adr2 = x"9" and inval2 = '1') then
							if wen1 = '1' and wadr1 = x"9" and v_r9 = '0' then
								data_r9 <= wdata1;
							elsif wen2 = '1' and wadr2 = x"9" and v_r9 = '0' then
								data_r9 <= wdata2;
							end if;
							v_r9 <= '0';
						else
							if wen1 = '1' and wadr1 = x"9" and v_r9 = '0' then
								data_r9 <= wdata1;
								v_r9 <= '1';
							elsif wen2 = '1' and wadr2 = x"9" and v_r9 = '0' then
								data_r9 <= wdata2;
								v_r9 <= '1';
							end if;
						end if;

					-- Registre 10
						if (inval_adr1 = x"A" and inval1 = '1') or(inval_adr2 = x"A" and inval2 = '1') then
							if wen1 = '1' and wadr1 = x"A" and v_r10 = '0' then
								data_r3 <= wdata1;
							elsif wen2 = '1' and wadr2 = x"A" and v_r10 = '0' then
								data_r3 <= wdata2;
							end if;
							v_r10 <= '0';
						else
							if wen1 = '1' and wadr1 = x"A" and v_r10 = '0' then
								data_r3 <= wdata1;
								v_r10 <= '1';
							elsif wen2 = '1' and wadr2 = x"A" and v_r10 = '0' then
								data_r3 <= wdata2;
								v_r10 <= '1';
							end if;
						end if;
					
					-- Registre 11
						if (inval_adr1 = x"B" and inval1 = '1') or(inval_adr2 = x"B" and inval2 = '1') then
							if wen1 = '1' and wadr1 = x"B" and v_r11 = '0' then
								data_r11 <= wdata1;
							elsif wen2 = '1' and wadr2 = x"B" and v_r11 = '0' then
								data_r11 <= wdata2;
							end if;
							v_r11 <= '0';
						else
							if wen1 = '1' and wadr1 = x"B" and v_r11 = '0' then
								data_r11 <= wdata1;
								v_r11 <= '1';
							elsif wen2 = '1' and wadr2 = x"B" and v_r11 = '0' then
								data_r11 <= wdata2;
								v_r11 <= '1';
							end if;
						end if;

					-- Registre 12
						if (inval_adr1 = x"C" and inval1 = '1') or(inval_adr2 = x"C" and inval2 = '1') then
							if wen1 = '1' and wadr1 = x"C" and v_r12 = '0' then
								data_r12 <= wdata1;
							elsif wen2 = '1' and wadr2 = x"C" and v_r12 = '0' then
								data_r12 <= wdata2;
							end if;
							v_r12 <= '0';
						else
							if wen1 = '1' and wadr1 = x"C" and v_r12 = '0' then
								data_r12 <= wdata1;
								v_r12 <= '1';
							elsif wen2 = '1' and wadr2 = x"C" and v_r12 = '0' then
								data_r12 <= wdata2;
								v_r12 <= '1';
							end if;
						end if;

					-- Registre SP
						if (inval_adr1 = x"D" and inval1 = '1') or(inval_adr2 = x"D" and inval2 = '1') then
							if wen1 = '1' and wadr1 = x"D" and v_SP = '0' then
								data_SP <= wdata1;
							elsif wen2 = '1' and wadr2 = x"D" and v_SP = '0' then
								data_SP <= wdata2;
							end if;
							v_SP <= '0';
						else
							if wen1 = '1' and wadr1 = x"D" and v_SP = '0' then
								data_SP <= wdata1;
								v_r12 <= '1';
							elsif wen2 = '1' and wadr2 = x"D" and v_SP = '0' then
								data_SP <= wdata2;
								v_SP <= '1';
							end if;
						end if;

					-- Registre LR
						if (inval_adr1 = x"E" and inval1 = '1') or(inval_adr2 = x"E" and inval2 = '1') then
							if wen1 = '1' and wadr1 = x"E" and v_LR = '0' then
								data_LR <= wdata1;
							elsif wen2 = '1' and wadr2 = x"E" and v_LR = '0' then
								data_LR <= wdata2;
							end if;
							v_LR <= '0';
						else
							if wen1 = '1' and wadr1 = x"E" and v_LR = '0' then
								data_LR <= wdata1;
								v_r12 <= '1';
							elsif wen2 = '1' and wadr2 = x"E" and v_LR = '0' then
								data_LR <= wdata2;
								v_LR <= '1';
							end if;
						end if;




				end if;
			end if;
		end process;

	-- read
	reg_rd1 <= 	data_r1 when radr1 = x"1" else
				data_r2 when radr1 = x"2" else
				data_r3 when radr1 = x"3" else
				data_r4 when radr1 = x"4" else
				data_r5 when radr1 = x"5" else
				data_r6 when radr1 = x"6" else
				data_r7 when radr1 = x"7" else
				data_r8 when radr1 = x"8" else
				data_r9 when radr1 = x"9" else
				data_r10 when radr1 = x"A" else
				data_r11 when radr1 = x"B" else
				data_r12 when radr1 = x"C" else
				data_SP when radr1 = x"D" else
				data_LR when radr1 = x"E" else
				data_PC when radr1 = x"F" else
				data_r0;

	reg_rd2 <= data_r1 when radr2 = x"1" else
			data_r2 when radr2 = x"2" else
			data_r3 when radr2 = x"3" else
			data_r4 when radr2 = x"4" else
			data_r5 when radr2 = x"5" else
			data_r6 when radr2 = x"6" else
			data_r7 when radr2 = x"7" else
			data_r8 when radr2 = x"8" else
			data_r9 when radr2 = x"9" else
			data_r10 when radr2 = x"A" else
			data_r11 when radr2 = x"B" else
			data_r12 when radr2 = x"C" else
			data_SP when radr2 = x"D" else
			data_LR when radr2 = x"E" else
			data_PC when radr2 = x"F" else
			data_r0;

	reg_rd3 <= data_r1 when radr3 = x"1" else
			data_r2 when radr3 = x"2" else
			data_r3 when radr3 = x"3" else
			data_r4 when radr3 = x"4" else
			data_r5 when radr3 = x"5" else
			data_r6 when radr3 = x"6" else
			data_r7 when radr3 = x"7" else
			data_r8 when radr3 = x"8" else
			data_r9 when radr3 = x"9" else
			data_r10 when radr3 = x"A" else
			data_r11 when radr3 = x"B" else
			data_r12 when radr3 = x"C" else
			data_SP when radr3 = x"D" else
			data_LR when radr3 = x"E" else
			data_PC when radr3 = x"F" else
			data_r0;

	reg_v1 	<= v_r1 when radr1 = x"1" else
			v_r2 when radr1 = x"2" else
			v_r3 when radr1 = x"3" else
			v_r4 when radr1 = x"4" else
			v_r5 when radr1 = x"5" else
			v_r6 when radr1 = x"6" else
			v_r7 when radr1 = x"7" else
			v_r8 when radr1 = x"8" else
			v_r9 when radr1 = x"9" else
			v_r10 when radr1 = x"A" else
			v_r11 when radr1 = x"B" else
			v_r12 when radr1 = x"C" else
			v_SP when radr1 = x"D" else
			v_LR when radr1 = x"E" else
			v_PC when radr1 = x"F" else
			v_r0;

	reg_v2 	<= v_r1 when radr2 = x"1" else
			v_r2 when radr2 = x"2" else
			v_r3 when radr2 = x"3" else
			v_r4 when radr2 = x"4" else
			v_r5 when radr2 = x"5" else
			v_r6 when radr2 = x"6" else
			v_r7 when radr2 = x"7" else
			v_r8 when radr2 = x"8" else
			v_r9 when radr2 = x"9" else
			v_r10 when radr2 = x"A" else
			v_r11 when radr2 = x"B" else
			v_r12 when radr2 = x"C" else
			v_SP when radr2 = x"D" else
			v_LR when radr2 = x"E" else
			v_PC when radr2 = x"F" else
			v_r0;

	reg_v3 	<= v_r1 when radr3 = x"1" else
			v_r2 when radr3 = x"2" else
			v_r3 when radr3 = x"3" else
			v_r4 when radr3 = x"4" else
			v_r5 when radr3 = x"5" else
			v_r6 when radr3 = x"6" else
			v_r7 when radr3 = x"7" else
			v_r8 when radr3 = x"8" else
			v_r9 when radr3 = x"9" else
			v_r10 when radr3 = x"A" else
			v_r11 when radr3 = x"B" else
			v_r12 when radr3 = x"C" else
			v_SP when radr3 = x"D" else
			v_LR when radr3 = x"E" else
			v_PC when radr3 = x"F" else
			v_r0;


	

	-- port sortie
		-- flags
			reg_cry		<= data_cry;
			reg_zero	<= data_zero;
			reg_neg		<= data_neg;
			reg_cznv	<= v_czn;
			reg_ovr		<= data_ovr;
			reg_vv		<= v_ovr;
		-- registre pc	
			reg_pc 		<= data_PC;
			reg_pcv		<= v_PC;




end Behavior;