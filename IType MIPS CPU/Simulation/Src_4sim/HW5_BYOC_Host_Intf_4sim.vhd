--
-- 
-- This module "wraps" the regular BYOC_Host_intf. (For simulation, it is actually replaced with a preloaded IMem)
-- It hides the fact that the BYOC_Host_intf is connected to the flash, to the VGA screen,
-- to the KBD and to the 7 segments.
--  
-- We left the signals we already used in HW4_MIPS design:
--   RS232 signals - to communicate with the PC BYOCInterface SW 
--   Switches - that control the BYOC_Host_intf
--   Instruction memory signals
--   Rdbks signals - to be read & displayed on the PC screen
--
--  and added the DMem signals required for the HW5_MIPS
--
--     The MIPS memory map is as follows:
--        00400000h - 00400FFCh : IMem   (1Kx32) 
--        10000000h - 10000004h : DMem   (4x32) -- only 4 addresses for simulation 
--
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- ***************************************************************************************************
-- ***************************************************************************************************

entity HW5_Host_Intf_4sim is
Port	(	
--
-- MIPS signals    [to be used by students]
MIPS_reset		: 	out  	STD_LOGIC;
MIPS_hold		: 	out  	STD_LOGIC;
MIPS_IMem_adrs 	: 	in  	STD_LOGIC_VECTOR (31 downto 0);-- MIPS IMem read address
MIPS_IMem_rd_data :	out		STD_LOGIC_VECTOR (31 downto 0);-- read data (sync read -  at the rising edge of MIPS_ck,  all the time)	
--
MIPS_DMem_adrs	:	in		STD_LOGIC_VECTOR (31 downto 0);-- The address to DMem *read/write)
MIPS_DMem_rd_data :	out		STD_LOGIC_VECTOR (31 downto 0);-- The data read from DMem_adrs in lw instruction. It is registered, i.e.= the MDR data 
MIPS_DMem_wr_data :	in		STD_LOGIC_VECTOR (31 downto 0);-- The data to be written into DMem_adrs in sw instruction 
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
leds_out 	: out STD_LOGIC_VECTOR (7 downto 0)-- to 8 LEDs 
		);
end HW5_Host_Intf_4sim; 


architecture Behavioral of HW5_Host_Intf_4sim is
		   
-- ***************************************************************************************************
-- ***************************************************************************************************


-- signals connecting the components & inputs
-- ==============================================

signal IMem_adrs 	: 	STD_LOGIC_VECTOR (31 downto 0);-- MIPS read/write address
signal IMem_rd_data :	STD_LOGIC_VECTOR (31 downto 0);-- read data (sync read -  at the rising edge of MIPS_ck,  all the time)	

signal DMem_adrs 	: 	STD_LOGIC_VECTOR (31 downto 0);-- MIPS read/write address
signal DMem_rd_data_mux :	STD_LOGIC_VECTOR (31 downto 0);-- read data (async read all the time)	
signal DMem_rd_data :	STD_LOGIC_VECTOR (31 downto 0);-- read data (sync read -  at the rising edge of MIPS_ck,  all the time)	-- i.e., the MDR_reg
signal DMem_wr_data :	STD_LOGIC_VECTOR (31 downto 0);-- write data 
signal DMem_we 		:	STD_LOGIC;-- '1' for we
signal DMem_reg0 	: 	STD_LOGIC_VECTOR (31 downto 0);-- one of the four DMem addresses memory
signal DMem_reg1 	: 	STD_LOGIC_VECTOR (31 downto 0);-- one of the four DMem addresses memory
signal DMem_reg2 	: 	STD_LOGIC_VECTOR (31 downto 0);-- one of the four DMem addresses memory
signal DMem_reg3 	: 	STD_LOGIC_VECTOR (31 downto 0);-- one of the four DMem addresses memory
signal DMem_reg4 	: 	STD_LOGIC_VECTOR (31 downto 0);-- a reg for all other DMem addresses

-- RDBK signals    [to be used by students in real implementation debug]
signal HI_rdbk0 	:	STD_LOGIC_VECTOR (31 downto 0);
signal HI_rdbk1 	:	STD_LOGIC_VECTOR (31 downto 0);
signal HI_rdbk2		:	STD_LOGIC_VECTOR (31 downto 0);
signal HI_rdbk3 	:	STD_LOGIC_VECTOR (31 downto 0);
signal HI_rdbk4 	:	STD_LOGIC_VECTOR (31 downto 0);
signal HI_rdbk5		:	STD_LOGIC_VECTOR (31 downto 0);
signal HI_rdbk6		:	STD_LOGIC_VECTOR (31 downto 0);
signal HI_rdbk7		:	STD_LOGIC_VECTOR (31 downto 0);
signal HI_rdbk8		:	STD_LOGIC_VECTOR (31 downto 0);
signal HI_rdbk9		:	STD_LOGIC_VECTOR (31 downto 0);
signal HI_rdbk10	:	STD_LOGIC_VECTOR (31 downto 0);
signal HI_rdbk11	:	STD_LOGIC_VECTOR (31 downto 0);
signal HI_rdbk12	:	STD_LOGIC_VECTOR (31 downto 0);
signal HI_rdbk13	:	STD_LOGIC_VECTOR (31 downto 0);
signal HI_rdbk14	:	STD_LOGIC_VECTOR (31 downto 0);
signal HI_rdbk15	:	STD_LOGIC_VECTOR (31 downto 0);
--
signal HI_RS232_Rx		: STD_LOGIC;




-- ***************************************************************************************************
-- To create a reset signal at startup
signal  reset_cntr	: STD_LOGIC_VECTOR  (3 downto 0) := x"0";
signal	powerup_reset :STD_LOGIC :='0';

-- Reset and CK signals
signal  RESET :STD_LOGIC :='0';
signal  CK :STD_LOGIC :='0';

signal  hold_cntr	: STD_LOGIC_VECTOR  (7 downto 0) := x"00";
signal  HOLD :STD_LOGIC :='0';




-- ***************************************************************************************************


begin


-- =============================== CKs & Rest signals ==============================
-- CKs
CK <= CK_25MHz;


--power up reset counter & signal
process(CK) 
	begin
		if CK'event and CK='1' then
			if reset_cntr < x"F" then
				reset_cntr <= reset_cntr+1;
			end if;
		end if;
end process;

process(CK) 
	begin
		if CK'event and CK='1' then
			if reset_cntr = x"E" or reset_cntr = x"D" then
				powerup_reset <= '1';
			else
				powerup_reset <= '0';
			end if;
		end if;
end process;

-- RESET
RESET <= switches_in(6) or powerup_reset;
MIPS_reset <= RESET;


-- HOLD signal creation
process(CK, RESET) 
	begin
		if RESET = '1' then
		hold_cntr <= b"00000000";
		elsif CK'event and CK='1' then
			hold_cntr <= hold_cntr + 1;
		end if;
end process;


HOLD <= '1' when hold_cntr=b"01101000" or hold_cntr=b"01101001" or hold_cntr=b"01110010" else '0';-- HOLD depends on hold_cntr used
MIPS_hold <= HOLD;-- HOLD depends on hold_cntr used


-- MIPS IMem 
-- connecting IMem signals to HW4_Host_intf
IMem_adrs <= MIPS_IMem_adrs;
MIPS_IMem_rd_data <= IMem_rd_data; 
-- actual IMem
IMem_wt_data: process (CK)
begin
if CK'event and CK='1' then
	if HOLD = '0' then
		case IMem_adrs is
			when x"00400000" =>     
				IMem_rd_data  <= x"20010001";
			when x"00400004" =>     
				IMem_rd_data  <= x"20020002";
			when x"00400008" =>     
				IMem_rd_data  <= x"20030003";
			when x"0040000C" =>     
				IMem_rd_data  <= x"20040004";
			when x"00400010" =>     
				IMem_rd_data  <= x"20050005";
			when x"00400014" =>     
				IMem_rd_data  <= x"20060006";
			when x"00400018" =>     
				IMem_rd_data  <= x"20070007";
			when x"0040001C" =>     
				IMem_rd_data  <= x"20080008";
			when x"00400020" =>     
				IMem_rd_data  <= x"20090009";
			when x"00400024" =>     
				IMem_rd_data  <= x"200A000A";
			when x"00400028" =>     
				IMem_rd_data  <= x"200B000B";
			when x"0040002C" =>     
				IMem_rd_data  <= x"200C000C";
			when x"00400030" =>     
				IMem_rd_data  <= x"200D000D";
			when x"00400034" =>     
				IMem_rd_data  <= x"200E000E";
			when x"00400038" =>     
				IMem_rd_data  <= x"200F000F";
			when x"0040003C" =>     
				IMem_rd_data  <= x"20100010";
			when x"00400040" =>     
				IMem_rd_data  <= x"20110001";
			when x"00400044" =>     
				IMem_rd_data  <= x"20120002";
			when x"00400048" =>     
				IMem_rd_data  <= x"20130004";
			when x"0040004C" =>     
				IMem_rd_data  <= x"20140008";
			when x"00400050" =>     
				IMem_rd_data  <= x"20150010";
			when x"00400054" =>     
				IMem_rd_data  <= x"20160020";
			when x"00400058" =>     
				IMem_rd_data  <= x"20170040";
			when x"0040005C" =>     
				IMem_rd_data  <= x"20180080";
			when x"00400060" =>     
				IMem_rd_data  <= x"20190100";
			when x"00400064" =>     
				IMem_rd_data  <= x"201B0200";
			when x"00400068" =>     
				IMem_rd_data  <= x"201C0400";
			when x"0040006C" =>     
				IMem_rd_data  <= x"201D0800";
			when x"00400070" =>     
				IMem_rd_data  <= x"201E1000";
			when x"00400074" =>     
				IMem_rd_data  <= x"201F2000";
			when x"00400078" =>     
				IMem_rd_data  <= x"02018020";
			when x"0040007C" =>     
				IMem_rd_data  <= x"02028020";
			when x"00400080" =>     
				IMem_rd_data  <= x"02038020";
			when x"00400084" =>     
				IMem_rd_data  <= x"02048020";
			when x"00400088" =>     
				IMem_rd_data  <= x"00000000";
			when x"0040008C" =>     
				IMem_rd_data  <= x"00000000";
--
--
			when x"00400090" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400094" =>     
				IMem_rd_data  <= x"00220820";
			when x"00400098" =>     
				IMem_rd_data  <= x"00000000";
			when x"0040009C" =>     
				IMem_rd_data  <= x"00000000";
			when x"004000A0" =>     
				IMem_rd_data  <= x"00000000";
			when x"004000A4" =>     
				IMem_rd_data  <= x"00230820";
			when x"004000A8" =>     
				IMem_rd_data  <= x"00000000";
			when x"004000AC" =>     
				IMem_rd_data  <= x"00000000";
			when x"004000B0" =>     
				IMem_rd_data  <= x"00000000";
			when x"004000B4" =>     
				IMem_rd_data  <= x"00810820";
			when x"004000B8" =>     
				IMem_rd_data  <= x"00000000";
			when x"004000BC" =>     
				IMem_rd_data  <= x"00000000";
			when x"004000C0" =>     
				IMem_rd_data  <= x"00000000";
			when x"004000C4" =>     
				IMem_rd_data  <= x"00A10820";
			when x"004000C8" =>     
				IMem_rd_data  <= x"00000000";
			when x"004000CC" =>     
				IMem_rd_data  <= x"00000000";
			when x"004000D0" =>     
				IMem_rd_data  <= x"00000000";
			when x"004000D4" =>     
				IMem_rd_data  <= x"00260820";
			when x"004000D8" =>     
				IMem_rd_data  <= x"00000000";
			when x"004000DC" =>     
				IMem_rd_data  <= x"00000000";
			when x"004000E0" =>     
				IMem_rd_data  <= x"00000000";
			when x"004000E4" =>     
				IMem_rd_data  <= x"00E83820";
			when x"004000E8" =>     
				IMem_rd_data  <= x"00000000";
			when x"004000EC" =>     
				IMem_rd_data  <= x"00000000";
			when x"004000F0" =>     
				IMem_rd_data  <= x"00000000";
			when x"004000F4" =>     
				IMem_rd_data  <= x"00E90820";
			when x"004000F8" =>     
				IMem_rd_data  <= x"00000000";
			when x"004000FC" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400100" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400104" =>     
				IMem_rd_data  <= x"002A0820";
			when x"00400108" =>     
				IMem_rd_data  <= x"00000000";
			when x"0040010C" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400110" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400114" =>     
				IMem_rd_data  <= x"002B0820";
			when x"00400118" =>     
				IMem_rd_data  <= x"00000000";
			when x"0040011C" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400120" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400124" =>     
				IMem_rd_data  <= x"002C0820";
			when x"00400128" =>     
				IMem_rd_data  <= x"00000000";
			when x"0040012C" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400130" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400134" =>     
				IMem_rd_data  <= x"002D0820";
			when x"00400138" =>     
				IMem_rd_data  <= x"00000000";
			when x"0040013C" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400140" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400144" =>     
				IMem_rd_data  <= x"002E0820";
			when x"00400148" =>     
				IMem_rd_data  <= x"00000000";
			when x"0040014C" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400150" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400154" =>     
				IMem_rd_data  <= x"002F0820";
			when x"00400158" =>     
				IMem_rd_data  <= x"00000000";
			when x"0040015C" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400160" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400164" =>     
				IMem_rd_data  <= x"00008020";
			when x"00400168" =>     
				IMem_rd_data  <= x"200F0003";
			when x"0040016C" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400170" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400174" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400178" =>     
				IMem_rd_data  <= x"22100001";
			when x"0040017C" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400180" =>     
				IMem_rd_data  <= x"21EFFFFF";
			when x"00400184" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400188" =>     
				IMem_rd_data  <= x"00000000";
			when x"0040018C" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400190" =>     
				IMem_rd_data  <= x"11E00005";
			when x"00400194" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400198" =>     
				IMem_rd_data  <= x"00000000";
			when x"0040019C" =>     
				IMem_rd_data  <= x"00000000";
			when x"004001A0" =>     
				IMem_rd_data  <= x"0810005E";
			when x"004001A4" =>     
				IMem_rd_data  <= x"00000000";
			when x"004001A8" =>     
				IMem_rd_data  <= x"20011000";-- cont: addi $1,$0,1000h
			when x"004001AC" =>     
				IMem_rd_data  <= x"00000000";
			when x"004001B0" =>     
				IMem_rd_data  <= x"20025555";-- addi $2,$0,5555h
			when x"004001B4" =>     
				IMem_rd_data  <= x"2003AAAA";-- addi $3,$0,AAAAh
			when x"004001B8" =>     
				IMem_rd_data  <= x"00210820";-- add $1,$1,$1  (#1)
			when x"004001BC" =>     
				IMem_rd_data  <= x"00000000";
			when x"004001C0" =>     
				IMem_rd_data  <= x"00000000";
			when x"004001C4" =>     
				IMem_rd_data  <= x"00000000";
			when x"004001C8" =>     
				IMem_rd_data  <= x"00210820";--  (#2)
			when x"004001CC" =>     
				IMem_rd_data  <= x"00000000";
			when x"004001D0" =>     
				IMem_rd_data  <= x"00000000";
			when x"004001D4" =>     
				IMem_rd_data  <= x"00000000";
			when x"004001D8" =>     
				IMem_rd_data  <= x"00210820";-- (#3)
			when x"004001DC" =>     
				IMem_rd_data  <= x"00000000";
			when x"004001E0" =>     
				IMem_rd_data  <= x"00000000";
			when x"004001E4" =>     
				IMem_rd_data  <= x"00000000";
			when x"004001E8" =>     
				IMem_rd_data  <= x"00210820";-- (#4)
			when x"004001EC" =>     
				IMem_rd_data  <= x"00000000";
			when x"004001F0" =>     
				IMem_rd_data  <= x"00000000";
			when x"004001F4" =>     
				IMem_rd_data  <= x"00000000";
			when x"004001F8" =>     
				IMem_rd_data  <= x"00210820";-- (#5)
			when x"004001FC" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400200" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400204" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400208" =>     
				IMem_rd_data  <= x"00210820";-- (#6)
			when x"0040020C" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400210" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400214" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400218" =>     
				IMem_rd_data  <= x"00210820";-- (#7)
			when x"0040021C" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400220" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400224" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400228" =>     
				IMem_rd_data  <= x"00210820";-- (#8)
			when x"0040022C" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400230" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400234" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400238" =>     
				IMem_rd_data  <= x"00210820";-- (#9)
			when x"0040023C" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400240" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400244" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400248" =>     
				IMem_rd_data  <= x"00210820";-- (#10)
			when x"0040024C" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400250" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400254" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400258" =>     
				IMem_rd_data  <= x"00210820";-- (#11)
			when x"0040025C" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400260" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400264" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400268" =>     
				IMem_rd_data  <= x"00210820";-- (#12)
			when x"0040026C" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400270" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400274" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400278" =>     
				IMem_rd_data  <= x"00210820";-- (#13)
			when x"0040027C" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400280" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400284" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400288" =>     
				IMem_rd_data  <= x"00210820";-- (#14)
			when x"0040028C" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400290" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400294" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400298" =>     
				IMem_rd_data  <= x"00210820";-- (#15)
			when x"0040029C" =>     
				IMem_rd_data  <= x"00000000";
			when x"004002A0" =>     
				IMem_rd_data  <= x"00000000";
			when x"004002A4" =>     
				IMem_rd_data  <= x"00000000";
			when x"004002A8" =>     
				IMem_rd_data  <= x"00210820";-- (#16)
			when x"004002AC" =>     
				IMem_rd_data  <= x"00000000";
			when x"004002B0" =>     
				IMem_rd_data  <= x"00000000";
			when x"004002B4" =>     
				IMem_rd_data  <= x"00000000";
			when x"004002B8" =>     
				IMem_rd_data  <= x"AC220000";-- sw $2,0($1)
			when x"004002BC" =>     
				IMem_rd_data  <= x"AC230004";-- sw $3,4($1)
			when x"004002C0" =>     
				IMem_rd_data  <= x"8C240000";-- lw $4,0($1)
			when x"004002C4" =>     
				IMem_rd_data  <= x"8C250004";-- lw $5,4($1)
			when x"004002C8" =>     
				IMem_rd_data  <= x"00000000";
			when x"004002CC" =>     
				IMem_rd_data  <= x"00000000";
			when x"004002D0" =>     
				IMem_rd_data  <= x"00000000";
			when x"004002D4" =>     
				IMem_rd_data  <= x"00A42820";-- add $5,$5,$4
			when x"004002D8" =>     
				IMem_rd_data  <= x"00000000";
			when x"004002DC" =>     
				IMem_rd_data  <= x"00000000";
			when x"004002E0" =>     
				IMem_rd_data  <= x"00000000";
			when x"004002E4" =>     
				IMem_rd_data  <= x"20A50001";-- addi $5,$5,1
			when x"004002E8" =>     
				IMem_rd_data  <= x"00000000";
			when x"004002EC" =>     
				IMem_rd_data  <= x"00000000";
			when x"004002F0" =>     
				IMem_rd_data  <= x"00000000";
			when x"004002F4" =>     
				IMem_rd_data  <= x"14A00007";-- bne $5,$0, errlp
			when x"004002F8" =>     
				IMem_rd_data  <= x"00000000";
			when x"004002FC" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400300" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400304" =>     
				IMem_rd_data  <= x"081000C1";-- endlp:  j endlp
			when x"00400308" =>     
				IMem_rd_data  <= x"00000000";
			when x"0040030C" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400310" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400314" =>     
				IMem_rd_data  <= x"081000C5";-- errlp: j errlp
			when x"00400318" =>     
				IMem_rd_data  <= x"00000000";
			when x"0040031C" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400320" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400324" =>     
				IMem_rd_data  <= x"081000C9";-- endlp2: j endlp2
			when x"00400328" =>     
				IMem_rd_data  <= x"00000000";
			when x"0040032C" =>     
				IMem_rd_data  <= x"00000000";
			when x"00400330" =>     
				IMem_rd_data  <= x"00000000";
--
--
			when others =>     
				IMem_rd_data  <= x"00000000";
		end case;
	end if;
end if;
end process;


-- MIPS DMem 
-- connecting IMem signals to Fetch_Unit_Host_intf
DMem_adrs <= MIPS_DMem_adrs;
MIPS_DMem_rd_data <= DMem_rd_data;
DMem_wr_data <= MIPS_DMem_wr_data;
DMem_we <=  MIPS_DMem_we;
-- actual DMem
DMem_write: process (CK,DMem_adrs,MIPS_DMem_wr_data,DMem_we)
begin
if RESET='1' then
	DMem_reg0	<= 	x"00000000";
	DMem_reg1	<= 	x"00000000";
	DMem_reg2	<= 	x"00000000";
	DMem_reg3	<= 	x"00000000";
	DMem_reg4	<= 	x"00000000";
elsif CK'event and CK='1' then
	if DMem_we ='1' and HOLD='0' then
		case DMem_adrs is
			when x"10000000" =>     
				DMem_reg0	<= 	DMem_wr_data;
			when x"10000004" =>     
				DMem_reg1	<= 	DMem_wr_data;
			when x"10000008" =>     
				DMem_reg2	<= 	DMem_wr_data;
			when x"1000000C" =>     
				DMem_reg3	<= 	DMem_wr_data;
--
			when others =>     
				DMem_reg4  <= DMem_wr_data;
		end case;
	end if;
end if;
end process;


DMem_read_mux: process (DMem_adrs,DMem_reg0,DMem_reg1,DMem_reg2,DMem_reg3,DMem_reg4,CK)
begin
	case DMem_adrs is
		when x"10000000" =>     
            DMem_rd_data_mux  <= DMem_reg0;
		when x"10000004" =>     
            DMem_rd_data_mux  <= DMem_reg1;
		when x"10000008" =>     
            DMem_rd_data_mux  <= DMem_reg2;
		when x"1000000C" =>     
            DMem_rd_data_mux  <= DMem_reg3;
--
		when others =>     
            DMem_rd_data_mux  <= DMem_reg4;
	end case;
end process;


DMem_read_reg: process (RESET,CK)  -- The MDR reg
begin
	if RESET ='1' then
		DMem_rd_data <= x"00000000";
	elsif CK'event and CK='1' and HOLD='0' then
		DMem_rd_data <= DMem_rd_data_mux;
	end if;
end process;



--Not used signals
-- RDBK signals  - connected to not used signals
HI_rdbk0	<=	rdbk0 ;
HI_rdbk1	<=	rdbk1 ;
HI_rdbk2	<=	rdbk2 ;
HI_rdbk3	<=	rdbk3 ;
HI_rdbk4	<=	rdbk4 ;
HI_rdbk5	<=	rdbk5 ;
HI_rdbk6	<=	rdbk6 ;
HI_rdbk7	<=	rdbk7 ;
HI_rdbk8	<=	rdbk8 ;
HI_rdbk9	<=	rdbk9 ;
HI_rdbk10	<=	rdbk10 ;
HI_rdbk11	<=	rdbk11 ;
HI_rdbk12	<=	rdbk12 ;
HI_rdbk13	<=	rdbk13 ;
HI_rdbk14	<=	rdbk14 ;
HI_rdbk15	<=	rdbk15 ;

-- RS232 signal (output is '1', input connected to a not used signal)
RS232_Tx	<= '1';
HI_RS232_Rx	<= RS232_Rx;

leds_out <= b"00000100";


end Behavioral;

-- ***************************************************************************************************
-- ***************************************************************************************************

