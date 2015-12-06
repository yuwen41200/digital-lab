/**
 * Binary Number to ASCII String Conversion Module
 */

module convert(
		input  [9:0] binary_in,
		output [7:0] text_out0,
		output [7:0] text_out1,
		output [7:0] text_out2
	);

assign text_out2 = (binary_in[3:0] < 10) ? (binary_in[3:0] + 8'd48) : (binary_in[3:0] + 8'd55);
assign text_out1 = (binary_in[7:4] < 10) ? (binary_in[7:4] + 8'd48) : (binary_in[7:4] + 8'd55);
assign text_out0 =  binary_in[9:8] + 8'd48;

endmodule
