LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY BCD_DISPLAY IS
	PORT( clk, reset: IN STD_LOGIC;
			number : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			sel : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			output : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END BCD_DISPLAY;

ARCHITECTURE logic OF BCD_DISPLAY IS
	
	SIGNAL refresh_counter : STD_LOGIC_VECTOR(19 DOWNTO 0);
	SIGNAL current_displayed : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL SEG_BCD : STD_LOGIC_VECTOR(3 DOWNTO 0);
	
	-- using the add 3 and shift algorithem to convert to bcd upto 5 digits
	FUNCTION BIN2BCD (A : STD_LOGIC_VECTOR(15 DOWNTO 0)) return STD_LOGIC_VECTOR IS
		VARIABLE tmp : STD_LOGIC_VECTOR(35 DOWNTO 0);
	BEGIN
		tmp := (others => '0');
		tmp(18 DOWNTO 3) := A;
		FOR i in 0 to 12 LOOP
			IF tmp(35 DOWNTO 32) > 4 THEN
				tmp(35 DOWNTO 32) := tmp(35 DOWNTO 32) + 3;
			END IF;
			
			IF tmp(31 DOWNTO 28) > 4 THEN
				tmp(31 DOWNTO 28) := tmp(31 DOWNTO 28) + 3;
			END IF;
			
			IF tmp(27 DOWNTO 24) > 4 THEN
				tmp(27 DOWNTO 24) := tmp(27 DOWNTO 24) + 3;
			END IF;
			
			IF tmp(23 DOWNTO 20) > 4 THEN
				tmp(23 DOWNTO 20) := tmp(23 DOWNTO 20) + 3;
			END IF;
			
			IF tmp(19 DOWNTO 16) > 4 THEN
				tmp(19 DOWNTO 16) := tmp(19 DOWNTO 16) + 3;
			END IF;
			
			tmp(35 DOWNTO 1) := tmp(34 DOWNTO 0);
		END LOOP;
		
		RETURN tmp(35 DOWNTO 16);
	END BIN2BCD;
	
BEGIN

	-- active low decoder
	PROCESS(SEG_BCD)
	BEGIN
		CASE(SEG_BCD) IS
		when "0000" => output <= "0000001"; -- "0"     
		when "0001" => output <= "1001111"; -- "1" 
		when "0010" => output <= "0010010"; -- "2" 
		when "0011" => output <= "0000110"; -- "3" 
		when "0100" => output <= "1001100"; -- "4" 
		when "0101" => output <= "0100100"; -- "5" 
		when "0110" => output <= "0100000"; -- "6" 
		when "0111" => output <= "0001111"; -- "7" 
		when "1000" => output <= "0000000"; -- "8"     
		when "1001" => output <= "0000100"; -- "9" 
		when "1010" => output <= "0000010"; -- a
		when "1011" => output <= "1100000"; -- b
		when "1100" => output <= "0110001"; -- C
		when "1101" => output <= "1000010"; -- d
		when "1110" => output <= "0110000"; -- E
		when "1111" => output <= "0111000"; -- F
		END CASE;
	END PROCESS;
	
	PROCESS(clk, reset)
	BEGIN
		IF(reset = '1') THEN
			refresh_counter <= (others => '0');
		ELSIF(rising_edge(clk)) THEN
			refresh_counter <= refresh_counter + 1;
		END IF;
	END PROCESS;
	
	current_displayed <= refresh_counter(19 DOWNTO 18);
	
	PROCESS(current_displayed)
		VARIABLE tmp : STD_LOGIC_VECTOR(19 DOWNTO 0);
	BEGIN
		tmp := BIN2BCD(number);
		CASE(current_displayed) IS
			WHEN "00" => 
				SEL <= "0111";
				SEG_BCD <= tmp(3 DOWNTO 0);
			WHEN "01" => 
				SEL <= "1011";
				SEG_BCD <= tmp(7 DOWNTO 4);
			WHEN "10" => 
				SEL <= "1101";
				SEG_BCD <= tmp(11 DOWNTO 8);
			WHEN "11" => 
				SEL <= "1110";
				SEG_BCD <= tmp(15 DOWNTO 12);
		END CASE;
	END PROCESS;
	
END logic;

-- packaging the entity

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

PACKAGE BCD_DISPLAY_pkg IS
	COMPONENT BCD_DISPLAY
		PORT( clk, reset: IN STD_LOGIC;
				number : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
				sel : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
				output : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
	END COMPONENT;
END BCD_DISPLAY_pkg;
