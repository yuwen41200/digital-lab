`timescale 1ns / 1ps
module ComplementTb;
	// Inputs
	reg [7:0] I;
	// Outputs
	wire [7:0] O;
	// Instantiate the Unit Under Test (UUT)
	Complement uut (
		.I(I),
		.O(O)
	);
	initial begin
		// Initialize Inputs
		I = 0;
		// Wait 100 ns for global reset to finish
		#100;
		// Add stimulus here
		I = 8'b11110000;
		#50;
		I = 8'b01010101;
		#50;
		I = 8'b10101010;
		#50;
		I = 8'b00000000;
		#50;
		I = 8'b11111111;
		#50;
		I = 8'b00100010;
	end
endmodule
