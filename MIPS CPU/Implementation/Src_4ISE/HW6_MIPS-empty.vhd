--
-- 
-- This module is the HW6_MIPS CPU implementation     see --@@@HW6 for HW6 related changes
--  
--
-- It supports Rtype instructions of: add, sub, and, or, xor, slt    
-- It also supports addi, beq, bne, lw & sw instructions
-- It also supports lui, ori, jr & jal instructions
-- 
-- There are 5 phases: IF, ID, EX, MEM, WB
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- ***************************************************************************************************
-- ***************************************************************************************************

entity HW6_MIPS is
Port	(	
-- Infrastructure signals [To be used by PC via RS232 or from Nexys2 board switches & pushbuttons, and VGA signals to the screen],
-- Infrastructure signals [To be used by PC via RS232 or from Nexys2 board switches & pushbuttons, and VGA signals to the screen],
-- Host intf signals
RS232_Rx		: in STD_LOGIC;
RS232_Tx		: out STD_LOGIC;
-- VGA signals
VGA_h_sync		: 	out  	STD_LOGIC;
VGA_v_sync		: 	out  	STD_LOGIC;
VGA_red0		: 	out  	STD_LOGIC;
VGA_red1		: 	out  	STD_LOGIC;
VGA_red2		: 	out  	STD_LOGIC;
VGA_grn0		: 	out  	STD_LOGIC;
VGA_grn1		: 	out  	STD_LOGIC;
VGA_grn2		: 	out  	STD_LOGIC;
VGA_blu1		: 	out  	STD_LOGIC;
VGA_blu2		: 	out  	STD_LOGIC;
--Flash Mem signals
MT_ce_n			: 	out  	STD_LOGIC;-- '0' when accessing MOBILE SDRAM mem
Flash_adrs 		: 	out		STD_LOGIC_VECTOR (23 downto 1);--Flash read/write address
Flash_ce_n		: 	out  	STD_LOGIC;-- '0' when accessing Flash mem
Flash_we_n		: 	out  	STD_LOGIC;-- '0' when writing to Flash mem
Flash_oe_n		: 	out  	STD_LOGIC;-- '0' when reding from Flash mem
Flash_rp_n		: 	out  	STD_LOGIC;-- '0' when reseting Flash mem
Flash_sts		: 	in  	STD_LOGIC;-- '1' when Flash mem FSM is done
Flash_data		:	inout	STD_LOGIC_VECTOR (15 downto 0); -- Date read from Imem or Dmem to be written to Flash mem or data read from Flash mem to be written to Imem or Dmem 
--
PS2C			: 	in  	STD_LOGIC;-- PS2 keyboard clock
PS2D			: 	in  	STD_LOGIC;-- PS2 keyboard data
--general signals
leds_out		:	out		STD_LOGIC_VECTOR (7 downto 0);-- 7=Flash_stts, 6=MIPS_ck, 5-0=Host_intf version
CK_50MHz 		:	in		STD_LOGIC;
buttons_in		:	in		STD_LOGIC_vector(3 downto 0);--  btn0 is single clock (manual clock), btn3 is manual reset
switches_in 	:	in		STD_LOGIC_VECTOR (7 downto 0);-- 4-0 to select which part to be displayed on the 7Segnets LEDs
sevenseg_out	:	out		STD_LOGIC_VECTOR (6 downto 0);-- to the 7 seg LEDs
anodes_out		:	out		STD_LOGIC_VECTOR (3 downto 0)-- to the 7 seg LEDs
		);
end HW6_MIPS; 


architecture Behavioral of HW6_MIPS is
		   
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
CK_25MHz 		: 	in		STD_LOGIC;
RESET_in 		: 	in 		STD_LOGIC;
HOLD_in 		: 	in 		STD_LOGIC;
-- MIPS signals
IR_reg_pID		:	out		STD_LOGIC_VECTOR  (31 downto 0);-- The IR_reg (instruction) to be used in ID 
sext_imm_pID	:	out		STD_LOGIC_VECTOR  (31 downto 0);-- The sext_imm to be used in ID 
PC_plus_4_reg_pID :	out		STD_LOGIC_VECTOR  (31 downto 0);-- to be read by TB in simulatio and rdbk in implementation - for verification purposes 
Rs_equals_Rt_pID  : in  	STD_LOGIC;-- '1' if value read from Rs equals the value read from Rt, '0' otherwise. Used in branch instructions.
--- IMem signals
MIPS_IMem_adrs	: 	out 	STD_LOGIC_VECTOR (31 downto 0); 
MIPS_IMem_rd_data : in 		STD_LOGIC_VECTOR (31 downto 0); 
jr_adrs_in		:	in		STD_LOGIC_VECTOR  (31 downto 0)--;--@@@HW6 JR support -- the GPR_rd_data1 value to be load into the PC in jr instruction   --@@@HW6 add JR support
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
COMPONENT BYOC_Host_intf is
Port	(	
--=========================The student's part=================================
-- MIPS signals    [to be used by students]
MIPS_reset		: 	out  	STD_LOGIC; -- output to the Student's design
MIPS_hold		: 	out  	STD_LOGIC; -- output to the Student's design
-- MIPS IMem signals
MIPS_IMem_adrs 	: 	in  	STD_LOGIC_VECTOR (31 downto 0);-- MIPS IMem read address  
MIPS_IMem_rd_data :	out		STD_LOGIC_VECTOR (31 downto 0);-- read data (sync read -  at the rising edge of MIPS_ck,  all the time)	
-- MIPS DMem signals
MIPS_DMem_we	:	in		STD_LOGIC;-- '1' when the CPU writes to MIPD_DMem (MIPS_Dmem_wr_data is written to MIPS_DMem_adrs at the rising edge of MIPS_ck), '0' when we do not write
MIPS_DMem_adrs 	: 	in  	STD_LOGIC_VECTOR (31 downto 0);-- MIPS DMem read/write address
MIPS_DMem_wr_data :	in		STD_LOGIC_VECTOR (31 downto 0);-- write data  (sync write - at the rising edge of MIPS_ck, if MIPS_DMem_we='1')		
MIPS_DMem_rd_data :	out		STD_LOGIC_VECTOR (31 downto 0);-- read data (sync read -  at the rising edge of MIPS_ck,  all the time)	
--
--============================Other signals to be directed to i/o pins==============================
--Flash Mem signals
Flash_adrs 		: 	out		STD_LOGIC_VECTOR (23 downto 1);--Flash read/write address
Flash_ce_n		: 	out  	STD_LOGIC;-- '1' when accessing Flash mem
Flash_we_n		: 	out  	STD_LOGIC;-- '1' when writing to Flash mem
Flash_oe_n		: 	out  	STD_LOGIC;-- '1' when reding from Flash mem
Flash_rp_n		: 	out  	STD_LOGIC;-- '0' when reseting Flash mem
Flash_sts		: 	in  	STD_LOGIC;-- '1' when Flash mem FSM is done
Flash_rd_data	:	in		STD_LOGIC_VECTOR (15 downto 0); -- data read from Flash mem to be written to Imem or Dmem 
Flash_wr_data	:	out		STD_LOGIC_VECTOR (15 downto 0); -- Date read from Imem or Dmem to be written to Flash
--
-- Infrastructure signals [To be used by PC via RS232 or from Nexys2 board switches & pushbuttons, and VGA signals to the screen],
-- Host intf signals
RS232_Rx		: in STD_LOGIC;
RS232_Tx		: out STD_LOGIC;
-- VGA signals
VGA_h_sync		: 	out  	STD_LOGIC;
VGA_v_sync		: 	out  	STD_LOGIC;
VGA_red0		: 	out  	STD_LOGIC;
VGA_red1		: 	out  	STD_LOGIC;
VGA_red2		: 	out  	STD_LOGIC;
VGA_grn0		: 	out  	STD_LOGIC;
VGA_grn1		: 	out  	STD_LOGIC;
VGA_grn2		: 	out  	STD_LOGIC;
VGA_blu1		: 	out  	STD_LOGIC;
VGA_blu2		: 	out  	STD_LOGIC;
--PS2 kbd signals
PS2_kbd_ck		:	in  	STD_LOGIC;
PS2_kbd_data	:	in  	STD_LOGIC;
--
--general signals
CK_25MHz 			: in STD_LOGIC; -- main clock input to the Host interface. From this clock we create all other clock signals in the design
buttons_in	: in STD_LOGIC_vector(3 downto 0);--  btn0 is single clock (manual clock), btn3 is manual reset
switches_in : in STD_LOGIC_VECTOR (7 downto 0);-- 4-0 to select which part to be displayed on the 7Segnets LEDs
sevenseg_out : out STD_LOGIC_VECTOR (6 downto 0);-- to the 7 seg LEDs
anodes_out 	: out STD_LOGIC_VECTOR (3 downto 0);-- to the 7 seg LEDs
leds_out 	: out STD_LOGIC_VECTOR (7 downto 0);-- to 8 LEDs (leftmost = Flash status, next = MIPS_ck, 6 right ones = version number)
--
--=========================additional part for the student=================================
-- RDBK signals
rdbk0 	:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk1 	:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk2	:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk3 	:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk4 	:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk5	:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk6	:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk7	:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk8	:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk9	:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk10	:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk11	:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk12	:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk13	:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk14	:	in	STD_LOGIC_VECTOR (31 downto 0);
rdbk15	:	in	STD_LOGIC_VECTOR (31 downto 0)
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
signal  RESET_from_host_intf :STD_LOGIC;-- is coming from the BYOC_Host_intf




-- Flash data bus signals (used to connect to the Flash_data "inout" pin)
signal  data_from_Flash	: STD_LOGIC_VECTOR  (15 downto 0);
signal  data_to_Flash	: STD_LOGIC_VECTOR  (15 downto 0);
-- Flasn control signals
signal	Flash_ce_n_line :STD_LOGIC;
signal	Flash_we_n_line :STD_LOGIC;
signal	Flash_oe_n_line :STD_LOGIC;

signal	Flash_rp_n_in_BYOC		: 	STD_LOGIC;-- '0' when reseting Flash mem
signal	Flash_sts_in_BYOC		: 	STD_LOGIC;-- '1' when Flash mem FSM is done

signal	leds_out_from_host_intf	: STD_LOGIC_VECTOR  (7 downto 0);-- 7=Flash_stts, 6=MIPS_ck, 5-0=Host_intf version




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

--@@@HW6 add JR support
signal jr_address	: STD_LOGIC_VECTOR  (31 downto 0);--the Rs value (usually from GPR_rd_data1) to be loaded into the PC in jr instruction

--@@@HW6 adding branch forwarding
signal  A_val_wt_fwd	: STD_LOGIC_VECTOR  (31 downto 0);--@@@HW6 adding branch forwarding
signal  B_val_wt_fwd	: STD_LOGIC_VECTOR  (31 downto 0);--@@@HW6 adding branch forwarding


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

signal	JAL		:  STD_LOGIC;-- '1' in JAL instruction --@@@HW6 adding JAL instruction


--=========================== EX phase ===============================================
--===================================================================================
--Registerd valid in EX phase  
signal  A_reg	: STD_LOGIC_VECTOR  (31 downto 0);
signal  B_reg	: STD_LOGIC_VECTOR  (31 downto 0);
signal  sext_imm_reg : STD_LOGIC_VECTOR  (31 downto 0);
signal  Rt_pEX	: STD_LOGIC_VECTOR  (4 downto 0);
signal  Rd_pEX	: STD_LOGIC_VECTOR  (4 downto 0);
signal  ALU_output	: STD_LOGIC_VECTOR  (31 downto 0);

signal  PC_plus_4_pEX : STD_LOGIC_VECTOR  (31 downto 0); 	--@@@HW6 adding JAL instruction

signal  A_reg_wt_fwd	: STD_LOGIC_VECTOR  (31 downto 0);	--@@@HW6 adding data forwarding
signal  B_reg_wt_fwd	: STD_LOGIC_VECTOR  (31 downto 0);	--@@@HW6 adding data forwarding
signal  Rs_pEX	: STD_LOGIC_VECTOR  (4 downto 0);			--@@@HW6 adding data forwarding



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

signal  JAL_pEX	:	STD_LOGIC;--@@@HW6 adding JAL instruction


--=========================== MEM phase ===============================================
--===================================================================================
--Registers valid in EX phase  
signal  B_reg_pMEM	: STD_LOGIC_VECTOR  (31 downto 0);
signal  Rd_pMEM		: STD_LOGIC_VECTOR  (4 downto 0);
signal  ALUout_reg	: STD_LOGIC_VECTOR  (31 downto 0);

signal  PC_plus_4_pMEM : STD_LOGIC_VECTOR  (31 downto 0); --@@@HW6 adding JAL instruction


-- MIPS control signals - created at the ID phase - delayed to EX phase
-------------------------------------------------------------------------------------------
-- Decoded signals for MEM phase
signal  RegWrite_pMEM : STD_LOGIC;
signal  MemWrite_pMEM : STD_LOGIC;
signal  MemToReg_pMEM : STD_LOGIC;

signal  JAL_pMEM	:	STD_LOGIC;--@@@HW6 adding JAL instruction



--=========================== WB phase ===============================================
--===================================================================================
--Registers valid in WB phase 
signal  MDR_reg	: STD_LOGIC_VECTOR  (31 downto 0); -- renaming of the MIPS_DMem_rd_data signal
signal  ALUout_reg_pWB	: STD_LOGIC_VECTOR  (31 downto 0); 
signal  GPR_wr_data	: STD_LOGIC_VECTOR  (31 downto 0);
signal  Rd_pWB : STD_LOGIC_VECTOR  (4 downto 0);

signal  PC_plus_4_pWB : STD_LOGIC_VECTOR  (31 downto 0); --@@@HW6 adding JAL instruction


--signals valid in WB phase
-- MIPS control signals - created at the ID phase - delayed to WB phase
---------------------------------------------------------------------------------------------
-- Decoded signals for WB phase
signal  RegWrite_pWB : STD_LOGIC;
signal  MemToReg_pWB : STD_LOGIC;

signal  JAL_pWB	:	STD_LOGIC;--@@@HW6 adding JAL instruction


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


--  Signals to external components 
--==============================
-- disconnecting the Mobile SRAM
MT_ce_n <= '1';-- making sure that the SRAM is not active

-- connecting Flash_data bidir signal
data_from_Flash	<= Flash_data;
Flash_data <= data_to_Flash	when (Flash_oe_n_line ='1' and Flash_ce_n_line='0') else (others => 'Z');

-- connecting other Flash signals
Flash_ce_n <= Flash_ce_n_line;
Flash_oe_n <= Flash_oe_n_line;
Flash_we_n <= Flash_we_n_line;

Flash_rp_n	<=	Flash_rp_n_in_BYOC and (not switches_in(4));
Flash_sts_in_BYOC <= Flash_sts;

--leds_out(7) <=  Flash_sts_in_BYOC;
leds_out <=  Flash_sts_in_BYOC & leds_out_from_host_intf(6 downto 0);-- 7=Flash_stts, 6=MIPS_ck, 5-0=Host_intf version


-- General signals
--==========================
RESET <= switches_in(6) or RESET_from_Host_Intf;



--============================= IF phase processes ========================================
--============================= =========================================================
-- no such processes. They are all inside the Fetch Unit	

--============================= ID phase processes ========================================
--============================= =========================================================
-- IR fields signals
Opcode <= IR_reg(31 downto 26);
Rs <= IR_reg(25 downto 21); --@@@HW6 a change is required here to support JAL 
Rt <= IR_reg(20 downto 16);
Rd <= IR_reg(15 downto 11);
Funct <= IR_reg(5 downto 0);

	
--beq & bne & jr forwarding  				--@@@HW6 adding branch & JR forwarding
--A mux of the Rs_equal_Rt comparator (beq/bne forwarding)

--Bmux of the Rs_equal_Rt comparator (beq/bne forwarding)				--@@@HW6 adding branch & JR forwarding
	
	
--beq/bne comparator    --@@@HW6 adding branch forwarding means a change here


----@@@HW6 add JR support   -- HW6 adding JR forwarding means a change here
jr_address  <= ??? 



-- Control decoder  - calculates the signals in ID phase
-- creates the following signals according to the opcode:
--		ALUsrcB		 '0' - selects B_reg, '1' - selects sext_imm_reg
--		ALUOP		 b"00" - add, b"01" - sub, b"10" - the Function field determines the ALU operation, b"11" - or --@@@HW6 adding  ORI support 
--		RegDst		 '1' - "Rd"=Rd (write to Rd - in Rtype inst. only),  '0' - "Rd"=Rt (write to Rt - in all other inst.)
--		MemWrite	 '1' - write to DMem
--		MemToReg	 '0' - write ALUout_reg data (to "Rd"), '1' - write MDR_reg data (to "Rd")
--		RegWrite	 '1' - write to GPR file (to "Rd")
--		JAL	         '1' - wrhen we are in jal instruction --@@@HW6 adding  JAL support 




--============================= EX phase processes ========================================
--======================================================================================
--A & B registers


-- with forwarding															-- @@@HW6 adding data forwarding
--src_A mux (forwarding)													-- @@@HW6 adding data forwarding in EX phase			

--src B mux (forwarding part) 												-- @@@HW6 adding data forwarding in EX phase



--sext_imm register


-- Rs register   --@@@HW6 added for data forwarding support

-- Rt register 

-- Rd register


-- PC_plus_4_pEX --@@@HW6 added to support JAL instruction


-- control signals regs  --@@@HW6  add JAL support here to



--============================= MEM phase processes ========================================
--========================================================================================
--ALUOUT register


--B delayed reg    --@@@HW6 need a change for data forwarding support 


-- RegDst mux and Rd_pMEM register


-- PC_plus_4_pMEM reg --@@@HW6 added to support JAL instruction


-- RegWrite_pMEM, MemToReg_pMEM, MemWrite_pEX FFs  --@@@HW6  add JAL_pMEM to support JAL



--============================= WB phase processes ========================================
--========================================================================================
-- MDR_reg -- connected directly from HW5_Host_intf - no need to do nothing

--ALUout_pWB register


--  MemToReg mux     --@@@HW6 requires changes to support JAL instruction


-- Rd_pWB register


-- PC_plus_4_pWB --@@@HW6 added to support JAL instruction


-- RegWrite_pWB, MemToReg_pWB FFs   --@@@HW6 added JAL_pWB FF to support JAL instruction  



-- ***************************************************************************************************
-- build special rdbk signals
rdbk3_vec  <=	b"000" & Rs  &  b"000" & Rt  &  b"000" & Rd  &  b"00" & Funct;
rdbk4_vec  <=	b"000" & RegWrite & b"0000"  &  b"00000000"  &  b"00000000"  &  b"0000" & b"000" & Rs_equals_Rt;
rdbk5_vec  <=   "000" & ALUsrcB_pEX & b"0000"  & b"00000000" & b"0000"   &  b"00" & ALUOP_pEX & "00" & Funct_pEX;
rdbk12_vec  <=	MemWrite_pMem & b"00" & MemToReg_pMEM & b"000" &  RegWrite_pMEM & b"000" & Rd_pMEM & b"000" & MemToReg_pWB & b"000" &  RegWrite_pWB & b"000" & Rd_pWB;



-- ***************************************************************************************************



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
MIPS_IMem_rd_data =>	IMem_rd_data,
jr_adrs_in		=>		jr_address --@@@HW6 changed for JR support
);



-- Connecting the GPR file
-- =========================================
GPR_file : GPR
Port map (	
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
A_in		=>			A_reg,   -- @@@HW6 should be A_reg_wt_fwd for adding data forwarding in EX phase
B_in		=>			B_reg,   -- @@@HW6 should be B_reg_wt_fwd for adding data forwarding in EX phase
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

  
-- Connecting the BYOC_Host_intf
-- =========================================
hostintf :  BYOC_Host_intf 
Port Map(	
--=========================The student's part=================================
-- MIPS signals    [to be used by students]
MIPS_reset			=>		RESET_from_host_intf, --The Host_intf drives the RESET signal
MIPS_hold			=>		HOLD,	--The Host_intf also drives the HOLD signal
-- MIPS IMem signals
MIPS_IMem_adrs		=>		IMem_adrs,		-- driven by the Fetch_Unit
MIPS_IMem_rd_data	=>		IMem_rd_data,	-- driven by the Host_intf and sent to the Fetch_Unit
-- MIPS DMem signals
MIPS_DMem_we		=>		MemWrite_pMEM,	-- '1' if we want to write into DMem at the next rising edge of the MIPS_ck (for sw instruction)
MIPS_DMem_adrs		=>		ALUout_reg,	-- driven by the ALUout_reg = The address to DMem 
MIPS_DMem_wr_data	=>		B_reg_pMEM,	-- The data to be written into DMem_adrs in sw instruction 	
MIPS_DMem_rd_data	=>		MDR_reg,		-- The data read from DMem_adrs in lw instruction. It is registered, i.e.= the MDR data 
--
--============================Other signals to be directed to i/o pins==============================
--Flash Mem signals
Flash_adrs 			=>		Flash_adrs,
Flash_ce_n			=>		Flash_ce_n_line,
Flash_we_n			=>		Flash_we_n_line,
Flash_oe_n			=>		Flash_oe_n_line,
Flash_rp_n			=>		Flash_rp_n_in_BYOC,
Flash_sts			=>		Flash_sts,
Flash_rd_data		=>		data_from_Flash,
Flash_wr_data		=>		data_to_Flash,
--
-- Infrastructure signals [To be used by PC via RS232 or from Nexys2 board switches & pushbuttons, and VGA signals to the screen],
-- Host intf signals
RS232_Rx			=>		RS232_Rx,
RS232_Tx			=>		RS232_Tx,
-- VGA signals
VGA_h_sync			=>		VGA_h_sync,
VGA_v_sync			=>		VGA_v_sync,
VGA_red0			=>		VGA_red0,
VGA_red1			=>		VGA_red1,
VGA_red2			=>		VGA_red2,
VGA_grn0			=>		VGA_grn0,
VGA_grn1			=>		VGA_grn1,
VGA_grn2			=>		VGA_grn2,
VGA_blu1			=>		VGA_blu1,
VGA_blu2			=>		VGA_blu2,
--PS2 kbd signals
PS2_kbd_ck			=>		PS2C,
PS2_kbd_data		=>		PS2D,
--
--general signals
CK_25MHz			=>		CK, -- CK_25MHz from the Clock_Driver
buttons_in			=>		buttons_in,
switches_in			=>		switches_in,
sevenseg_out		=>		sevenseg_out,
anodes_out			=>		anodes_out,
leds_out			=>		leds_out_from_host_intf,
--
--=========================additional part for the student=================================
-- RDBK signals
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
rdbk15			=> 			GPR_wr_data
);









end Behavioral;

-- ***************************************************************************************************
-- ***************************************************************************************************

