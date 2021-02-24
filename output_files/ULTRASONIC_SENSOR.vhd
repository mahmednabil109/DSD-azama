LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.MATH_REAL.ALL;

ENTITY ULTRASONIC_SENSOR IS
	GENERIC( SENSING_HZ : REAL := 1.0);
	PORT( clk, reset, echo: IN STD_LOGIC;
			trig, done : OUT STD_LOGIC;
			distance : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END ULTRASONIC_SENSOR;

ARCHITECTURE logic OF ULTRASONIC_SENSOR IS

	CONSTANT MAX_ECHO_TIME : real := 30.0;
	CONSTANT TRIGER_WIDTH : real := 20.0;
	CONSTANT SENSING_PERIOD : natural := natural(ceil(50.0 * 1.0E6 / SENSING_HZ));
	
	SIGNAL timer_r, dist_r : INTEGER RANGE 0 TO SENSING_PERIOD;
	SIGNAL f : STD_LOGIC := '0';
	
BEGIN

	PROCESS(clk)
	BEGIN
	
		IF(rising_edge(clk)) THEN
			timer_r <= timer_r + 1;
			trig <= '0';
			-- calculating the distance by just converting the clock cycles to micrsencodes 
			-- then multiply the time by the speed of sound and getting the half of the travel distance 
			distance <= std_logic_vector(to_unsigned(dist_r * 34/ 100000, distance'length));
			-- every time generating a trigger pulse with width 20ms
			IF timer_r < integer(ceil(TRIGER_WIDTH * 50.0)) THEN
				done <= '0';
				trig <= '1';
				dist_r <= 0	;
				f <= '1';
			ELSIF echo = '1' and f = '1' THEN
				dist_r <= dist_r + 1;
			END IF;
			-- reseting every thing to start again with a given frequency
			IF timer_r = SENSING_PERIOD THEN
				timer_r <= 0;
				done <= '1';
				f <= '0';
				IF dist_r >= integer(ceil(MAX_ECHO_TIME * 50.0 * 1000.0)) THEN
					distance <= (distance'range => '1');
				END IF;
			END IF;
		END IF;
		
	END PROCESS;
	
END logic;

-- packaging the entity

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.MATH_REAL.ALL;

PACKAGE ULTRASONIC_SENSOR_pkg IS
	COMPONENT ULTRASONIC_SENSOR
		GENERIC( SENSING_HZ : REAL := 1.0);
		PORT( clk, reset, echo: IN STD_LOGIC;
				trig, done : OUT STD_LOGIC;
				distance : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
	END COMPONENT;
END ULTRASONIC_SENSOR_pkg;
