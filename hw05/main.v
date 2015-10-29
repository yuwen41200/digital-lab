module main(
		input clk,
		input rst,
		input btn,
		input rx,
		output tx,
		output [7:0] led
	);

localparam [1:0] S_IDLE = 2'b00, S_WAIT = 2'b01, S_SEND = 2'b10, S_INCR = 2'b11;
localparam MEM_SIZE = 32;

wire btn_pressed;
wire transmit;
wire [7:0] tx_byte;
wire received;
wire [7:0] rx_byte;
wire is_receiving;
wire is_transmitting;
wire recv_error;
reg  [7:0] send_counter;
reg  [1:0] current_state, next_state;
reg  [7:0] data [0:MEM_SIZE-1];
reg  [7:0] rx_temp;
integer idx;

debounce debounce(.clk(clk), .btn_input(btn), .btn_output(btn_pressed));

uart uart(.clk(clk), .rst(rst), .rx(rx), .tx(tx), .transmit(transmit), .tx_byte(tx_byte), .received(received),
	.rx_byte(rx_byte), .is_receiving(is_receiving), .is_transmitting(is_transmitting), .recv_error(recv_error));

assign led = {7'b0, btn_pressed};
assign tx_byte = data[send_counter];
assign transmit = (current_state == S_WAIT) ? 1 : 0;

always begin
	data[ 0] = 8'h48; // H
	data[ 1] = 8'h65; // e
	data[ 2] = 8'h6C; // l
	data[ 3] = 8'h6C; // l
	data[ 4] = 8'h6F; // o
	data[ 5] = 8'h2C; // ,
	data[ 6] = 8'h20; // (space)
	data[ 7] = 8'h57; // w
	data[ 8] = 8'h6F; // o
	data[ 9] = 8'h72; // r
	data[10] = 8'h6C; // l
	data[11] = 8'h64; // d
	data[12] = 8'h21; // !
	data[13] = 8'h20; // (space)
	data[14] = 8'h0;  // (end of string)
	for (idx = 15; idx < MEM_SIZE; idx = idx + 1)
		data[idx] = 8'h0;
end

always @(posedge clk) begin
	if (rst)
		current_state <= S_IDLE;
	else
		current_state <= next_state;
end

always @(posedge clk) begin
	if (rst || (current_state == S_IDLE))
		send_counter <= 0;
	else if (current_state == S_INCR)
		send_counter <= send_counter + 1;
end

always @(*) begin
	case (current_state)
		S_IDLE: // wait for a button click
			if (btn_pressed)
				next_state = S_WAIT;
			else
				next_state = S_IDLE;
		S_WAIT: // wait for the transmission of the current data byte begins
			if (is_transmitting)
				next_state = S_SEND;
			else
				next_state = S_WAIT;
		S_SEND: // wait for the transmission of the current data byte finishes
			if (is_transmitting)
				next_state = S_SEND;
			else
				next_state = S_INCR;
		S_INCR: // transmit the next data byte, i.e. next character
			if (tx_byte == 8'h0)
				next_state = S_IDLE;
			else
				next_state = S_WAIT;
	endcase
end

// The following logic stores the UART input in a temporary buffer
always @(posedge clk) begin
	if (rst)
		rx_temp <= 8'b0;
	else if (received)
		rx_temp <= rx_byte;
end

endmodule
