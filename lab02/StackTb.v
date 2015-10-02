`timescale 1ns / 1ps
module StackTb;
	// Inputs
	reg clk, reset, push, pop;
	reg [15:0] in;
	// Outputs
	wire [15:0] out;
	// Instantiate the Unit Under Test (UUT)
	Stack uut (
		.clk(clk),
		.reset(reset),
		.in(in),
		.push(push),
		.pop(pop),
		.out(out)
	);
	always #25 clk = ~clk;
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		push = 0;
		pop = 0;
		in = 0;
		// Wait 50 ns for global reset to finish
		#50;
		// Add stimulus here
		reset = 0;
		in = 3692;
		push = 1;
		#50;
		in = -7338;
		#50;
		in = 32767;
		#50;
		in = 0;
		#50;
		in = -32768;
		#50;
		push = 0;
		in = 0;
		pop = 1;
		#250;
		pop = 0;
		#50
		$finish;
	end
endmodule
