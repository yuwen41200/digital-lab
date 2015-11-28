/**
 * Control the Brightness of LEDs through a Rotary Dial
 */

module main(
		input rst,
		input clk,
		input rot_a,
		input rot_b,
		output [7:0] led
	);

wire rotary_event, rotary_right, light;
reg  [6:0] brightness;

rotary_ctrl rot(clk, rot_a, rot_b, rotary_event, rotary_right);
pwm_gen pwm(clk, brightness, light);

assign led = {8{light}};

always @(posedge clk) begin
	if (rst)
		brightness <= 0;
	else if (rotary_event && rotary_right && brightness < 100)
		brightness <= brightness + 1;
	else if (rotary_event && ~rotary_right && brightness > 0)
		brightness <= brightness - 1;
	else
		brightness <= brightness;
end

endmodule
