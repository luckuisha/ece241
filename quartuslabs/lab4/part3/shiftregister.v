module shiftregister (input [3:0]KEY, input [9:0]SW, output [9:0]LEDR);
	access u0 (~KEY[0], SW[9], ~KEY[1], ~KEY[2] ,~KEY[3], SW[7:0], LEDR[7:0]);
endmodule

module shifter(input left, right, loadLeft, d, loadn, Clock, reset, output reg q);
	reg [2:0]w;
	 always@(posedge Clock)
		begin
		if (loadLeft)
			w[0] = left;
		else
			w[0] = right;
		
		if (loadn)
			w[1] = w[0];
		else
			w[1]= d;
			
		if(reset == 1'b0)
			q<=0;
		else
			q<=w[1];

	end
endmodule

module access (input Clock, reset, parallelLoadn, rotateRight, lsRight, input [7:0]DATA_IN, output [7:0]q);
	reg w1;
	always@(*)
	begin
		if(lsRight == 1'b1 && rotateRight == 1'b1 && parallelLoadn == 1'b1)
			w1 = 1'b0;
		else
			w1 = q[0];
		end
		shifter u1 (q[1], q[7], rotateRight, DATA_IN[0], parallelLoadn, Clock, reset, q[0]);
		shifter u2 (q[2], q[0], rotateRight, DATA_IN[1], parallelLoadn, Clock, reset, q[1]);
		shifter u3 (q[3], q[1], rotateRight, DATA_IN[2], parallelLoadn, Clock, reset, q[2]);
		shifter u4 (q[4], q[2], rotateRight, DATA_IN[3], parallelLoadn, Clock, reset, q[3]);
		shifter u5 (q[5], q[3], rotateRight, DATA_IN[4], parallelLoadn, Clock, reset, q[4]);
		shifter u6 (q[6], q[4], rotateRight, DATA_IN[5], parallelLoadn, Clock, reset, q[5]);
		shifter u7 (q[7], q[5], rotateRight, DATA_IN[6], parallelLoadn, Clock, reset, q[6]);
		shifter u8 (w1, q[6], rotateRight, DATA_IN[7], parallelLoadn, Clock, reset, q[7]);
endmodule