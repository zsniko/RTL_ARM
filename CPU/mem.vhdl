library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Mem is
	port(
	-- Exe interface
			exe2mem_empty	: in Std_logic;
			mem_pop			: out Std_logic;
			exe_mem_adr		: in Std_Logic_Vector(31 downto 0);
			exe_mem_data	: in Std_Logic_Vector(31 downto 0);
			exe_mem_dest	: in Std_Logic_Vector(3 downto 0);

			exe_mem_lw		: in Std_Logic;
			exe_mem_lb		: in Std_Logic;
			exe_mem_sw		: in Std_Logic;
			exe_mem_sb		: in Std_Logic;

	-- Mem WB
			mem_res			: out Std_Logic_Vector(31 downto 0);
			mem_dest			: out Std_Logic_Vector(3 downto 0);
			mem_wb			: out Std_Logic;
			
	-- Dcache interface
			mem_adr			: out Std_Logic_Vector(31 downto 0);
			mem_stw			: out Std_Logic;
			mem_stb			: out Std_Logic;
			mem_load			: out Std_Logic;

			mem_data			: out Std_Logic_Vector(31 downto 0);
			dc_data			: in Std_Logic_Vector(31 downto 0);
			dc_stall			: in Std_Logic;

	-- global interface
			vdd				: in bit;
			vss				: in bit);
end Mem;

----------------------------------------------------------------------

architecture Behavior OF Mem is

signal lb_data : Std_Logic_Vector(31 downto 0);

begin

	with exe_mem_adr(1 downto 0) select
		lb_data <=	X"000000" & dc_data(31 downto 24)	when "11",
						X"000000" & dc_data(23 downto 16)	when "10",
						X"000000" & dc_data(15 downto 8)		when "01",
						X"000000" & dc_data(7 downto 0)		when others;

	mem_res	<= lb_data when exe_mem_lb  = '1' else dc_data;
	mem_dest	<= exe_mem_dest;
	mem_wb <= '1' when (exe_mem_lw = '1' or exe_mem_lb = '1') and
								exe2mem_empty = '0' and dc_stall = '0' else '0';
			
	mem_adr <=	exe_mem_adr(31 downto 2) & "00" when exe_mem_lw = '1' or exe_mem_lb = '1' else
					exe_mem_adr;

	mem_stw <= '1' when exe_mem_sw = '1' and exe2mem_empty = '0' else '0';
	mem_stb <= '1' when exe_mem_sb = '1' and exe2mem_empty = '0' else '0';
	mem_load <= '1' when (exe_mem_lw = '1' or exe_mem_lb = '1') and
								exe2mem_empty = '0' else '0';

	mem_data <= exe_mem_data;

	mem_pop <= '1' when exe2mem_empty = '0' and dc_stall = '0' else '0';
end Behavior;
