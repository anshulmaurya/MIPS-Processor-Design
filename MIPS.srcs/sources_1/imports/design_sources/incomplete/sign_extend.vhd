LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
use ieee.numeric_std.all;

ENTITY sign_extend IS
   PORT( 
      Instruction_15_0               : IN     std_logic_vector (15 DOWNTO 0);
      Instruction_15_0_Sign_Extended : OUT    std_logic_vector (31 DOWNTO 0)
   );
END sign_extend ;


ARCHITECTURE struct OF sign_extend IS

BEGIN
-- Insert your code here --
--Instruction_15_0_Sign_Extended <= x"0000"&Instruction_15_0 when Instruction_15_0(0)='0';
Instruction_15_0_Sign_Extended <= x"ffff"&Instruction_15_0 when Instruction_15_0(15)='1' else 
                                  x"0000"&Instruction_15_0;

END struct;