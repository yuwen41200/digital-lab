//`include "FullAdder.v"
//`include "Complement.v"
// 8-bit Subtractor: A - B = D
module Subtractor(A, B, D);
	input  [7:0] A, B;
	output [8:0] D;
	wire   [8:0] AA, BB, T;
	wire   U;
	assign AA[8] = A[7];
	assign BB[8] = B[7];
	assign AA[7:0] = A[7:0];
	assign BB[7:0] = B[7:0];
	Complement C(BB, T);
	FullAdder  F(AA, T, 1'b0, D, U);
endmodule
