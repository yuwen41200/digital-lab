// 9-bit 2's Complement: I' = O
module Complement(I, O);
	input  [8:0] I;
	output [8:0] O;
	wire   [8:0] T;
	Comp C0(I[0], 1'b0, 1'b0, T[0], O[0]);
	Comp C1(I[1], T[0], O[0], T[1], O[1]);
	Comp C2(I[2], T[1], O[1], T[2], O[2]);
	Comp C3(I[3], T[2], O[2], T[3], O[3]);
	Comp C4(I[4], T[3], O[3], T[4], O[4]);
	Comp C5(I[5], T[4], O[4], T[5], O[5]);
	Comp C6(I[6], T[5], O[5], T[6], O[6]);
	Comp C7(I[7], T[6], O[6], T[7], O[7]);
	Comp C8(I[8], T[7], O[7], T[8], O[8]);
endmodule
// 1-bit 2's Complement: I' = O
module Comp(I, Cin, Oprecede, Cout, O);
	input  I, Cin, Oprecede;
	output Cout, O;
	assign Cout = Cin | Oprecede;
	assign O = I ^ Cout;
endmodule
