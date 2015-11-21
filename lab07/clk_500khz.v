/**
 * Divide the input clock by 100 to generate a 500 kHz clock.
 * Copyright Notice: This code is written by the TAs of this course.
 */

module clk_500khz(input clk, input rst, input divider, output reg clk500k);

reg [7:0] divider;

always @(posedge clk) begin
	if (rst)
		clk500k <= 0;
	else
		clk500k <= (divider < 50) ? 1 : 0;
end

always @(posedge clk) begin
	if (rst)
		divider <= 0;
	else
		divider <= (divider == 99) ? 0 : divider + 1;
end

endmodule
