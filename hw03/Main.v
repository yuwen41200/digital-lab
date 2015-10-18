module Main(
		input CLK, RST, BTN_E, BTN_W,
		output reg [7:0] LED
	);

	reg btn_e_count, btn_w_count;
	reg [3:0] counter;

	always @(posedge CLK) begin
		// reseting all registers
		if (RST) begin
			counter     <= 0;
			btn_e_count <= 0;
			btn_w_count <= 0;
		end
		// debouncing button signals
		if (BTN_E)
			btn_e_count <= btn_e_count + 1;
		else
			btn_e_count <= 0;
		if (BTN_W)
			btn_w_count <= btn_w_count + 1;
		else
			btn_w_count <= 0;
		// increasing or decreasing the counter
		if (btn_e_count >= 3) begin
			if (counter >= -7)
				counter <= counter - 1;
			else
				counter <= -8;
		end
		if (btn_w_count >= 3) begin
			if (counter <= 6)
				counter <= counter + 1;
			else
				counter <= 7;
		end
	end

	always @(*) begin
		LED = {{4{counter[3]}}, counter[3:0]};
	end

endmodule
