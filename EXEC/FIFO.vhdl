-- LIBRARY ieee;
-- USE ieee.std_logic_1164.ALL;
-- USE ieee.numeric_std.ALL;

-- ENTITY FIFO IS
--     GENERIC ( WIDTH: INTEGER := 72 );
--     PORT (
--         din      : IN  std_logic_vector(WIDTH-1 DOWNTO 0); -- data in
--         dout     : OUT std_logic_vector(WIDTH-1 DOWNTO 0); -- data out
--         push     : IN  std_logic; -- push data
--         pop      : IN  std_logic; -- pop data
--         full     : OUT std_logic; -- full flag
--         empty    : OUT std_logic; -- empty flag
--         reset_n  : IN  std_logic; -- reset
--         ck       : IN  std_logic; -- clock
--         vdd      : IN  bit; -- power
--         vss      : IN  bit  -- ground
--     );
-- END FIFO;

-- ARCHITECTURE df_fifo OF FIFO IS
    
--     SIGNAL fifo_d : STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0) := (OTHERS => '0'); -- Initialize with all zeros
--     SIGNAL fifo_v : STD_LOGIC := '0'; -- Initialize to 0

-- BEGIN

--     PROCESS(ck)
--     BEGIN
--         IF RISING_EDGE(ck) THEN
--             IF reset_n = '0' THEN 
--                 fifo_v <= '0';
--             ELSE 
--                 IF fifo_v = '0' THEN        -- if there is no data in the fifo
--                     IF push = '1' THEN      -- if we are pushing data
--                         fifo_d <= din;      -- put the data in the fifo
--                         fifo_v <= '1';      -- and set the valid flag
--                     END IF;
--                 ELSE                        -- if there is data in the fifo
--                     IF pop = '1' THEN       -- if we are popping data
--                         IF push = '1' THEN  -- and if we are pushing more data
--                             fifo_d <= din;  -- put the data in the fifo
--                             fifo_v <= '1';  -- and set the valid flag
--                         ELSE                -- if we are popping data but are not pushing more data
--                             fifo_v <= '0';  -- clear the valid flag
--                         END IF;
--                     ELSE                    -- if we are not popping data but there is data in the fifo
--                         fifo_v <= '1';      -- set the valid flag
--                     END IF;
--                 END IF;
--             END IF;
--         END IF;
--     END PROCESS;
    
--     full <= '1' WHEN fifo_v = '1' AND pop = '1' ELSE '0'; -- if there is data in the fifo and we are popping data, then the fifo is full
--     empty <= NOT fifo_v; -- if there is no data in the fifo, then the fifo is empty
--     dout <= fifo_d; -- output the data from the fifo

-- END df_fifo;


LIBRARY ieee;
use ieee.std_logic_1164.all;

ENTITY FIFO IS
    GENERIC ( WIDTH: INTEGER := 72 );
	PORT(
		din		: in std_logic_vector(71 downto 0);
		dout		: out std_logic_vector(71 downto 0);

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
END FIFO;

architecture dataflow of FIFO is

signal fifo_d	: std_logic_vector(72 -1 downto 0);
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
