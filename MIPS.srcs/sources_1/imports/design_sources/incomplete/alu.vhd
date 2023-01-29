LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_signed.all;

ENTITY ALU IS
   PORT( 
      A           : IN     std_logic_vector (31 DOWNTO 0);
      ALU_control : IN     std_logic_vector (3 DOWNTO 0);
      B           : IN     std_logic_vector (31 DOWNTO 0);
      ALU_result  : OUT    std_logic_vector (31 DOWNTO 0);
      zero        : OUT    std_logic;
      overflow    : OUT    std_logic
   );
END ALU ;

ARCHITECTURE behav OF ALU IS

   -- Architecture declarations
   CONSTANT zero_value : std_logic_vector(31 downto 0) := (others => '0');

   -- Internal signal declarations
   SIGNAL ALU_result_internal : std_logic_vector(31 DOWNTO 0) := (others => '0');
   SIGNAL s_A, s_B, s_C : std_logic;
    
BEGIN
-- Insert your code here --
    process(ALU_control,A,B)
    --variable declaration
    --variable opVal  : std_logic_vector (31 DOWNTO 0);
    begin
    zero <= '0';
    overflow <= '0';
    if ALU_control = "0000" 
    then
        ALU_result_internal <= A and B;
        
    elsif ALU_control = "0001" 
    then
        ALU_result_internal <= A or B;
        
    elsif ALU_control = "0010" 
    then
        ALU_result_internal <= A + B;
        if ALU_result_internal > 31         -- checking for addition overflow
        then
            overflow <= '1';
        end if;
        
    elsif ALU_control = "0110" 
    then
        ALU_result_internal <= A - B; 
        if ALU_result_internal > -31        --checking for substraction overflow
        then
            overflow <= '1';
        end if;
               
    elsif ALU_control = "0111"
    then
        if A<B then
            ALU_result_internal <= x"00000001";
        else
            ALU_result_internal <= x"00000000";
        end if;
        
    elsif ALU_control = "1100"
    then
        ALU_result_internal <= A nor B;
        
    else 
        ALU_result_internal <= x"00000000";
        
    end if;
  
    End process;
    ALU_result <= ALU_result_internal;  
    -- setting flags
    zero <= '1' when ALU_result_internal = x"00000000";
    
END behav;
