module register(input [9:0]SW, input [3:0]KEY, output [6:0]HEX0,output [6:0]HEX1,output [6:0]HEX2,output [6:0]HEX3,output [6:0]HEX4,output [6:0]HEX5, output [7:0]LEDR);
	wire [7:0]w;
	wire [7:0]w1;
	ALU u0 (SW[3:0], w1[3:0], ~KEY[3:1], w1[7:0], w);
	assign LEDR = w;
	registerer u8 (w, ~KEY[0], SW[9], w1[7:0]);
	display u1 (4'b0000, HEX2[6:0]);
	display u2 (SW[3:0], HEX0[6:0]);
	display u3 (4'b0000, HEX1[6:0]);
	display u4 (4'b0000, HEX3[6:0]);
	display u5 (w1[3:0], HEX4[6:0]);
	display u6 (w1[7:4], HEX5[6:0]);
endmodule

module ALU(input [3:0]A, input[3:0]B,input [2:0]KEY,input [7:0]registerVal, output reg [7:0]ALUout);
	wire [7:0]in; 
	wire [4:0]w;
	assign in = {A,B};
	fulladder u7 (in[7:0], w[4:0]);
	always@(*)
	begin
		case (KEY)
			3'b000: ALUout = {3'b000, w[4:0]};
			3'b001: ALUout[4:0] = A + B;
			3'b010: ALUout = {~(A&B),~(A|B)};
			3'b011: if (A||B) 
						ALUout[7:0] = 8'b11000000;
			3'b100: if (((B[0] & B[1] & B[2] & ~B[3]) | (B[0] & B[1] & ~B[2] & B[3]) | (B[0] & ~B[1] & B[2] & B[3]) | (~B[0] & B[1] & B[2] & B[3])) & ((~A[0]&~A[1]&A[2]&A[3])|(A[0]&~A[1]&~A[2]&A[3])|(~A[0]&A[1]&~A[2]&A[3])|(~A[0]&A[1]&A[2]&~A[3])|(A[0]&~A[1]&A[2]&~A[3])|(A[0]&A[1]&~A[2]&~A[3])))
						ALUout[7:0] = 8'b00111111;
			3'b101: ALUout = {B, ~A};
			3'b110: ALUout = {A^B ,A~^B};
			3'b111: ALUout = registerVal;
			default: ALUout [7:0] = 8'b00000000;
		endcase
	end
endmodule

module fulladder(input [7:0]in, output [4:0]out);
	wire w0, w1, w2;
	adder u0 (in[4], in[0], 1'b0, w0, out[0]);
	adder u1 (in[5], in[1], w0, w1, out[1]);
	adder u2 (in[6], in[2], w1, w2, out[2]);
	adder u3 (in[7], in[3], w2, out[4], out[3]);
endmodule
	

module adder(input b, a, ci, output co, s);
	//assign co = ((b | a | ~ci ) & (b | ~a | ci ) & (~b | a | ci ) & (b | a | ci ));
	//assign s = ((b | a | ci ) & (b | ~a | ~ci ) & (~b | a | ~ci ) & (~b | ~a | ci ));
	assign co = ((a^b)&ci)|(a&b);
	assign s = ((a^b)^ci);
endmodule


module display(input [3:0]SW,output [6:0]HEX);

	 assign HEX[0]= (~SW[3]&~SW[2]&~SW[1]&SW[0])+(~SW[3]&SW[2]&~SW[1]&~SW[0])+(SW[3]&~SW[2]&SW[1]&SW[0])+(SW[3]&SW[2]&~SW[1]&SW[0]);
	 assign HEX[1]=(~SW[3]&SW[2]&~SW[1]&SW[0])+(~SW[3]&SW[2]&SW[1]&~SW[0])+(SW[3]&~SW[2]&SW[1]&SW[0])+(SW[3]&SW[2]&~SW[1]&~SW[0])+(SW[3]&SW[2]&SW[1]&~SW[0])+(SW[3]&SW[2]&SW[1]&SW[0]);
	 assign HEX[2]=(~SW[3]&~SW[2]&SW[1]&~SW[0])+(SW[3]&SW[2]&~SW[1]&~SW[0])+(SW[3]&SW[2]&SW[1]&~SW[0])+(SW[3]&SW[2]&SW[1]&SW[0]);
	 assign HEX[3]=(~SW[3]&~SW[2]&~SW[1]&SW[0])+(~SW[3]&SW[2]&~SW[1]&~SW[0])+(~SW[3]&SW[2]&SW[1]&SW[0])+(SW[3]&~SW[2]&SW[1]&~SW[0])+(SW[3]&SW[2]&SW[1]&SW[0]);
	 assign HEX[4]=(~SW[3]&~SW[2]&~SW[1]&SW[0])+(~SW[3]&~SW[2]&SW[1]&SW[0])+(~SW[3]&SW[2]&~SW[1]&~SW[0])+(~SW[3]&SW[2]&~SW[1]&SW[0])+(~SW[3]&SW[2]&SW[1]&SW[0])+(SW[3]&~SW[2]&~SW[1]&SW[0]);
	 assign HEX[5]=(~SW[3]&~SW[2]&~SW[1]&SW[0])+(~SW[3]&~SW[2]&SW[1]&~SW[0])+(~SW[3]&~SW[2]&SW[1]&SW[0])+(~SW[3]&SW[2]&SW[1]&SW[0])+(SW[3]&SW[2]&~SW[1]&SW[0]);
	 assign HEX[6]=(~SW[3]&~SW[2]&~SW[1]&SW[0])+(~SW[3]&SW[2]&SW[1]&SW[0])+(SW[3]&SW[2]&~SW[1]&~SW[0])+(~SW[3]&~SW[2]&~SW[1]&~SW[0]);
endmodule

module registerer(input [7:0]d, Clock, Reset_b, output reg [7:0]q);
	 always@(posedge Clock)
	 begin
		if(Reset_b == 1'b0)
			q<=0;
		else
			q<=d;
	end
endmodule
 
