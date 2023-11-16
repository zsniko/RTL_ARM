library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library work;
use work.all;
use work.ram.all;


--  A testbench has no ports.
entity main_tb is
end main_tb;

architecture behav of main_tb is
	
	component icache
	port(
	-- Icache interface
			if_adr			: in Std_Logic_vector(31 downto 0) ;
			if_adr_valid	: in Std_Logic;

			ic_inst			: out Std_Logic_vector(31 downto 0) ;
			ic_stall			: out Std_Logic);
	end component;

	component dcache
	port(
	-- Dcache outterface
			mem_adr			: in Std_Logic_Vector(31 downto 0);
			mem_stw			: in Std_Logic;
			mem_stb			: in Std_Logic;
			mem_load			: in Std_Logic;

			mem_data			: in Std_Logic_Vector(31 downto 0);
			dc_data			: out Std_Logic_Vector(31 downto 0);
			dc_stall			: out Std_Logic;

			ck					: in Std_logic);
	end component;

	component arm_core
	port(
	-- Icache interface
			if_adr			: out Std_Logic_Vector(31 downto 0) ;
			if_adr_valid	: out Std_Logic;

			ic_inst			: in Std_Logic_Vector(31 downto 0) ;
			ic_stall			: in Std_Logic;

	-- Dcache interface
			mem_adr			: out Std_Logic_Vector(31 downto 0);
			mem_stw			: out Std_Logic;
			mem_stb			: out Std_Logic;
			mem_load			: out Std_Logic;

			mem_data			: out Std_Logic_Vector(31 downto 0);
			dc_data			: in Std_Logic_Vector(31 downto 0);
			dc_stall			: in Std_Logic;


	-- global interface
			ck					: in Std_Logic;
			reset_n			: in Std_Logic;
			vdd				: in bit;
			vss				: in bit);
	end component;

	signal	if_adr			: Std_Logic_Vector(31 downto 0) ;
	signal	if_adr_valid	: Std_Logic;

	signal	ic_inst			: Std_Logic_Vector(31 downto 0) ;
	signal	ic_stall			: Std_Logic;
   
	signal	mem_adr			: Std_Logic_Vector(31 downto 0);
	signal	mem_stw			: Std_Logic;
	signal	mem_stb			: Std_Logic;
	signal	mem_load			: Std_Logic;

	signal	mem_data			: Std_Logic_Vector(31 downto 0);
	signal	dc_data			: Std_Logic_Vector(31 downto 0);
	signal	dc_stall			: Std_Logic;

	signal	ck					: Std_Logic;
	signal	reset_n			: Std_Logic;
	signal	vdd				: bit := '1';
	signal	vss				: bit := '0';

	signal	GoodAdr			: Std_Logic_Vector(31 downto 0) ;
	signal	BadAdr			: Std_Logic_Vector(31 downto 0) ;

	begin
	--  Component instantiation.

	icache_i : icache
	port map (	if_adr			=> if_adr,
					if_adr_valid	=> if_adr_valid,
					ic_inst			=> ic_inst,
					ic_stall			=> ic_stall);

	dcache_i : dcache
	port map (	mem_adr	=> mem_adr,
					mem_stw	=> mem_stw,
					mem_stb	=> mem_stb,
					mem_load	=> mem_load,

					mem_data	=> mem_data,
					dc_data	=> dc_data,
					dc_stall	=> dc_stall,

					ck			=> ck);

	arm_core_i : arm_core
	port map (

			if_adr			=> if_adr,
			if_adr_valid	=> if_adr_valid,

			ic_inst			=> ic_inst,
			ic_stall			=> ic_stall,

			mem_adr			=> mem_adr,
			mem_stw			=> mem_stw,
			mem_stb			=> mem_stb,
			mem_load			=> mem_load,

			mem_data			=> mem_data,
			dc_data			=> dc_data,
			dc_stall			=> dc_stall,

			ck					=> ck,
			reset_n			=> reset_n,
			vdd				=> vdd,
			vss				=> vss);

   -- Test ADR GOOD or BAD

--process(if_adr, if_adr_valid)
--begin
--	if if_adr_valid = '1' then
--		 assert if_adr /= GoodAdr report "GOOD!!!" severity failure;
--		 assert if_adr /= BadAdr report "BAD!!!" severity failure;
--	end if;
--end process;
	
	--  This process does the real job.
process

begin

	GoodAdr <= std_logic_vector(TO_SIGNED(mem_goodadr + 4, 32));
	BadAdr <= std_logic_vector(TO_SIGNED(mem_badadr + 4, 32));

	reset_n <= '0';
	ck <= '0';
	wait for 1 ns;
	ck <= '1';
	wait for 1 ns;
	reset_n <= '1';

	while not (if_adr_valid = '1' and (if_adr = GoodAdr or if_adr = BadAdr)) loop
		ck <= '0';
		wait for 1 ns;
		ck <= '1';
		wait for 1 ns;
	end loop;

	assert if_adr /= GoodAdr report "GOOD!!!" severity note;
	assert if_adr /= BadAdr report "BAD!!!" severity note;
	assert false report "end of test" severity note;

wait;
end process;
end behav;
