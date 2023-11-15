LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY FIFO IS
    GENERIC ( WIDTH: INTEGER := 72 );
    PORT (
        din      : IN  std_logic_vector(WIDTH-1 DOWNTO 0); -- data in
        dout     : OUT std_logic_vector(WIDTH-1 DOWNTO 0); -- data out
        push     : IN  std_logic; -- push data
        pop      : IN  std_logic; -- pop data
        full     : OUT std_logic; -- full flag
        empty    : OUT std_logic; -- empty flag
        reset_n  : IN  std_logic; -- reset
        ck       : IN  std_logic; -- clock
        vdd      : IN  bit; -- power
        vss      : IN  bit  -- ground
    );
END FIFO;

ARCHITECTURE df_fifo OF FIFO IS
    
    SIGNAL fifo_d : STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0) := (OTHERS => '0'); -- Initialize with all zeros
    SIGNAL fifo_v : STD_LOGIC := '0'; -- Initialize to 0

BEGIN

    PROCESS(ck)
    BEGIN
        IF RISING_EDGE(ck) THEN
            IF reset_n = '0' THEN 
                fifo_v <= '0';
            ELSE 
                IF fifo_v = '0' THEN        -- if there is no data in the fifo
                    IF push = '1' THEN      -- if we are pushing data
                        fifo_d <= din;      -- put the data in the fifo
                        fifo_v <= '1';      -- and set the valid flag
                    END IF;
                ELSE                        -- if there is data in the fifo
                    IF pop = '1' THEN       -- if we are popping data
                        IF push = '1' THEN  -- and if we are pushing more data
                            fifo_d <= din;  -- put the data in the fifo
                            fifo_v <= '1';  -- and set the valid flag
                        ELSE                -- if we are popping data but are not pushing more data
                            fifo_v <= '0';  -- clear the valid flag
                        END IF;
                    ELSE                    -- if we are not popping data but there is data in the fifo
                        fifo_v <= '1';      -- set the valid flag
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;
    
    full <= '1' WHEN fifo_v = '1' AND pop = '1' ELSE '0'; -- if there is data in the fifo and we are popping data, then the fifo is full
    empty <= NOT fifo_v; -- if there is no data in the fifo, then the fifo is empty
    dout <= fifo_d; -- output the data from the fifo

END df_fifo;
