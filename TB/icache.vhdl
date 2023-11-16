library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ram.all;

entity Icache is
	port(
	-- Icache interface
			if_adr			: in Std_Logic_vector(31 downto 0) ;
			if_adr_valid	: in Std_Logic;

			ic_inst			: out Std_Logic_vector(31 downto 0) ;
			ic_stall			: out Std_Logic);
end Icache;

----------------------------------------------------------------------

architecture Behavior OF Icache is

begin

-- Gestion du PC

process (if_adr, if_adr_valid)

variable adr : signed(31 downto 0);
variable inst : signed(31 downto 0);

begin
	if (if_adr_valid = '1') then
		adr := signed(if_adr);
		inst := TO_SIGNED(mem_lw(TO_INTEGER(adr)), 32);
		ic_inst <= std_logic_vector(inst);
	end if;
end process;

ic_stall <= '0';

end Behavior;
