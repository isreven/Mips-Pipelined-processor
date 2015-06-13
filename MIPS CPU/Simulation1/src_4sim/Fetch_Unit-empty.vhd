--
-- 
-- This module is the Fetch Unit modified for HW4
--  
-- Changes made (from HW2 version) are marked with: --@@@ changes for Rtype MIPS
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

entity Fetch_Unit is
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
MIPS_IMem_rd_data     : in STD_LOGIC_VECTOR (31 downto 0);
jr_adrs_in : in STD_LOGIC_VECTOR(31 downto 0)
		);
end Fetch_Unit; 

architecture Behavioral of Fetch_Unit is
		   
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
signal  IR_reg			: STD_LOGIC_VECTOR  (31 downto 0);
signal  imm 			: STD_LOGIC_VECTOR  (15 downto 0);
signal  sext_imm 		: STD_LOGIC_VECTOR  (31 downto 0);
signal  opcode 			: STD_LOGIC_VECTOR  (5 downto 0);
signal  funct 			: STD_LOGIC_VECTOR  (5 downto 0);
signal  Rs_equals_Rt	: STD_LOGIC;
signal  imm_sign		: STD_LOGIC;
-- PC 
signal  PC_reg			: STD_LOGIC_VECTOR  (31 downto 0);

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
--




--============================= IF phase processes ========================================
--============================= =========================================================

Rs_equals_Rt <= Rs_equals_Rt_pID; --@@@ changes for Rtype MIPS

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
		jump_adrs when others;

-- PC Adder - incrementing PC by 4  (create the PC_plus_4 signal)

	PC_plus_4 <= PC_reg + x"4";

-- IR_reg   (rename of the IMem_rd_data signal)
	IR_reg <= IMem_rd_data;

-- imm sign extension	  (create the sext_imm signal)
imm <= IR_reg(15 downto 0);
process(opcode, imm, imm_sign)
	begin
	imm_sign <= imm(15);

	if opcode = b"001111" then -- lui
		sext_imm <= imm & x"0000";
	elsif imm_sign = '0' or opcode = b"001101" then -- If this is an ORI instruction we shouldn't sign extend the imm.
		sext_imm <= x"0000" & imm;
	else
		sext_imm <= x"FFFF" & imm;
	end if;
end process;

-- BRANCH address  (create the branch_adrs signal)

	branch_adrs <= PC_plus_4_pID + (sext_imm(29 downto 0) & b"00");

-- JUMP address    (create the jump_adrs signal)

	jump_adrs <= PC_plus_4_pID(31 downto 28) & IR_Reg(25 downto 0) & b"00";

-- JR address    (create the jr_adrs signal)  

	jr_adrs <= jr_adrs_in;

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

-- BRANCH address

-- JUMP address

-- instruction decoder
opcode <= IR_reg(31 downto 26);
funct <= IR_reg(5 downto 0);
	
--PC_plus_4_dlyd register

-- PC_source   (create the PC_source signal)
process (opcode,funct,Rs_equals_Rt)
	begin
		if opcode=b"00000" then -- R-type
			if funct=b"001000" then --jr
				PC_source <= b"10";
			else 
				PC_source <= b"00"; -- defualt
			end if;
		elsif opcode=b"00010" then -- jump
			PC_source <= b"11"; -- 
		elsif opcode=b"00011" then --jal
			PC_source <= b"11";
		elsif opcode=b"00100" and Rs_equals_Rt='1' then -- beq
			PC_source <= b"01";
		elsif opcode=b"00101" and Rs_equals_Rt='0' then -- bne
			PC_source <= b"01";
		else 
			PC_source <= b"00";  -- defualt
		end if;
	end process;
	


-- connect output pins									--@@@ changes for Rtype MIPS
PC_plus_4_reg_pID <= PC_plus_4_pID;						--@@@ changes for Rtype MIPS
sext_imm_pID <= sext_imm;								--@@@ changes for Rtype MIPS
IR_reg_pID <= IR_reg;									--@@@ changes for Rtype MIPS

end Behavioral;

-- ***************************************************************************************************
-- ***************************************************************************************************

