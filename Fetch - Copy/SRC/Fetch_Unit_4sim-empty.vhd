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
rdbk15			:out STD_LOGIC_VECTOR (31 downto 0); 
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





--- ========================  Host intf signals  =====================================
--====================================================================================
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

-- Connecting the Fetch_Unit pins to inner signals
-- =============================================================
-- MIPS signals    [to be used by students]
CK			<=		CK_25MHz;
RESET		<=		RESET_in;
HOLD		<=   	HOLD_in;
MIPS_IMem_adrs 	<=  IMem_adrs;
IMem_rd_data <=		MIPS_IMem_rd_data; 
-- RDBK signals    [to be used by students]
rdbk0 		<= 		PC_reg;
rdbk1 		<= 		PC_plus_4;
rdbk2 		<= 		branch_adrs;
rdbk3 		<= 		jr_adrs;
rdbk4 		<= 		jump_adrs;
rdbk5 		<= 		PC_plus_4_pID;
rdbk6 		<= 		IR_reg;
rdbk7 		<= 		x"00000000";
rdbk8 		<= 		x"00000000";
rdbk9 		<= 		x"00000000";
rdbk10 		<= 		x"00000000";
rdbk11 		<= 		x"00000000";
rdbk12 		<= 		x"00000000";
rdbk13 		<= 		x"00000000";
rdbk14 		<= 		x"00000000";
rdbk15 		<= 		x"00000000";
--




--============================= IF phase processes ========================================
--============================= =========================================================
--PC register

IMem_adrs <= PC_reg; -- connect PC_reg to IMem

	process (CK,RESET)
	begin
		if RESET = '1' then 
			PC_reg <= x"00400000";
		elsif CK'event and CK='1' then
			if HOLD = '0' then
				PC_reg <= PC_mux_out;
			end if;
		end if;
	end process;

--PC source mux

	with PC_source select
		PC_mux_out <=
		PC_plus_4 when "00", 
		branch_adrs when "01",
		jr_adrs when "10",
		jump_adrs when "11";

-- PC Adder - incrementing PC by 4  (create the PC_plus_4 signal)

	PC_plus_4 <= PC_reg + x"4";

-- IR_reg   (rename of the IMem_rd_data signal)

	IR_reg <= IMem_rd_data;

-- imm sign extension	  (create the sext_imm signal)
	imm <= IR_reg(15 downto 0);

	with imm(15 downto 15) select
		sext_imm <=
		x"0000" & imm when b"0",
		x"FFFF" & imm when b"1";
		
-- BRANCH address  (create the branch_adrs signal)
	
	branch_adrs <= PC_plus_4_pID + (sext_imm(29 downto 0) & b"00");

-- JUMP address    (create the jump_adrs signal)

	jump_adrs <= PC_plus_4_pID(31 downto 28) & IR_Reg(25 downto 0) & b"00";

-- JR address    (create the jr_adrs signal)  

	jr_adrs <= x"00400004";
	
--PC_plus_4_dlyd register    (create the PC_plus_4_pID signal)

	process (CK,RESET)
	begin
		if RESET = '1' then 
			PC_plus_4_pID <= b"00000000000000000000000000000000";
		elsif CK'event and CK='1' then
			if HOLD = '0' then
				PC_plus_4_pID <= pc_plus_4;
			end if;
		end if;
	end process;



-- instruction decoder
opcode <= IR_reg(31 downto 26);
funct <= IR_reg(5 downto 0);

-- PC_source   (create the PC_source signal)

process (opcode,funct)
	begin
		if opcode=b"00000" then 
			if funct=b"001000" then
				PC_source <= b"10";
			else 
				PC_source <= b"00";
			end if;
		elsif opcode=b"00010" then
			PC_source <= b"11";
		elsif opcode=b"00011" then
			PC_source <= b"11";
		elsif opcode=b"00100" then
			PC_source <= b"01";
		elsif opcode=b"00101" then
			PC_source <= b"01";
		else 
			PC_source <= b"00";
		end if;
	end process;




-- output signals for TB verification
CK_out_to_TB	<= CK;
RESET_out_to_TB	<= RESET;
HOLD_out_to_TB	<= HOLD;
IR_reg_out_to_TB <= IR_reg;
PC_plus_4_pID_out_to_TB <= PC_plus_4_pID;



end Behavioral;

-- ***************************************************************************************************
-- ***************************************************************************************************




