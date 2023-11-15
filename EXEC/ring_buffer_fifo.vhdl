library ieee;
use ieee.std_logic_1164.all;

ENTITY ring_buffer IS
    GENERIC(
        RAM_WIDTH : natural; 
        RAM_DEPTH : natural 
    );
    PORT(
        clk :       in std_logic;
        rst :       in std_logic; 
        -- Write Port
        wr_en :     in std_logic; 
        wr_data :   in std_logic_vector( RAM_WIDTH - 1 downto 0 ); 
        -- Read Port
        rd_en:      in std_logic;
        rd_valid:   out std_logic;
        rd_data:    out std_logic_vector( RAM_WIDTH - 1 downto 0 );
        -- Flags 
        empty:      out std_logic; -- 0 element in the buffer
        empty_next: out std_logic; -- 1 or 0 element left
        full:       out std_logic; -- 0 room in the buffer
        full_next:  out std_logic; -- 1 or 0 room left 
        fill_count: out integer range RAM_DEPTH - 1 downto 0 -- number of elements in the buffer
    );
END ring_buffer;

ARCHITECTURE RTL of ring_buffer IS 

  type ram_type is array( 0 to RAM_DEPTH - 1 ) of -- Define RAM type 
    std_logic_vector( wr_data'range ); -- RAM_WIDTH - 1 downto 0
  signal ram: ram_type; 

  subtype index_type is integer range ram_type'range; -- Define index type: 0 to RAM_DEPTH - 1
  signal head: index_type; -- Head pointer
  signal tail: index_type; -- Tail pointer

  signal empty_i : std_logic;
  signal full_i  : std_logic;
  signal fill_count_i : integer range RAM_DEPTH - 1 downto 0; 
  
  -- Increment and wrap subprogram
  procedure increment(signal index: inout index_type) is 
  begin 
    if index = index_type'high then 
       index <= index_type'low; 
    else 
       index <= index + 1; 
    end if;
  end procedure;

  BEGIN 
    -- Copy internal signals to output ports
    empty <= empty_i; 
    full <= full_i; 
    fill_count <= fill_count_i; 
    -- Set the flags 
    empty_i     <= '1'  when fill_count_i = 0 else '0'; 
    empty_next  <= '1'  when fill_count_i <= 1 else '0';
    full_i      <= '1'  when fill_count_i >= RAM_DEPTH - 1 else '0';
    full_next   <= '1'  when fill_count_i >= RAM_DEPTH - 2 else '0';
    -- Update Head Ptr in write 
    PROC_HEAD: process (clk)
    begin 
      if rising_edge(clk) then 
        if rst = '1' then 
          head <= index_type'low; 
        else 
          if wr_en = '1' and full_i = '0' then 
            increment(head);
          end if;
        end if;
      end if;
    end process; 

   -- Update Tail Ptr in read 
    PROC_TAIL: process (clk)
    begin 
      if rising_edge(clk) then 
        if rst = '1' then 
          tail <= index_type'low; 
          rd_valid <= '0';
        else 
          rd_valid <= '0';
          if rd_en = '1' and empty_i = '0' then 
            increment(tail);
            rd_valid <= '1';
          end if;
        end if;
      end if;
    end process;

   -- Write to & Read from RAM 
    PROC_RAM: process (clk)
    begin 
      if rising_edge(clk) then 
        ram(head) <= wr_data; 
        rd_data <= ram(tail);
      end if;
    end process;

    -- Update till count 
    PROC_COUNT: process (head, tail)
    begin 
      if head < tail then 
        fill_count_i <= head - tail + RAM_DEPTH;
      else 
        fill_count_i <= head - tail;
      end if;
    end process;

END ARCHITECTURE;

