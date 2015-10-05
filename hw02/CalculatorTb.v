`timescale 1ns / 1ps
// The following testbench was originally written by the TAs in the course
module CalculatorTb;
	// Inputs
	reg CLK, RESET, OP_MODE, IN_VALID;
	reg [3:0] IN;
	// Outputs
	wire OUT_VALID;
	wire [15:0] OUT;
	reg  [15:0] answer;
	integer i, error, flag;
	// Instantiate the Unit Under Test (UUT)
	Calculator uut (
		.CLK(CLK),
		.RESET(RESET),
		.OP_MODE(OP_MODE),
		.IN_VALID(IN_VALID),
		.IN(IN),
		.OUT_VALID(OUT_VALID),
		.OUT(OUT)
	);
	always #5 CLK = ~CLK;
	initial begin
		// Initialize Inputs
		CLK      = 0;
		RESET    = 0;
		OP_MODE  = 0;
		IN_VALID = 0;
		IN       = 0;
		i        = 0;
		error    = 0;
		flag     = 0;
		// Reset
		#20;
		@(posedge CLK);
		RESET = 1;
		@(posedge CLK);
		RESET = 0;
		#10;
		@(posedge CLK);
		IN_VALID = 0;
		IN       = 0;
		OP_MODE  = 0;
		@(posedge CLK);
		IN_VALID = 1'd1;
		IN       = 4'd12;
		OP_MODE  = 0;
		@(posedge CLK);
		IN_VALID = 1'd1;
		IN       = 4'd9;
		OP_MODE  = 0;
		@(posedge CLK);
		IN_VALID = 1'd1;
		IN       = 4'd6;
		OP_MODE  = 0;
		@(posedge CLK);
		IN_VALID = 1'd1;
		IN       = 4'b0100;
		OP_MODE  = 1'd1;
		@(posedge CLK);
		IN_VALID = 1'd1;
		IN       = 4'b0001;
		OP_MODE  = 1'd1;
		@(posedge CLK);
		IN_VALID = 0;
		IN       = 0;
		OP_MODE  = 0;
		@(posedge CLK);
		@(posedge CLK);
		@(posedge CLK);
		@(posedge CLK);
		@(posedge CLK);
		@(posedge CLK);
		if (flag) begin
			@(posedge CLK);
			IN_VALID = 1'd1;
			IN       = 4'd15;
			OP_MODE  = 0;
			@(posedge CLK);
			IN_VALID = 1'd1;
			IN       = 4'd8;
			OP_MODE  = 0;
			@(posedge CLK);
			IN_VALID = 1'd1;
			IN       = 4'b0100;
			OP_MODE  = 1;
		end
		@(posedge CLK);
		IN_VALID = 1'd1;
		IN       = 4'd11;
		OP_MODE  = 0;
		@(posedge CLK);
		IN_VALID = 1'd1;
		IN       = 4'b0001;
		OP_MODE  = 1;
		@(posedge CLK);
		IN_VALID = 1'd1;
		IN       = 4'd7;
		OP_MODE  = 0;
		@(posedge CLK);
		IN_VALID = 1'd1;
		IN       = 4'd4;
		OP_MODE  = 0;
		@(posedge CLK);
		IN_VALID = 1'd1;
		IN       = 4'b0100;
		OP_MODE  = 1;
		@(posedge CLK);
		IN_VALID = 1'd1;
		IN       = 4'b0010;
		OP_MODE  = 1;
		@(posedge CLK);
		IN_VALID = 1'd1;
		IN       = 4'd13;
		OP_MODE  = 0;
		@(posedge CLK);
		IN_VALID = 1'd1;
		IN       = 4'd12;
		OP_MODE  = 0;
		@(posedge CLK);
		IN_VALID = 1'd1;
		IN       = 4'd11;
		OP_MODE  = 0;
		@(posedge CLK);
		IN_VALID = 1'd1;
		IN       = 4'b0100;
		OP_MODE  = 1;
		@(posedge CLK);
		IN_VALID = 1'd1;
		IN       = 4'b0100;
		OP_MODE  = 1;
		@(posedge CLK);
		IN_VALID = 1'd1;
		IN       = 4'd0001;
		OP_MODE  = 1;
		@(posedge CLK);
		IN_VALID = 0;
		IN       = 0;
		OP_MODE  = 0;
		@(posedge CLK);
		@(posedge CLK);
	end
	// Check Correctness
	always @(posedge CLK) begin
		if (OUT_VALID && i==0) begin
			i = i+1;
			answer = OUT[15:0];
			if (answer != 16'd66)
				error = error+1;
			@(posedge CLK);
			@(posedge CLK);
			flag = 1;
		end
		if (OUT_VALID && flag) begin
			answer = OUT[15:0];
			if (answer != 16'd1819)
				error = error+1;
			@(posedge CLK);
			@(posedge CLK);
			i = i+1;
		end
		if (i == 2) begin
			if (error == 0) begin
				$display("--------------------------------------------------------------------");
				$display("                             PASS!!!                                ");
				$display("--------------------------------------------------------------------");
				@(CLK);
				@(CLK);
				$finish;
			end
			else begin
				$display("--------------------------------------------------------------------");
				$display("                             FAIL!!!                                ");
				$display("--------------------------------------------------------------------");
				@(CLK);
				@(CLK);
				$finish;
			end
		end
	end
endmodule
