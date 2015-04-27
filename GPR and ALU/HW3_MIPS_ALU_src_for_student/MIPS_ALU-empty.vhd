--
-- 
-- This module is the MIPS ALU 
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

entity MIPS_ALU is
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
end MIPS_ALU;
 

architecture Behavioral of MIPS_ALU is
		   
-- ***************************************************************************************************
-- ***************************************************************************************************


-- inner signals
-- ====================================================
signal  ALU_cmd : STD_LOGIC_VECTOR  (2 downto 0);-- 000=AND, 001=OR, 010=ADD, 011=XOR, 110=sub, 111=slt, 100,101= not used for now
signal  ALU_A_in  : STD_LOGIC_VECTOR  (31 downto 0);
signal  ALU_B_in  : STD_LOGIC_VECTOR  (31 downto 0);
signal  ALU_output : STD_LOGIC_VECTOR  (31 downto 0);



begin


-- enter your design here



end Behavioral;

-- ***************************************************************************************************
-- ***************************************************************************************************

