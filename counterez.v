module counterez(input [9:0]SW, input [3:0]KEY, input CLOCK_50, output [6:0]HEX0, output [9:0]LEDR);
	thing u0 (SW[0], SW[1], CLOCK_50, 1'b0, KEY[0], LEDR[4:0]);
	display u1 (LEDR[3:0], HEX0);
endmodule

module thing (input a, b, clock, parLoad, clear_b, output reg [3:0]q);
	reg [25:0]w;
	wire [25:0]out;
	speed u2(a, b,out[25:0]);
	
	always @ (posedge clock)
		begin
			if (w==0)
				w<=out;
			else
				w<=w-1;
		end

	always @ (posedge clock)
		begin
			if (clear_b == 1'b0)
				q<=0;
			else if (parLoad == 1'b1)
				q<=q; 
			else if (w == 0)
				if (q == 4'b1111)
				q<=0;
			else
				q<=q+1;
		end
endmodule

module speed (input a, b, output reg [25:0]c);
	 always @ (*)
		begin
			if ((a & b) == 1'b1)
				c = 26'b10111110101111000001111111;
			else if (a == 1'b0 & b == 1'b1)
				c = 26'b01011111010111100000111111;
			else if (a == 1'b1 & b == 1'b0)
				c = 26'b00101111101011110000011111;
			else 
				c = 26'b00000000000000000000000000;
		end
endmodule

module display(input [3:0]SW, output [6:0]HEX);
	 assign HEX[0]= (~SW[3]&~SW[2]&~SW[1]&SW[0])+(~SW[3]&SW[2]&~SW[1]&~SW[0])+(SW[3]&~SW[2]&SW[1]&SW[0])+(SW[3]&SW[2]&~SW[1]&SW[0]);
	 assign HEX[1]=(~SW[3]&SW[2]&~SW[1]&SW[0])+(~SW[3]&SW[2]&SW[1]&~SW[0])+(SW[3]&~SW[2]&SW[1]&SW[0])+(SW[3]&SW[2]&~SW[1]&~SW[0])+(SW[3]&SW[2]&SW[1]&~SW[0])+(SW[3]&SW[2]&SW[1]&SW[0]);
	 assign HEX[2]=(~SW[3]&~SW[2]&SW[1]&~SW[0])+(SW[3]&SW[2]&~SW[1]&~SW[0])+(SW[3]&SW[2]&SW[1]&~SW[0])+(SW[3]&SW[2]&SW[1]&SW[0]);
	 assign HEX[3]=(~SW[3]&~SW[2]&~SW[1]&SW[0])+(~SW[3]&SW[2]&~SW[1]&~SW[0])+(~SW[3]&SW[2]&SW[1]&SW[0])+(SW[3]&~SW[2]&SW[1]&~SW[0])+(SW[3]&SW[2]&SW[1]&SW[0]);
	 assign HEX[4]=(~SW[3]&~SW[2]&~SW[1]&SW[0])+(~SW[3]&~SW[2]&SW[1]&SW[0])+(~SW[3]&SW[2]&~SW[1]&~SW[0])+(~SW[3]&SW[2]&~SW[1]&SW[0])+(~SW[3]&SW[2]&SW[1]&SW[0])+(SW[3]&~SW[2]&~SW[1]&SW[0]);
	 assign HEX[5]=(~SW[3]&~SW[2]&~SW[1]&SW[0])+(~SW[3]&~SW[2]&SW[1]&~SW[0])+(~SW[3]&~SW[2]&SW[1]&SW[0])+(~SW[3]&SW[2]&SW[1]&SW[0])+(SW[3]&SW[2]&~SW[1]&SW[0]);
	 assign HEX[6]=(~SW[3]&~SW[2]&~SW[1]&SW[0])+(~SW[3]&SW[2]&SW[1]&SW[0])+(SW[3]&SW[2]&~SW[1]&~SW[0])+(~SW[3]&~SW[2]&~SW[1]&~SW[0]);
endmodule