/**
 * The top module of Lab 7: SD Card Reader Circuit. The behavior of this module is as follows:
 *   a. When the SD card is initialized, turns on all the LEDs.
 *   b. A user must press the reset button to properly reset the SD card controller.
 *   c. Then, a user can press the west button to trigger the SD card controller to search the SD card.
 *   d. The UART terminal will then display the designated string found on the SD card.
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
localparam [2:0] S_SDCD_INIT = 3'd0, S_SDCD_IDLE = 3'd1, S_SDCD_WAIT = 3'd2, S_SDCD_READ = 3'd3, S_SDCD_VRFY = 3'd4;
localparam [1:0] S_UART_IDLE = 2'd0, S_UART_WAIT = 2'd1, S_UART_SEND = 2'd2, S_UART_INCR = 2'd3;

// Declare system variables
reg [2:0] P, P_next;
reg [1:0] Q, Q_next;
reg [9:0] sdcd_counter;
reg [9:0] uart_counter;

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
wire clk_sel, clk_500khz;
wire init_finish;

clk_divider#(100) clk_divider(
		.clk(clk),
		.rst(rst),
		.clk_out(clk_500khz)
	);

assign clk_sel = (init_finish) ? clk : clk_500khz;

// Declare SD card controller signals
reg  rd_req;
reg  [31:0] rd_adr;
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
		.block_address(rd_adr),
		.init_finish(init_finish),
		.dout(sdcd_out),
		.out_valid(out_valid)
	);

assign led = (P == S_SDCD_IDLE) ? 8'hFF : {2'b0, rd_adr[5:0]};

// Application signals
reg  [7:0] pattern [0:7];
reg  sdcd_verify_success;

// The following code describes an SRAM memory block that is connected to the data output port of the SD card controller.
// Once the read request is made to the SD card controller, 512 bytes of data will be sequentially written to the SRAM memory,
// one byte per clock cycle, as long as the 'out_valid' signal is high.
reg  [7:0] sram [0:511];
reg  [7:0] data_out;
wire [7:0] data_in;
wire write_enabled, enabled;
wire [8:0] sram_addr;

assign write_enabled = out_valid;    // Write data to the SRAM when 'out_valid' is high.
assign enabled = 1;                  // Always enable the SRAM block.
assign data_in = sdcd_out;           // Input data always come from the SD card controller.
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

// FSM for the SD card reader
always @(posedge clk) begin
	if (rst)
		P <= S_SDCD_INIT;
	else
		P <= P_next;
end

always @(*) begin
	case (P)
		S_SDCD_INIT:  // Wait for the SD card initialization.
			if (init_finish)
				P_next = S_SDCD_IDLE;
			else
				P_next = S_SDCD_INIT;
		S_SDCD_IDLE:  // Wait for a button click.
			if (btn_r)
				P_next = S_SDCD_WAIT;
			else
				P_next = S_SDCD_IDLE;
		S_SDCD_WAIT:  // Issue a 'rd_req' to the SD card controller.
			P_next = S_SDCD_READ;
		S_SDCD_READ:  // Wait for the input data to enter the SRAM buffer.
			if (sdcd_counter == 512)
				P_next = S_SDCD_VRFY;
			else
				P_next = S_SDCD_READ;
		S_SDCD_VRFY:  // Verify whether the data block begins with 'DLAB_TAG'.
			if (sdcd_verify_success)
				P_next = S_SDCD_IDLE;
			else
				P_next = S_SDCD_WAIT;
	endcase
end

always @(posedge clk) begin
	if (rst || P == S_SDCD_IDLE) begin
		rd_req <= 0;
		rd_adr <= 32'd8191;
	end
	else if (P == S_SDCD_WAIT) begin
		rd_req <= 1;
		rd_adr <= rd_adr + 1;
	end
	else begin
		rd_req <= 0;
		rd_adr <= rd_adr;
	end
end

always @(posedge clk) begin
	if (rst || P == S_SDCD_WAIT)
		sdcd_counter <= 0;
	else if (P == S_SDCD_READ && out_valid)
		sdcd_counter <= sdcd_counter + 1;
end

always @(posedge clk) begin
	if (rst || P == S_SDCD_WAIT) begin
		pattern[0] <= 8'b0;
		pattern[1] <= 8'b0;
		pattern[2] <= 8'b0;
		pattern[3] <= 8'b0;
		pattern[4] <= 8'b0;
		pattern[5] <= 8'b0;
		pattern[6] <= 8'b0;
		pattern[7] <= 8'b0;
	end
	else if (P == S_SDCD_READ && out_valid && sdcd_counter >= 0 && sdcd_counter <= 7)
		pattern[sdcd_counter] <= sdcd_out;
end

always @(posedge clk) begin
	if (rst || P == S_SDCD_IDLE || P == S_SDCD_WAIT)
		sdcd_verify_success <= 0;
	else if (P == S_SDCD_VRFY && pattern[0] == 8'h44 && pattern[1] == 8'h4C && pattern[2] == 8'h41 && pattern[3] == 8'h42
	                          && pattern[4] == 8'h5F && pattern[5] == 8'h54 && pattern[6] == 8'h41 && pattern[7] == 8'h47)
		sdcd_verify_success <= 1;
end

// FSM for the UART controller
always @(posedge clk) begin
	if (rst)
		Q <= S_UART_IDLE;
	else
		Q <= Q_next;
end

always @(*) begin
	case (Q)
		S_UART_IDLE:  // When the block is found, start a UART transmission.
			if (sdcd_verify_success)
				Q_next = S_UART_WAIT;
			else
				Q_next = S_UART_IDLE;
		S_UART_WAIT:  // Wait for the transmission of the current data byte begins.
			if (is_transmitting)
				Q_next = S_UART_SEND;
			else
				Q_next = S_UART_WAIT;
		S_UART_SEND:  // Wait for the transmission of the current data byte finishes.
			if (is_transmitting)
				Q_next = S_UART_SEND;
			else
				Q_next = S_UART_INCR;
		S_UART_INCR:  // Determine if whole data transmission ends.
			if (tx_byte == 8'b0)
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
