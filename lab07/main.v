/**
 * The sample top module of Lab 7: SD card reader. The behavior of this module is as follows:
 *   a. When the SD card is initialized, turns on all the LEDs.
 *   b. The user must press the reset button to properly reset the SD card controller.
 *   c. The user can then press the west button to trigger the SD card controller to read the super block
 *      of the SD card (located at block 8192) into a SRAM memory.
 *   d. The LED will then display the first byte of the super block, i.e. 0xeb.
 */

module main(
		// General system I/O ports
		input clk,
		input rst,
		input btn,
		input rx,
		output tx,
		output [7:0] led,
		// SD card specific I/O ports
		output cs,
		output sclk,
		output mosi,
		input miso
	);

// FSM states
localparam [2:0] S_SDCD_INIT = 3'd0, S_SDCD_IDLE = 3'd1, S_SDCD_WAIT = 3'd2, S_SDCD_READ = 3'd3, S_SDCD_VERIFY = 3'd4;
localparam [1:0] S_UART_IDLE = 2'd0, S_UART_WAIT = 2'd1, S_UART_SEND = 2'd2, S_UART_INCR = 2'd3;

// Declare system variables
reg [2:0] P, P_next;
reg [1:0] Q, Q_next;
reg [9:0] sdcd_counter;
reg [9:0] uart_counter;
reg [7:0] signature;

// Button debounce
wire btn_r;

debounce debounce(
		.clk(clk),
		.btn_in(btn),
		.btn_out(btn_r)
	);

// Declare UART signals
wire transmit;
wire received;
wire [7:0] tx_byte;
wire [7:0] rx_byte;
wire is_receiving;
wire is_transmitting;
wire recv_error;

uart uart(
		.clk(clk),
		.rst(rst),
		.rx(rx),
		.tx(tx),
		.transmit(transmit),
		.tx_byte(tx_byte),
		.received(received),
		.rx_byte(rx_byte),
		.is_receiving(is_receiving),
		.is_transmitting(is_transmitting),
		.recv_error(recv_error)
	);

// Clock selection for the SD card controller
wire clk_sel, clk_500k;

clk_divider#(100) clk_divider(
		.clk(clk),
		.rst(rst),
		.clk_out(clk_500k)
	);

assign clk_sel = (init_finish) ? clk : clk_500k;

// Declare SD card controller signals
reg  rd_req;
reg  [31:0] rd_addr;
wire init_finish;
wire [7:0] sdcd_out;
wire out_valid;

sd_card sd_card(
		.cs(cs),
		.sclk(sclk),
		.mosi(mosi),
		.miso(miso),
		.clk(clk_sel),
		.rst(rst),
		.rd_req(rd_req),
		.block_address(rd_addr),
		.init_finish(init_finish),
		.dout(sdcd_out),
		.out_valid(out_valid)
	);

// Application signals
reg  sdcd_read_done;
wire uart_transmit_start;

assign led = (sdcd_read_done) ? signature : (P == S_SDCD_IDLE) ? 8'b11111111 : 8'b0;
assign uart_transmit_start = 0;

// The following code describes an SRAM memory block that is connected to the data output port of the SD card controller.
// Once the read request is made to the SD card controller, 512 bytes of data will be sequentially read into the SRAM memory block,
// one byte per clock cycle (as long as the 'out_valid' signal is high).
reg  [7:0] sram [511:0];
reg  [7:0] data_out;
wire [7:0] data_in;
wire write_enabled, enabled;
wire [8:0] sram_addr;

assign write_enabled = out_valid; // Write data to the SRAM when 'out_valid' is high.
assign enabled = 1;               // Always enable the SRAM block.
assign data_in = sdcd_out;        // Input data always comes from the SD card controller.
assign sram_addr = (Q == S_UART_IDLE) ? sdcd_counter[8:0] : uart_counter[8:0];

always @(posedge clk)
	if (enabled && write_enabled)
		sram[sram_addr] <= data_in;  // Write data to the SRAM block.

always @(posedge clk) begin
	if (enabled && write_enabled)
		data_out <= data_in;         // Forward the written data to the read port.
	else
		data_out <= sram[sram_addr]; // Send the current data to the read port.
end

// FSM of the SD card reader that reads the super block (512 bytes)
always @(posedge clk) begin
	if (rst) begin
		P <= S_SDCD_INIT;
		sdcd_read_done <= 0;
	end
	else begin
		P <= P_next;
		sdcd_read_done <= (P == S_SDCD_VERIFY) ? 1 : sdcd_read_done;
	end
end

always @(*) begin
	case (P)
		S_SDCD_INIT: // Wait for SD card initialization.
			if (init_finish)
				P_next = S_SDCD_IDLE;
			else
				P_next = S_SDCD_INIT;
		S_SDCD_IDLE: // Wait for a button click.
			if (btn_r)
				P_next = S_SDCD_WAIT;
			else
				P_next = S_SDCD_IDLE;
		S_SDCD_WAIT: // Issue a 'rd_req' to the SD card controller.
			P_next = S_SDCD_READ;
		S_SDCD_READ: // Wait for the input data to enter the SRAM buffer.
			if (sdcd_counter == 512)
				P_next = S_SDCD_VERIFY;
			else
				P_next = S_SDCD_READ;
		S_SDCD_VERIFY: // Read byte 0 of the super block from 'sram'.
			P_next = S_SDCD_IDLE;
		default:
			P_next = S_SDCD_IDLE;
	endcase
end

always @(posedge clk) begin
	if (P == S_SDCD_IDLE) begin
		rd_req <= 0;
		rd_addr <= 32'd8192;
	end
	else if (P == S_SDCD_WAIT) begin
		rd_req <= 1; // Controls the 'rd_req' and 'rd_addr' signals.
		rd_addr <= 32'd8192;
	end
	else begin
		rd_req <= 0;
		rd_addr <= 32'd8192;
	end
end

always @(posedge clk) begin
	if (rst || P == S_SDCD_VERIFY)
		sdcd_counter <= 0;
	else if (P == S_SDCD_READ && out_valid)
		sdcd_counter <= sdcd_counter + 1; // Controls the 'sdcd_counter' signal.
end

always @(posedge clk) begin
	if (rst)
		signature <= 8'b0;
	else if (enabled && P == S_SDCD_VERIFY)
		signature <= data_out; // Retrieves the content of 'sram[0]' for led display.
end

// FSM of the UART controller
always @(posedge clk) begin
	if (rst)
		Q <= S_UART_IDLE;
	else
		Q <= Q_next;
end

always @(*) begin
	case (Q)
		S_UART_IDLE: // Wait for a trigger.
			if (uart_transmit_start)
				Q_next = S_UART_WAIT;
			else
				Q_next = S_UART_IDLE;
		S_UART_WAIT: // Wait for the transmission of the current data byte begins.
			if (is_transmitting)
				Q_next = S_UART_SEND;
			else
				Q_next = S_UART_WAIT;
		S_UART_SEND: // Wait for the transmission of the current data byte finishes.
			if (is_transmitting)
				Q_next = S_UART_SEND;
			else
				Q_next = S_UART_INCR;
		S_UART_INCR:
			if (tx_byte == 8'b0) // Data transmission ends.
				Q_next = S_UART_IDLE;
			else
				Q_next = S_UART_WAIT;
	endcase
end

always @(posedge clk) begin
	if (rst || Q == S_UART_IDLE)
		uart_counter <= 0;
	else if (Q == S_UART_INCR)
		uart_counter <= uart_counter + 1;
end

assign transmit = (Q == S_UART_WAIT) ? 1 : 0;
assign tx_byte = data_out;

endmodule
