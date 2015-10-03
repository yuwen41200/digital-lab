// A 4-bit postfix calculator
module Calculator(
		input CLK, RESET, OP_MODE, IN_VALID, unsigned [3:0] IN,
		output reg OUT_VALID, signed [15:0] OUT
	);
	reg PUSH, POP, PREV_IN_VALID, NEXT_OUT_VALID;
	reg unsigned [3:0] PREV_IN;
	Stack STK(CLK, RESET, {{12{1'b0}}, PREV_IN[3:0]}, PUSH, POP, OUT);
	always @(posedge CLK) begin
		if (RESET) begin
			PUSH           <= 0;
			POP            <= 0;
			NEXT_OUT_VALID <= 0;
			$display("%t: Calculator Reset.", $time);
		end
		else if (IN_VALID && !OP_MODE) begin
			PUSH           <= 1;
			POP            <= 0;
			NEXT_OUT_VALID <= 0;
			$display("%t: Operand Loaded.", $time);
		end
		else if (IN_VALID && OP_MODE) begin
			PUSH           <= 1;
			POP            <= 1;
			NEXT_OUT_VALID <= 0;
			$display("%t: Operator Loaded.", $time);
		end
		else if (PREV_IN_VALID && !IN_VALID) begin
			PUSH           <= 0;
			POP            <= 1;
			NEXT_OUT_VALID <= 1;
			$display("%t: Output Generated.", $time);
		end
		else begin
			PUSH           <= 0;
			POP            <= 0;
			NEXT_OUT_VALID <= 0;
			$display("%t: States Cleared.", $time);
		end
		if (NEXT_OUT_VALID)
			OUT_VALID      <= 1;
		else
			OUT_VALID      <= 0;
		PREV_IN_VALID      <= IN_VALID;
		PREV_IN            <= IN;
	end
endmodule
