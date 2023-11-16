LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Reg IS
	PORT(
	-- Write Port 1 prioritaire
		wdata1		: in Std_Logic_Vector(31 downto 0); 
		wadr1		: in Std_Logic_Vector(3 downto 0); 
		wen1		: in Std_Logic; -- write enable, write when set to '1'

	-- Write Port 2 non prioritaire
		wdata2		: in Std_Logic_Vector(31 downto 0);
		wadr2		: in Std_Logic_Vector(3 downto 0);
		wen2		: in Std_Logic; -- write enable, write when set to '1'

	-- Write CSPR Port
		wcry		: in Std_Logic; -- write carry
		wzero		: in Std_Logic; -- flag zero
		wneg		: in Std_Logic; -- flag negative
		wovr		: in Std_Logic; -- flag overflow
		cspr_wb		: in Std_Logic; -- write CSPR when set to '1'
		
	-- Read Port 1 32 bits
		reg_rd1		: out Std_Logic_Vector(31 downto 0); 
		radr1		: in Std_Logic_Vector(3 downto 0);
		reg_v1		: out Std_Logic; -- valid bit for the read register

	-- Read Port 2 32 bits
		reg_rd2		: out Std_Logic_Vector(31 downto 0);
		radr2		: in Std_Logic_Vector(3 downto 0);
		reg_v2		: out Std_Logic;

	-- Read Port 3 32 bits
		reg_rd3		: out Std_Logic_Vector(31 downto 0);
		radr3		: in Std_Logic_Vector(3 downto 0);
		reg_v3		: out Std_Logic;

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

		inval_czn	: in Std_Logic; -- Common invalidity bit for flags C,Z,N
		inval_ovr	: in Std_Logic;	-- Invalidity bit for flag V

	-- PC
		reg_pc		: out Std_Logic_Vector(31 downto 0);
		reg_pcv		: out Std_Logic; -- valid bit 
		inc_pc		: in Std_Logic;  -- increment PC when set to '1', otherwise offset of jump instruction
	
	-- global interface
		ck			: in Std_Logic;
		reset_n		: in Std_Logic;
		vdd			: in bit;
		vss			: in bit);
END;

ARCHITECTURE Behavior OF Reg IS
	COMPONENT add_32b
		PORT (
			A: 		in Std_Logic_Vector(31 downto 0);
			B: 		in Std_Logic_Vector(31 downto 0);
			Cin: 	in Std_Logic;
			S: 		out Std_Logic_Vector(31 downto 0);
			Cout: 	out Std_Logic
		);
	END COMPONENT;

	-- Register Bank (r0-r15) data 
	type data_array is array (0 to 15) of Std_Logic_Vector(31 downto 0);
	signal r_data : data_array :=(others => (others=>'0')); -- register data r0-r15, accessible as r_data(i)
 	-- Register Bank (r0-r15) Valid bit
	type valid_array is array (0 to 15) of Std_Logic;
	signal r_valid : valid_array; -- register valid bit r0-r15
	-- PC
	signal PCinc4 : Std_Logic_Vector(31 downto 0); -- PC + 4
	-- 2 Validity bits for 4 flags 
	signal cznv_valid: Std_Logic;
	signal v_valid: Std_Logic;


BEGIN 
	incPC: add_32b
		PORT MAP(
			A => r_data(15),
			B => x"00000004",
			Cin => '0',
			S => PCinc4,
			Cout => open
		);
    
    -- Write to register
	gen: for i in 0 to 15 generate
		begin
			process(ck)
            variable validity : Std_Logic; -- immediate update
			begin 
				if rising_edge(ck) then 
                    validity := r_valid(i); -- Init
					if reset_n = '0' then 
						r_data(i) <= (others => '0');
						r_valid(i) <= '1'; 
					else
						if (inval_adr1 = std_logic_vector(to_unsigned(i, 4)) and inval1 = '1') or 
							(inval_adr2 = std_logic_vector(to_unsigned(i, 4)) and inval2 = '1') then
							r_valid(i) <= '0';
                            validity := '0';
						end if; 
						
						if wen1 = '1' and wadr1 = std_logic_vector(to_unsigned(i, 4)) and validity ='0' then
								r_data(i) <= wdata1;
								r_valid(i) <= '1';
						elsif wen2 = '1' and wadr2 = std_logic_vector(to_unsigned(i, 4)) and validity ='0'  then
								r_data(i) <= wdata2;
								r_valid(i) <= '1';
						end if;

                        if inc_pc = '1' and i=15 then 
                            r_data(i) <= PCinc4;
                        end if ;

					end if;
				end if;
			end process;
		end generate gen;


	process(ck)
	
	begin 
		if rising_edge(ck) then 
			
			if reset_n = '0' then 
				reg_cry <= '0';
				reg_zero <= '0';
				reg_neg <= '0';
				reg_ovr <= '0';
				cznv_valid <= '1';
				v_valid <= '1';
			else
				-- CDPR
				if inval_czn = '1' then
					cznv_valid <= '0';
					if cznv_valid = '0' and cspr_wb = '1' then
						reg_cry <= wcry;
						reg_zero <= wzero;
						reg_neg <= wneg;	
					end if;
				else 
					if cznv_valid = '0' and cspr_wb = '1' then
						cznv_valid <= '1';
						reg_cry <= wcry;
						reg_zero <= wzero;
						reg_neg <= wneg;		
					end if;	
				end if;
			    -- overflow
				if inval_ovr = '1' then
					v_valid <= '0';
					if v_valid = '0'and cspr_wb = '1' then
						reg_ovr <= wovr;
					end if;
				else
					if v_valid = '0'and cspr_wb = '1' then
						v_valid <= '1';
						reg_ovr <= wovr;
					end if;
				end if;

			end if;
		end if;

	end process;

	-- Read data from register
	reg_rd1 <= r_data(to_integer(unsigned(radr1)));
	reg_rd2 <= r_data(to_integer(unsigned(radr2)));
	reg_rd3 <= r_data(to_integer(unsigned(radr3)));
	reg_v1 <= r_valid(to_integer(unsigned(radr1)));
	reg_v2 <= r_valid(to_integer(unsigned(radr2)));
	reg_v3 <= r_valid(to_integer(unsigned(radr3)));


	-- PC Register
	reg_pc <= r_data(15);
	reg_pcv <= r_valid(15);

	-- Flags
	reg_cznv <= cznv_valid;
	reg_vv <= v_valid;


	

END Behavior;