`timescale 1ns / 1ps
module FullAdderTb;
	// Inputs
	reg [7:0] A;
	reg [7:0] B;
	reg Cin;
	// Outputs
	wire [7:0] S;
	wire Cout;
	// Instantiate the Unit Under Test (UUT)
	FullAdder uut (
		.A(A),
		.B(B),
		.Cin(Cin),
		.S(S),
		.Cout(Cout)
	);
	initial begin
		// Initialize Inputs
		A = 0;
		B = 0;
		Cin = 0;
		// Wait 100 ns for global reset to finish
		#100;
		// Add stimulus here
		A = 8'b01010101;
		B = 8'b10101010;
		#50;
		A = 8'b11111111;
		B = 8'b00000001;
		#50;
		A = 8'b00000000;
		B = 8'b11111111;
		Cin = 1'b1;
		#50;
		A = 8'b01100110;
		B = 8'b00010001;
	end
endmodule
