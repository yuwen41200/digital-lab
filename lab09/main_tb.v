`timescale 1ns / 1ps

module main_tb;

reg  clk;
reg  rst;
reg  btn;
wire LCD_E;
wire LCD_RS;
wire LCD_RW;
wire [3:0] LCD_D;

main uut(
	.clk(clk),
	.rst(rst),
	.btn(btn),
	.LCD_E(LCD_E),
	.LCD_RS(LCD_RS),
	.LCD_RW(LCD_RW),
	.LCD_D(LCD_D)
);

always #10 clk = ~clk;

initial begin
	clk = 0;
	rst = 1;
	btn = 0;
	#100;
	rst = 0;
	#500000;
	$finish;
end

endmodule
