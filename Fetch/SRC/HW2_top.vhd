--
-- 
-- This module is the top wrapping the Fetch Unit
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

entity HW2_top is
Port	(	
-- Infrastructure signals [To be used by PC via RS232 or from Nexys2 board switches & pushbuttons, and VGA signals to the screen],
-- Host intf signals
RS232_Rx		: in STD_LOGIC;
RS232_Tx		: out STD_LOGIC;
--
CK_50MHz 		: in STD_LOGIC;
buttons_in		: in STD_LOGIC_vector(3 downto 0);
switches_in 	: in STD_LOGIC_VECTOR (7 downto 0);
leds_out 		: out STD_LOGIC_VECTOR (7 downto 0)-- to 8 LEDs 
--
		);
end HW2_top; 


architecture Behavioral of HW2_top is
		   
-- ***************************************************************************************************
-- ***************************************************************************************************



-- components used:  Fetch_Unit_Host_intf
-- ====================================================

-- ***************************************************************************************************
Component Fetch_Unit is
Port	(	
--
CK_25MHz 		: in STD_LOGIC;
RESET_in 		: in STD_LOGIC;
HOLD_in 		: in STD_LOGIC;
-- IMem signals
MIPS_IMem_adrs	     : out STD_LOGIC_VECTOR (31 downto 0); 
MIPS_IMem_rd_data     : in STD_LOGIC_VECTOR (31 downto 0); 
--rdbk signals
rdbk0			:out STD_LOGIC_VECTOR (31 downto 0); 
rdbk1			:out STD_LOGIC_VECTOR (31 downto 0); 
rdbk2			:out STD_LOGIC_VECTOR (31 downto 0); 
rdbk3			:out STD_LOGIC_VECTOR (31 downto 0); 
rdbk4			:out STD_LOGIC_VECTOR (31 downto 0); 
rdbk5			:out STD_LOGIC_VECTOR (31 downto 0); 
rdbk6			:out STD_LOGIC_VECTOR (31 downto 0); 
rdbk7			:out STD_LOGIC_VECTOR (31 downto 0); 
rdbk8			:out STD_LOGIC_VECTOR (31 downto 0); 
rdbk9			:out STD_LOGIC_VECTOR (31 downto 0); 
rdbk10			:out STD_LOGIC_VECTOR (31 downto 0); 
rdbk11			:out STD_LOGIC_VECTOR (31 downto 0); 
rdbk12			:out STD_LOGIC_VECTOR (31 downto 0); 
rdbk13			:out STD_LOGIC_VECTOR (31 downto 0); 
rdbk14			:out STD_LOGIC_VECTOR (31 downto 0); 
rdbk15			:out STD_LOGIC_VECTOR (31 downto 0) 
		);
END COMPONENT;



COMPONENT Clock_Driver is
port
 (
  CK_50MHz_IN			: in  std_logic ;
  CK_25MHz_OUT			: out std_logic
  );
END COMPONENT;



COMPONENT Fetch_Unit_Host_intf is
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


--- ========================  connection signals  =====================================
--====================================================================================
--general signals 
signal	CK_25MHz_signal		:STD_LOGIC;
signal  RESET_signal 		:STD_LOGIC  :='0';
signal  HOLD_signal 		:STD_LOGIC;
signal	IMem_adrs_signal 	: STD_LOGIC_VECTOR  (31 downto 0);
signal  IMem_rd_data_signal	: STD_LOGIC_VECTOR  (31 downto 0);

-- for rdbk connections
signal  rdbk0_signal		: STD_LOGIC_VECTOR  (31 downto 0);
signal  rdbk1_signal		: STD_LOGIC_VECTOR  (31 downto 0);
signal  rdbk2_signal		: STD_LOGIC_VECTOR  (31 downto 0);
signal  rdbk3_signal		: STD_LOGIC_VECTOR  (31 downto 0);
signal  rdbk4_signal		: STD_LOGIC_VECTOR  (31 downto 0);
signal  rdbk5_signal		: STD_LOGIC_VECTOR  (31 downto 0);
signal  rdbk6_signal		: STD_LOGIC_VECTOR  (31 downto 0);
signal  rdbk7_signal		: STD_LOGIC_VECTOR  (31 downto 0);
signal  rdbk8_signal		: STD_LOGIC_VECTOR  (31 downto 0);
signal  rdbk9_signal		: STD_LOGIC_VECTOR  (31 downto 0);
signal  rdbk10_signal		: STD_LOGIC_VECTOR  (31 downto 0);
signal  rdbk11_signal		: STD_LOGIC_VECTOR  (31 downto 0);
signal  rdbk12_signal		: STD_LOGIC_VECTOR  (31 downto 0);
signal  rdbk13_signal		: STD_LOGIC_VECTOR  (31 downto 0);
signal  rdbk14_signal		: STD_LOGIC_VECTOR  (31 downto 0);
signal  rdbk15_signal		: STD_LOGIC_VECTOR  (31 downto 0);






-- ***************************************************************************************************


begin


-- Connecting the Fetch_Unit_Host_intf_4sim
-- =============================================================
Fetch_unit_imp: Fetch_Unit 
Port map	(	
--
CK_25MHz 	=>		CK_25MHz_signal,
RESET_in 	=>		RESET_signal,
HOLD_in 	=>		HOLD_signal,
-- IMem signals
MIPS_IMem_adrs	=>		IMem_adrs_signal,
MIPS_IMem_rd_data  =>	IMem_rd_data_signal,

--rdbk signals
rdbk0		=>		rdbk0_signal, 
rdbk1		=>		rdbk1_signal,
rdbk2		=>		rdbk2_signal, 
rdbk3		=>		rdbk3_signal, 
rdbk4		=>		rdbk4_signal, 
rdbk5		=>		rdbk5_signal,
rdbk6		=>		rdbk6_signal, 
rdbk7		=>		rdbk7_signal, 
rdbk8		=>		rdbk8_signal, 
rdbk9		=>		rdbk9_signal,
rdbk10		=>		rdbk10_signal,
rdbk11		=>		rdbk11_signal,
rdbk12		=>		rdbk12_signal, 
rdbk13		=>		rdbk13_signal, 
rdbk14		=>		rdbk14_signal, 
rdbk15		=>		rdbk15_signal 
		);



-- Connecting the Fetch_Unit_Host_intf_4sim
-- =============================================================
hostintf : Fetch_Unit_Host_intf
Port map (	
--
-- MIPS signals    [to be used by students]
MIPS_reset		=>   RESET_signal, --The Fetch_Unit_Host_intf drives the RESET signal
MIPS_hold		=>   HOLD_signal, --The Fetch_Unit_Host_intf drives the HOLD signal
MIPS_IMem_adrs 	=>   IMem_adrs_signal, -- driven by the Fetch_Unit
MIPS_IMem_rd_data =>   IMem_rd_data_signal, -- driven by the Fetch_Unit_Host_intf
-- RDBK signals    [to be used by students]
rdbk0 		=> 		rdbk0_signal,
rdbk1 		=> 		rdbk1_signal,
rdbk2 		=> 		rdbk2_signal,
rdbk3 		=> 		rdbk3_signal,
rdbk4 		=> 		rdbk4_signal,
rdbk5 		=> 		rdbk5_signal,
rdbk6 		=> 		rdbk6_signal,
rdbk7 		=> 		rdbk7_signal,
rdbk8 		=> 		rdbk8_signal,
rdbk9 		=> 		rdbk9_signal,
rdbk10 		=> 		rdbk10_signal,
rdbk11 		=> 		rdbk11_signal,
rdbk12 		=> 		rdbk12_signal,
rdbk13 		=> 		rdbk13_signal,
rdbk14 		=> 		rdbk14_signal,
rdbk15 		=> 		rdbk15_signal,
--
-- Infrastructure signals [To be used by PC via RS232 or from Nexys2 board switches & pushbuttons, and VGA signals to the screen],
-- Host intf signals
RS232_Rx	=> 		RS232_Rx,
RS232_Tx	=> 		RS232_Tx,
--general signals
CK_25MHz	=> 		CK_25MHz_signal,
buttons_in	=>		buttons_in,
switches_in	=>		switches_in,
leds_out 	=>		leds_out
); 

clock_divider : Clock_Driver
port map
 (
  CK_50MHz_IN		=>      CK_50MHz,
  CK_25MHz_OUT		=>      CK_25MHz_signal
  );



end Behavioral;

-- ***************************************************************************************************
-- ***************************************************************************************************




