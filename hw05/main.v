module main(
		input clk,
		input rst,
		input btn,
		input rx,
		output tx,
		output [7:0] led
	);

localparam [1:0] S_IDLE = 2'b00, S_WAIT = 2'b01, S_SEND = 2'b10, S_INCR = 2'b11;
localparam MEM_SIZE = 256;

wire btn_pressed;
wire transmit;
wire [7:0]  tx_byte;
wire received;
wire [7:0]  rx_byte;
wire is_receiving;
wire is_transmitting;
wire recv_error;
reg  [7:0]  send_counter, recv_counter;
reg  [1:0]  current_state, next_state;
reg  [7:0]  data [0:MEM_SIZE-1];
reg  [15:0] recv_invalid;
integer idx;

debounce debounce(.clk(clk), .btn_input(btn), .btn_output(btn_pressed));

uart uart(.clk(clk), .rst(rst), .rx(rx), .tx(tx), .transmit(transmit), .tx_byte(tx_byte), .received(received),
	.rx_byte(rx_byte), .is_receiving(is_receiving), .is_transmitting(is_transmitting), .recv_error(recv_error));

assign led = {7'b0, btn_pressed};
assign tx_byte = data[send_counter];
assign transmit = (current_state == S_WAIT) ? 1 : 0;

// Circuit for Receiving Data

always @(posedge clk) begin
	if (rst) begin
		recv_counter <= 0;
		recv_invalid <= 0;
	end
	else if (received || is_receiving) begin
		if (recv_invalid == 52083) begin // (1/9600 * 10) / (2 * 10^-8) = 52083.333
			recv_counter <= recv_counter + 1;
			recv_invalid <= 0;
		end
		else
			recv_invalid <= recv_invalid + 1;
	end
end

always @(posedge clk) begin
	if (rst)
		for (idx = 0; idx < MEM_SIZE; idx = idx + 1)
			data[idx] <= 8'h0;
	else if ((received || is_receiving) && (recv_invalid == 0)) begin
		if (rx_byte >= 8'h61 && rx_byte <= 8'h7A)
			data[recv_counter] <= rx_byte - 8'h20;
		else
			data[recv_counter] <= rx_byte;
	end
end

// Circuit for Transmitting Data

always @(posedge clk) begin
	if (rst)
		current_state <= S_IDLE;
	else
		current_state <= next_state;
end

always @(posedge clk) begin
	if (rst || current_state == S_IDLE)
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

endmodule
