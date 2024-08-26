module alu(A, B, Control, Result, ZeroFlag, NegativeFlag, OverflowFlag, CarryFlag);

	input [31:0] A, B;
	input [2:0]	 Control;

	output [31:0] Result;
	output 				ZeroFlag, NegativeFlag, OverflowFlag, CarryFlag;

	wire [31:0] a_and_b;
	wire [31:0] a_or_b;
	wire [31:0] not_b;
	wire [31:0] sum_mux;
	wire [31:0] sum;
	wire [31:0] result_mux;
	wire 			 	cout;

	// Logic.

		// AND operation.
		assign a_and_b = A & B;

		// OR operation.
		assign a_or_b = A | B;

		// Addition operation.
		// REFER : https://youtu.be/4cjs2GrOf6Y.
		assign not_b = ~B;
		assign sum_mux = (Control[0] == 1'b0) ? B : not_b;
		assign { cout, sum } = A + sum_mux + Control[0];

		// Final mux.
		assign result_mux = (Control[1:0] == 2'b00) ? sum :
												(Control[1:0] == 2'b01) ? sum :
												(Control[1:0] == 2'b10) ? a_and_b : a_or_b;

		assign Result = result_mux;

		// Flags.

			assign ZeroFlag = &(~Result); // Indicates whether the result is 0 or not.

			// REFER : https://youtu.be/7towQUO9aZI for understanding signed and unsigned numbers and how
			// they overflow.

			assign NegativeFlag = Result[31]; // Indicates whether the result is negative or not.

			assign OverflowFlag = (~Control[1]) & (A[31] ^ sum[31]) & (~(A[31] ^ B[31] ^ Control[0]));

			assign CarryFlag = cout & (~Control[1]);
endmodule
