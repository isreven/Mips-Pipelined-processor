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

entity Fetch_Unit_Host_intf_4sim is
Port	(	
--
-- MIPS signals    [to be used by students]
MIPS_reset		: 	out  	STD_LOGIC;
MIPS_hold		: 	out  	STD_LOGIC;
MIPS_IMem_adrs 	: 	in  	STD_LOGIC_VECTOR (31 downto 0);-- MIPS read/write address
MIPS_IMem_rd_data :	out		STD_LOGIC_VECTOR (31 downto 0);-- read data (sync read -  at the rising edge of MIPS_ck,  all the time)	
-- RDBK signals    [to be used by students]
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
rdbk15	:	in	STD_LOGIC_VECTOR (31 downto 0);
--
-- Infrastructure signals [To be used by PC via RS232 or from Nexys2 board switches & pushbuttons, and VGA signals to the screen],
-- Host intf signals
RS232_Rx		: in STD_LOGIC;
RS232_Tx		: out STD_LOGIC;
--general signals
CK_25MHz 		: in STD_LOGIC;
buttons_in	: in STD_LOGIC_vector(3 downto 0);--  btn0 is single clock (manual clock), btn3 is manual reset
switches_in : in STD_LOGIC_VECTOR (7 downto 0);-- 4-0 to select which part to be displayed on the 7Segnets LEDs
                                              -- 7-5 to select modes of the BYOC_Host_interface (e.g., single ck, reset, etc.)
leds_out 	: out STD_LOGIC_VECTOR (7 downto 0)-- to 8 LEDs 
		);
end Fetch_Unit_Host_intf_4sim; 


architecture Behavioral of Fetch_Unit_Host_intf_4sim is
		   
-- ***************************************************************************************************
-- ***************************************************************************************************





-- signals connecting the components & inputs
-- ==============================================

signal IMem_adrs 	: 	STD_LOGIC_VECTOR (31 downto 0);-- MIPS read/write address
signal IMem_rd_data :	STD_LOGIC_VECTOR (31 downto 0);-- read data (sync read -  at the rising edge of MIPS_ck,  all the time)	

-- RDBK signals    [to be used by students in real implementation debug]
signal FU_rdbk0 	:	STD_LOGIC_VECTOR (31 downto 0);
signal FU_rdbk1 	:	STD_LOGIC_VECTOR (31 downto 0);
signal FU_rdbk2		:	STD_LOGIC_VECTOR (31 downto 0);
signal FU_rdbk3 	:	STD_LOGIC_VECTOR (31 downto 0);
signal FU_rdbk4 	:	STD_LOGIC_VECTOR (31 downto 0);
signal FU_rdbk5		:	STD_LOGIC_VECTOR (31 downto 0);
signal FU_rdbk6		:	STD_LOGIC_VECTOR (31 downto 0);
signal FU_rdbk7		:	STD_LOGIC_VECTOR (31 downto 0);
signal FU_rdbk8		:	STD_LOGIC_VECTOR (31 downto 0);
signal FU_rdbk9		:	STD_LOGIC_VECTOR (31 downto 0);
signal FU_rdbk10	:	STD_LOGIC_VECTOR (31 downto 0);
signal FU_rdbk11	:	STD_LOGIC_VECTOR (31 downto 0);
signal FU_rdbk12	:	STD_LOGIC_VECTOR (31 downto 0);
signal FU_rdbk13	:	STD_LOGIC_VECTOR (31 downto 0);
signal FU_rdbk14	:	STD_LOGIC_VECTOR (31 downto 0);
signal FU_rdbk15	:	STD_LOGIC_VECTOR (31 downto 0);
--
signal FURS232_Rx		: STD_LOGIC;




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


HOLD <= '1' when hold_cntr=b"00001000" or hold_cntr=b"00001001" or hold_cntr=b"00010010" else '0';-- HOLD depends on hold_cntr used
MIPS_hold <= HOLD;-- HOLD depends on hold_cntr used


-- MIPS IMem 
-- connecting IMem signals to Fetch_Unit_Host_intf
IMem_adrs <= MIPS_IMem_adrs;
MIPS_IMem_rd_data <= IMem_rd_data; 
-- actual IMem
IMem_wt_data: process (CK)
begin
if CK'event and CK='1' then
	if HOLD = '0' then
		case IMem_adrs is
			when x"00400000" =>     
				IMem_rd_data  <= x"FEDC0000";
			when x"00400004" =>     
				IMem_rd_data  <= x"00001111";
			when x"00400008" =>     
				IMem_rd_data  <= x"00002222";
			when x"0040000c" =>     
				IMem_rd_data  <= x"00003333";
			when x"00400010" =>     
				IMem_rd_data  <= x"00004444";
			when x"00400014" =>     
				IMem_rd_data  <= x"14000002";-- bne 2 instructions forward, i.e.,  to 0x40020
			when x"00400018" =>     
				IMem_rd_data  <= x"00006666";
			when x"0040001c" =>     
				IMem_rd_data  <= x"00007777";
			when x"00400020" =>     
				IMem_rd_data  <= x"88888888";
			when x"00400024" =>     
				IMem_rd_data  <= x"00009999";
			when x"00400028" =>     
				IMem_rd_data  <= x"0000AAAA";
			when x"0040002c" =>     
				IMem_rd_data  <= x"0000BBBB";
			when x"00400030" =>     
				IMem_rd_data  <= x"0000CCCC";
			when x"00400034" =>     
				IMem_rd_data  <= x"08100011";-- j to 0x400044 ( inst 0x 100011)
			when x"00400038" =>     
				IMem_rd_data  <= x"0000EEEE";
			when x"0040003c" =>     
				IMem_rd_data  <= x"0000FFFF";
 --	
			when x"00400040" =>     
				IMem_rd_data  <= x"20000000";
			when x"00400044" =>     
				IMem_rd_data  <= x"20001111";
			when x"00400048" =>     
				IMem_rd_data  <= x"20002222";
			when x"0040004c" =>     
				IMem_rd_data  <= x"20003333";
			when x"00400050" =>     
				IMem_rd_data  <= x"00000008";-- jr instruction
			when x"00400054" =>     
				IMem_rd_data  <= x"20005555";
			when x"00400058" =>     
				IMem_rd_data  <= x"20006666";
			when x"0040005c" =>     
				IMem_rd_data  <= x"20007777";
			when x"00400060" =>     
				IMem_rd_data  <= x"20008888";
			when x"00400064" =>     
				IMem_rd_data  <= x"20009999";
			when x"00400068" =>     
				IMem_rd_data  <= x"2000AAAA";
			when x"0040006c" =>     
				IMem_rd_data  <= x"2000BBBB";
			when x"00400070" =>     
				IMem_rd_data  <= x"2000CCCC";
			when x"00400074" =>     
				IMem_rd_data  <= x"2000DDDD";
			when x"00400078" =>     
				IMem_rd_data  <= x"2000EEEE";
			when x"0040007c" =>     
				IMem_rd_data  <= x"29ABCDEF";
--
			when others =>     
				IMem_rd_data  <= x"00000000";
		end case;
    end if;
end if;
end process;




--un-used signals
-- RDBK signals  - connected to nothing
FU_rdbk0	<=	rdbk0 ;
FU_rdbk1	<=	rdbk1 ;
FU_rdbk2	<=	rdbk2 ;
FU_rdbk3	<=	rdbk3 ;
FU_rdbk4	<=	rdbk4 ;
FU_rdbk5	<=	rdbk5 ;
FU_rdbk6	<=	rdbk6 ;
FU_rdbk7	<=	rdbk7 ;
FU_rdbk8	<=	rdbk8 ;
FU_rdbk9	<=	rdbk9 ;
FU_rdbk10	<=	rdbk10 ;
FU_rdbk11	<=	rdbk11 ;
FU_rdbk12	<=	rdbk12 ;
FU_rdbk13	<=	rdbk13 ;
FU_rdbk14	<=	rdbk14 ;
FU_rdbk15	<=	rdbk15 ;
-- RS232 signal (output is '1', input connected to nothing)
RS232_Tx	<= '1';
FURS232_Rx	<= RS232_Rx;

leds_out <= b"00000100";

end Behavioral;

-- ***************************************************************************************************
-- ***************************************************************************************************

