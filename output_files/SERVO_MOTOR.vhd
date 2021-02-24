LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.MATH_REAL.ALL;

ENTITY SERVO_MOTOR IS
	GENERIC(
		clk_hz, pulse_hz, min_pulse_us, max_pulse_us : REAL;
		step_count                                   : POSITIVE
	);
	PORT(
		clk, reset : IN STD_LOGIC;
		position    : IN INTEGER RANGE 0 TO step_count - 1;
		pwm        : OUT STD_LOGIC
	);
END SERVO_MOTOR;

ARCHITECTURE logic OF SERVO_MOTOR IS

	-- Number of clock cycles in <us_count> Microseconds
	FUNCTION cycles_per_us (us_count : REAL) RETURN INTEGER IS
	BEGIN
		RETURN INTEGER(round(clk_hz / 1.0e6 * us_count));
	END FUNCTION;
  
	CONSTANT min_count : INTEGER := cycles_per_us(min_pulse_us);
	CONSTANT max_count : INTEGER := cycles_per_us(max_pulse_us);
	CONSTANT min_max_range_us : REAL := max_pulse_us - min_pulse_us;
	CONSTANT step_us : REAL := min_max_range_us / REAL(step_count - 1);
	CONSTANT cycles_per_step : POSITIVE := cycles_per_us(step_us);
	constant counter_max : INTEGER := INTEGER(round(clk_hz / pulse_hz)) - 1;
  
	SIGNAL counter : INTEGER range 0 to counter_max;
	SIGNAL duty_cycle : INTEGER range 0 to max_count;
  
BEGIN
	COUNTER_PROC : PROCESS(clk)
	  BEGIN
		 IF rising_edge(clk) THEN
			IF reset = '1' THEN
			  counter <= 0;

			ELSE
			  IF counter < counter_max THEN
				 counter <= counter + 1;
			  ELSE
				 counter <= 0;
			  END IF;

			END IF;
		 END IF;
	END PROCESS;

  PWM_PROC : PROCESS(clk)
  BEGIN
    IF rising_edge(clk) THEN
      IF reset = '1' THEN
        pwm <= '0';

      ELSE
        pwm <= '0';

        IF counter < duty_cycle THEN
          pwm <= '1';
        END IF;

      END IF;
    END IF;
  END PROCESS;

  DUTY_CYCLE_PROC : PROCESS(clk)
  BEGIN
    IF rising_edge(clk) THEN
      IF reset = '1' THEN
        duty_cycle <= min_count;

      ELSE
        duty_cycle <= position * cycles_per_step + min_count;

      END IF;
    END IF;
  END PROCESS;
END logic;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

PACKAGE SERVO_MOTOR_pkg IS
	COMPONENT SERVO_MOTOR
		GENERIC(
			clk_hz, pulse_hz, min_pulse_us, max_pulse_us : REAL;
			step_count                                   : POSITIVE
		);
		PORT(
			clk, reset : IN STD_LOGIC;
			position    : IN INTEGER RANGE 0 TO step_count - 1;
			pwm        : OUT STD_LOGIC
		);
	END COMPONENT;
END SERVO_MOTOR_pkg;