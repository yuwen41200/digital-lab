module Main(
		input CLK, RST, BTN_E, BTN_W,
		output [7:0] LED
	);

	reg signed [31:0] btn_e_count, btn_w_count;
	reg signed [3:0] counter;
	reg operated;

	// outputting the counter value to the leds
	assign LED = {{4{counter[3]}}, counter};

	// debouncing button signals
	always @(posedge CLK) begin
		if (RST) begin
			btn_e_count <= 0;
			btn_w_count <= 0;
			operated <= 0;
		end
		else if (btn_e_count >= 32'd10000000) begin
			btn_e_count <= 0;
			operated <= 1;
		end
		else if (btn_w_count >= 32'd10000000) begin
			btn_w_count <= 0;
			operated <= 1;
		end
		else if (BTN_E && ~operated)
			btn_e_count <= btn_e_count + 1;
		else if (BTN_W && ~operated)
			btn_w_count <= btn_w_count + 1;
		else if (~BTN_E && ~BTN_W)
			operated <= 0;
		else begin
			btn_e_count <= 0;
			btn_w_count <= 0;
		end
	end

	// increasing or decreasing the counter
	always @(posedge CLK) begin
		if (RST)
			counter <= 0;
		else if (btn_e_count >= 32'd10000000) begin
			if (counter >= -7)
				counter <= counter - 1;
			else
				counter <= -8;
		end
		else if (btn_w_count >= 32'd10000000) begin
			if (counter <= 6)
				counter <= counter + 1;
			else
				counter <= 7;
		end
	end

endmodule
