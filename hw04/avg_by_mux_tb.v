`timescale 1ns / 1ps

module avg_by_mux_tb;

	reg clk;
	reg rst;
	wire [7:0] avg;

	avg_by_mux uut (
		.clk(clk),
		.rst(rst),
		.avg(avg)
	);

	always #20 clk = ~clk;

	initial begin
		clk = 0;
		rst = 1;
		#100;
		rst = 0;
		#1500;
		$finish;
	end

endmodule
