module display(input [0:9]SW, output [0:6]HEX0);

	assign HEX0[0] = ~((SW[0] | SW[1] | SW[2] | ~SW[3]) & (SW[0] | ~SW[1] | SW[2] | SW[3]) & (~SW[0] | SW[1] | ~SW[2] | ~SW[3]) & (~SW[0] | ~SW[1] | SW[2] | ~SW[3]));
	assign HEX0[1] = ~((SW[0] | ~SW[1] | SW[2] | ~SW[3]) & (SW[0] | ~SW[1] | ~SW[2] | SW[3]) & (~SW[0] | SW[1] | ~SW[2] | ~SW[3]) & (~SW[0] | ~SW[1] | SW[2] | SW[3]) & (~SW[0] | ~SW[1] | ~SW[2] | ~SW[3]) & (~SW[0] | ~SW[1] | ~SW[2] | SW[3]));
	assign HEX0[2] = ~((SW[0] | SW[1] | ~SW[2] | SW[3]) & (~SW[0] | ~SW[1] | SW[2] | SW[3]) & (~SW[0] | ~SW[1] | ~SW[2] | SW[3]) & (~SW[0] | ~SW[1] | ~SW[2] | ~SW[3]));
	assign HEX0[3] = ~((SW[0] | SW[1] | SW[2] | ~SW[3]) & (SW[0] | ~SW[1] | SW[2] | SW[3]) & (SW[0] | ~SW[1] | ~SW[2] | ~SW[3]) & (~SW[0] | SW[1] | ~SW[2] | SW[3]) & (~SW[0] | ~SW[1] | ~SW[2] | ~SW[3]));
	assign HEX0[4] = ~((SW[0] | SW[1] | SW[2] | ~SW[3]) & (SW[0] | ~SW[1] | ~SW[2] | ~SW[3]) & (SW[0] | SW[1] | ~SW[2] | ~SW[3]) & (SW[0] | ~SW[1] | SW[2] | SW[3]) & (SW[0] | ~SW[1] | SW[2] | ~SW[3]) & (~SW[0] | SW[1] | SW[2] | ~SW[3]));
	assign HEX0[5] = ~((SW[0] | SW[1] | SW[2] | ~SW[3]) & (SW[0] | SW[1] | ~SW[2] | ~SW[3]) & (SW[0] | SW[1] | ~SW[2] | SW[3]) & (SW[0] | ~SW[1] | ~SW[2] | ~SW[3]) & (~SW[0] | ~SW[1] | SW[2] | ~SW[3]));
	assign HEX0[6] = ~((SW[0] | SW[1] | SW[2] | SW[3]) & (SW[0] | SW[1] | SW[2] | ~SW[3]) & (SW[0] | ~SW[1] | ~SW[2] | ~SW[3]) & (~SW[0] | ~SW[1] | SW[2] | SW[3]));

endmodule
