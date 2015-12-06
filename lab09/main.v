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
reg [2:0]  state, next_state;
reg [7:0]  output_idx;
reg [9:0]  output_list [0:255];
reg [9:0]  outer_idx;
reg [10:0] inner_idx;
reg [24:0] wait_count;

localparam [2:0] INIT_MEM = 0, WAIT_SM1 = 1, FIND_PRIME = 2, WAIT_SM2 = 3,
                 MARK_MUL = 4, GEN_OUT  = 5, PRINT_LCD  = 6, WAIT_LG  = 7;

// Instantiate modules
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
			next_state = PRINT_LCD;
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

// Hello world
always @(posedge clk) begin
	if (rst) begin
		row_A <= 128'h2248656C6C6F2C20576F726C64212220; // "Hello, World!"
		row_B <= 128'h44656D6F206F6620746865204C43442E; // Demo of the LCD.
	end
	else if (btn_r) begin
		row_A <= row_B;
		row_B <= row_A;
	end
end

endmodule
