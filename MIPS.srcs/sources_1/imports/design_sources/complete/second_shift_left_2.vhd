LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
use ieee.numeric_std.all; 


ENTITY Second_Shift_Left_2 IS
   PORT( 
      Instruction_15_0_Sign_Extended              : IN     std_logic_vector (31 DOWNTO 0);
      Instruction_15_0_Sign_Extended_Left_Shifted : OUT    std_logic_vector (31 DOWNTO 0)
   );
END Second_Shift_Left_2 ;


ARCHITECTURE struct OF Second_Shift_Left_2 IS

BEGIN
   --Instruction_15_0_Sign_Extended_Left_Shifted <= x"00400028";
   --Instruction_15_0_Sign_Extended_Left_Shifted <= Instruction_15_0_Sign_Extended shl 3;
   --Instruction_15_0_Sign_Extended_Left_Shifted <= (Instruction_15_0_Sign_Extended(29 downto 0) & "00");
   Instruction_15_0_Sign_Extended_Left_Shifted <= Instruction_15_0_Sign_Extended(31 downto 2) & "00";
   --Instruction_15_0_Sign_Extended_Left_Shifted <= (Instruction_15_0_Sign_Extended and x"1111111C");
END struct;
