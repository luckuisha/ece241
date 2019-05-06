module mux2to1v (input [0:2]SW, output [0:0]LEDR);

	wire w1, w2, w3;

	v7404 u0 (SW[2],,,,,, w1,,,,,);
	v7408 u1 (SW[0], w1,,,,,,, w3,,,);
	v7408 u2 (SW[1], SW[2],,,,,,, w2,,,);
	v7432 u3 (w2, w3,,,,,,, LEDR[0],,,);

endmodule // mux2to1

module v7404 (input pin1, pin3, pin5, pin9, pin11, pin13,
		output pin2, pin4, pin6, pin8, pin10, pin12);

		assign pin2 = !pin1;
		assign pin4 = !pin3;
		assign pin6 = !pin5;
		assign pin8 = !pin9;
		assign pin10 = !pin11;
		assign pin12 = !pin13;

endmodule // 7404 NOT

module v7408 (input pin1, pin2, pin4, pin5, pin9, pin10, pin12, pin13,
		output pin3, pin6, pin8, pin11);

		assign pin3 = pin1 & pin2;
		assign pin6 = pin4 & pin5;
		assign pin8 = pin9 & pin10;
		assign pin11 = pin12 & pin13;

endmodule // 7408 AND

module v7432 (input pin1, pin2, pin4, pin5, pin9, pin10, pin12, pin13,
		output pin3, pin6, pin8, pin11);

		assign pin3 = pin1 | pin2;
		assign pin6 = pin4 | pin5;
		assign pin8 = pin9 | pin10;
		assign pin11 = pin12 | pin13;

endmodule // 7432 OR