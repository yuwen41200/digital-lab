/**
 * Testbench for Module: main
 */

`timescale 10ns / 1ps

module main_tb;

reg  clk;
reg  rst;
reg  btn;
wire [127:0] row_A;
wire [127:0] row_B;
wire LCD_E;
wire LCD_RS;
wire LCD_RW;
wire [3:0] LCD_D;

main uut(
	.clk(clk),
	.rst(rst),
	.btn(btn),
	.temp1(row_A),
	.temp2(row_B),
	.LCD_E(LCD_E),
	.LCD_RS(LCD_RS),
	.LCD_RW(LCD_RW),
	.LCD_D(LCD_D)
);

always #1 clk = ~clk;

initial begin
	clk = 0;
	rst = 1;
	btn = 0;
	// 100 ns
	#10;
	rst = 0;
	btn = 1;
	// 50 ms
	#5000000;
	btn = 0;
	// 2.5 s
	#250000000;
	$finish;
end

endmodule
