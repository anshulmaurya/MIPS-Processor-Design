LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_signed.ALL;
use ieee.numeric_std.all;

ENTITY mips_single_cycle IS
   PORT( 
      clk                                  : IN     std_logic;
      rst                                  : IN     std_logic
     );
END mips_single_cycle ;


ARCHITECTURE struct OF mips_single_cycle IS

   -- Internal signal declarations
   signal watch                                       : std_logic_vector (31 DOWNTO 0) ;
   signal mux_io_bw_regFile_alu_out                   : std_logic_vector (31 DOWNTO 0) ;
   signal mux_second_sel                              : std_logic ;
   signal ReadData_2                                  : std_logic_vector (31 DOWNTO 0) ;
   signal ReadData_1                                  : std_logic_vector (31 DOWNTO 0) ;
   signal mux_first_output                            : std_logic_vector (4 DOWNTO 0);
   signal mux_second_ip_1                             : std_logic_vector (31 DOWNTO 0) ;
   signal mux_io_attached_add_out                     : std_logic_vector (31 DOWNTO 0) ;
   signal Main_Control_Unit_Branch                    : std_logic ;
   signal adder_first_PC_incremented                  : std_logic_vector (31 DOWNTO 0);
   signal adder_second_add_result                     : std_logic_vector (31 DOWNTO 0);
   signal mux_second_output_add                       : std_logic_vector(31 downto 0);
   signal mux_second_output_io                        : std_logic_vector(31 downto 0);
   signal mips_single_cycle_out                       : std_logic_vector(31 downto 0);
   SIGNAL ALUOp                                       : std_logic_vector(1 DOWNTO 0);
   SIGNAL ALUSrc                                      : std_logic;
   SIGNAL ALU_control                                 : std_logic_vector(3 DOWNTO 0);
   SIGNAL ALU_result                                  : std_logic_vector(31 DOWNTO 0);
   SIGNAL Branch                                      : std_logic;
   SIGNAL Instruction                                 : std_logic_vector(31 DOWNTO 0);
   SIGNAL Instruction_15_0_Sign_Extended              : std_logic_vector(31 DOWNTO 0);
   SIGNAL Instruction_15_0_Sign_Extended_Left_Shifted : std_logic_vector(31 DOWNTO 0);
   SIGNAL Instruction_25_0_Left_Shifted               : std_logic_vector(27 DOWNTO 0);
   SIGNAL Jump                                        : std_logic;
   SIGNAL MemRead                                     : std_logic;
   SIGNAL MemToReg                                    : std_logic;
   SIGNAL MemWrite                                    : std_logic;
   SIGNAL PC                                          : std_logic_vector(31 DOWNTO 0);
   SIGNAL PC_incremented                              : std_logic_vector(31 DOWNTO 0);
   SIGNAL PC_next                                     : std_logic_vector(31 DOWNTO 0);
   SIGNAL RegDst                                      : std_logic;
   SIGNAL RegWrite                                    : std_logic;
   SIGNAL adder_second_result                         : std_logic_vector(31 DOWNTO 0);
   SIGNAL alu_second_operand                          : std_logic_vector(31 DOWNTO 0);
   SIGNAL branch_when_equal                           : std_logic;
   SIGNAL ReadData                                    : std_logic_vector(31 DOWNTO 0);
   SIGNAL jump_address                                : std_logic_vector(31 DOWNTO 0);
   SIGNAL mux_second_i3_output                        : std_logic_vector(31 DOWNTO 0);
   SIGNAL regfile_ReadData_1                          : std_logic_vector(31 DOWNTO 0);
   SIGNAL regfile_ReadData_2                          : std_logic_vector(31 DOWNTO 0);
   SIGNAL regfile_WriteAddr                           : std_logic_vector(4 DOWNTO 0);
   SIGNAL regfile_WriteData                           : std_logic_vector(31 DOWNTO 0);
   SIGNAL zero                                        : std_logic;
   SIGNAL overflow                                    : std_logic;


   -- Component Declarations
   COMPONENT ALU
   PORT (
      A           : IN     std_logic_vector (31 DOWNTO 0);
      ALU_control : IN     std_logic_vector (3 DOWNTO 0);
      B           : IN     std_logic_vector (31 DOWNTO 0);
      ALU_result  : OUT    std_logic_vector (31 DOWNTO 0);
      zero        : OUT    std_logic;
      overflow    : OUT    std_logic
   );
   END COMPONENT;
   
   COMPONENT ALU_controller
   PORT (
      ALU_op      : IN     std_logic_vector (1 DOWNTO 0);
      funct       : IN     std_logic_vector (5 DOWNTO 0);
      ALU_control : OUT    std_logic_vector (3 DOWNTO 0)
   );
   END COMPONENT;
   
   COMPONENT DM
   PORT (
      Address   : IN     std_logic_vector (31 DOWNTO 0);
      MemRead   : IN     std_logic ;
      MemWrite  : IN     std_logic ;
      WriteData : IN     std_logic_vector (31 DOWNTO 0);
      clk       : IN     std_logic ;
      rst       : IN     std_logic ;
      ReadData  : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;
   
   COMPONENT First_Shift_Left_2
   PORT (
      Instruction_25_0              : IN     std_logic_vector (25 DOWNTO 0);
      Instruction_25_0_Left_Shifted : OUT    std_logic_vector (27 DOWNTO 0)
   );
   END COMPONENT;
   
   COMPONENT IM
   PORT (
      ReadAddress : IN     std_logic_vector (31 DOWNTO 0);
      rst         : IN     std_logic ;
      Instruction : OUT    std_logic_vector (31 DOWNTO 0);
      clk         : IN     std_logic
   );
   END COMPONENT;
   
   COMPONENT Main_Control_Unit
   PORT (
      Instruction_31_26 : IN     std_logic_vector (5 DOWNTO 0);
      ALUOp             : OUT    std_logic_vector (1 DOWNTO 0);
      ALUSrc            : OUT    std_logic ;
      Branch            : OUT    std_logic ;
      Jump              : OUT    std_logic ;
      MemRead           : OUT    std_logic ;
      MemToReg          : OUT    std_logic ;
      MemWrite          : OUT    std_logic ;
      RegDst            : OUT    std_logic ;
      RegWrite          : OUT    std_logic 
   );
   END COMPONENT;
   
   COMPONENT PC_register
   PORT (
      PC_next : IN     std_logic_vector (31 DOWNTO 0);
      clk     : IN     std_logic ;
      rst     : IN     std_logic ;
      PC      : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;
   
   COMPONENT RegFile
   PORT (
      ReadAddr_1 : IN     std_logic_vector (4 DOWNTO 0);
      ReadAddr_2 : IN     std_logic_vector (4 DOWNTO 0);
      RegWrite   : IN     std_logic ;
      WriteAddr  : IN     std_logic_vector (4 DOWNTO 0);
      WriteData  : IN     std_logic_vector (31 DOWNTO 0);
      clk        : IN     std_logic ;
      rst        : IN     std_logic ;
      ReadData_1 : OUT    std_logic_vector (31 DOWNTO 0);
      ReadData_2 : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;
   
   COMPONENT Second_Shift_Left_2
   PORT (
      Instruction_15_0_Sign_Extended              : IN     std_logic_vector (31 DOWNTO 0);
      Instruction_15_0_Sign_Extended_Left_Shifted : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;
   
   COMPONENT adder_first
   PORT (
      PC            : IN     std_logic_vector (31 DOWNTO 0);
      PC_incremented : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;
   
   COMPONENT adder_second
   PORT (
      A          : IN     std_logic_vector (31 DOWNTO 0);
      B          : IN     std_logic_vector (31 DOWNTO 0);
      add_result : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;
   
   COMPONENT mux_first
   PORT (
      instruction_15_11 : IN     std_logic_vector (4 DOWNTO 0);
      instruction_20_16 : IN     std_logic_vector (4 DOWNTO 0);
      sel               : IN     std_logic ;
      output            : OUT    std_logic_vector (4 DOWNTO 0)
   );
   END COMPONENT;
   
   COMPONENT mux_second
   PORT (
      input_0 : IN     std_logic_vector (31 DOWNTO 0);
      input_1 : IN     std_logic_vector (31 DOWNTO 0);
      sel     : IN     std_logic ;
      output  : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;
   
   COMPONENT sign_extend
   PORT (
      Instruction_15_0                 : IN     std_logic_vector (15 DOWNTO 0);
      Instruction_15_0_Sign_Extended   : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;
   
BEGIN
-- Insert your code here --
mux_second_sel <= Branch and zero;
mux_io_attached_adder: mux_second PORT MAP(
    input_0 => adder_first_PC_incremented,
    input_1 => adder_second_add_result,
    sel     => mux_second_sel,
    output => mux_io_attached_add_out
    );
    
--mux_second_ip_1 <= Instruction_25_0_Left_Shifted(27 downto 0)&adder_first_PC_incremented(31 downto 28);
mux_second_ip_1 <= Instruction_25_0_Left_Shifted & adder_first_PC_incremented(31 downto 28);
mux_io_attached_mux: mux_second PORT MAP(
    input_0 => mux_io_attached_add_out,
    input_1 => mux_second_ip_1,
    sel     => jump,
    output => PC_next
    );
watch <= PC_next;
ALU_controller_io: ALU_controller port map(
      ALU_op      =>    ALUOp,
      funct       =>    instruction(5 downto 0),
      ALU_control =>    ALU_control
    );

DM_io: DM port map(
      Address   => ALU_result,
      MemRead   => MemRead,
      MemWrite  => MemWrite,
      WriteData => ReadData_2,
      clk       => clk,
      rst       => rst,
      ReadData  => ReadData
    );
    
mux_io_bw_dm_regFile: mux_second PORT MAP(
    input_0 => ALU_result,
    input_1 => ReadData,
    sel     => MemToReg,
    output => RegFile_WriteData
    );
    
mux_io_bw_regFile_alu: mux_second PORT MAP(
    input_0 => ReadData_2,
    input_1 => Instruction_15_0_Sign_Extended,
    sel     => ALUSrc,
    output => mux_io_bw_regFile_alu_out
    );

ALU_io: ALU port map(
      A           => ReadData_1,
      ALU_control => ALU_control,
      B           => mux_io_bw_regFile_alu_out,
      ALU_result  => ALU_result,
      zero        => zero,
      overflow    => overflow
    );
    
--watch <= Instruction_25_0_Left_Shifted;
First_Shift_Left_2_io: First_Shift_Left_2 port map(
      Instruction_25_0              =>  instruction(25 downto 0),
      Instruction_25_0_Left_Shifted =>  Instruction_25_0_Left_Shifted
);    

IM_io: IM port map(
      ReadAddress =>    PC,
      rst         =>    rst,
      Instruction =>    Instruction,
      clk         =>    clk
);

Main_Control_Unit_io: Main_Control_Unit port map(
      Instruction_31_26 => instruction(31 downto 26),
      ALUOp             => ALUOp,
      ALUSrc            => ALUSrc,
      Branch            => Branch,
      Jump              => Jump,
      MemRead           => MemRead,
      MemToReg          => MemToReg,
      MemWrite          => MemWrite,
      RegDst            => RegDst,
      RegWrite          => RegWrite
);

PC_register_io: PC_register port map(
      PC_next =>    PC_next,
      clk     =>    clk,
      rst     =>    rst,
      PC      =>    PC
);

RegFile_io: RegFile port map(
      ReadAddr_1 => instruction(25 downto 21),
      ReadAddr_2 => instruction(20 downto 16),
      RegWrite   => RegWrite,
      WriteAddr  => mux_first_output,
      WriteData  => RegFile_WriteData,
      clk        => clk,
      rst        => rst,
      ReadData_1 => ReadData_1,
      ReadData_2 => ReadData_2
);

Second_Shift_Left_2_io: Second_Shift_Left_2 port map(
      Instruction_15_0_Sign_Extended              => Instruction_15_0_Sign_Extended,
      Instruction_15_0_Sign_Extended_Left_Shifted => Instruction_15_0_Sign_Extended_Left_Shifted
    );

adder_first_io: adder_first port map(
      PC             => pc,
      PC_incremented => adder_first_PC_incremented
);

adder_second_io: adder_second port map(
      A          => adder_first_PC_incremented,
      B          => Instruction_15_0_Sign_Extended_Left_Shifted,
      add_result => adder_second_add_result
);

mux_first_io: mux_first port map(
      instruction_15_11 => instruction(15 downto 11),
      instruction_20_16 => instruction(20 downto 16),
      sel               => RegDst,
      output            => mux_first_output
);

sign_extend_io: sign_extend port map(
      Instruction_15_0                 => Instruction(15 downto 0),
      Instruction_15_0_Sign_Extended   => Instruction_15_0_Sign_Extended
);

END struct;