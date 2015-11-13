module main(
		input clk,
		input rst,
		input btn,
		input rx,
		output tx,
		output [7:0] led
	);

localparam [2:0] S1_IDLE = 0, S1_ROW0 = 1, S1_ROW1 = 2, S1_ROW2 = 3, S1_ROW3 = 4, S1_PEND = 5, S1_DONE = 6;
localparam [1:0] S2_IDLE = 0, S2_WAIT = 1, S2_SEND = 2, S2_INCR = 3;

wire btn_r;
wire transmit;
wire [7:0] tx_byte;
wire received;
wire [7:0] rx_byte;
wire is_receiving;
wire is_transmitting;
wire recv_error;
wire multi_done;

reg [7:0]  mtx_a [0:15];
reg [7:0]  mtx_b [0:15];
reg [17:0] mtx_c [0:15];
reg [17:0] temp  [0:15];
reg [2:0]  curr_state1, next_state1;
reg [1:0]  curr_state2, next_state2;
reg [7:0]  recv_counter, send_counter;
reg [7:0]  result [0:255];
integer idx;

debounce debounce(.clk(clk), .btn_in(btn), .btn_out(btn_r));

uart uart(.clk(clk), .rst(rst), .rx(rx), .tx(tx), .transmit(transmit), .tx_byte(tx_byte), .received(received),
	.rx_byte(rx_byte), .is_receiving(is_receiving), .is_transmitting(is_transmitting), .recv_error(recv_error));

assign led = {7'b0, recv_error};
assign tx_byte = result[send_counter];
assign multi_done = (curr_state1 == S1_DONE) ? 1 : 0;
assign transmit = (curr_state2 == S2_WAIT) ? 1 : 0;

/**
 * receive two matrices from a binary file
 */

always @(posedge clk) begin
	if (rst)
		recv_counter <= 0;
	else if (received)
		recv_counter <= recv_counter + 1;
end

always @(posedge clk) begin
	if (rst) begin
		for (idx = 0; idx < 16; idx = idx + 1)
			mtx_a[idx] <= 8'h0;
		for (idx = 0; idx < 16; idx = idx + 1)
			mtx_b[idx] <= 8'h0;
	end
	else if (received) begin
		if (recv_counter < 16)
			mtx_a[recv_counter] <= rx_byte;
		else if (recv_counter >= 16 && recv_counter < 32)
			mtx_b[recv_counter-16] <= rx_byte;
	end
end

/**
 * multiply the received matrices and convert the results to text
 */

always @(posedge clk) begin
	if (rst)
		curr_state1 <= S1_IDLE;
	else
		curr_state1 <= next_state1;
end

always @(posedge clk) begin
	if (curr_state1 >= 1 && curr_state1 <= 4) begin
		for (idx = 0; idx < 4; idx = idx + 1) begin
			temp[idx+0]  <= mtx_a[curr_state1*4-4] * mtx_b[idx+0];
			temp[idx+4]  <= mtx_a[curr_state1*4-3] * mtx_b[idx+4];
			temp[idx+8]  <= mtx_a[curr_state1*4-2] * mtx_b[idx+8];
			temp[idx+12] <= mtx_a[curr_state1*4-1] * mtx_b[idx+12];
		end
	end
end

always @(posedge clk) begin
	if (curr_state1 >= 2 && curr_state1 <= 5) begin
		for (idx = 0; idx < 4; idx = idx + 1) begin
			mtx_c[curr_state1*4+idx-8]  <= temp[idx+0] + temp[idx+4] + temp[idx+8] + temp[idx+12];
		end
	end
end

always @(*) begin
	case (curr_state1)
		S1_IDLE:
			if (btn_r)
				next_state1 = S1_ROW0;
			else
				next_state1 = S1_IDLE;
		S1_ROW0:
			next_state1 = S1_ROW1;
		S1_ROW1:
			next_state1 = S1_ROW2;
		S1_ROW2:
			next_state1 = S1_ROW3;
		S1_ROW3:
			next_state1 = S1_PEND;
		S1_PEND:
			next_state1 = S1_DONE;
		S1_DONE:
			next_state1 = S1_IDLE;
	endcase
end

/**
 * output the resulting text to a terminal
 */

always @(posedge clk) begin
	if (rst)
		curr_state2 <= S2_IDLE;
	else
		curr_state2 <= next_state2;
end

always @(posedge clk) begin
	if (rst || curr_state2 == S2_IDLE)
		send_counter <= 0;
	else if (curr_state2 == S2_INCR)
		send_counter <= send_counter + 1;
end

always @(*) begin
	case (curr_state2)
		S2_IDLE:
			if (multi_done)
				next_state2 = S2_WAIT;
			else
				next_state2 = S2_IDLE;
		S2_WAIT:
			if (is_transmitting)
				next_state2 = S2_SEND;
			else
				next_state2 = S2_WAIT;
		S2_SEND:
			if (is_transmitting)
				next_state2 = S2_SEND;
			else
				next_state2 = S2_INCR;
		S2_INCR:
			if (tx_byte == 8'h0)
				next_state2 = S2_IDLE;
			else
				next_state2 = S2_WAIT;
	endcase
end

endmodule
