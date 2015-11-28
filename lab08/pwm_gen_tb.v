/**
 * Testbench for Module: pwm_gen
 *   50 MHz frequency is 20 ns period.
 */

`timescale 10ns / 1ns

module pwm_gen_tb;

reg  clk;
reg  [6:0] duty_cycle;
wire pwm_signal;

pwm_gen uut(clk, duty_cycle, pwm_signal);

always #1 clk = ~clk;

initial begin
	clk = 0;
	duty_cycle = 0;
	#50000000;
	duty_cycle = 10;
	#50000000;
	duty_cycle = 25;
	#50000000;
	duty_cycle = 50;
	#50000000;
	duty_cycle = 75;
	#50000000;
	duty_cycle = 90;
	#50000000;
	duty_cycle = 100;
	#50000000;
	$finish;
end

endmodule
