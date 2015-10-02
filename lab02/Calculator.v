// A 4-bit postfix calculator
module Calculator(
	input CLK, RESET, OP_MODE, IN_VALID, [3:0] IN,
	output reg OUT_VALID, [15:0] OUT
);
	reg   [3:0] IN2;
	reg   PUSH, POP;
	reg   [15:0] TEMP [0:1];
	Stack  S(CLK, RESET, IN2, PUSH, POP, OUT);
	always @(posedge CLK) begin
		IN2 <= IN;
		if (RESET) begin
			PUSH      <= 0;
			POP       <= 0;
			OUT_VALID <= 0;
		end
		else if (IN_VALID && !OP_MODE) begin
			PUSH <= 1;
			POP  <= 0;
		end
		else if (IN_VALID && OP_MODE) begin
			PUSH    <= 0;
			POP     <= 1;
			TEMP[1] <= OUT;
			#10;
			TEMP[0] <= OUT;
			#10;
			case (IN)
				4'b0001:
					IN2 <= TEMP[0]+TEMP[1];
				4'b0010:
					IN2 <= TEMP[0]-TEMP[1];
				4'b0100:
					IN2 <= TEMP[0]*TEMP[1];
			endcase
			PUSH <= 1;
			POP  <= 0;
		end
		else if (!IN_VALID) begin
			PUSH      <= 0;
			POP       <= 1;
			OUT_VALID <= 1;
		end
	end
endmodule
