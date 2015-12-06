/**
 * Button Debounce Module
 */

module debounce(
	input clk,
	input btn_in,
	output reg btn_out
);

// 20 ms @ 50MHz
parameter DEBOUNCE_PERIOD = 1000000;

reg [20:0] counter;
reg pressed;

always @(posedge clk) begin
	if (btn_in)
		counter <= counter + 1;
	else
		counter <= 0;
end

always @(posedge clk) begin
	if (counter >= DEBOUNCE_PERIOD && pressed) begin
		btn_out <= 0;
		pressed <= 1;
	end
	else if (counter >= DEBOUNCE_PERIOD && ~pressed) begin
		btn_out <= 1;
		pressed <= 1;
	end
	else if (~btn_in) begin
		btn_out <= 0;
		pressed <= 0;
	end
end

endmodule
