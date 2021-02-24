LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE WORK.BCD_DISPLAY_pkg.ALL;
USE WORK.ULTRASONIC_SENSOR_pkg.ALL;
USE WORK.SERVO_MOTOR_pkg.ALL;
USE WORK.uart_pkg.ALL;

ENTITY testing IS
	PORT( clk, echo, reset, rx : IN STD_LOGIC;
			trig                 : BUFFER STD_LOGIC;
			output               : BUFFER STD_LOGIC_VECTOR(6 DOWNTO 0);
			sel                  : BUFFER STD_LOGIC_VECTOR(3 DOWNTO 0);
			servo ,tx            : BUFFER STD_LOGIC;
			leds                 : BUFFER STD_LOGIC_VECTOR(3 DOWNTO 0);
			motors               : BUFFER STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END testing;

ARCHITECTURE logic OF testing IS
	
	CONSTANT clk_hz       : REAL := 50.0e6;
	CONSTANT pulse_hz     : REAL := 50.0;
	CONSTANT min_pulse_us : REAL := 550.0;
	CONSTANT max_pulse_us : REAL := 2300.0;
	CONSTANT step_bits    : POSITIVE := 8;
	CONSTANT step_count   : POSITIVE := 2**step_bits;
	CONSTANT SENSING_HZ   : REAL := 3.0;
	
	SIGNAL position       : INTEGER RANGE 0 to step_count - 1 := 0;
	SIGNAL distance       : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL done           : STD_LOGIC;
	SIGNAL ena, f1, f2    : STD_LOGIC := '0';
	SIGNAL busy, send     : STD_LOGIC;
	SIGNAL hamda          : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL data           : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL data_to_pc     : STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => '0');
	SIGNAL send_counter   : STD_LOGIC_VECTOR(25 DOWNTO 0);
	-- TMP SIGNALS
	SIGNAL send_flag, enable_flag : STD_LOGIC := '0';
	SIGNAL reset_servo : STD_LOGIC := '0';
	SIGNAL ovf_flag : STD_LOGIC := '0';
	SIGNAL zer_flag : STD_LOGIC := '0';
BEGIN

	uss: ULTRASONIC_SENSOR GENERIC MAP(
					SENSING_HZ => SENSING_HZ
				)
				PORT MAP(
					clk => clk,
					reset => reset,
					trig => trig,
					echo => echo,
					distance => distance,
					done => done
				);
	
	bd: BCD_DISPLAY PORT MAP(
					clk => clk,
					reset => reset,
					number => std_logic_vector(to_unsigned( position, 16)), -- distance
					sel => sel,
					output => output
				);
				
	sm: SERVO_MOTOR GENERIC MAP(
					clk_hz => clk_hz,
					pulse_hz => pulse_hz,
					min_pulse_us => min_pulse_us,
					max_pulse_us => max_pulse_us,
					step_count => step_count
				)
				PORT MAP(
					clk => clk,
					reset => reset,
					pwm => servo,
					position => position
				);
				
	bl: uart GENERIC MAP(baud_rate => 9600, d_width => 8, parity => 0) 
				PORT MAP(
					clk => clk, 
					reset_n => not reset,
					tx_ena => ena,
					tx_data => data_to_pc,
					rx_data => data(7 DOWNTO 0),
					rx_busy => busy,
					tx_busy => leds(0),
					rx => rx,
					tx => tx
				);
				
	SENDING_DATA_TO_PC: PROCESS(clk, reset)
	BEGIN
		IF(rising_edge(clk)) THEN
			IF(done = '1') THEN
				IF(distance > 63) THEN
					ovf_flag <= '1';
				ELSE
					ovf_flag <= '0';
				END IF;
					
				leds(1) <= not leds(1);
				data_to_pc <=   ovf_flag & zer_flag & distance(5 DOWNTO 0);
				ena <= '1';
			END IF;
			IF ena = '1' THEN
				ena <= '0';
			END IF;
		END IF;
	END PROCESS;
				
	SWEEPING : PROCESS(done, reset_servo)
		VARIABLE direction : STD_LOGIC := '0';
	BEGIN
		IF(reset_servo = '1') THEN
			position <= 0;
			direction := '0';
			zer_flag <= '1';
		ELSIF(rising_edge(done)) THEN
			zer_flag <= '0';
			IF(position = 250) THEN
				direction := '1';
			END IF;
			IF(position = 0) THEN
				direction := '0';
				zer_flag <= '1';
			END IF;
			
			CASE direction IS
				WHEN '0' => position <= position + 10;
				WHEN '1' => position <= position - 10;
			END CASE;
		END IF;
	END PROCESS;
	
	RESETING_SERVO: PROCESS(clk)
	BEGIN
		IF rising_edge(clk) THEN
			CASE data(7 DOWNTO 0) IS
				WHEN "01010001" => reset_servo <= '1';
				WHEN "00100110" => motors <= "1010";
				WHEN "00101000" => motors <= "0101";
				WHEN "00100111" => motors <= "0110";
				WHEN "00100101" => motors <= "1001";
				WHEN others => leds(3 DOWNTO 2) <= data(3 DOWNTO 2);
									motors <= "0000";
			END CASE;
			IF reset_servo = '1' THEN
				reset_servo <= '0';
			END IF;
		END IF;
	END PROCESS;
	
	
END logic;