module traffic_light_hw (
		input clk, reset,
		output reg green_light, red_light, yellow_light,
		output reg [3:0] cnt
	);

	reg [1:0] state, next_state;
	localparam green = 0, yellow = 1, red = 2;

	always @(posedge clk, negedge reset) begin
		if (!reset)
			state <= green;
		else
			state <= next_state;
	end

	always @* begin
		if (cnt == 4'd4)
			next_state = yellow;
		else if (cnt == 4'd6)
			next_state = red;
		else if (cnt == 4'd9)
			next_state = green;
	end

	always @* begin
		case (state)
			green:
				begin
					green_light  = 1'b1;
					yellow_light = 1'b0;
					red_light 	 = 1'b0;
				end
			yellow:
				begin
					green_light  = 1'b0;
					yellow_light = 1'b1;
					red_light 	 = 1'b0;
				end
			red:
				begin
					green_light  = 1'b0;
					yellow_light = 1'b0;
					red_light 	 = 1'b1;
				end
		endcase
	end

	always @(posedge clk, negedge reset) begin
		if (!reset)
			cnt <= 4'd0;
		else if (cnt == 4'd9)
			cnt <= 4'd0;
		else
			cnt <= cnt + 4'd1;
	end

endmodule
