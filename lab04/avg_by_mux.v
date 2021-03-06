module avg_by_mux(
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

	// php > for ($i=0; $i<=31; $i++) echo ".data".$i."(data0[".$i."]), ";
	mux_selector mux0(.data0(data0[0]), .data1(data0[1]), .data2(data0[2]), .data3(data0[3]), .data4(data0[4]), .data5(data0[5]), .data6(data0[6]), .data7(data0[7]), .data8(data0[8]), .data9(data0[9]), .data10(data0[10]), .data11(data0[11]), .data12(data0[12]), .data13(data0[13]), .data14(data0[14]), .data15(data0[15]), .data16(data0[16]), .data17(data0[17]), .data18(data0[18]), .data19(data0[19]), .data20(data0[20]), .data21(data0[21]), .data22(data0[22]), .data23(data0[23]), .data24(data0[24]), .data25(data0[25]), .data26(data0[26]), .data27(data0[27]), .data28(data0[28]), .data29(data0[29]), .data30(data0[30]), .data31(data0[31]), .data_count(data_count), .in(in0));
	mux_selector mux1(.data0(data1[0]), .data1(data1[1]), .data2(data1[2]), .data3(data1[3]), .data4(data1[4]), .data5(data1[5]), .data6(data1[6]), .data7(data1[7]), .data8(data1[8]), .data9(data1[9]), .data10(data1[10]), .data11(data1[11]), .data12(data1[12]), .data13(data1[13]), .data14(data1[14]), .data15(data1[15]), .data16(data1[16]), .data17(data1[17]), .data18(data1[18]), .data19(data1[19]), .data20(data1[20]), .data21(data1[21]), .data22(data1[22]), .data23(data1[23]), .data24(data1[24]), .data25(data1[25]), .data26(data1[26]), .data27(data1[27]), .data28(data1[28]), .data29(data1[29]), .data30(data1[30]), .data31(data1[31]), .data_count(data_count), .in(in1));
	mux_selector mux2(.data0(data2[0]), .data1(data2[1]), .data2(data2[2]), .data3(data2[3]), .data4(data2[4]), .data5(data2[5]), .data6(data2[6]), .data7(data2[7]), .data8(data2[8]), .data9(data2[9]), .data10(data2[10]), .data11(data2[11]), .data12(data2[12]), .data13(data2[13]), .data14(data2[14]), .data15(data2[15]), .data16(data2[16]), .data17(data2[17]), .data18(data2[18]), .data19(data2[19]), .data20(data2[20]), .data21(data2[21]), .data22(data2[22]), .data23(data2[23]), .data24(data2[24]), .data25(data2[25]), .data26(data2[26]), .data27(data2[27]), .data28(data2[28]), .data29(data2[29]), .data30(data2[30]), .data31(data2[31]), .data_count(data_count), .in(in2));
	mux_selector mux3(.data0(data3[0]), .data1(data3[1]), .data2(data3[2]), .data3(data3[3]), .data4(data3[4]), .data5(data3[5]), .data6(data3[6]), .data7(data3[7]), .data8(data3[8]), .data9(data3[9]), .data10(data3[10]), .data11(data3[11]), .data12(data3[12]), .data13(data3[13]), .data14(data3[14]), .data15(data3[15]), .data16(data3[16]), .data17(data3[17]), .data18(data3[18]), .data19(data3[19]), .data20(data3[20]), .data21(data3[21]), .data22(data3[22]), .data23(data3[23]), .data24(data3[24]), .data25(data3[25]), .data26(data3[26]), .data27(data3[27]), .data28(data3[28]), .data29(data3[29]), .data30(data3[30]), .data31(data3[31]), .data_count(data_count), .in(in3));
	mux_selector mux4(.data0(data4[0]), .data1(data4[1]), .data2(data4[2]), .data3(data4[3]), .data4(data4[4]), .data5(data4[5]), .data6(data4[6]), .data7(data4[7]), .data8(data4[8]), .data9(data4[9]), .data10(data4[10]), .data11(data4[11]), .data12(data4[12]), .data13(data4[13]), .data14(data4[14]), .data15(data4[15]), .data16(data4[16]), .data17(data4[17]), .data18(data4[18]), .data19(data4[19]), .data20(data4[20]), .data21(data4[21]), .data22(data4[22]), .data23(data4[23]), .data24(data4[24]), .data25(data4[25]), .data26(data4[26]), .data27(data4[27]), .data28(data4[28]), .data29(data4[29]), .data30(data4[30]), .data31(data4[31]), .data_count(data_count), .in(in4));
	mux_selector mux5(.data0(data5[0]), .data1(data5[1]), .data2(data5[2]), .data3(data5[3]), .data4(data5[4]), .data5(data5[5]), .data6(data5[6]), .data7(data5[7]), .data8(data5[8]), .data9(data5[9]), .data10(data5[10]), .data11(data5[11]), .data12(data5[12]), .data13(data5[13]), .data14(data5[14]), .data15(data5[15]), .data16(data5[16]), .data17(data5[17]), .data18(data5[18]), .data19(data5[19]), .data20(data5[20]), .data21(data5[21]), .data22(data5[22]), .data23(data5[23]), .data24(data5[24]), .data25(data5[25]), .data26(data5[26]), .data27(data5[27]), .data28(data5[28]), .data29(data5[29]), .data30(data5[30]), .data31(data5[31]), .data_count(data_count), .in(in5));
	mux_selector mux6(.data0(data6[0]), .data1(data6[1]), .data2(data6[2]), .data3(data6[3]), .data4(data6[4]), .data5(data6[5]), .data6(data6[6]), .data7(data6[7]), .data8(data6[8]), .data9(data6[9]), .data10(data6[10]), .data11(data6[11]), .data12(data6[12]), .data13(data6[13]), .data14(data6[14]), .data15(data6[15]), .data16(data6[16]), .data17(data6[17]), .data18(data6[18]), .data19(data6[19]), .data20(data6[20]), .data21(data6[21]), .data22(data6[22]), .data23(data6[23]), .data24(data6[24]), .data25(data6[25]), .data26(data6[26]), .data27(data6[27]), .data28(data6[28]), .data29(data6[29]), .data30(data6[30]), .data31(data6[31]), .data_count(data_count), .in(in6));
	mux_selector mux7(.data0(data7[0]), .data1(data7[1]), .data2(data7[2]), .data3(data7[3]), .data4(data7[4]), .data5(data7[5]), .data6(data7[6]), .data7(data7[7]), .data8(data7[8]), .data9(data7[9]), .data10(data7[10]), .data11(data7[11]), .data12(data7[12]), .data13(data7[13]), .data14(data7[14]), .data15(data7[15]), .data16(data7[16]), .data17(data7[17]), .data18(data7[18]), .data19(data7[19]), .data20(data7[20]), .data21(data7[21]), .data22(data7[22]), .data23(data7[23]), .data24(data7[24]), .data25(data7[25]), .data26(data7[26]), .data27(data7[27]), .data28(data7[28]), .data29(data7[29]), .data30(data7[30]), .data31(data7[31]), .data_count(data_count), .in(in7));

	adder_tree adder(
		.clk(clk), .rst(rst), .in_valid(in_valid),
		.in0(in0), .in1(in1), .in2(in2), .in3(in3), .in4(in4), .in5(in5), .in6(in6), .in7(in7),
		.sum(sum)
	);

	assign avg = (sum + 128) >> 8;

	always @(posedge clk) begin
		if (rst) begin
			`include "data.dat"
			data_count <= 0;
			in_valid <= 1;
		end
		else begin
			if (data_count < 31)
				data_count <= data_count + 1;
			else
				in_valid <= 0;
		end
		// $display("data_count = %d at time = %d", data_count, $time);
	end

endmodule
