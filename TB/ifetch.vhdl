library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IFetch is
	port(
	-- Icache interface
			if_adr			: out Std_Logic_Vector(31 downto 0) ;
			if_adr_valid	: out Std_Logic;

			ic_inst			: in Std_Logic_Vector(31 downto 0) ;
			ic_stall			: in Std_Logic;

	-- Decode interface
			dec2if_empty	: in Std_Logic;
			if_pop			: out Std_Logic;
			dec_pc			: in Std_Logic_Vector(31 downto 0) ;

			if_ir				: out Std_Logic_Vector(31 downto 0) ;
			if2dec_empty	: out Std_Logic;
			dec_pop			: in Std_Logic;

	-- global interface
			ck					: in Std_Logic;
			reset_n			: in Std_Logic;
			vdd				: in bit;
			vss				: in bit);
end IFetch;

----------------------------------------------------------------------

architecture Behavior OF IFetch is

component fifo_32b
	port(
		din		: in std_logic_vector(31 downto 0);
		dout		: out std_logic_vector(31 downto 0);

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

signal if2dec_push	: std_logic;
signal if2dec_full	: std_logic;

begin

	if2dec : fifo_32b
	port map (	din		=> ic_inst,
					dout		=> if_ir,

					push		 => if2dec_push,
					pop		 => dec_pop,

					empty		 => if2dec_empty,
					full		 => if2dec_full,

					reset_n	 => reset_n,
					ck			 => ck,
					vdd		 => vdd,
					vss		 => vss);


	if_adr_valid <= '1' when dec2if_empty = '0' else '0';
	if_pop <= '1' when dec2if_empty = '0' and ic_stall = '0' and if2dec_full = '0' else '0';
	if2dec_push <= '1' when dec2if_empty = '0' and ic_stall = '0' and if2dec_full = '0' else '0';

	if_adr <= dec_pc;
end Behavior;
