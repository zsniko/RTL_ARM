package mem is

	function mem_lw (adr : integer) return integer;
	attribute foreign of mem_lw : function is "VHPIDIRECT mem_lw";

	procedure mem_sw (variable adr : in integer; variable data : in integer);
	attribute foreign of mem_sw : procedure is "VHPIDIRECT mem_sw";

	procedure mem_sb (variable adr : in integer; variable data : in integer);
	attribute foreign of mem_sb : procedure is "VHPIDIRECT mem_sb";

	function mem_goodadr return integer;
	attribute foreign of mem_goodadr : function is "VHPIDIRECT mem_goodadr";

	function mem_badadr return integer;
	attribute foreign of mem_badadr : function is "VHPIDIRECT mem_badadr";

end mem;

package body mem is
	function mem_lw (adr : integer) return integer is
	begin
		assert false severity failure;
	end mem_lw;

	procedure mem_sw (variable adr : in integer; variable data : in integer) is
	begin
		assert false severity failure;
	end mem_sw;

	procedure mem_sb (variable adr : in integer; variable data : in integer) is
	begin
		assert false severity failure;
	end mem_sb;

	function mem_goodadr return integer is
	begin
		assert false severity failure;
	end mem_goodadr;

	function mem_badadr return integer is
	begin
		assert false severity failure;
	end mem_badadr;
end mem;
