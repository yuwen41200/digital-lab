`timescale 1ns / 1ps

module pre_norm_tb;

// Inputs
reg clk;
reg [1:0] rmode;
reg add;
reg [31:0] opa;
reg [31:0] opb;
reg opa_nan;
reg opb_nan;

// Outputs
wire [26:0] fracta_out;
wire [26:0] fractb_out;
wire [7:0] exp_dn_out;
wire sign;
wire nan_sign;
wire result_zero_sign;
wire fasu_op;

// Instantiate the Unit Under Test (UUT)
pre_norm uut (
	.clk(clk),
	.rmode(rmode),
	.add(add),
	.opa(opa),
	.opb(opb),
	.opa_nan(opa_nan),
	.opb_nan(opb_nan),
	.fracta_out(fracta_out),
	.fractb_out(fractb_out),
	.exp_dn_out(exp_dn_out),
	.sign(sign),
	.nan_sign(nan_sign),
	.result_zero_sign(result_zero_sign),
	.fasu_op(fasu_op)
);

always #1 clk = ~clk;

initial begin
	// Initialize Inputs
	clk = 0;
	rmode = 3;
	add = 1;
	opa = 0;
	opb = 0;
	opa_nan = 0;
	opb_nan = 0;

	// Wait 10 ns for global reset to finish
	#10;

	// Add stimulus here
	opa = 32'b01000000000000101010101101010101;
	opb = 32'b01000000100000000000000101010101;
	#10;

	opa = 32'b00111111100000101010101101010101;
	opb = 32'b11000000000000000000000101010101;
	#10;

	opa = 32'b01000000000000101010101101010101;
	opb = 32'b01000000100000000000000101010101;
	add = 0;
	#10;

	opa = 32'b00111111100000101010101101010101;
	opb = 32'b11000000000000000000000101010101;
	#10;

	// Simulation done
	$finish;
end

endmodule
