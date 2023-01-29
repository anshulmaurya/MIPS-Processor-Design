LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


ENTITY PC_register IS
   PORT( 
      PC_next : IN     std_logic_vector (31 DOWNTO 0);
      clk     : IN     std_logic;
      rst     : IN     std_logic;
      PC      : OUT    std_logic_vector (31 DOWNTO 0)
   );
END PC_register ;


ARCHITECTURE struct OF PC_register IS

	constant text_segment_start : std_logic_vector(31 downto 0) := x"00400000";
	
BEGIN
-- Insert your code here --

PROCESS (clk,rst) 
BEGIN
IF  rst = '1' then
--IF (rst'EVENT AND rst = '0') then
    PC <= text_segment_start;
ELSIF (clk'EVENT AND clk = '1' and rst = '0') then
    --PC <= text_segment_start + x"20";
    if PC_next > x"00f00000"
    then 
        PC <= x"0" & PC_next(31 downto 4)  ;
    else 
        PC <= PC_next; 
    end if;
    --PC <= PC_next + x"20";
END IF;
END PROCESS;
END struct;

