// A stack that can store 10 16-bit signed integer
module Stack (
		input clk, reset, signed [15:0] in,
		input push, pop,
		output reg signed [15:0] out
	);
	reg signed [4:0] ptr;
	reg signed [15:0] stack [0:9];
	always @(posedge clk) begin
		$monitor("  -->  ptr = %d and stack[ptr] = %d at %t", ptr, stack[ptr], $time);
		if (reset) begin
			ptr <= -1;
			$display("%t: Stack Reset.", $time);
		end
		else if (push && !pop) begin
			stack[ptr+1] <= in;
			ptr <= ptr+1;
			$display("%t: Push Finished.", $time);
		end
		else if (pop && !push) begin
			out <= stack[ptr];
			ptr <= ptr-1;
			$display("%t: Pop Finished.", $time);
		end
		else if (push && pop) begin
			case (in)
				16'd1:
					stack[ptr-1] <= stack[ptr-1] + stack[ptr];
				16'd2:
					stack[ptr-1] <= stack[ptr-1] - stack[ptr];
				16'd4:
					stack[ptr-1] <= stack[ptr-1] * stack[ptr];
			endcase
			ptr <= ptr-1;
			$display("%t: Calculation Finished.", $time);
		end
	end
endmodule
