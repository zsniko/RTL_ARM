
LIBRARY ieee;
use ieee.std_logic_1164.all;

ENTITY FIFO IS
    GENERIC ( WIDTH: INTEGER := 72 );
	PORT(
		din		: in std_logic_vector(WIDTH-1 downto 0);
		dout	: out std_logic_vector(WIDTH-1 downto 0);

		-- commands
		push	: in std_logic;
		pop		: in std_logic;

		-- flags
		full	: out std_logic;
		empty	: out std_logic;

		reset_n	: in std_logic;
		ck		: in std_logic;
		vdd		: in bit;
		vss		: in bit
	);
END FIFO;

architecture dataflow of FIFO is

signal fifo_d	: std_logic_vector(WIDTH-1 downto 0);
signal fifo_v	: std_logic;

-- 	une fifo est pleine quand :
--	elle est valide et qu'on ne pop pas 
--	On considère qu'une fifo est valide quand il y a de la donnée et que l'on sait quelle est cette donnée

begin

	process(ck)
		begin
		if rising_edge(ck) then
			-- Valid bit
			if reset_n = '0' then -- reset la fifo => on la rend invalide
				fifo_v <= '0';
			else
			--quand y a de la merde dans la fifo, ie quand fifo_v = '0' ie qu'on ne compte pas utilisé ce qu'il y a dedans
				
				if fifo_v = '0' then -- si la fifo n'est aps valide et que push = 1
				
					if push = '1' then -- si on push la fifo devient valide
						fifo_v <= '1'; -- elle devient valide
					else
						fifo_v <= '0';
					end if;
				else --quand la fifo est valide ie qu'on sait et on utilise ce qu'il y a dedans
					if pop = '1' then
						if push = '1' then
							fifo_v <= '1';
						else
							fifo_v <= '0';
						end if;
					else
						fifo_v <= '1';
					end if;
				end if;
			end if;

			-- data
			if fifo_v = '0' then
				if push = '1' then
					fifo_d <= din;
				end if;
			elsif push='1' and pop='1' then
					fifo_d <= din;
			end if;
		end if;
	end process;

	full <= '1' when fifo_v = '1' and pop = '0' else '0';
	empty <= not fifo_v;
	dout <= fifo_d;

end dataflow;
