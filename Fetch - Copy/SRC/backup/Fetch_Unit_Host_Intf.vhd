--
-- 
-- This module "wraps" the regular BYOC_Host_intf. 
-- It hides the fact that the BYOC_Host_intf is connected to the flash, to the VGA screen,
-- to the KBD and to the 7 segments.
--  
-- We left only the necessary signals for the Fetch_Unit design:
--   RS232 signals - to communicate with the PC BYOCInterface SW 
--   Switches - that control the BYOC_Host_intf
--   Instruction memory signals
--   Rdbks signals - to be read & displayed on the PC screen
--
--      The MIPS memory map is as follows:
--        00400000h - 00400FFCh : IMem   (1Kx32) 
--
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- ***************************************************************************************************
-- ***************************************************************************************************

entity Fetch_Unit_Host_intf is
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
leds_out 		: out STD_LOGIC_VECTOR (7 downto 0)-- to 8 LEDs (leftmost = MIPS_ck, 7 right ones = version number)
		);
end Fetch_Unit_Host_intf; 


architecture Behavioral of Fetch_Unit_Host_intf is
		   

-- all components used:  only BYOC_Host_intf
-- ====================================================

-- ***************************************************************************************************
COMPONENT BYOC_Host_intf is
Port	(	
-- MIPS signals    [to be used by students]
MIPS_reset		: 	out  	STD_LOGIC;
MIPS_hold		: 	out  	STD_LOGIC;--'1' in single ck mode. '1' means ck has no influence. ck works when MIPS_hold='0'. In single_ck we make it '0' for 1 ck period only
-- MIPS IMem signals
MIPS_IMem_adrs 	: 	in  	STD_LOGIC_VECTOR (31 downto 0);-- MIPS read/write address
MIPS_IMem_rd_data :	out		STD_LOGIC_VECTOR (31 downto 0);-- read data (sync read -  at the rising edge of MIPS_ck,  all the time)	
-- MIPS DMem signals
MIPS_DMem_we	:	in		STD_LOGIC;-- '1' when the CPU writes to MIPD_DMem (MIPS_Dmem_wr_data is written to MIPS_DMem_adrs at the rising edge of MIPS_ck), '0' when we do not write
MIPS_DMem_adrs 	: 	in  	STD_LOGIC_VECTOR (31 downto 0);-- MIPS read/write address
MIPS_DMem_wr_data :	in		STD_LOGIC_VECTOR (31 downto 0);-- write data  (sync write - at the rising edge of MIPS_ck, if MIPS_DMem_we='1')		
MIPS_DMem_rd_data :	out		STD_LOGIC_VECTOR (31 downto 0);-- read data (sync read -  at the rising edge of MIPS_ck,  all the time)	
--
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
CK_25MHz 		:	in		STD_LOGIC;
buttons_in		:	in		STD_LOGIC_vector(3 downto 0);--  btn0 is single clock (manual clock), btn3 is manual reset
switches_in		:	in		STD_LOGIC_VECTOR (7 downto 0);-- 4-0 to select which part to be displayed on the 7Segnets LEDs
sevenseg_out	:	out		STD_LOGIC_VECTOR (6 downto 0);-- to the 7 seg LEDs
anodes_out		:	out		STD_LOGIC_VECTOR (3 downto 0);-- to the 7 seg LEDs
leds_out		:	out		STD_LOGIC_VECTOR (7 downto 0);-- 7=Flash_stts, 6=MIPS_ck, 5-0=Host_intf version
--
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
-- Constants 
-- =============================================================


-- signals connecting the components & inputs
-- ==============================================
-- MIPS DMem signals
signal FU_MIPS_DMem_we		:	STD_LOGIC :='0';-- '1' when the CPU writes to MIPD_DMem (MIPS_Dmem_wr_data is written to MIPS_DMem_adrs at the rising edge of MIPS_ck), '0' when we do not write
signal FU_MIPS_DMem_adrs 	: 	STD_LOGIC_VECTOR (31 downto 0) :=(others => '0');-- MIPS read/write address
signal FU_MIPS_DMem_wr_data :	STD_LOGIC_VECTOR (31 downto 0) :=(others => '0');-- write data  (sync write - at the rising edge of MIPS_ck, if MIPS_DMem_we='1')		
signal FU_MIPS_DMem_rd_data :	STD_LOGIC_VECTOR (31 downto 0);-- read data (sync read -  at the rising edge of MIPS_ck,  all the time)	
--
--Flash Mem signals
signal FU_Flash_adrs 		: 	STD_LOGIC_VECTOR (23 downto 1);--Flash read/write address
signal FU_Flash_ce_n		: 	STD_LOGIC;-- '1' when accessing Flash mem
signal FU_Flash_we_n		: 	STD_LOGIC;-- '1' when writing to Flash mem
signal FU_Flash_oe_n		: 	STD_LOGIC;-- '1' when reding from Flash mem
signal FU_Flash_rp_n		: 	STD_LOGIC;-- '0' when reseting Flash mem
signal FU_Flash_sts			: 	STD_LOGIC :='1';-- '1' when Flash mem FSM is done
signal FU_Flash_rd_data		:	STD_LOGIC_VECTOR (15 downto 0) :=(others => '0'); -- data read from Flash mem to be written to Imem or Dmem 
signal FU_Flash_wr_data		:	STD_LOGIC_VECTOR (15 downto 0); -- Date read from Imem or Dmem to be written to Flash
--
-- Infrastructure signals [To be used by PC via RS232 or from Nexys2 board switches & pushbuttons, and VGA signals to the screen],
-- VGA signals
signal FU_VGA_h_sync		: 	STD_LOGIC;
signal FU_VGA_v_sync		: 	STD_LOGIC;
signal FU_VGA_red0			: 	STD_LOGIC;
signal FU_VGA_red1			: 	STD_LOGIC;
signal FU_VGA_red2			: 	STD_LOGIC;
signal FU_VGA_grn0			: 	STD_LOGIC;
signal FU_VGA_grn1			: 	STD_LOGIC;
signal FU_VGA_grn2			: 	STD_LOGIC;
signal FU_VGA_blu1			: 	STD_LOGIC;
signal FU_VGA_blu2			: 	STD_LOGIC;
--PS2 kbd signals
signal FU_PS2_kbd_ck		:	STD_LOGIC :='0';
signal FU_PS2_kbd_data		:	STD_LOGIC:='0';
--
--general signals
signal FU_sevenseg_out 		: STD_LOGIC_VECTOR (6 downto 0);-- to the 7 seg LEDs
signal FU_anodes_out 		: STD_LOGIC_VECTOR (3 downto 0);-- to the 7 seg LEDs
--




-- ***************************************************************************************************

-- Reset and CK signals
signal  RESET 				:STD_LOGIC;
signal  HOLD 				:STD_LOGIC;
signal  RESET_from_Host_Intf :STD_LOGIC;
signal  CK 					:STD_LOGIC;





-- ***************************************************************************************************


begin

											  
											  
-- all other signal equations
-- =============================== CKs & Rest signals ==============================
CK <= CK_25MHz;

RESET <= switches_in(6) or RESET_from_Host_Intf;

MIPS_reset <= RESET;




-- Component connections 
-- =============================================================
hostintf : BYOC_Host_intf
Port map (	
-- MIPS signals    [to be used by students]
MIPS_RESET		=>      RESET_from_Host_Intf,
MIPS_HOLD		=>      MIPS_hold,
-- MIPS IMem signals
MIPS_IMem_adrs 	=>		MIPS_IMem_adrs,
MIPS_IMem_rd_data =>	MIPS_IMem_rd_data,
-- MIPS DMem signals
MIPS_DMem_we	=>		'0',
MIPS_DMem_adrs 	=>		x"00000000",
MIPS_DMem_wr_data =>	x"00000000",		
MIPS_DMem_rd_data =>	FU_MIPS_DMem_rd_data,	
--
--Flash Mem signals
Flash_adrs 		=>		FU_Flash_adrs,
Flash_ce_n 		=>		FU_Flash_ce_n,
Flash_we_n 		=>		FU_Flash_we_n,
Flash_oe_n 		=>		FU_Flash_oe_n,
Flash_rp_n		=>		FU_Flash_rp_n,
Flash_sts		=>		'1',
Flash_rd_data	=>		x"0000",
Flash_wr_data	=>		FU_Flash_wr_data,
--
-- Infrastructure signals [To be used by PC via RS232 or from Nexys2 board switches & pushbuttons, and VGA signals to the screen],
-- Host intf signals
RS232_Rx		=>		RS232_Rx,
RS232_Tx		=>		RS232_Tx,
-- VGA signals
VGA_h_sync		=>		FU_VGA_h_sync,
VGA_v_sync		=>		FU_VGA_v_sync,
VGA_red0		=>		FU_VGA_red0,
VGA_red1		=>		FU_VGA_red1,
VGA_red2		=>		FU_VGA_red2,
VGA_grn0		=>		FU_VGA_grn0,
VGA_grn1		=>		FU_VGA_grn1,
VGA_grn2		=>		FU_VGA_grn2,
VGA_blu1		=>		FU_VGA_blu1,
VGA_blu2		=>		FU_VGA_blu2,
--PS2 kbd signals
PS2_kbd_ck		=>		'0',
PS2_kbd_data	=>		'0',
--general signals
CK_25MHz 		=>		CK_25MHz,
buttons_in		=>		buttons_in,
switches_in 	=>		switches_in,
sevenseg_out 	=>		FU_sevenseg_out,
anodes_out 		=>		FU_anodes_out,
leds_out 		=>		leds_out,
-- RDBK signals
rdbk0			=>		rdbk0,
rdbk1			=>		rdbk1,
rdbk2			=>		rdbk2,
rdbk3			=>		rdbk3,
rdbk4			=>		rdbk4,
rdbk5			=>		rdbk5,
rdbk6			=>		rdbk6,
rdbk7			=>		rdbk7,
rdbk8			=>		rdbk8,
rdbk9			=>		rdbk9,
rdbk10			=>		rdbk10,
rdbk11			=>		rdbk11,
rdbk12			=>		rdbk12,
rdbk13			=>		rdbk13,
rdbk14			=>		rdbk14,
rdbk15			=>		rdbk15
); 



end Behavioral;

-- ***************************************************************************************************
-- ***************************************************************************************************
