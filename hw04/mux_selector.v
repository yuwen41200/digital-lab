module mux_selector(
		// php > for ($i=0; $i<=31; $i++) echo "data".$i.", ";
		input [7:0] data0, data1, data2, data3, data4, data5, data6, data7,
		input [7:0] data8, data9, data10, data11, data12, data13, data14, data15,
		input [7:0] data16, data17, data18, data19, data20, data21, data22, data23,
		input [7:0] data24, data25, data26, data27, data28, data29, data30, data31,
		input [5:0] data_count, output reg [7:0] in
	);

	always @(*) begin
		case (data_count)
			// php > for ($i=0; $i<=31; $i++) echo $i.": in = data".$i.";\n";
			0: in = data0;
			1: in = data1;
			2: in = data2;
			3: in = data3;
			4: in = data4;
			5: in = data5;
			6: in = data6;
			7: in = data7;
			8: in = data8;
			9: in = data9;
			10: in = data10;
			11: in = data11;
			12: in = data12;
			13: in = data13;
			14: in = data14;
			15: in = data15;
			16: in = data16;
			17: in = data17;
			18: in = data18;
			19: in = data19;
			20: in = data20;
			21: in = data21;
			22: in = data22;
			23: in = data23;
			24: in = data24;
			25: in = data25;
			26: in = data26;
			27: in = data27;
			28: in = data28;
			29: in = data29;
			30: in = data30;
			31: in = data31;
			default: in = 0;
		endcase
	end

endmodule
