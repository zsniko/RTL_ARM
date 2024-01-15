library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Reg is
	port(
	-- Write Port 1
		wdata1		: in Std_Logic_Vector(31 downto 0);
		wadr1			: in Std_Logic_Vector(3 downto 0);
		wen1			: in Std_Logic;

	-- Write Port 2
		wdata2		: in Std_Logic_Vector(31 downto 0);
		wadr2			: in Std_Logic_Vector(3 downto 0);
		wen2			: in Std_Logic;

	-- Write CSPR Port
		wcry			: in Std_Logic;
		wzero			: in Std_Logic;
		wneg			: in Std_Logic;
		wovr			: in Std_Logic;
		cspr_wb			: in Std_Logic;
		
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
end Reg;

architecture Behavior OF Reg is

	signal r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14  : Std_Logic_Vector(31 downto 0);
	signal r0v, r1v, r2v, r3v, r4v, r5v, r6v, r7v, r8v, r9v, r10v, r11v, r12v, r13v, r14v, pcv: Std_Logic;
	signal c, z, n, o, cznv, vv : Std_Logic;
	signal pc : Std_Logic_Vector(31 downto 0);
	
begin


-- Mise à jour des flags de sortie

reg_cry <= c; 
reg_zero <= z;
reg_neg <= n;
reg_cznv <= cznv;
reg_ovr <= o; 
reg_vv <= vv;

-- Mise à jour des registres en lecture

with radr1 select reg_rd1 <=
  	r0 when "0000",
	r1 when "0001",
	r2 when "0010",
	r3 when "0011",
	r4 when "0100",
	r5 when "0101",
	r6 when "0110",
	r7 when "0111",
	r8 when "1000",
	r9 when "1001",
	r10 when "1010",
	r11 when "1011",
	r12 when "1100",
	r13 when "1101",
	r14 when "1110",
	pc when "1111",
	x"00000000" when others;
	
with radr1 select reg_v1 <=
	r0v when "0000",
	r1v when "0001",
	r2v when "0010",
	r3v when "0011",
	r4v when "0100",
	r5v when "0101",
	r6v when "0110",
	r7v when "0111",
	r8v when "1000",
	r9v when "1001",
	r10v when "1010",
	r11v when "1011",
	r12v when "1100",
	r13v when "1101",
	r14v when "1110",
	pcv when "1111",
	'0' when others;

with radr2 select reg_rd2 <=
  	r0 when "0000",
	r1 when "0001",
	r2 when "0010",
	r3 when "0011",
	r4 when "0100",
	r5 when "0101",
	r6 when "0110",
	r7 when "0111",
	r8 when "1000",
	r9 when "1001",
	r10 when "1010",
	r11 when "1011",
	r12 when "1100",
	r13 when "1101",
	r14 when "1110",
	pc when "1111",
	x"00000000" when others;
	
with radr2 select reg_v2 <=
	r0v when "0000",
	r1v when "0001",
	r2v when "0010",
	r3v when "0011",
	r4v when "0100",
	r5v when "0101",
	r6v when "0110",
	r7v when "0111",
	r8v when "1000",
	r9v when "1001",
	r10v when "1010",
	r11v when "1011",
	r12v when "1100",
	r13v when "1101",
	r14v when "1110",
	pcv when "1111",
	'0' when others;

with radr3 select reg_rd3 <=
  	r0 when "0000",
	r1 when "0001",
	r2 when "0010",
	r3 when "0011",
	r4 when "0100",
	r5 when "0101",
	r6 when "0110",
	r7 when "0111",
	r8 when "1000",
	r9 when "1001",
	r10 when "1010",
	r11 when "1011",
	r12 when "1100",
	r13 when "1101",
	r14 when "1110",
	pc when "1111",
	x"00000000" when others;
	
with radr3 select reg_v3 <=
	r0v when "0000",
	r1v when "0001",
	r2v when "0010",
	r3v when "0011",
	r4v when "0100",
	r5v when "0101",
	r6v when "0110",
	r7v when "0111",
	r8v when "1000",
	r9v when "1001",
	r10v when "1010",
	r11v when "1011",
	r12v when "1100",
	r13v when "1101",
	r14v when "1110",
	pcv when "1111",
	'0' when others;

-- Mise à jour de PC et du flag de validite de PC
reg_pc <= pc;
reg_pcv <= pcv;  

process(ck)
begin
	if (rising_edge(ck)) then
		if (reset_n = '0') then
			r0v <= '1';
			r1v <= '1';
			r2v <= '1';
			r3v <= '1';
			r4v <= '1';
			r5v <= '1';
			r6v <= '1';
			r7v <= '1';
			r8v <= '1';
			r9v <= '1';
			r10v <= '1';
			r11v <= '1';
			r12v <= '1';
			r13v <= '1';
			r14v <= '1';
			cznv <= '1';
			vv <= '1';
			pcv <= '1';
			pc <= x"00000000";
		else
			-- Valid bit czn
			if (cznv = '1') then
				if (inval_czn ='1') then
					cznv <= '0';
				else 
					cznv <= '1';
				end if;
			else
				if (inval_czn ='0') then
					if (cspr_wb = '1') then
						cznv <= '1';
					else
						cznv <= '0';
					end if;
				else
					cznv <= '0';
				end if;
			end if;

			-- Valid bit ovr
			if (vv = '1') then
				if (inval_ovr ='1') then
					vv <= '0';
				else 
					vv <= '1';
				end if;
			else
				if (inval_ovr ='0') then
					if (cspr_wb = '1') then
						vv <= '1';
					else
						vv <= '0';
					end if;
				else
					vv <= '0';
				end if;
			end if;

			-- Valid bit reg0
			if (r0v = '1') then
				if ((inval1 ='1' and inval_adr1 = "0000") or (inval2 ='1' and inval_adr2 = "0000")) then
					r0v <= '0';
				else 
					r0v <= '1';
				end if;
			else
				if ((not(inval1 ='1' and inval_adr1 = "0000") or (inval2 ='1' and inval_adr2 = "0000"))) then
					if ((wen1 = '1' and wadr1 = "0000") or (wen2 = '1' and wadr2 = "0000")) then
						r0v <= '1';
					else
						r0v <= '0';
					end if;
				else
					r0v <= '0';
				end if;
			end if;
			
			-- Valid bit reg1
			if (r1v = '1') then
				if ((inval1 ='1' and inval_adr1 = "0001") or (inval2 ='1' and inval_adr2 = "0001")) then
					r1v <= '0';
				else 
					r1v <= '1';
				end if;
			else
				if ((not(inval1 ='1' and inval_adr1 = "0001") or (inval2 ='1' and inval_adr2 = "0001"))) then
					if ((wen1 = '1' and wadr1 = "0001") or (wen2 = '1' and wadr2 = "0001")) then
						r1v <= '1';
					else
						r1v <= '0';
					end if;
				else
					r1v <= '0';
				end if;
			end if;

			-- Valid bit reg2
			if (r2v = '1') then
				if ((inval1 ='1' and inval_adr1 = "0010") or (inval2 ='1' and inval_adr2 = "0010")) then
					r2v <= '0';
				else 
					r2v <= '1';
				end if;
			else
				if ((not(inval1 ='1' and inval_adr1 = "0010") or (inval2 ='1' and inval_adr2 = "0010"))) then
					if ((wen1 = '1' and wadr1 = "0010") or (wen2 = '1' and wadr2 = "0010")) then
						r2v <= '1';
					else
						r2v <= '0';
					end if;
				else
					r2v <= '0';
				end if;
			end if;
			
			-- Valid bit reg3
			if (r3v = '1') then
				if ((inval1 ='1' and inval_adr1 = "0011") or (inval2 ='1' and inval_adr2 = "0011")) then
					r3v <= '0';
				else 
					r3v <= '1';
				end if;
			else
				if ((not(inval1 ='1' and inval_adr1 = "0011") or (inval2 ='1' and inval_adr2 = "0011"))) then
					if ((wen1 = '1' and wadr1 = "0011") or (wen2 = '1' and wadr2 = "0011")) then
						r3v <= '1';
					else
						r3v <= '0';
					end if;
				else
					r3v <= '0';
				end if;
			end if;

			-- Valid bit reg4
			if (r4v = '1') then
				if ((inval1 ='1' and inval_adr1 = "0100") or (inval2 ='1' and inval_adr2 = "0100")) then
					r4v <= '0';
				else 
					r4v <= '1';
				end if;
			else
				if ((not(inval1 ='1' and inval_adr1 = "0100") or (inval2 ='1' and inval_adr2 = "0100"))) then
					if ((wen1 = '1' and wadr1 = "0100") or (wen2 = '1' and wadr2 = "0100")) then
						r4v <= '1';
					else
						r4v <= '0';
					end if;
				else
					r4v <= '0';
				end if;
			end if;

			-- Valid bit reg5
			if (r5v = '1') then
				if ((inval1 ='1' and inval_adr1 = "0101") or (inval2 ='1' and inval_adr2 = "0101")) then
					r5v <= '0';
				else 
					r5v <= '1';
				end if;
			else
				if ((not(inval1 ='1' and inval_adr1 = "0101") or (inval2 ='1' and inval_adr2 = "0101"))) then
					if ((wen1 = '1' and wadr1 = "0101") or (wen2 = '1' and wadr2 = "0101")) then
						r5v <= '1';
					else
						r5v <= '0';
					end if;
				else
					r5v <= '0';
				end if;
			end if;

			-- Valid bit reg6
			if (r6v = '1') then
				if ((inval1 ='1' and inval_adr1 = "0110") or (inval2 ='1' and inval_adr2 = "0110")) then
					r6v <= '0';
				else 
					r6v <= '1';
				end if;
			else
				if ((not(inval1 ='1' and inval_adr1 = "0110") or (inval2 ='1' and inval_adr2 = "0110"))) then
					if ((wen1 = '1' and wadr1 = "0110") or (wen2 = '1' and wadr2 = "0110")) then
						r6v <= '1';
					else
						r6v <= '0';
					end if;
				else
					r6v <= '0';
				end if;
			end if;

			-- Valid bit reg7
			if (r7v = '1') then
				if ((inval1 ='1' and inval_adr1 = "0111") or (inval2 ='1' and inval_adr2 = "0111")) then
					r7v <= '0';
				else 
					r7v <= '1';
				end if;
			else
				if ((not(inval1 ='1' and inval_adr1 = "0111") or (inval2 ='1' and inval_adr2 = "0111"))) then
					if ((wen1 = '1' and wadr1 = "0111") or (wen2 = '1' and wadr2 = "0111")) then
						r7v <= '1';
					else
						r7v <= '0';
					end if;
				else
					r7v <= '0';
				end if;
			end if;

			-- Valid bit reg8
			if (r8v = '1') then
				if ((inval1 ='1' and inval_adr1 = "1000") or (inval2 ='1' and inval_adr2 = "1000")) then
					r8v <= '0';
				else 
					r8v <= '1';
				end if;
			else
				if ((not(inval1 ='1' and inval_adr1 = "1000") or (inval2 ='1' and inval_adr2 = "1000"))) then
					if ((wen1 = '1' and wadr1 = "1000") or (wen2 = '1' and wadr2 = "1000")) then
						r8v <= '1';
					else
						r8v <= '0';
					end if;
				else
					r8v <= '0';
				end if;
			end if;

			-- Valid bit reg9
			if (r9v = '1') then
				if ((inval1 ='1' and inval_adr1 = "1001") or (inval2 ='1' and inval_adr2 = "1001")) then
					r9v <= '0';
				else 
					r9v <= '1';
				end if;
			else
				if ((not(inval1 ='1' and inval_adr1 = "1001") or (inval2 ='1' and inval_adr2 = "1001"))) then
					if ((wen1 = '1' and wadr1 = "1001") or (wen2 = '1' and wadr2 = "1001")) then
						r9v <= '1';
					else
						r9v <= '0';
					end if;
				else
					r9v <= '0';
				end if;
			end if;

			-- Valid bit reg10
			if (r10v = '1') then
				if ((inval1 ='1' and inval_adr1 = "1010") or (inval2 ='1' and inval_adr2 = "1010")) then
					r10v <= '0';
				else 
					r10v <= '1';
				end if;
			else
				if ((not(inval1 ='1' and inval_adr1 = "1010") or (inval2 ='1' and inval_adr2 = "1010"))) then
					if ((wen1 = '1' and wadr1 = "1010") or (wen2 = '1' and wadr2 = "1010")) then
						r10v <= '1';
					else
						r10v <= '0';
					end if;
				else
					r10v <= '0';
				end if;
			end if;

			-- Valid bit reg11
			if (r11v = '1') then
				if ((inval1 ='1' and inval_adr1 = "1011") or (inval2 ='1' and inval_adr2 = "1011")) then
					r11v <= '0';
				else 
					r11v <= '1';
				end if;
			else
				if ((not(inval1 ='1' and inval_adr1 = "1011") or (inval2 ='1' and inval_adr2 = "1011"))) then
					if ((wen1 = '1' and wadr1 = "1011") or (wen2 = '1' and wadr2 = "1011")) then
						r11v <= '1';
					else
						r11v <= '0';
					end if;
				else
					r11v <= '0';
				end if;
			end if;

			-- Valid bit reg12
			if (r12v = '1') then
				if ((inval1 ='1' and inval_adr1 = "1100") or (inval2 ='1' and inval_adr2 = "1100")) then
					r12v <= '0';
				else 
					r12v <= '1';
				end if;
			else
				if ((not(inval1 ='1' and inval_adr1 = "1100") or (inval2 ='1' and inval_adr2 = "1100"))) then
					if ((wen1 = '1' and wadr1 = "1100") or (wen2 = '1' and wadr2 = "1100")) then
						r12v <= '1';
					else
						r12v <= '0';
					end if;
				else
					r12v <= '0';
				end if;
			end if;
		
			-- Valid bit reg13
			if (r13v = '1') then
				if ((inval1 ='1' and inval_adr1 = "1101") or (inval2 ='1' and inval_adr2 = "1101")) then
					r13v <= '0';
				else 
					r13v <= '1';
				end if;
			else
				if ((not(inval1 ='1' and inval_adr1 = "1101") or (inval2 ='1' and inval_adr2 = "1101"))) then
					if ((wen1 = '1' and wadr1 = "1101") or (wen2 = '1' and wadr2 = "1101")) then
						r13v <= '1';
					else
						r13v <= '0';
					end if;
				else
					r13v <= '0';
				end if;
			end if;

			-- Valid bit reg14
			if (r14v = '1') then
				if ((inval1 ='1' and inval_adr1 = "1110") or (inval2 ='1' and inval_adr2 = "1110")) then
					r14v <= '0';
				else 
					r14v <= '1';
				end if;
			else
				if ((not(inval1 ='1' and inval_adr1 = "1110") or (inval2 ='1' and inval_adr2 = "1110"))) then
					if ((wen1 = '1' and wadr1 = "1110") or (wen2 = '1' and wadr2 = "1110")) then
						r14v <= '1';
					else
						r14v <= '0';
					end if;
				else
					r14v <= '0';
				end if;
			end if;

			-- Valid bit pc
			if (pcv = '1') then
				if ((inval1 ='1' and inval_adr1 = "1111") or (inval2 ='1' and inval_adr2 = "1111")) then
					pcv <= '0';
				else 
					pcv <= '1';
				end if;
			else
				if ((not(inval1 ='1' and inval_adr1 = "1111") or (inval2 ='1' and inval_adr2 = "1111"))) then
					if ((wen1 = '1' and wadr1 = "1111") or (wen2 = '1' and wadr2 = "1111")) then
						pcv <= '1';
					else
						pcv <= '0';
					end if;
				else
					pcv <= '0';
				end if;
			end if;
		end if;
			

			-- Data czn
		if (cznv = '0') then
			if (cspr_wb = '1') then
					c <= wcry;
					z <= wzero;
					n <= wneg;
			end if;
		else
			c <= c;
			z <= z;
			n <= n;
		end if;

			-- Data ovr
		if (vv = '0') then
			if (cspr_wb = '1') then
					o <= wovr;	
			end if;
		else
			o <= o;
		end if;

			-- Data r0
		if ((r0v ='0') and (wen1 = '1' and wadr1 = "0000")) then
					r0 <= wdata1;

		elsif ((r0v ='0')and (wen2 = '1' and wadr2 = "0000")) then		
					r0 <= wdata2;
		else
			r0 <= r0;
		end if;

			-- Data r1
		if ((r1v ='0') and (wen1 = '1' and wadr1 = "0001")) then
					r1 <= wdata1;
			
		elsif ((r1v ='0')and (wen2 = '1' and wadr2 = "0001")) then		
					r1 <= wdata2;
		else
			r1 <= r1;
		end if;

			-- Data r2
		if ((r2v ='0') and (wen1 = '1' and wadr1 = "0010")) then
					r2 <= wdata1;
			
		elsif ((r2v ='0')and (wen2 = '1' and wadr2 = "0010")) then		
					r2 <= wdata2;
		else
			r2 <= r2;
		end if;

			-- Data r3
		if ((r3v ='0') and (wen1 = '1' and wadr1 = "0011")) then
					r3 <= wdata1;
			
		elsif ((r3v ='0')and (wen2 = '1' and wadr2 = "0011")) then		
					r3 <= wdata2;
		else
			r3 <= r3;
		end if;

			-- Data r4
		if ((r4v ='0') and (wen1 = '1' and wadr1 = "0100")) then
					r4 <= wdata1;
			
		elsif ((r4v ='0')and (wen2 = '1' and wadr2 = "0100")) then		
					r4 <= wdata2;
		else
			r4 <= r4;
		end if;

			-- Data r5
		if ((r5v ='0') and (wen1 = '1' and wadr1 = "0101")) then
					r5 <= wdata1;
			
		elsif ((r5v ='0')and (wen2 = '1' and wadr2 = "0101")) then		
					r5 <= wdata2;
		else
			r5 <= r5;
		end if;

			-- Data r6
		if ((r6v ='0') and (wen1 = '1' and wadr1 = "0110")) then
					r6 <= wdata1;
			
		elsif ((r6v ='0')and (wen2 = '1' and wadr2 = "0110")) then		
					r6 <= wdata2;
		else
			r6 <= r6;
		end if;

			-- Data r7
		if ((r7v ='0') and (wen1 = '1' and wadr1 = "0111")) then
					r7 <= wdata1;
			
		elsif ((r7v ='0')and (wen2 = '1' and wadr2 = "0111")) then		
					r7 <= wdata2;
		else
			r7 <= r7;
		end if;

			-- Data r8
		if ((r8v ='0') and (wen1 = '1' and wadr1 = "1000")) then
					r8 <= wdata1;
			
		elsif ((r8v ='0')and (wen2 = '1' and wadr2 = "1000")) then		
					r8 <= wdata2;
		else
			r8 <= r8;
		end if;

			-- Data r9
		if ((r9v ='0') and (wen1 = '1' and wadr1 = "1001")) then
					r9 <= wdata1;
			
		elsif ((r9v ='0')and (wen2 = '1' and wadr2 = "1001")) then		
					r9 <= wdata2;
		else
			r9 <= r9;
		end if;

			-- Data r10
		if ((r10v ='0') and (wen1 = '1' and wadr1 = "1010")) then
					r10 <= wdata1;
			
		elsif ((r10v ='0')and (wen2 = '1' and wadr2 = "1010")) then		
					r10 <= wdata2;
		else
			r10 <= r10;
		end if;

			-- Data r11
		if ((r11v ='0') and (wen1 = '1' and wadr1 = "1011")) then
					r11 <= wdata1;
			
		elsif ((r11v ='0')and (wen2 = '1' and wadr2 = "1011")) then		
					r11 <= wdata2;
		else
			r11 <= r11;
		end if;

			-- Data r12
		if ((r12v ='0') and (wen1 = '1' and wadr1 = "1100")) then
					r12 <= wdata1;
			
		elsif ((r12v ='0')and (wen2 = '1' and wadr2 = "1100")) then		
					r12 <= wdata2;
		else
			r12 <= r12;
		end if;

			-- Data r13
		if ((r13v ='0') and (wen1 = '1' and wadr1 = "1101")) then
					r13 <= wdata1;
			
		elsif ((r13v ='0')and (wen2 = '1' and wadr2 = "1101")) then		
					r13 <= wdata2;
		else
			r13 <= r13;
		end if;

			-- Data r14
		if ((r14v ='0') and (wen1 = '1' and wadr1 = "1110")) then
					r14 <= wdata1;
			
		elsif ((r14v ='0')and (wen2 = '1' and wadr2 = "1110")) then		
					r14 <= wdata2;
		else
			r14 <= r14;
		end if;

			-- Data pc
		if (reset_n = '0') then
					pc <= x"00000000";	

		elsif ((pcv ='0') and (wen1 = '1' and wadr1 = "1111")) then
					pc <= wdata1;
			
		elsif ((pcv ='0') and (wen2 = '1' and wadr2 = "1111")) then		
					pc <= wdata2;

		elsif ((pcv ='1') and (inc_pc = '1')) then
					pc <= std_logic_vector (unsigned(pc) + 4);
		else
			pc <= pc;
		end if;
	end if;	
end process;

end Behavior;

