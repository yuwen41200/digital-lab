module avg_by_shift(
		input  clk, rst,
		output [7:0] avg
	);

	reg  in_valid;
	reg  [7:0]  data0 [0:31];
	reg  [7:0]  data1 [0:31];
	reg  [7:0]  data2 [0:31];
	reg  [7:0]  data3 [0:31];
	reg  [7:0]  data4 [0:31];
	reg  [7:0]  data5 [0:31];
	reg  [7:0]  data6 [0:31];
	reg  [7:0]  data7 [0:31];
	reg  [5:0]  data_count;
	wire [7:0]  in0, in1, in2, in3, in4, in5, in6, in7;
	wire [15:0] sum;

	adder_tree adder(
		.clk(clk), .rst(rst), .in_valid(in_valid),
		.in0(in0), .in1(in1), .in2(in2), .in3(in3), .in4(in4), .in5(in5), .in6(in6), .in7(in7),
		.sum(sum)
	);

	assign avg = (sum + 128) >> 8;
	assign in0 = data0[0];
	assign in1 = data1[0];
	assign in2 = data2[0];
	assign in3 = data3[0];
	assign in4 = data4[0];
	assign in5 = data5[0];
	assign in6 = data6[0];
	assign in7 = data7[0];

	always @(posedge clk) begin
		if (rst) begin
			`include "data.dat"
			data_count <= 0;
			in_valid <= 1;
		end
		else begin
			if (data_count < 32) begin
				// do sth
				data_count <= data_count + 1;
			end
			else
				in_valid <= 0;
		end
	end

endmodule
