/**
 * Rotary Dial Controller
 * Copyright Notice: This code was written by the TAs of this course.
 */

module rotary_ctrl(
		input clk,
		input rot_a,
		input rot_b,
		output reg rotary_event,
		output reg rotary_right
	);

reg rot_a_temp, rot_b_temp;
reg rotary_q1, rotary_q2;
reg delay_rotary_q1;

always @(posedge clk) begin
	rot_a_temp <= rot_a;
	rot_b_temp <= rot_b;
end

always @(posedge clk) begin
	case ({rot_b_temp, rot_a_temp})
		2'b00:
			begin
				rotary_q1 <= 1'b0;
				rotary_q2 <= rotary_q2;
			end
		2'b01:
			begin
				rotary_q1 <= rotary_q1;
				rotary_q2 <= 1'b0;
			end
		2'b10:
			begin
				rotary_q1 <= rotary_q1;
				rotary_q2 <= 1'b1;
			end
		2'b11:
			begin
				rotary_q1 <= 1'b1;
				rotary_q2 <= rotary_q2;
			end
		default:
			begin
				rotary_q1 <= rotary_q1;
				rotary_q2 <= rotary_q2;
			end
	endcase
end

always @(posedge clk) begin
	delay_rotary_q1 <= rotary_q1;
	if (rotary_q1 == 1'b1 && delay_rotary_q1 == 1'b0) begin
		rotary_event <= 1'b1;
		rotary_right <= rotary_q2;
	end
	else begin
		rotary_event <= 1'b0;
		rotary_right <= rotary_right;
	end
end

endmodule
