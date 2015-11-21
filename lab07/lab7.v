/**
 * The sample top module of Lab 7: SD card reader. The behavior of this module is as follows:
 *   a. When the SD card is initialized, turns on all the LEDs.
 *   b. The user must press the reset button to properly reset the SD card controller.
 *   c. The user can then press the west button to trigger the SD card controller to read the super block
 *      of the SD card (located at block 8192) into a SRAM memory.
 *   d. The LED will then display the first byte of the super block, i.e. 0xeb.
 * Copyright Notice: This code is written by the TAs of this course.
 */
module lab7(
		// General system I/O ports
		input  clk,
		input  reset,
		input  button,
		input  rx,
		output tx,
		output [7:0] led,

		// SD card specific I/O ports
		output cs,
		output sclk,
		output mosi,
		input  miso
		);

localparam [2:0] S_SD_INIT = 3'b000, S_SD_IDLE = 3'b001, S_SD_WAIT = 3'b010, S_SD_READ = 3'b011, S_SD_BYTE0 = 3'b100;
localparam [1:0] S_UART_IDLE = 2'b00, S_UART_WAIT = 2'b01, S_UART_SEND = 2'b10, S_UART_INCR = 2'b11;

// declare system variables
wire btn_level, btn_pressed;
reg  prev_btn_level;
reg  [2:0] P, P_next;
reg  [1:0] Q, Q_next;
reg  [9:0] uart_counter;
reg  [9:0] sd_counter;
reg  [7:0] signature;

// declare UART signals
wire transmit;
wire received;
wire [7:0] rx_byte;
wire [7:0] tx_byte;
wire is_receiving;
wire is_transmitting;
wire recv_error;

// declare SD card interface signals
wire clk_sel;
wire clk_500k;
reg  rd_req;
reg  [31:0] rd_addr;
wire init_finish;
wire [7:0] sd_dout;
wire out_valid;

// declare a SRAM memory block
reg  [7:0] sram[511:0];
reg  [7:0] data_out;
wire [7:0] data_in;
wire       we, en;
wire [8:0] sram_addr;

// application sginals
wire print_message;

reg test_flag;

assign clk_sel = (init_finish)? clk : clk_500k; // clock selection for the SD controller
assign led = (test_flag)? signature : (P == S_SD_IDLE)? 8'b11111111 : 8'b0;
assign print_message = 0; // flag that triggers the operation of the UART controller

debounce btn_db0(
		.clk(clk),
		.btn_input(button),
		.btn_output(btn_level)
		);

uart uart0(
		.clk(clk),
		.rst(reset),
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

sd_card sd_card0(
		.cs(cs),
		.sclk(sclk),
		.mosi(mosi),
		.miso(miso),
		.clk(clk_sel),
		.rst(reset),

		.rd_req(rd_req),
		.block_address(rd_addr),
		.init_finish(init_finish),
		.dout(sd_dout),
		.out_valid(out_valid)
	);

clk_divider#(100) clk_divider0(
		.clk(clk),
		.reset(reset),
		.clk_out(clk_500k)
	);

//
// enable one cycle of btn_pressed per each button hit
//
always @(posedge clk) begin
	if (reset)
		prev_btn_level <= 0;
	else
		prev_btn_level <= btn_level;
end

assign btn_pressed = (btn_level == 1 && prev_btn_level == 0)? 1 : 0;

// ------------------------------------------------------------------------
// The following code describes an SRAM memory block that is connected
// to the data output port of the SD controller.
// Once the read request is made to the SD controller, 512 bytes of data
// will be sequentially read into the SRAM memory block, one byte per
// clock cycle (as long as the out_valid signal is high).

assign we = out_valid;     // Write data into SRAM when out_valid is high.
assign en = 1;             // Always enable the SRAM block.
assign data_in = sd_dout;  // Input data always comes from the SD controller.

// Set the master FSM that controls the SRAM addresses, the master
// is the SD_FSM when the UART_FSM is in the idle state.
assign sram_addr = (Q == S_UART_IDLE)? sd_counter[8:0] : uart_counter[8:0];

always @(posedge clk) begin // Write data into the SRAM block
	if (en && we) begin
		sram[sram_addr] <= data_in;
	end
end
	
always @(posedge clk) begin // The read data port of the SRAM is always active
	if (en && we)             // If data is being written into SRAM, also
		data_out <= data_in;    // forward the data to the read port
	else
		data_out <= sram[sram_addr];  // Send current data to the read port
end

// End of the SRAM memory block
// ------------------------------------------------------------------------

// ------------------------------------------------------------------------
// FSM of the SD card reader that reads the super block (512 bytes)
always @(posedge clk) begin
	if (reset) begin
		P <= S_SD_INIT;
		test_flag <= 0;
	end
	else begin
		P <= P_next;
		test_flag <= (P == S_SD_BYTE0)? 1 : test_flag;
	end
end

always @(*) begin // FSM next-state logic
	case (P)
		S_SD_INIT: // wait for SD card initialization
			if (init_finish == 1) P_next = S_SD_IDLE;
			else P_next = S_SD_INIT;
		S_SD_IDLE: // wait for button click
			if (btn_pressed == 1) P_next = S_SD_WAIT;
			else P_next = S_SD_IDLE;
		S_SD_WAIT: // issue a rd_req to the SD controller until it's ready
			P_next = S_SD_READ;
		S_SD_READ: // wait for the input data to enter the SRAM buffer
			if (sd_counter == 512) P_next = S_SD_BYTE0;
			else P_next = S_SD_READ;
		S_SD_BYTE0: // read byte 0 of the superblock from sram[]
			P_next = S_SD_IDLE;
		default:
			P_next = S_SD_IDLE;
	endcase
end

// FSM output logic: controls the 'rd_req' and 'rd_addr' signals.
// In this example, we always set rd_addr to 8192 since we only have
// to read the super block. For lab7, you must control 'rd_addr'
// to scan through all the SD card blocks (each block has 512 bytes).
//
always @(posedge clk) begin
	if (P == S_SD_IDLE) begin
		rd_req <= 0;
		rd_addr <= 32'd8192;
	end
	else if (P == S_SD_WAIT) begin
		rd_req <= 1;
		rd_addr <= 32'd8192;
	end
	else begin
		rd_req <= 0;
		rd_addr <= 32'd8192;
	end
end

// FSM output logic: controls the 'sd_counter' signal.
//
always @(posedge clk) begin
	if (reset || P == S_SD_BYTE0)
		sd_counter <= 0;
	else if (P == S_SD_READ && out_valid)
		sd_counter <= sd_counter + 1;
end

// FSM ouput logic: Retrieves the content of sram[0] for led display
//
always @(posedge clk) begin
	if (reset) signature <= 8'b0;
	else if (en && P == S_SD_BYTE0) signature <= data_out;
end

// End of the FSM of the SD card reader
// ------------------------------------------------------------------------

// ------------------------------------------------------------------------
// FSM of the UART print data controller
always @(posedge clk) begin
	if (reset) Q <= S_UART_IDLE;
	else Q <= Q_next;
end

always @(*) begin // FSM next-state logic
	case (Q)
		S_UART_IDLE: // wait for button click
			if (print_message == 1) Q_next = S_UART_WAIT;
			else Q_next = S_UART_IDLE;
		S_UART_WAIT: // wait for the transmission of current data byte begins
			if (is_transmitting == 1) Q_next = S_UART_SEND;
			else Q_next = S_UART_WAIT;
		S_UART_SEND: // wait for the transmission of current data byte finishes
			if (is_transmitting == 0) Q_next = S_UART_INCR; // transmit next character
			else Q_next = S_UART_SEND;
		S_UART_INCR:
			if (tx_byte == 8'b0) Q_next = S_UART_IDLE; // data transmission ends
			else Q_next = S_UART_WAIT;
	endcase
end

// FSM output logics
assign transmit = (Q == S_UART_WAIT)? 1 : 0;
assign tx_byte = data_out;

// FSM-controlled send_counter incrementing data path
always @(posedge clk) begin
	if (reset || (Q == S_UART_IDLE))
		uart_counter <= 0;
	else if (Q == S_UART_INCR)
		uart_counter <= uart_counter + 1;
end
// End of the FSM of the UART print data controller
// ------------------------------------------------------------------------

endmodule
