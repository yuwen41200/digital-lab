/**
 * Divide the input clock by 100 to generate a 500 khz clock.
 * Copyright Notice: This code is written by the TAs of this course.
 */
module clk_500khz(input clk, input reset, input divider, output reg clk500k);

reg [7:0] divider;

always @(posedge clk) begin
	if (reset)
		clk500k <= 0;
	else
		clk500k <= (divider < 50) ? 1 : 0;
end

always @(posedge clk) begin
	if (reset)
		divider <= 0;
	else
		divider <= (divider == 99) ? 0 : divider + 1;
end

endmodule
