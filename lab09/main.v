/**
 * Top Module: Finding Primes Using the Sieve Algorithm
 */

module main(
		input clk,
		input rst,
		input btn,
		output LCD_E,
		output LCD_RS,
		output LCD_RW,
		output [3:0] LCD_D
	);

// Instantiate modules - Signal declarations
reg  [127:0] row_A, row_B;
wire btn_r;

// An SRAM memory block - Signal declarations
reg  [7:0] sram [0:1023];
reg  [7:0] data_out;
wire [7:0] data_in;
wire write_enabled, enabled;
wire [9:0] sram_addr;

// FSM for the sieve algorithm - Signal declarations
reg  [2:0]  state, next_state;
reg  [7:0]  print_idx0, print_idx1;
reg  [7:0]  output_idx;
reg  [9:0]  output_list [0:255];
reg  [9:0]  outer_idx;
reg  [10:0] inner_idx;
reg  [24:0] wait_count;
wire [9:0]  print_idx0_r, print_idx1_r;
wire [7:0]  char00, char01, char02, char03, char04, char05,
            char10, char11, char12, char13, char14, char15;

localparam [2:0] INIT_MEM = 0, WAIT_SM1 = 1, FIND_PRIME = 2, WAIT_SM2 = 3,
                 MARK_MUL = 4, GEN_OUT  = 5, PRINT_LCD  = 6, WAIT_LG  = 7;

// Instantiate modules
assign print_idx0_r = print_idx0 + 1;
assign print_idx1_r = print_idx1 + 1;

lcd lcd0(
	.clk(clk),
	.rst(rst),
	.row_A(row_A),
	.row_B(row_B),
	.LCD_E(LCD_E),
	.LCD_RS(LCD_RS),
	.LCD_RW(LCD_RW),
	.LCD_D(LCD_D)
);

debounce debounce0(
	.clk(clk),
	.btn_in(btn),
	.btn_out(btn_r)
);

convert convert0(
	.binary_in(print_idx0_r),
	.text_out0(char00),
	.text_out1(char01),
	.text_out2(char02)
);

convert convert1(
	.binary_in(output_list[print_idx0]),
	.text_out0(char03),
	.text_out1(char04),
	.text_out2(char05)
);

convert convert2(
	.binary_in(print_idx1_r),
	.text_out0(char10),
	.text_out1(char11),
	.text_out2(char12)
);

convert convert3(
	.binary_in(output_list[print_idx1]),
	.text_out0(char13),
	.text_out1(char14),
	.text_out2(char15)
);

// An SRAM memory block
assign write_enabled = (state == INIT_MEM || (state == MARK_MUL && inner_idx[10] == 0)) ? 1 : 0;
assign enabled = 1;
assign data_in = (state == INIT_MEM) ? 1 : 0;
assign sram_addr = (state == MARK_MUL) ? inner_idx : outer_idx;

always @(posedge clk)
	if (enabled && write_enabled) begin
		sram[sram_addr] <= data_in;
		$display("Debug Message: data_out = %d, inner_idx = %d, outer_idx = %d", data_out, inner_idx, outer_idx);
	end

always @(posedge clk) begin
	if (enabled && write_enabled)
		data_out <= data_in;
	else
		data_out <= sram[sram_addr];
end

// FSM for the sieve algorithm
always @(*) begin
	case (state)
		INIT_MEM:
		// Initialize all memories to one
			if (outer_idx == 1023)
				next_state = WAIT_SM1;
			else
				next_state = INIT_MEM;
		WAIT_SM1:
		// Wait for a short time
			if (wait_count == 5)
				next_state = FIND_PRIME;
			else
				next_state = WAIT_SM1;
		FIND_PRIME:
		// Find the next prime number
			if (data_out == 1)
				next_state = WAIT_SM2;
			else if (outer_idx == 1023)
				next_state = GEN_OUT;
			else
				next_state = WAIT_SM1;
		WAIT_SM2:
		// Wait for a short time
			if (wait_count == 5)
				next_state = MARK_MUL;
			else
				next_state = WAIT_SM2;
		MARK_MUL:
		// Mark its multiples as zero
			if (inner_idx >= 1023)
				next_state = WAIT_SM1;
			else
				next_state = MARK_MUL;
		GEN_OUT:
		// Generate final output
			if (outer_idx == 1023)
				next_state = PRINT_LCD;
			else
				next_state = GEN_OUT;
		PRINT_LCD:
		// Print two lines on the LCD display
			next_state = WAIT_LG;
		WAIT_LG:
		// Wait for a long time
			if (wait_count == 25'b1111111111111111111111111)
				next_state = PRINT_LCD;
			else
				next_state = WAIT_LG;
	endcase
end

always @(posedge clk) begin
	if (rst)
		state <= INIT_MEM;
	else
		state <= next_state;
end

always @(posedge clk) begin
	if (rst)
		outer_idx <= 2;
	else if (state == INIT_MEM || state == FIND_PRIME || state == GEN_OUT) begin
		if (outer_idx < 1023)
			outer_idx <= outer_idx + 1;
		else
			outer_idx <= 2;
	end
end

always @(posedge clk) begin
	if (state == MARK_MUL)
		inner_idx <= inner_idx + outer_idx - 1;
	else
		inner_idx <= outer_idx + outer_idx - 2;
end

always @(posedge clk) begin
	if (rst)
		output_idx <= 0;
	else if (state == GEN_OUT && data_out == 1) begin
		output_list[output_idx] <= outer_idx - 1;
		output_idx <= output_idx + 1;
	end
end

always @(posedge clk) begin
	if (state == WAIT_SM1 || state == WAIT_SM2 || state == WAIT_LG)
		wait_count <= wait_count + 1;
	else
		wait_count <= 0;
end

always @(posedge clk) begin
	if (rst) begin
		row_A <= 128'h5072696D652023303020697320303030;
		row_B <= 128'h5072696D652023303020697320303030;
		// string[16](PPrriimmee..##0000..iiss..000000)
	end
	else if (state == PRINT_LCD) begin
		row_A[23:0]  <= {char03, char04, char05};
		row_A[71:56] <= {char01, char02};
		row_B[23:0]  <= {char13, char14, char15};
		row_B[71:56] <= {char11, char12};
	end
end

always @(posedge clk) begin
	if (rst) begin
		print_idx0 <= 0;
		print_idx1 <= 1;
	end
	else if (state == PRINT_LCD) begin
		if (print_idx0 + 1 < output_idx)
			print_idx0 <= print_idx0 + 1;
		else
			print_idx0 <= 0;
		if (print_idx1 + 1 < output_idx)
			print_idx1 <= print_idx1 + 1;
		else
			print_idx1 <= 0;
	end
end

endmodule
