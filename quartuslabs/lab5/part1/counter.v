module counter(input [9:0]SW, input [3:0]KEY, output [6:0]HEX0, output [6:0]HEX1, output [9:0]LEDR);
	wire [7:0]w;
	wire nd, nd1, nd2, nd3, nd4, nd5, nd6, nd7;
	
	flipflop u0 (SW[1], SW[0], ~KEY[0], w[0]);
	assign nd = w[0] & SW[1];
	
	flipflop u1 (nd, SW[0], ~KEY[0], w[1]);
	assign nd1 = w[1] & nd;
	
	flipflop u2 (nd1, SW[0], ~KEY[0], w[2]);
	assign nd2 = w[2] & nd1;
	
	flipflop u3 (nd2, SW[0], ~KEY[0], w[3]);
	assign nd3 = w[3] & nd2;
	
	flipflop u4 (nd3, SW[0], ~KEY[0], w[4]);
	assign nd4 = w[4] & nd3;
	
	flipflop u5 (nd4, SW[0], ~KEY[0], w[5]);
	assign nd5 = w[5] & nd4;
	
	flipflop u6 (nd5, SW[0], ~KEY[0], w[6]);
	assign nd6 = w[6] & nd5;
	
	flipflop u7 (nd6, SW[0], ~KEY[0], w[7]);
	
	display u8 (w[3:0], HEX0);
	display u9 (w[7:4], HEX1);
endmodule

module flipflop(input t, clear, clock, output reg q);
	wire w;
	assign w = t ^ q;
	always @ (posedge clock)
		begin
			if (!clear)
				q<=1'b0;
			else
				q<=w;
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