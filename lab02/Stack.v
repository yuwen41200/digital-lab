// A stack that can store 10 16-bit signed integer
module Stack (
	input clk, reset, [15:0] in,
	input push, pop,
	output reg [15:0] out
);
	reg [4:0]  ptr;
	reg [15:0] stack [0:9];
	always @(posedge clk) begin
		if (reset)
			ptr <= 0;
		else if (push) begin
			stack[ptr+1] <= in;
			ptr <= ptr+1;
		end
		else if (pop) begin
			out <= stack[ptr];
			ptr <= ptr-1;
		end
	end
endmodule
