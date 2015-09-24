`timescale 1ns / 1ps
module SubtractorTb;
	// Inputs
	reg [7:0] A;
	reg [7:0] B;
	// Outputs
	wire [8:0] D;
	// Instantiate the Unit Under Test (UUT)
	Subtractor uut (
		.A(A),
		.B(B),
		.D(D)
	);
	// The following testbench was originally written by Microsheep
	integer wrongflag, i, j, answer;
	reg CLK;
	real CYCLE;
	always #(CYCLE/132) CLK = ~CLK;
	initial begin
		// Initialize Inputs
		A = 0;
		B = 0;
		CLK = 0;
		CYCLE = 2;
		wrongflag = 0;
		@(posedge CLK);
		for (i = -128; i <= 127; i = i + 1 ) begin
			for (j = -128; j <= 127; j = j + 1 ) begin
				@(posedge CLK) begin
					A = i[7:0];
					B = j[7:0];
					answer = i - j;
				end
				@(negedge CLK) begin
					$display("When A=%b(%0d), B=%b(%0d):", A, i, B, j);
					$display("    Your answer is %b, correct answer is %b(%0d).", D, answer[8:0], answer);
					if (D != answer[8:0]) begin
						$display("------------------------------------------------- WRONG!!! -------------------------------------------------");
						wrongflag = 1;
					end
				end
			end
		end
		if (wrongflag == 0) begin
			$display("***************************");
			$display("       ALL CORRECT!!!      ");
			$display("***************************");
		end
		$finish;
	end
endmodule
