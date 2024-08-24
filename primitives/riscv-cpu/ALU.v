module alu(A, B, ALUControl, Result);

	input [31:0] A, B;
	input [2:0]	 ALUControl;

	output [31:0] Result;

	wire [31:0] a_and_b;
	wire [31:0] a_or_b;
	wire [31:0] not_b;
	wire [31:0] sum_mux;
	wire [31:0] sum;
	wire [31:0] result_mux;

	// Logic.

		// AND operation.
		assign a_and_b = A & B;

		// OR operation.
		assign a_or_b = A | B;

		// Addition operation.
		// REFER : https://youtu.be/4cjs2GrOf6Y.
		assign not_b = ~B;
		assign sum_mux = (ALUControl[0] == 1'b0) ? B : not_b;
		assign sum = A + sum_mux + ALUControl[0];

		// Final mux.
		assign result_mux = (ALUControl[1:0] == 2'b00) ? sum :
												(ALUControl[1:0] == 2'b01) ? sum :
												(ALUControl[1:0] == 2'b10) ? a_and_b : a_or_b;

		assign Result = result_mux;
endmodule
