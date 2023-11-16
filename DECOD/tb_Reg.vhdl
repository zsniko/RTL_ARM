LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.math_real.all;

ENTITY tb_Reg IS
END tb_Reg;

ARCHITECTURE simu of tb_Reg IS 
COMPONENT Reg
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
END COMPONENT;

-- Write Port 1 prioritaire
signal wdata1		: Std_Logic_Vector(31 downto 0);
signal wadr1		: Std_Logic_Vector(3 downto 0);
signal wen1			: Std_Logic;
-- Write Port 2 non prioritaire
signal wdata2		: Std_Logic_Vector(31 downto 0);
signal wadr2		: Std_Logic_Vector(3 downto 0);
signal wen2			: Std_Logic;
-- Write CSPR Port
signal wcry			: Std_Logic;
signal wzero		: Std_Logic;
signal wneg			: Std_Logic;
signal wovr			: Std_Logic;
signal cspr_wb		: Std_Logic;
-- Read Port 1 32 bits
signal reg_rd1		: Std_Logic_Vector(31 downto 0);
signal radr1		: Std_Logic_Vector(3 downto 0) := "0000"; -- to avoid to_integer warning at metavalue 'U'
signal reg_v1		: Std_Logic;
-- Read Port 2 32 bits
signal reg_rd2		: Std_Logic_Vector(31 downto 0);
signal radr2		: Std_Logic_Vector(3 downto 0) := "0000";
signal reg_v2		: Std_Logic;
-- Read Port 3 32 bits
signal reg_rd3		: Std_Logic_Vector(31 downto 0);
signal radr3		: Std_Logic_Vector(3 downto 0) := "0000"; 
signal reg_v3		: Std_Logic;
-- read CSPR Port
signal reg_cry		: Std_Logic;
signal reg_zero	    : Std_Logic;
signal reg_neg		: Std_Logic;
signal reg_cznv	    : Std_Logic;
signal reg_ovr		: Std_Logic;
signal reg_vv		: Std_Logic;
-- Invalidate Port
signal inval_adr1	: Std_Logic_Vector(3 downto 0) := "0000";
signal inval1		: Std_Logic := '0';
signal inval_adr2	: Std_Logic_Vector(3 downto 0) := "0000";
signal inval2		: Std_Logic := '0';
signal inval_czn	: Std_Logic := '0';
signal inval_ovr	: Std_Logic := '0';
-- PC
signal reg_pc		: Std_Logic_Vector(31 downto 0) := x"00000000";
signal reg_pcv		: Std_Logic;
signal inc_pc		: Std_Logic := '0';
-- global interface
signal ck			: Std_Logic;
signal reset_n		: Std_Logic := '0';
signal vdd			: bit;
signal vss			: bit;


BEGIN 
 Reg_sim: Reg PORT MAP(
    -- Write Port 1 prioritaire
        wdata1		=> wdata1,
        wadr1		=> wadr1,
        wen1		=> wen1,
    -- Write Port 2 non prioritaire
        wdata2		=> wdata2,
        wadr2		=> wadr2,
        wen2		=> wen2,
    -- Write CSPR Port
        wcry		=> wcry,
        wzero		=> wzero,
        wneg		=> wneg,
        wovr		=> wovr,
        cspr_wb		=> cspr_wb,
    -- Read Port 1 32 bits
        reg_rd1		=> reg_rd1,
        radr1		=> radr1,
        reg_v1		=> reg_v1,
    -- Read Port 2 32 bits
        reg_rd2		=> reg_rd2,
        radr2		=> radr2,
        reg_v2		=> reg_v2,
    -- Read Port 3 32 bits
        reg_rd3		=> reg_rd3,
        radr3		=> radr3,
        reg_v3		=> reg_v3,
    -- read CSPR Port
        reg_cry		=> reg_cry,
        reg_zero	=> reg_zero,
        reg_neg		=> reg_neg,
        reg_cznv	=> reg_cznv,
        reg_ovr		=> reg_ovr,
        reg_vv		=> reg_vv,
    -- Invalidate Port
        inval_adr1	=> inval_adr1,
        inval1		=> inval1,
        inval_adr2	=> inval_adr2,
        inval2		=> inval2,
        inval_czn	=> inval_czn,
        inval_ovr	=> inval_ovr,
    -- PC   
        reg_pc		=> reg_pc,
        reg_pcv		=> reg_pcv,
        inc_pc		=> inc_pc,
    -- global interface 
        ck			=> ck,
        reset_n		=> reset_n,
        vdd			=> vdd,
        vss			=> vss
    );

    -- Clock generation
    clk_p: process
    begin
            ck <= '0';
            wait for 10 ns;
            ck <= '1';
            wait for 10 ns;
    end process;

    -- Reset generation
    reset_p: process
    begin
            reset_n <= '0';
            wait for 20 ns;
            reset_n <= '1';
            wait;
    end process;
        
    -- Stimulus process
    stimu_p: process(ck)
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

                    wdata1 <= rand_slv(32);
                    wadr1 <= rand_slv(4);
                    wen1 <= rand_slv(1)(0);

                    wdata2 <= x"00000000";
                    wadr2 <= "0000";
                    wen2 <= '0';

                    radr1 <= wadr1;
                    radr2 <= "0000";
                    radr3 <= "0000";

                    
                    inval1 <= '1';
                    --inval1 <= rand_slv(1)(0);
                    inval2 <= '0';
                    inval_czn <= '0';
                    inval_ovr <= '0';
                    
                    wcry <= '0';
                    wzero <= '0';
                    wneg <= '0';
                    wovr <= '0';
                    cspr_wb <= '0';
                    
                    
                    -- wdata1 <= rand_slv(32);
                    -- wadr1 <= rand_slv(4);
                    -- wen1 <= rand_slv(1)(0);

                    -- wdata2 <= rand_slv(32);
                    -- wadr2 <= rand_slv(4);
                    -- wen2 <= rand_slv(1)(0);

                    -- radr1 <= wadr1;
                    -- radr2 <= wadr2;
                    -- radr3 <= rand_slv(4);

                    -- inval_adr1 <= rand_slv(4);
		            -- inval_adr2 <= rand_slv(4);

                    -- inval1 <= rand_slv(1)(0);
                    -- inval2 <= rand_slv(1)(0);
                    -- inval_czn <= rand_slv(1)(0);
                    -- inval_ovr <= rand_slv(1)(0);
                    
                    -- wcry <= rand_slv(1)(0);
                    -- wzero <= rand_slv(1)(0);
                    -- wneg <= rand_slv(1)(0);
                    -- wovr <= rand_slv(1)(0);
                    -- cspr_wb <= rand_slv(1)(0);

                    inc_pc <= '1' ;
                        
                end if;
                
        end process;
        inval_adr1 <= wadr1;
		inval_adr2 <= "0000";


END simu;
