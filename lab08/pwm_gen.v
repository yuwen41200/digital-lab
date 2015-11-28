/**
 * PWM Signal Generator
 *   We set the output signal to 95 Hz.
 *     50 MHz / 95 Hz ~ 526316
 *     lg 526316 ~ 19
 *   Thus 0 <= counter <= 524287.
 *   Also note that 0 <= duty_cycle <= 100.
 */

module pwm_gen(
		input clk,
		input [18:0] duty_cycle,
		output pwm_signal
	);

reg  [18:0] counter;
wire [18:0] high;

assign high = (duty_cycle == 0) ? 0 : (5242 * duty_cycle + 87);
assign pwm_signal = (counter < high) ? 1 : 0;

always @(posedge clk) begin
	counter <= counter + 1;
end

endmodule
