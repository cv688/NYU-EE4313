LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL; --use CONV_INTEGER

ENTITY rc5_enc IS

 PORT  (
  clr: IN STD_LOGIC;  -- asynchronous reset
  clk: IN STD_LOGIC;  -- Clock signal
  din: IN STD_LOGIC_VECTOR(63 DOWNTO 0);--64-bit input
  dout: OUT STD_LOGIC_VECTOR(63 DOWNTO 0) --64-bit output
  );

END rc5_enc;

ARCHITECTURE rtl OF rc5_enc IS
--round counter
SIGNAL i_cnt: STD_LOGIC_VECTOR(3 DOWNTO 0);  
SIGNAL a_sub: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL a_rot: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL a: STD_LOGIC_VECTOR(31 DOWNTO 0);
--register to store value A
SIGNAL a_reg: STD_LOGIC_VECTOR(31 DOWNTO 0); 
SIGNAL b_sub: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL b_rot: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL b: STD_LOGIC_VECTOR(31 DOWNTO 0);
--register to store value B
SIGNAL b_reg: STD_LOGIC_VECTOR(31 DOWNTO 0);

TYPE rom IS ARRAY (0 TO 25) OF STD_LOGIC_VECTOR(31
DOWNTO 0);

CONSTANT skey: rom:=rom'(
X"00000000",X"00000000",X"46F8E8C5",X"460C6085",
X"70F83B8A", X"284B8303", X"513E1454", X"F621ED22",
X"3125065D",X"11A83A5D",X"D427686B", X"713AD82D", 
X"4B792F99", X"2799A4DD", X"A7901C49", X"DEDE871A",
X"36C03196", X"A7EFC249", X"61A78BB8", X"3B0A1D2B",
X"4DBFCA76", X"AE162167", X"30D76B0A", X"43192304", 
X"F6CC1431", X"65046380");

BEGIN
PROCESS(clr, clk) 
BEGIN
IF(clr='0')THEN 
i_cnt<="1100";
ELSIF(clk'EVENT AND clk='1') THEN
IF(i_cnt="0001") THEN
i_cnt<="1100";
ELSE
i_cnt<=i_cnt-'1';
END IF;
END IF;
END PROCESS;


--B = ((B-S[2xi+1])>>>A) XOR A;

-- b_reg
PROCESS(clr, clk)  BEGIN
IF(clr='0') THEN b_reg <= din(63 DOWNTO 32);
ELSIF(clk'EVENT AND clk='1') THEN b_reg<=b;
END IF;
END PROCESS;

b_sub <= b_reg - skey(CONV_INTEGER(i_cnt & '1')); 

WITH a_reg(4 DOWNTO 0) SELECT
    b_rot<=b_sub(0) & b_sub(31 downto 1) WHEN "00001",
	b_sub(1 DOWNTO 0) & b_sub(31 DOWNTO 2) WHEN "00010",
	b_sub(2 DOWNTO 0) & b_sub(31 DOWNTO 3) WHEN "00011",
	b_sub(3 DOWNTO 0) & b_sub(31 DOWNTO 4) WHEN "00100",
	b_sub(4 DOWNTO 0) & b_sub(31 DOWNTO 5) WHEN "00101",
	b_sub(5 DOWNTO 0) & b_sub(31 DOWNTO 6) WHEN "00110",
	b_sub(6 DOWNTO 0) & b_sub(31 DOWNTO 7) WHEN "00111",
	b_sub(7 DOWNTO 0) & b_sub(31 DOWNTO 8) WHEN "01000",
	b_sub(8 DOWNTO 0) & b_sub(31 DOWNTO 9) WHEN "01001",
	b_sub(9 DOWNTO 0) & b_sub(31 DOWNTO 10) WHEN "01010",
	b_sub(10 DOWNTO 0) & b_sub(31 DOWNTO 11) WHEN "01011",
	b_sub(11 DOWNTO 0) & b_sub(31 DOWNTO 12) WHEN "01100",
	b_sub(12 DOWNTO 0) & b_sub(31 DOWNTO 13) WHEN "01101",
	b_sub(13 DOWNTO 0) & b_sub(31 DOWNTO 14) WHEN "01110",
	b_sub(14 DOWNTO 0) & b_sub(31 DOWNTO 15) WHEN "01111",
	b_sub(15 DOWNTO 0) & b_sub(31 DOWNTO 16) WHEN "10000",
	b_sub(16 DOWNTO 0) & b_sub(31 DOWNTO 17) WHEN "10001",
	b_sub(17 DOWNTO 0) & b_sub(31 DOWNTO 18) WHEN "10010",
	b_sub(18 DOWNTO 0) & b_sub(31 DOWNTO 19) WHEN "10011",
	b_sub(19 DOWNTO 0) & b_sub(31 DOWNTO 20) WHEN "10100",
	b_sub(20 DOWNTO 0) & b_sub(31 DOWNTO 21) WHEN "10101",
	b_sub(21 DOWNTO 0) & b_sub(31 DOWNTO 22) WHEN "10110",
	b_sub(22 DOWNTO 0) & b_sub(31 DOWNTO 23) WHEN "10111",
	b_sub(23 DOWNTO 0) & b_sub(31 DOWNTO 24) WHEN "11000",
	b_sub(24 DOWNTO 0) & b_sub(31 DOWNTO 25) WHEN "11001",
	b_sub(25 DOWNTO 0) & b_sub(31 DOWNTO 26) WHEN "11010",
	b_sub(26 DOWNTO 0) & b_sub(31 DOWNTO 27) WHEN "11011",
	b_sub(27 DOWNTO 0) & b_sub(31 DOWNTO 28) WHEN "11100",
	b_sub(28 DOWNTO 0) & b_sub(31 DOWNTO 29) WHEN "11101",
	b_sub(29 DOWNTO 0) & b_sub(31 DOWNTO 30) WHEN "11110",
	b_sub(30 DOWNTO 0) & b_sub(31) WHEN "11111",
	b_sub WHEN OTHERS;
b<=b_rot XOR a_reg;

--A = ((A-S[2xi])>>>B) xor B;

-- a_reg
PROCESS(clr, clk)  BEGIN
IF(clr='0') THEN a_reg<=din(31 DOWNTO 0);
ELSIF(clk'EVENT AND clk='1') THEN a_reg<=a;
END IF;
END PROCESS;

a_sub <= a_reg - skey(CONV_INTEGER(i_cnt & '0')); 

WITH b(4 DOWNTO 0) SELECT
   a_rot<=a_sub(0) & a_sub(31 downto 1) WHEN "00001",
	a_sub(1 DOWNTO 0) & a_sub(31 DOWNTO 2) WHEN "00010",
	a_sub(2 DOWNTO 0) & a_sub(31 DOWNTO 3) WHEN "00011",
	a_sub(3 DOWNTO 0) & a_sub(31 DOWNTO 4) WHEN "00100",
	a_sub(4 DOWNTO 0) & a_sub(31 DOWNTO 5) WHEN "00101",
	a_sub(5 DOWNTO 0) & a_sub(31 DOWNTO 6) WHEN "00110",
	a_sub(6 DOWNTO 0) & a_sub(31 DOWNTO 7) WHEN "00111",
	a_sub(7 DOWNTO 0) & a_sub(31 DOWNTO 8) WHEN "01000",
	a_sub(8 DOWNTO 0) & a_sub(31 DOWNTO 9) WHEN "01001",
	a_sub(9 DOWNTO 0) & a_sub(31 DOWNTO 10) WHEN "01010",
	a_sub(10 DOWNTO 0) & a_sub(31 DOWNTO 11) WHEN "01011",
	a_sub(11 DOWNTO 0) & a_sub(31 DOWNTO 12) WHEN "01100",
	a_sub(12 DOWNTO 0) & a_sub(31 DOWNTO 13) WHEN "01101",
	a_sub(13 DOWNTO 0) & a_sub(31 DOWNTO 14) WHEN "01110",
	a_sub(14 DOWNTO 0) & a_sub(31 DOWNTO 15) WHEN "01111",
	a_sub(15 DOWNTO 0) & a_sub(31 DOWNTO 16) WHEN "10000",
	a_sub(16 DOWNTO 0) & a_sub(31 DOWNTO 17) WHEN "10001",
	a_sub(17 DOWNTO 0) & a_sub(31 DOWNTO 18) WHEN "10010",
	a_sub(18 DOWNTO 0) & a_sub(31 DOWNTO 19) WHEN "10011",
	a_sub(19 DOWNTO 0) & a_sub(31 DOWNTO 20) WHEN "10100",
	a_sub(20 DOWNTO 0) & a_sub(31 DOWNTO 21) WHEN "10101",
	a_sub(21 DOWNTO 0) & a_sub(31 DOWNTO 22) WHEN "10110",
	a_sub(22 DOWNTO 0) & a_sub(31 DOWNTO 23) WHEN "10111",
	a_sub(23 DOWNTO 0) & a_sub(31 DOWNTO 24) WHEN "11000",
	a_sub(24 DOWNTO 0) & a_sub(31 DOWNTO 25) WHEN "11001",
	a_sub(25 DOWNTO 0) & a_sub(31 DOWNTO 26) WHEN "11010",
	a_sub(26 DOWNTO 0) & a_sub(31 DOWNTO 27) WHEN "11011",
	a_sub(27 DOWNTO 0) & a_sub(31 DOWNTO 28) WHEN "11100",
	a_sub(28 DOWNTO 0) & a_sub(31 DOWNTO 29) WHEN "11101",
	a_sub(29 DOWNTO 0) & a_sub(31 DOWNTO 30) WHEN "11110",
	a_sub(30 DOWNTO 0) & a_sub(31) WHEN "11111",
	a_sub WHEN OTHERS;

a<=a_rot XOR b; 

dout<=b_reg & a_reg; 

END rtl;

