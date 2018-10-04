module fulladder(input [9:0]SW, output [9:0]LEDR);
	wire w0, w1, w2;
	adder u0 (SW[4], SW[0], SW[8], w0, LEDR[0]);
	adder u1 (SW[5], SW[1], w0, w1, LEDR[1]);
	adder u2 (SW[6], SW[2], w1, w2, LEDR[2]);
	adder u3 (SW[7], SW[3], w2, LEDR[9], LEDR[3]);
endmodule
	

module adder(input b, a, ci, output co, s);
	assign co = ((b | a | ~ci ) & (b | ~a | ci) & (~b | a | ci ) & (b | a | ci ));
	assign s = ((b | a | ci ) & (b | ~a | ~ci ) & (~b | a | ~ci ) & (~b | ~a | ci ));
endmodule