/**
 * Main Module: Find Primes Using the Sieve Algorithm
 */

module main(
		input clk,
		input rst,
		input  button,
		output LCD_E,
		output LCD_RS,
		output LCD_RW,
		output [3:0]LCD_D
		);

		wire btn_level, btn_pressed;
		reg prev_btn_level;
		reg [127:0] row_A, row_B;
		
		lcd lcd0( 
			.clk(clk),
			.rst(rst),
			.row_A(row_A),
			.row_B(row_B),
			.LCD_E(LCD_E),
			.LCD_RS(LCD_RS),
			.LCD_RW(LCD_RW),
			.LCD_D(LCD_D)
		);
		
		debounce debounce0(
			.clk(clk),
			.btn_input(button),
			.btn_output(btn_level)
	 );
		
		always @(posedge clk) begin
			if (rst)
				prev_btn_level <= 1;
			else
				prev_btn_level <= btn_level;
		end

		assign btn_pressed = (btn_level == 1 && prev_btn_level == 0)? 1 : 0;

		always @(posedge clk) begin
			if (rst) begin
				row_A <= 128'h2248656C6C6F2C20576F726C64212220; // "Hello, World!"
				row_B <= 128'h44656D6F206F6620746865204C43442E; // Demo of the LCD.
			end
			else if (btn_pressed) begin
				row_A <= row_B;
				row_B <= row_A;
			end
		end

endmodule
