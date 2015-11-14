module convert(
		input [17:0] binary_in,
		output [7:0] text_out0,
		output [7:0] text_out1,
		output [7:0] text_out2,
		output [7:0] text_out3,
		output [7:0] text_out4
	);

assign text_out4 = (binary_in[3:0]   < 10) ? (binary_in[3:0]   + 8'd48) : (binary_in[3:0]   + 8'd65);
assign text_out3 = (binary_in[7:4]   < 10) ? (binary_in[7:4]   + 8'd48) : (binary_in[7:4]   + 8'd65);
assign text_out2 = (binary_in[11:8]  < 10) ? (binary_in[11:8]  + 8'd48) : (binary_in[11:8]  + 8'd65);
assign text_out1 = (binary_in[15:12] < 10) ? (binary_in[15:12] + 8'd48) : (binary_in[15:12] + 8'd65);
assign text_out0 =  binary_in[17:16] + 8'd48;

endmodule
