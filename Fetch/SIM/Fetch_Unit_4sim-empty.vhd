--
-- 
-- This module is the Fetch Unit
--  
--
--   
--
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- ***************************************************************************************************
-- ***************************************************************************************************

entity Fetch_Unit_4sim is
Port	(	
-- Infrastructure signals [To be used by PC via RS232 or from Nexys2 board switches & pushbuttons, and VGA signals to the screen],
-- Host intf signals
RS232_Rx		: in STD_LOGIC;
RS232_Tx		: out STD_LOGIC;
--
CK_50MHz 		: in STD_LOGIC;
buttons_in		: in STD_LOGIC_vector(3 downto 0);
switches_in 	: in STD_LOGIC_VECTOR (7 downto 0);
leds_out 		: out STD_LOGIC_VECTOR (7 downto 0);-- to 8 LEDs 
--
-- signals to be tested by the TB
CK_out_to_TB	: out STD_LOGIC; 
RESET_out_to_TB	: out STD_LOGIC; 
HOLD_out_to_TB	: out STD_LOGIC; 
IR_reg_out_to_TB : out STD_LOGIC_VECTOR (31 downto 0); 
PC_plus_4_pID_out_to_TB : out STD_LOGIC_VECTOR (31 downto 0) 
		);
end Fetch_Unit_4sim; 


architecture Behavioral of Fetch_Unit_4sim is
		   
-- ***************************************************************************************************
-- ***************************************************************************************************



-- components used:  Fetch_Unit_Host_intf
-- ====================================================

-- ***************************************************************************************************
COMPONENT Clock_Driver is
port
 (
  CK_50MHz_IN			: in  std_logic ;
  CK_25MHz_OUT			: out std_logic
  );
END COMPONENT;

COMPONENT Fetch_Unit_Host_intf_4sim is
Port	(	
--
-- MIPS signals    [to be used by students]
MIPS_reset		: 	out  	STD_LOGIC;
MIPS_hold		: 	out  	STD_LOGIC;
MIPS_IMem_adrs 	: 	in  	STD_LOGIC_VECTOR (31 downto 0);-- MIPS read/write address
MIPS_IMem_rd_data :	out		STD_LOGIC_VECTOR (31 downto 0);-- read data (sync read -  at the rising edge of MIPS_ck,  all the time)	
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


--- ========================  Host intf signals  =====================================
--====================================================================================
signal	CK_25MHz		:STD_LOGIC  :='0';-- the ck input to the host interface
signal  RESET 			:STD_LOGIC;-- is coming directly from the Fetch_Unit_Host_intf
signal  CK 				:STD_LOGIC;-- is coming directly from the Fetch_Unit_Host_intf
signal  HOLD 			:STD_LOGIC;-- is coming directly from the Fetch_Unit_Host_intf
signal	IMem_adrs 		: STD_LOGIC_VECTOR  (31 downto 0);
signal  IMem_rd_data	: STD_LOGIC_VECTOR  (31 downto 0);


--- ========================  MIPS signals  ==========================================
--====================================================================================

--=========================== IF phase ===============================================
--====================================================================================
-- IR & related signals
signal  IR_reg			: STD_LOGIC_VECTOR  (31 downto 0) := x"00000000";
signal  imm 			: STD_LOGIC_VECTOR  (15 downto 0);
signal  sext_imm 		: STD_LOGIC_VECTOR  (31 downto 0);
signal  opcode 			: STD_LOGIC_VECTOR  (5 downto 0);
signal  funct 			: STD_LOGIC_VECTOR  (5 downto 0);

-- PC 
signal  PC_reg			: STD_LOGIC_VECTOR  (31 downto 0) := x"00000000";

-- PC_mux
-- control 
signal  PC_Source 		: STD_LOGIC_VECTOR  (1 downto 0);-- 0=PC+4, 1=BRANCH, 2=JR, 3=JUMP 
-- inputs to PC_mux
signal  PC_plus_4 		: STD_LOGIC_VECTOR  (31 downto 0);
signal  jump_adrs 		: STD_LOGIC_VECTOR  (31 downto 0);
signal  branch_adrs 	: STD_LOGIC_VECTOR  (31 downto 0);
signal  jr_adrs 		: STD_LOGIC_VECTOR  (31 downto 0);
-- output
signal  PC_mux_out		: STD_LOGIC_VECTOR  (31 downto 0);


signal  PC_plus_4_pID 	: STD_LOGIC_VECTOR  (31 downto 0);
--- ================== End of MIPS signals ==========================================
--- =================================================================================






-- ***************************************************************************************************


begin

-- Connecting the Fetch_Unit_Host_intf_4sim
-- =============================================================
hostintf : Fetch_Unit_Host_intf_4sim
Port map (	
--
-- MIPS signals    [to be used by students]
MIPS_reset		=>   RESET, --The Fetch_Unit_Host_intf drives the RESET signal directly
MIPS_hold		=>   HOLD, --The Fetch_Unit_Host_intf drives the HOLD signal directly
MIPS_IMem_adrs 	=>   IMem_adrs,
MIPS_IMem_rd_data =>   IMem_rd_data,
-- RDBK signals    [to be used by students]
rdbk0 		=> 		PC_reg,
rdbk1 		=> 		PC_plus_4,
rdbk2 		=> 		branch_adrs,
rdbk3 		=> 		jr_adrs,
rdbk4 		=> 		jump_adrs,
rdbk5 		=> 		PC_plus_4_pID,
rdbk6 		=> 		IR_reg,
rdbk7 		=> 		x"00000000",
rdbk8 		=> 		x"00000000",
rdbk9 		=> 		x"00000000",
rdbk10 		=> 		x"00000000",
rdbk11 		=> 		x"00000000",
rdbk12 		=> 		x"00000000",
rdbk13 		=> 		x"00000000",
rdbk14 		=> 		x"00000000",
rdbk15 		=> 		x"00000000",
--
-- Infrastructure signals [To be used by PC via RS232 or from Nexys2 board switches & pushbuttons, and VGA signals to the screen],
-- Host intf signals
RS232_Rx	=> 		RS232_Rx,
RS232_Tx	=> 		RS232_Tx,
--general signals
CK_25MHz	=> 		CK_25MHz,
buttons_in	=>		buttons_in,
switches_in	=>		switches_in,
leds_out 	=>		leds_out
); 

clock_divider : Clock_Driver
port map
 (
  CK_50MHz_IN		=>      CK_50MHz,
  CK_25MHz_OUT		=>      CK_25MHz
  );


-- RESET
--RESET <= MIPS_reset from Fetch_Unit_Host_intf is connected directly to the RESET signal

-- HOLD
--HOLD <= MIPS_hold from Fetch_Unit_Host_intf is connected directly to the HOLD signal

-- CK
CK <=  CK_25MHz;



--============================= IF phase processes ========================================
--============================= =========================================================
--PC register

IMem_adrs <= PC_reg; -- connect PC_reg to IMem

--PC source mux


-- PC Adder - incrementing PC by 4  (create the PC_plus_4 signal)


-- IR_reg   (rename of the IMem_rd_data signal)


-- imm sign extension	  (create the sext_imm signal)


-- BRANCH address  (create the branch_adrs signal)


-- JUMP address    (create the jump_adrs signal)


-- JR address    (create the jr_adrs signal)  

	
--PC_plus_4_dlyd register    (create the PC_plus_4_pID signal)


-- instruction decoder
opcode <= IR_reg(31 downto 26);
funct <= IR_reg(5 downto 0);


-- PC_source   (create the PC_source signal)


-- output signals for TB verification
CK_out_to_TB	<= CK;
RESET_out_to_TB	<= RESET;
HOLD_out_to_TB	<= HOLD;
IR_reg_out_to_TB <= IR_reg;
PC_plus_4_pID_out_to_TB <= PC_plus_4_pID;



end Behavioral;

-- ***************************************************************************************************
-- ***************************************************************************************************




