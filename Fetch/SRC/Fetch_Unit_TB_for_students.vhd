-----------------------------------------------------------------
-- test bench for Fetch Unit
-- by Danny Seidner 19/8/14
-----------------------------------------------------------------

library	ieee;
use ieee.std_logic_arith.all;  
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use std.textio.all;
use IEEE.NUMERIC_STD.all;

-----------------------------------------------------------------
  

entity Fetch_Unit_TB is
end Fetch_Unit_TB;

architecture Testing of Fetch_Unit_TB is

-- the component under test
component HW2_top_4sim is
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
-- signals to be tested
--
-- signals to be tested
CK_out_to_TB	: out STD_LOGIC; 
RESET_out_to_TB	: out STD_LOGIC; 
HOLD_out_to_TB	: out STD_LOGIC; 
IR_reg_out_to_TB : out STD_LOGIC_VECTOR (31 downto 0); 
PC_plus_4_pID_out_to_TB : out STD_LOGIC_VECTOR (31 downto 0) 
		);
end component;

-- signal declarations
signal TB_RS232_Rx	: 	STD_LOGIC; 
signal TB_RS232_Tx	: 	STD_LOGIC; 
--
signal TB_CK_50MHz		: 	STD_LOGIC; 
signal TB_btns		:	STD_LOGIC_VECTOR (3 downto 0);
signal TB_switches	:	STD_LOGIC_VECTOR (7 downto 0);
signal TB_leds_out 	:	STD_LOGIC_VECTOR (7 downto 0);
--
-- signals to be tested by the TB
signal Tested_CK	: STD_LOGIC; 
signal Tested_RESET	: STD_LOGIC; 
signal Tested_HOLD	: STD_LOGIC; 
signal Tested_IR_reg : STD_LOGIC_VECTOR (31 downto 0); 
signal Tested_PC_plus_4_pID : STD_LOGIC_VECTOR (31 downto 0);

-- Testing mechanism signals
signal i : integer :=0;-- for counting TB CK cycles
signal err_cntr: integer :=0;

signal ck_no_expected_val : integer :=0;-- value from file that should be equal to i
signal PC_expected_val : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";-- value from file that should be equal to Tested_PC_plus_4_pID
signal IR_expected_val : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";-- value from file that should be equal to Tested_IR_reg


-- =========================================================================
function  to_hex_string(std_vec: in std_logic_vector) return string is
   
    variable vecopy: std_logic_vector(std_vec'length-1 downto 0) := std_vec;-- copy of the input value
    variable nibble : std_logic_vector(3 downto 0); -- to here we copy 4 bits and check the hex value 
	variable hex_string: string (std_vec'length/4 downto 1); -- string index starts from 1
    
  begin
    assert (std_vec'length mod 4)=0   report "Not a multiple of 4 bits!!, Aborting."   severity FAILURE;
    for i in hex_string'range loop
		nibble :=  vecopy(i*4-1 downto (i-1)*4);
		case nibble is
			when "0000" => hex_string(i) := '0';
			when "0001" => hex_string(i) := '1';
			when "0010" => hex_string(i) := '2';
			when "0011" => hex_string(i) := '3';
			when "0100" => hex_string(i) := '4';
			when "0101" => hex_string(i) := '5';
			when "0110" => hex_string(i) := '6';
			when "0111" => hex_string(i) := '7';
			when "1000" => hex_string(i) := '8';
			when "1001" => hex_string(i) := '9';
			when "1010" => hex_string(i) := 'A';
			when "1011" => hex_string(i) := 'B';
			when "1100" => hex_string(i) := 'C';
			when "1101" => hex_string(i) := 'D';
			when "1110" => hex_string(i) := 'E';
			when "1111" => hex_string(i) := 'F';
			when others => hex_string(i) := 'x';
		end case;
    end loop;
    return hex_string;
 end function;

-- =========================================================================
 function to_std_logic_vector( s : string ; siz : integer ) -- s is the string to be converted, siz is the number of bits in the result r 
	return std_logic_vector 
	is
		variable r : std_logic_vector(siz-1 downto 0) ;
		variable nibble : std_logic_vector(3 downto 0); -- to here we write the hex value 
		variable k : integer; -- k=siz/4-i   (if siz=32, i= 1 to 8, k= 7 to 0)
	begin
		r := conv_std_logic_vector(0,siz);
		for i in 1 to siz/4 loop
		k := siz/4 - i;
		  case s(i) is
			when '1' => nibble := b"0001";
			when '2' => nibble := b"0010";
			when '3' => nibble := b"0011";
			when '4' => nibble := b"0100";
			when '5' => nibble := b"0101";
			when '6' => nibble := b"0110";
			when '7' => nibble := b"0111";
			when '8' => nibble := b"1000";
			when '9' => nibble := b"1001";
			when 'A' => nibble := b"1010";
			when 'B' => nibble := b"1011";
			when 'C' => nibble := b"1100";
			when 'D' => nibble := b"1101";
			when 'E' => nibble := b"1110";
			when 'F' => nibble := b"1111";
			when 'a' => nibble := b"1010";
			when 'b' => nibble := b"1011";
			when 'c' => nibble := b"1100";
			when 'd' => nibble := b"1101";
			when 'e' => nibble := b"1110";
			when 'f' => nibble := b"1111";
--			when '0' => nibble := b"0000";
			when others => nibble := b"0000";
		  end case;		
		r(k*4+3 downto k*4) := nibble ;
		end loop ;
		return r ;
	end function ;

-- =========================================================================

	
 FILE data_file : text open read_mode is "C:\Users\Matan\Dropbox\IDC\Year 2\Spring\Build Your Own Computer\Mips-Pipelined-processor\Fetch\SRC\HW2_Fetch_Unit_TB_data.dat";



 

begin
    	
-- connecting the unit under test to TB signals	
Testing_Fetch_Unit : HW2_top_4sim 
	Port map	(	
RS232_Rx	=> 	TB_RS232_Rx,
RS232_Tx	=>	TB_RS232_Tx,
--
CK_50MHz	=>	TB_CK_50MHz,
buttons_in	=>	TB_btns,
switches_in	=>	TB_switches,
leds_out 	=>	TB_leds_out,
--
-- signals to be tested by TB
CK_out_to_TB	=> Tested_CK,
RESET_out_to_TB	=>	Tested_RESET,
HOLD_out_to_TB	=>	Tested_HOLD, 
IR_reg_out_to_TB =>	Tested_IR_reg,
PC_plus_4_pID_out_to_TB => Tested_PC_plus_4_pID
		);

		
-- creating the TB signals		
    TB_switches <= b"00000000";
    TB_btns <= b"0000";
	

-- External CK, 50 MHz CK
	 process  
		begin
			TB_ck_50MHz <= '1';			-- clock cycle 20 ns
			wait for 10 ns;
			TB_ck_50MHz <= '0';
			wait for 10 ns;
		end process;
	

  


-- Checking the design and issuing error messages 
verify: process

VARIABLE vectorline 		: line;
VARIABLE ck_no_from_file	: integer;
VARIABLE space1  			: string (1 to 4);
VARIABLE PC_value_from_file	: string (1 to 8);
VARIABLE space2				: string (1 to 5);
VARIABLE IR_value_from_file : string (1 to 8);


begin
  i <= 0;
  err_cntr <=0;
  
  wait until Tested_RESET = '1';
  wait until Tested_RESET = '0';
  wait for 1 ns;
  report "================== Start checking signals ======================================";
--  
  wait until Tested_CK='1';
  i <= i+1;
--
-- read the headline
    READLINE (data_file,vectorline);
--
  while not ENDFILE(data_file) loop  
    READLINE (data_file,vectorline);
--
    READ ( vectorline,ck_no_from_file);
    READ ( vectorline,space1);
    READ ( vectorline,PC_value_from_file);
    READ ( vectorline,space2);
    READ ( vectorline,IR_value_from_file);
--	
	ck_no_expected_val <= ck_no_from_file;
	PC_expected_val <= to_std_logic_vector(PC_value_from_file,32);-- if we want this to become effective, we need to change the simulation time -- this is NOT required in regular assignment
	IR_expected_val <= to_std_logic_vector(IR_value_from_file,32);
--
    wait until Tested_CK='1';
	i <= i+1;
--
-- check CK serial no.
	assert ck_no_expected_val = i report "Error in counting CKs. CK no is " &  integer'image(i) & ", expected " & integer'image(ck_no_expected_val) severity ERROR;
	if ck_no_expected_val /= i then err_cntr <= err_cntr + 1; end if;

-- check PC value    
	assert Tested_PC_plus_4_pID = PC_expected_val report "Error in PC+4 reg in CK cycle " & integer'image(i) &"!!! " & " was " & to_hex_string(Tested_PC_plus_4_pID) & " instead of " & to_hex_string(PC_expected_val) severity error;
    if Tested_PC_plus_4_pID /= PC_expected_val then err_cntr <= err_cntr + 1; end if;

-- check IR value    
    assert Tested_IR_reg = IR_expected_val report "Error in IR reg in CK cycle " & integer'image(i) &"!!! " & " was " & to_hex_string(Tested_IR_reg) & " instead of " & to_hex_string(IR_expected_val) severity error;
    if Tested_IR_reg /= IR_expected_val then err_cntr <= err_cntr + 1; end if;
--
  end loop;
 
  wait until Tested_CK='1';
	
  if err_cntr > 0 then
	report "========== no of errors is: " & integer'image(err_cntr) & ", ================ test FAILED!! =================" severity ERROR; 
  else
	report "============ Test pass!! ===============";
  end if;
	
	wait;
end process verify;


	
	
end Testing;



