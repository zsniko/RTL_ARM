library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ram.all;

entity Dcache is
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

end Dcache;

----------------------------------------------------------------------

architecture Behavior OF Dcache is

begin

-- Gestion du PC

process (mem_adr, mem_load)

variable adr : signed(31 downto 0);
variable data : signed(31 downto 0);

begin
	if (mem_load = '1') then
		adr := signed(mem_adr);
		data := TO_SIGNED(mem_lw(TO_INTEGER(adr)), 32);
		dc_data <= std_logic_vector(data);
	end if;
end process;


process (ck)

variable adr : signed(31 downto 0);
variable data : signed(31 downto 0);
variable res : integer;

begin
	if rising_edge(ck) then
		adr := signed(mem_adr);
		data := signed(mem_data);
		if	mem_stw = '1' then
			res := mem_sw(TO_INTEGER(adr), TO_INTEGER(data));
		elsif mem_stb='1' then
			res := mem_sb(TO_INTEGER(adr), TO_INTEGER(data));
		end if;
	end if;
end process;

dc_stall <= '0';

end Behavior;
