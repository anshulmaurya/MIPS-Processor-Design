LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;


ENTITY Main_Control_Unit IS
   PORT( 
      Instruction_31_26 : IN     std_logic_vector (5 DOWNTO 0);
      ALUOp             : OUT    std_logic_vector (1 DOWNTO 0);
      ALUSrc            : OUT    std_logic;
      Branch            : OUT    std_logic;
      Jump              : OUT    std_logic;
      MemRead           : OUT    std_logic;
      MemToReg          : OUT    std_logic;
      MemWrite          : OUT    std_logic;
      RegDst            : OUT    std_logic;
      RegWrite          : OUT    std_logic
   );
END Main_Control_Unit ;


ARCHITECTURE struct OF Main_Control_Unit IS

BEGIN
   ---------------------------------------------------------------------------
   process1: PROCESS(Instruction_31_26)
   ---------------------------------------------------------------------------
   BEGIN
   -- Default Values --
   RegDst <= '0';
   ALUSrc <= '0';
   MemToReg <= '0';
   RegWrite <= '0';
   MemRead <= '0';
   MemWrite <= '0';
   Branch <= '0';
   ALUOp <= "00";
   Jump <= '0';   
      CASE Instruction_31_26 IS
      WHEN "000000" =>		-- R-Type
         RegDst <= '1';
         RegWrite <= '1';
         ALUOp <= "10";
      WHEN "100011" =>		-- lw
         ALUSrc <= '1';
         MemToReg <= '1';
         RegWrite <= '1';
         MemRead <= '1';
      WHEN "101011" =>		-- sw
         ALUSrc <= '1';
         MemWrite <= '1';
      WHEN "000100" =>		-- beq
         Branch <= '1';
         ALUOp <= "01";
      WHEN "000010" =>		-- j
         Jump <= '1';
      WHEN "001000" =>		-- addi
         ALUSrc <= '1';
         RegWrite <= '1';
      WHEN OTHERS => NULL;
      END CASE;
   END PROCESS process1;
END struct;
