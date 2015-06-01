--
-- 
-- This module is the HW5_MIPS CPU implementation 
--  
--
-- It supports Rtype instructions of: add, sub, and, or, xor, slt    
-- It also supports addi, beq, bne, lw & sw instructions
-- 
-- There are 5 phases: IF, ID, EX, MEM, WB
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- ***************************************************************************************************
-- ***************************************************************************************************

entity HW5_MIPS_4sim is
Port	(	
-- Infrastructure signals [To be used by PC via RS232 or from Nexys2 board switches & pushbuttons, and VGA signals to the screen],
-- Host intf signals
RS232_Rx		: in STD_LOGIC;
RS232_Tx		: out STD_LOGIC;
--general signals
CK_50MHz 		: in STD_LOGIC;
buttons_in		: in STD_LOGIC_vector(3 downto 0);--  btn0 is single clock (manual clock), btn3 is manual reset
switches_in 	: in STD_LOGIC_VECTOR (7 downto 0);-- 4-0 to select which part to be displayed on the 7Segnets LEDs
leds_out 		: out STD_LOGIC_VECTOR (7 downto 0);-- to 8 LEDs (leftmost = Flash status, next = MIPS_ck, 6 right ones = BYOC_Host_intf version number)
--
-- signals to be tested by the TB
CK_out_to_TB			:	out STD_LOGIC; 
RESET_out_to_TB			:	out STD_LOGIC; 
HOLD_out_to_TB			:	out STD_LOGIC; 
rdbk0_out_to_TB 		:	out STD_LOGIC_VECTOR (31 downto 0); 
rdbk1_out_to_TB 		:	out STD_LOGIC_VECTOR (31 downto 0); 
rdbk2_out_to_TB 		:	out STD_LOGIC_VECTOR (31 downto 0); 
rdbk3_out_to_TB 		:	out STD_LOGIC_VECTOR (31 downto 0); 
rdbk4_out_to_TB 		:	out STD_LOGIC_VECTOR (31 downto 0); 
rdbk5_out_to_TB 		:	out STD_LOGIC_VECTOR (31 downto 0); 
rdbk6_out_to_TB 		:	out STD_LOGIC_VECTOR (31 downto 0); 
rdbk7_out_to_TB 		:	out STD_LOGIC_VECTOR (31 downto 0); 
rdbk8_out_to_TB 		:	out STD_LOGIC_VECTOR (31 downto 0); 
rdbk9_out_to_TB 		:	out STD_LOGIC_VECTOR (31 downto 0); 
rdbk10_out_to_TB 		:	out STD_LOGIC_VECTOR (31 downto 0); 
rdbk11_out_to_TB 		:	out STD_LOGIC_VECTOR (31 downto 0); 
rdbk12_out_to_TB 		:	out STD_LOGIC_VECTOR (31 downto 0); 
rdbk13_out_to_TB 		:	out STD_LOGIC_VECTOR (31 downto 0); 
rdbk14_out_to_TB 		:	out STD_LOGIC_VECTOR (31 downto 0); 
rdbk15_out_to_TB 		:	out STD_LOGIC_VECTOR (31 downto 0) 
		);
end HW5_MIPS_4sim; 


architecture Behavioral of HW5_MIPS_4sim is
		   
-- ***************************************************************************************************
-- ***************************************************************************************************

-- constants
constant MIPS_data_width : INTEGER :=32; --data width in bits     
constant MIPS_adrs_width : INTEGER :=32; -- Full address width of MIPS CPU



-- all components used:  Fetch_Unit, GPR file, MIPS_ALU, Clock_Driver, HW4_Host_intf
-- ===================================================================================
-- ***************************************************************************************************
COMPONENT Fetch_Unit is
Port	(	
-- general input signals
CK_25MHz 		: in STD_LOGIC;
RESET_in 		: in STD_LOGIC;
HOLD_in 		: in STD_LOGIC;
-- MIPS signals
IR_reg_pID		:	out		STD_LOGIC_VECTOR  (31 downto 0);-- The IR_reg (instruction) to be used in ID 
sext_imm_pID	:	out		STD_LOGIC_VECTOR  (31 downto 0);-- The sext_imm to be used in ID 
PC_plus_4_reg_pID :	out		STD_LOGIC_VECTOR  (31 downto 0);-- to be read by TB in simulatio and rdbk in implementation - for verification purposes 
Rs_equals_Rt_pID  : in  	STD_LOGIC;-- '1' if value read from Rs equals the value read from Rt, '0' otherwise. Used in branch instructions.
--- IMem signals
MIPS_IMem_adrs	     : out STD_LOGIC_VECTOR (31 downto 0); 
MIPS_IMem_rd_data     : in STD_LOGIC_VECTOR (31 downto 0) 
		);
END COMPONENT;


-- ***************************************************************************************************
COMPONENT GPR is
Port( 	
--RST			:	in		STD_LOGIC;
CK			: 	in  	STD_LOGIC;
rd_reg1 	: 	in  	STD_LOGIC_VECTOR (4 downto 0);-- Rs
rd_reg2 	: 	in  	STD_LOGIC_VECTOR (4 downto 0);-- Rt
wr_reg	 	: 	in  	STD_LOGIC_VECTOR (4 downto 0);-- Rd (in R-Type instruction, Rt in LW)
rd_data1 	: 	out 	STD_LOGIC_VECTOR (31 downto 0);-- Rs contents
rd_data2 	: 	out 	STD_LOGIC_VECTOR (31 downto 0);-- Rt contents
wr_data 	: 	in	 	STD_LOGIC_VECTOR (31 downto 0);-- contents to be written into Rd (or Rt)
Reg_Write 	: 	in  	STD_LOGIC;-- "0" means no register is written into
GPR_hold 	: 	in  	STD_LOGIC-- "1" means no register is written into
	);
end COMPONENT;


-- ***************************************************************************************************
COMPONENT MIPS_ALU is
Port	(	
-- ALU operation control inputs
ALUOP		: in STD_LOGIC_VECTOR(1 downto 0);-- 00=add, 01=sub, 10=by Function
Funct		: in STD_LOGIC_VECTOR(5 downto 0);-- 32=ADD, 34=sub, 36=AND, 37=OR, 38=XOR, 42=SLT
-- data inputs & data control inputs
A_in		: in STD_LOGIC_VECTOR(31 downto 0);
B_in		: in STD_LOGIC_VECTOR(31 downto 0);
sext_imm	: in STD_LOGIC_VECTOR(31 downto 0);
ALUsrcB		: in STD_LOGIC;
-- data output
ALU_out		: out STD_LOGIC_VECTOR(31 downto 0)
		);
end COMPONENT;


-- ***************************************************************************************************
COMPONENT Clock_Driver is
port
 (
  CK_50MHz_IN			: in  std_logic ;
  CK_25MHz_OUT			: out std_logic
  );
END COMPONENT;


-- ***************************************************************************************************
COMPONENT HW5_Host_intf_4sim is
Port	(	
--
-- MIPS signals    [to be used by students]
MIPS_reset		: 	out  	STD_LOGIC;
MIPS_hold		: 	out  	STD_LOGIC;
MIPS_IMem_adrs 	: 	in  	STD_LOGIC_VECTOR (31 downto 0);-- MIPS IMem read address
MIPS_IMem_rd_data :	out		STD_LOGIC_VECTOR (31 downto 0);-- read data (sync read -  at the rising edge of MIPS_ck,  all the time)	
--
MIPS_DMem_adrs	:	in		STD_LOGIC_VECTOR  (31 downto 0);-- The address to DMem 
MIPS_DMem_rd_data :	out		STD_LOGIC_VECTOR  (31 downto 0);-- The data read from DMem_adrs in lw instruction. It is registered, i.e.= the MDR data 
MIPS_DMem_wr_data :	in		STD_LOGIC_VECTOR  (31 downto 0);-- The data to be written into DMem_adrs in sw instruction 
MIPS_DMem_we	:	in  	STD_LOGIC;-- '1' if we want to write into DMem at the next rising edge of the MIPS_ck (for sw instruction)
-- RDBK signals    [to be used by students]
rdbk0 			:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk1 			:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk2			:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk3 			:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk4 			:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk5			:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk6			:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk7			:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk8			:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk9			:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk10			:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk11			:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk12			:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk13			:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk14			:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk15			:	in	STD_LOGIC_VECTOR (31 downto 0);
--
-- Infrastructure signals [To be used by PC via RS232 or from Nexys2 board switches & pushbuttons, and VGA signals to the screen],
-- Host intf signals
RS232_Rx		: in STD_LOGIC;
RS232_Tx		: out STD_LOGIC;
--general signals
CK_25MHz 		: in STD_LOGIC;
buttons_in		: in STD_LOGIC_vector(3 downto 0);--  btn0 is single clock (manual clock), btn3 is manual reset
switches_in 	: in STD_LOGIC_VECTOR (7 downto 0);-- 4-0 to select which part to be displayed on the 7Segnets LEDs
												  -- 7-5 to select modes of the BYOC_Host_interface (e.g., single ck, reset, etc.)
leds_out 		: out STD_LOGIC_VECTOR (7 downto 0)-- to 8 LEDs 
		);
END COMPONENT;

-- ***************************************************************************************************
-- ***************************************************************************************************

-- signals connecting the components, inputs & external logic
-- ===========================================================
-- Reset and CK signals
signal  CK :STD_LOGIC :='0';
signal  RESET :STD_LOGIC :='0';-- The main RESET signal combined from switches in & MIPS_reset
signal  HOLD :STD_LOGIC :='0';-- The main RESET signal combined from switches in & MIPS_reset
signal  MIPS_reset_from_Fetch_Unit	:STD_LOGIC;-- is coming from the Fetch_Unit_Host_intf

-- Fetch Unit signals
--- =============================================================================



--- ======================== MIPS signals =========================================
--- =============================================================================

--=========================== IF phase ===============================================
--===================================================================================
-- almost all signals are inside the Fetch Unit

-- except IMem signals
signal	IMem_adrs 	: STD_LOGIC_VECTOR  (31 downto 0);
signal  IMem_rd_data	: STD_LOGIC_VECTOR  (31 downto 0);

-- and we have the PC_plus_4 coming out of the Fetch_Unit for rdbk to Host_Intf  & TB
signal  PC_plus_4	: STD_LOGIC_VECTOR  (31 downto 0);



--=========================== ID phase ===============================================
--===================================================================================
--ID phase  (a register with valid value along the ID phase)
signal  IR_reg	: STD_LOGIC_VECTOR  (31 downto 0);
-- IR reg signals   (valid in ID phase)
signal  Opcode	: STD_LOGIC_VECTOR  (5 downto 0);--IR[5:0]
signal  Rs : STD_LOGIC_VECTOR  (4 downto 0);-- IR[25:21]
signal  Rt : STD_LOGIC_VECTOR  (4 downto 0);-- IR[20:16]
signal  Rd : STD_LOGIC_VECTOR  (4 downto 0);--IR[15:0]
signal  Funct	: STD_LOGIC_VECTOR  (5 downto 0);--IR[5:0]

-- other signals active in ID phase
signal  sext_imm : STD_LOGIC_VECTOR  (31 downto 0);
signal  GPR_rd_data1 : STD_LOGIC_VECTOR  (31 downto 0);
signal  GPR_rd_data2 : STD_LOGIC_VECTOR  (31 downto 0);
signal  Rs_equals_Rt : STD_LOGIC;--  '1' if contents of Rs equals the contents of Rt, '0' if not. 


-- MIPS control signals - created at the ID phase
---------------------------------------------------------------
-- Decoded signals for EX phase
signal  ALUsrcB : STD_LOGIC;-- '0' selects A_reg, '1' selects sext sext_imm
signal  ALUOP : STD_LOGIC_VECTOR  (1 downto 0);-- 00=add, 01=sub, 10=by Function
signal  RegDst : STD_LOGIC;--'0' selects Rt, '1' selects Rd
-- Decoded signals for MEM phase
signal  MemWrite : STD_LOGIC;-- '1' for writing to the DMem
-- Decoded signals for WB phase
signal  RegWrite : STD_LOGIC;-- '1' for writing to the GPR file
signal  MemToReg : STD_LOGIC;-- '1' for writing MDR data to the GPR file, '0 for writing ALUout_reg_pWB data to the GPR file



--=========================== EX phase ===============================================
--===================================================================================
--Registerd valid in EX phase  
signal  A_reg	: STD_LOGIC_VECTOR  (31 downto 0);
signal  B_reg	: STD_LOGIC_VECTOR  (31 downto 0);
signal  sext_imm_reg : STD_LOGIC_VECTOR  (31 downto 0);
signal  Rt_pEX	: STD_LOGIC_VECTOR  (4 downto 0);
signal  Rd_pEX	: STD_LOGIC_VECTOR  (4 downto 0);
signal  ALU_output	: STD_LOGIC_VECTOR  (31 downto 0);


-- MIPS control signals - created at the ID phase - delayed to EX phase
-------------------------------------------------------------------------------------------
-- Decoded signals for EX phase
signal  ALUsrcB_pEX : STD_LOGIC;
signal  Funct_pEX	: STD_LOGIC_VECTOR  (5 downto 0);--IR[5:0]
signal  ALUOP_pEX : STD_LOGIC_VECTOR  (1 downto 0);
signal  RegDst_pEX : STD_LOGIC;
signal  RegWrite_pEX : STD_LOGIC;
signal  MemWrite_pEX : STD_LOGIC;
signal  MemToReg_pEX : STD_LOGIC;



--=========================== MEM phase ===============================================
--===================================================================================
--Registerd valid in EX phase  
signal  B_reg_pMEM	: STD_LOGIC_VECTOR  (31 downto 0);
signal  Rd_pMEM		: STD_LOGIC_VECTOR  (4 downto 0);
signal  ALUout_reg	: STD_LOGIC_VECTOR  (31 downto 0);


-- MIPS control signals - created at the ID phase - delayed to EX phase
-------------------------------------------------------------------------------------------
-- Decoded signals for MEM phase
signal  RegWrite_pMEM : STD_LOGIC;
signal  MemWrite_pMEM : STD_LOGIC;
signal  MemToReg_pMEM : STD_LOGIC;




--=========================== WB phase ===============================================
--===================================================================================
--Registers valid in WB phase 
signal  MDR_reg	: STD_LOGIC_VECTOR  (31 downto 0); -- renaming of the MIPS_DMem_rd_data signal
signal  ALUout_reg_pWB	: STD_LOGIC_VECTOR  (31 downto 0); 
signal  GPR_wr_data	: STD_LOGIC_VECTOR  (31 downto 0);
signal  Rd_pWB : STD_LOGIC_VECTOR  (4 downto 0);


--signals valid in WB phase
-- MIPS control signals - created at the ID phase - delayed to WB phase
---------------------------------------------------------------------------------------------
-- Decoded signals for WB phase
signal  RegWrite_pWB : STD_LOGIC;
signal  MemToReg_pWB : STD_LOGIC;



--- ================== End of MIPS signals =========================================
--- =============================================================================



-- ***************************************************************************************************
---- Host Intf signals

signal  rdbk3_vec : STD_LOGIC_VECTOR(31 downto 0);
signal  rdbk4_vec : STD_LOGIC_VECTOR(31 downto 0);
signal  rdbk5_vec : STD_LOGIC_VECTOR(31 downto 0);
signal  rdbk12_vec : STD_LOGIC_VECTOR(31 downto 0);




-- ***************************************************************************************************


begin


-- all signal equations



--============================= IF phase processes ========================================
--============================= =========================================================
-- no such processes. They are all inside the Fetch Unit	

--============================= ID phase processes ========================================
--============================= =========================================================
-- IR fields signals
Opcode <= IR_reg(31 downto 26);
Rs <= IR_reg(25 downto 21);
--Rt <= IR_reg(20 downto 16) or (JAL & JAL & JAL & JAL & JAL);-- if JAL, Rt=$31
Rt <= IR_reg(20 downto 16);
Rd <= IR_reg(15 downto 11);
Funct <= IR_reg(5 downto 0);
-- imm <= IR_reg(15 downto 0); not required here - already handled inside Fetch_Unit
	

--beq/bne comparator (create Rs_equals_Rt signal)


-- Control decoder  - calculates the signals in ID phase
-- creates the following signals according to the opcode:
--		ALUsrcB		 '0' - selects B_reg, '1' - selects sext_imm_reg
--		ALUOP		 b"00" - add, b"01" - sub, b"10" - the Function field determines the ALU operation 
--		RegDst		 '1' - "Rd"=Rd (write to Rd),  '0' - "Rd"=Rt (write to Rt)
--		MemWrite	 '1' - write to DMem
--		MemToReg	 '0' - write ALUout_reg data (to "Rd"), '1' - write MDR_reg data (to "Rd")
--		RegWrite	 '1' - write to GPR file (to "Rd")


--============================= EX phase processes ========================================
--======================================================================================
--A & B registers


--sext_imm register


-- Rt register 


-- Rd register


-- control signals FFs 
-- RegWrite_pEX, MemToReg_pEX, MemWrite_pEX FFs



--============================= MEM phase processes ========================================
--========================================================================================
--ALUOUT register


--B delayed reg


-- RegDst mux and Rd_pMEM register


-- control signals FFs 
-- RegWrite_pMEM, MemToReg_pMEM, MemWrite_pMEM FFs



--============================= WB phase processes ========================================
--========================================================================================

-- MDR_reg no need to define -- connected directly from HW5_Host_intf - resides inside the DMem


--ALUout_pWB register


--MemToReg mux


-- Rd_pWB register


-- control signals FFs 
-- RegWrite_pWB, MemToReg_pWB FFs



-- ***************************************************************************************************
-- build special rdbk signals
rdbk3_vec  <=	b"000" & Rs  &  b"000" & Rt  &  b"000" & Rd  &  b"00" & Funct;
rdbk4_vec  <=	b"000" & RegWrite & b"0000"  &  b"00000000"  &  b"00000000"  &  b"0000" & b"000" & Rs_equals_Rt;
rdbk5_vec  <=   "000" & ALUsrcB_pEX & b"0000"  & b"00000000" & b"0000"   &  b"00" & ALUOP_pEX & "00" & Funct_pEX;
rdbk12_vec  <=	MemWrite_pMem & b"00" & MemToReg_pMEM & b"000" &  RegWrite_pMEM & b"000" & Rd_pMEM & b"000" & MemToReg_pWB & b"000" &  RegWrite_pWB & b"000" & Rd_pWB;



-- ***************************************************************************************************
-- Connect the signals to be tested by the TB
CK_out_to_TB			<=		CK;
RESET_out_to_TB			<=		RESET;
HOLD_out_to_TB			<=		HOLD;
rdbk0_out_to_TB 		<= 		PC_plus_4;
rdbk1_out_to_TB 		<= 		IR_reg; 
rdbk2_out_to_TB 		<= 		sext_imm;
rdbk3_out_to_TB 		<=		rdbk3_vec;
rdbk4_out_to_TB 		<=		rdbk4_vec;
rdbk5_out_to_TB 		<=		rdbk5_vec;
rdbk6_out_to_TB 		<=		A_reg;
rdbk7_out_to_TB 		<= 		B_reg;
rdbk8_out_to_TB 		<=		sext_imm_reg;
rdbk9_out_to_TB 		<= 		ALU_output;
rdbk10_out_to_TB 		<=		ALUout_reg;
rdbk11_out_to_TB 		<= 		B_reg_pMEM;
rdbk12_out_to_TB 		<= 		rdbk12_vec;
rdbk13_out_to_TB 		<=		MDR_reg;
rdbk14_out_to_TB 		<=  	ALUout_reg_pWB;
rdbk15_out_to_TB 		<= 		GPR_wr_data;



-- ***************************************************************************************************
-- Component connections 
-- ============================================================================
-- Components used:  HW4_Host_intf,  Clock_Driver, HW4_MIPS, GPR, MIPS_ALU
-- ============================================================================

-- Connecting the Fetch_Unit
-- =========================================
fetch_unit_imp : Fetch_Unit 
Port map(	
-- general input signals
CK_25MHz		=>      CK,
RESET_in 		=>		RESET,
HOLD_in 		=>		HOLD,
-- MIPS signals
IR_reg_pID		=>		IR_reg,-- connecting IR_reg_pID to the signal called IR_reg
sext_imm_pID	=>		sext_imm,-- same for the signal called sext_imm
PC_plus_4_reg_pID =>	PC_plus_4,
Rs_equals_Rt_pID =>		Rs_equals_Rt,
--- IMem signals
MIPS_IMem_adrs	=>		IMem_adrs,
MIPS_IMem_rd_data =>	IMem_rd_data
);



-- Connecting the GPR file
-- =========================================
GPR_file : GPR
Port map (	
--RST		  =>     not connected
CK			=>	CK,
rd_reg1 	=>	Rs,
rd_reg2 	=>	Rt,
wr_reg 		=>	Rd_pWB,
rd_data1	=>	GPR_rd_data1,
rd_data2	=>	GPR_rd_data2,
wr_data 	=>  GPR_wr_data, 
Reg_Write 	=>  RegWrite_pWB,
GPR_hold 	=>  HOLD --,
	);

	
-- Connecting the MIPS_ALU
-- =========================================
ALU : MIPS_ALU 
Port map(	
-- ALU operation control inputs
ALUOP		=>			ALUOP_pEX,
Funct		=>			Funct_pEX,
-- data inputs & data control inputs
A_in		=>			A_reg,
B_in		=>			B_reg,
sext_imm	=>			sext_imm_reg,
ALUsrcB		=>			ALUsrcB_pEX,
-- data output
ALU_out		=>			ALU_output
		);


-- Connecting the Clock_Driver
-- =========================================
clock_divider : Clock_Driver
port map
 (
  CK_50MHz_IN		=>      CK_50MHz, -- directly form the HW_MIPS i/o pin
  CK_25MHz_OUT		=>      CK -- the CK signal to the entire HW4_MIPS design
  );

  
 -- Connecting the HW4_Host_intf_4sim
-- =========================================
hostintf : HW5_Host_intf_4sim
Port map (	
--
-- MIPS signals   
MIPS_reset		=>   RESET,			--The Host_intf drives the RESET signal
MIPS_hold		=>   HOLD,			--The Host_intf also drives the HOLD signal
MIPS_IMem_adrs 	=>   IMem_adrs,		-- driven by the Fetch_Unit
MIPS_IMem_rd_data => IMem_rd_data,	-- driven by the Host_intf and sent back to the Fetch_Unit
--
MIPS_DMem_adrs 	=>   ALUout_reg,	-- driven by the ALUout_reg = The address to DMem 
MIPS_DMem_rd_data => MDR_reg,		-- The data read from DMem_adrs in lw instruction. It is registered, i.e.= the MDR data 
MIPS_DMem_wr_data => B_reg_pMEM,	-- The data to be written into DMem_adrs in sw instruction 
MIPS_DMem_we	=>   MemWrite_pMEM,	-- '1' if we want to write into DMem at the next rising edge of the MIPS_ck (for sw instruction)
-- RDBK signals    [to be used by students]
rdbk0 			=> 			PC_plus_4,
rdbk1 			=> 			IR_reg,
rdbk2 			=> 			sext_imm,
rdbk3 			=> 			rdbk3_vec,
rdbk4 			=> 			rdbk4_vec,
rdbk5			=> 			rdbk5_vec,
rdbk6			=> 			A_reg,
rdbk7			=> 			B_reg,
rdbk8			=> 			sext_imm_reg,
rdbk9			=> 			ALU_output,
rdbk10			=> 			ALUout_reg,
rdbk11			=> 			B_reg_pMEM,
rdbk12			=> 			rdbk12_vec,
rdbk13			=> 			MDR_reg,
rdbk14			=> 			ALUout_reg_pWB,
rdbk15			=> 			GPR_wr_data,
--
-- Infrastructure signals [To be used by PC via RS232 or from Nexys2 board switches & pushbuttons, and VGA signals to the screen],
-- Host intf signals  -- all of these signals are directly connected to the HW4_MIPS i/o pins
RS232_Rx	=> 		RS232_Rx,
RS232_Tx	=> 		RS232_Tx,
--general signals
CK_25MHz	=> 		CK,
buttons_in	=>		buttons_in,
switches_in	=>		switches_in,
leds_out 	=>		leds_out
); 







end Behavioral;

-- ***************************************************************************************************
-- ***************************************************************************************************

