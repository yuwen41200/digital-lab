// vim: set filetype=verilog:
// 9-bit Adder: A + B = S
module FullAdder(A, B, Cin, S, Cout);
	input  [8:0] A, B;
	input  Cin;
	output [8:0] S;
	output Cout;
	wire   [7:0] T;
	Adder A0(A[0], B[0],  Cin, S[0], T[0]);
	Adder A1(A[1], B[1], T[0], S[1], T[1]);
	Adder A2(A[2], B[2], T[1], S[2], T[2]);
	Adder A3(A[3], B[3], T[2], S[3], T[3]);
	Adder A4(A[4], B[4], T[3], S[4], T[4]);
	Adder A5(A[5], B[5], T[4], S[5], T[5]);
	Adder A6(A[6], B[6], T[5], S[6], T[6]);
	Adder A7(A[7], B[7], T[6], S[7], T[7]);
	Adder A8(A[8], B[8], T[7], S[8], Cout);
endmodule
// 1-bit Adder: A + B = S
module Adder(A, B, Cin, S, Cout);
	input  A, B, Cin;
	output S, Cout;
	assign S = Cin ^ A ^ B;
	assign Cout = (A & B) | (Cin & B) | (Cin & A);
endmodule
