`timescale 1ns / 1ns // `timescale time_unit/time_precision

// Part 2 skeleton

module week1VGAandCount
	(	SW,
		KEY,
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,
		GPIO_1,
		HEX0,
		HEX1,
		LEDR,
		HEX2,
		HEX3,
		HEX4,
		HEX5,
		PS2_DAT,
		PS2_CLK//	VGA Blue[9:0]
	);
	
	output [6:0] HEX0,HEX1,HEX2,HEX3, HEX4, HEX5;
	input [9:0] SW;
	input			CLOCK_50;				//	50 MHz
	input [3:0]KEY;
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	input PS2_DAT, PS2_CLK;
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	
	vga_adapter VGA(
			.resetn(1'b1),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 7;
		defparam VGA.BACKGROUND_IMAGE = "start.mif";
	
		//wire enable;
		wire [20:0] colour;
		wire [14:0] pixel;
		wire reset, endGame, start;
		wire [4:0] outp;
		wire [1:0] state;
		wire [7:0] x;
		wire [6:0] y;
		wire writeEn, triggered;
		reg clickTrig;
		wire resetn, ldreset;
		wire makeBreak, valid; 
		assign resetn = SW[9];
		wire [7:0] character; 
		output reg [2:0] LEDR;
		
		keyboard_press_driver kB(CLOCK_50, valid, makeBreak, character, PS2_DAT,PS2_CLK, resetn);
		
		always@(*)
		begin
			if(character==8'b01011010&&makeBreak)
			begin
				clickTrig = 1'b1;
				LEDR[0] = 1'b1;
			end
			else 
			begin
				clickTrig = 1'b0;
				LEDR[0] = 1'b0;
			end
		end
		
		
		input [6:0] GPIO_1;
		
		reg chopTrig, kickTrig;

		always@(*)
		begin
			if (GPIO_1[1]==1'b1)
			begin
				chopTrig=1'b1;
				LEDR[1]=1'b1;
			end
			else 
			begin
				chopTrig=1'b0;
				LEDR[1]=1'b0;
			end
		end
		
		always@(*)
		begin
			if (GPIO_1[3]==1'b1)
			begin
				kickTrig=1'b1;
				LEDR[2]=1'b1;
			end
			else 
			begin
				kickTrig=1'b0;
				LEDR[2]=1'b0;
			end
		end
		
		bigCount c(CLOCK_50, SW[1], pixel, ldreset);
		xyCounter(CLOCK_50, SW[1], x, y, ldreset);
		

		
		control c1( ~KEY[3], CLOCK_50, makeBreak, clickTrig, chopTrig, kickTrig, x, y, endGame, state, start, writeEn, ldreset, triggered);
		muxDisplay d(pixel, CLOCK_50, state, colour, endGame, start);
		counter c0(CLOCK_50, triggered, outp, endGame);
		
		//counter2 c2(CLOCK_50, switch);
		
		hex_decoder h0((outp-1), HEX0);
		hex_decoder h1({3'b000, endGame}, HEX1);
		hex_decoder h2(character[3:0], HEX2);
		hex_decoder h3(character[7:4], HEX3);
		hex_decoder h4({2'b00,state}, HEX4);
		hex_decoder h5({3'b000, triggered}, HEX5); 
		
		
		
endmodule



module control(go, clock, makeBreak, clickTrig, chopTrig, kickTrig, x, y, endGame, state, start, ldDraw,ldreset, triggered);
	input [7:0] x;
	input [6:0] y;
	input go, clock, clickTrig, chopTrig, kickTrig, endGame, makeBreak;
	
	reg [5:0] current_state, next_state;
	
	wire Xmax, Ymax;
	
	output reg start, ldDraw, triggered, ldreset;
	output reg [2:0] state;
	
	

	localparam startGame 		= 5'd0,		
				  drawKick			= 5'd1,
				  kick_C				= 5'd2,
				  chop_C				= 5'd3,
				  click_C			= 5'd4,
				  endGame_C			= 5'd5,
				  drawChop			= 5'd6,
				  drawClick			= 5'd7,
				  kickWait 			= 5'd8,
				  clickWait			= 5'd9,
				  chopWait			= 5'd10;
				  
	always@(*)
    begin: state_table 
            case (current_state)
                startGame: next_state = go ? drawKick: startGame; // Loop in current state until go signal goes low
					 drawKick: 	next_state = (x==8'b10011111 && y==7'b1111000)? kick_C: drawKick;
					 kick_C:		next_state = kickTrig ? kickWait : kick_C;
					 kickWait:	next_state = ~kickTrig ? drawChop : kickWait;
					 drawChop: 	next_state = (x==8'b10011111 && y==7'b1111000)? chop_C: drawChop;
					 chop_C:		next_state = chopTrig ? chopWait : chop_C;
					 chopWait:	next_state = ~chopTrig ? drawClick : chopWait;
					 drawClick:	next_state = (x==8'b10011111 && y==7'b1111000)? click_C: drawClick;
					 click_C:	next_state = clickTrig ? clickWait : click_C;
					 clickWait:	next_state = ~clickTrig ? drawKick : clickWait;
					 //endGame_C:	next_state = startGame;
            default: next_state = startGame;
        endcase
    end // state_table

	
	always @(*)
    begin: enable_signals
        // By default make all our signals 0
		  ldDraw = 1'b0;
		  start = 1'b1;
		  ldreset = 1'b0;

        case (current_state)
				startGame: begin
					start = 1'b1;
					ldreset = 1'b1;
				end
            drawKick: begin
					 state = 2'b01;
					 ldDraw = 1'b1;
					 start = 1'b0;
                end
				drawChop: begin
					 state = 2'b00;
					 ldDraw = 1'b1;
					  start = 1'b0;
                end
				drawClick: begin
					state = 2'b10;
					ldDraw = 1'b1;
					 start = 1'b0;
				   end
            kick_C: begin
					 state = 2'b01;
					 ldDraw = 1'b0;
					  start = 1'b0;
                end
				chop_C: begin
					 state = 2'b00;
					 ldDraw = 1'b0;
					  start = 1'b0;
                end
				 click_C: begin
					 state = 2'b10;
					 ldDraw = 1'b0;
					  start = 1'b0;
                end
				endGame_C:begin
					state = 2'b11;
					ldDraw = 1'b1;
					 start = 1'b0;
					end	
				kickWait:begin
					state = 2'b01;
				   ldDraw = 1'b0;
					 start = 1'b0;
					 ldreset = 1'b1;
					end
				chopWait:begin
					state = 2'b00;
					 ldDraw = 1'b0;
					  start = 1'b0;
					  ldreset = 1'b1;
					end
				clickWait:begin
					state = 2'b10;
					ldDraw = 1'b0;
					start = 1'b0;
					ldreset = 1'b1;
					end
         //default:      // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
	
	always @(*)begin
		if (state==2'b01)
			triggered = kickTrig;
		else if (state==2'b10)
			triggered = clickTrig;
		else if (state==2'b00)
			triggered = chopTrig;
		else if (current_state==startGame)
			triggered= 1'b1;
		else 
			triggered = 1'b0;
	end
	
	
    always@(posedge clock)
    begin: state_FFs
        if (endGame)
				current_state <= endGame_C;
        else
            current_state <= next_state;
    end // state_FFS

endmodule



module muxDisplay(pixel, clock, state, colour, endGame, start);
	
	input clock, endGame, start;
	input [1:0] state;
	input [14:0] pixel;
	wire [20:0] kickD, chopD, clickD, endD;
	output reg [20:0] colour;
	
	
	//chop1 chop1(pixel, clock, 21'b00000000000000000000, 1'b0, chopD1);
	//kick1 kick1(pixel, clock, 21'b00000000000000000000, 1'b0, kickD1);
	//click1 click1(pixel, clock, 21'b00000000000000000000, 1'b0, clickD1);	
	chop2 chop(pixel, clock, 21'b00000000000000000000, 1'b0, chopD);
	kick2 kick(pixel, clock, 21'b00000000000000000000, 1'b0, kickD);
	click2 click(pixel, clock, 21'b00000000000000000000, 1'b0, clickD);
	black ends(pixel, clock, 21'b00000000000000000000, 1'b0, endD);
	
	always@(*)
	begin
		if (endGame||state==2'b11 && !start)
		begin
			colour = endD;
		end
		else if (state==2'b00 && !start)
		begin
			colour = chopD;
		end
		//else if (state==2'b00&&!switch)
			//colour = chopD1;
		else if (state==2'b01 && !start)
		begin
			colour = kickD;
		end
		//else if (state==2'b01&&!switch)
		//	colour = kickD1;
		else if (state==2'b10 && !start)
		begin
			colour = clickD;
		end
	end
		
endmodule

module bigCount(clock, enable, pixel, reset);
	input clock, enable, reset;
	output reg [14:0] pixel;
	
	always@(posedge clock)
	begin
		if (reset)
		begin
			pixel<=15'd0;
		end
		else if(pixel==15'b100101100000000||~enable)
			pixel<=15'b000000000000000;
		else
			pixel<=pixel+1;
	end
	
endmodule


module xyCounter(clock, enable, x, y, reset);
	input clock, enable, reset;
	output reg[7:0] x;
	output reg [6:0]y;
	
	always@(posedge clock)
	begin
		if(reset)
			begin
				x=8'd0;
				y=7'd0;
			end
		if (~enable||(x==8'b10011111 && y==7'b1111000))
			begin
				x<=8'b00000000;
				y<=7'b0000000;
			end
		else if(x==8'b10011111)
			begin
				x<=8'b00000000;
				y<=y+1;
			end
		else
			x<=x+1;		
	end
	
endmodule




module counter(CLOCK_50, reset, outP, endGame);

	wire [27:0] b, pLoad;
	output [3:0] outP;
	input CLOCK_50, reset;
	output endGame;
	wire enable;

	
	assign b = 28'b0010111110101111000010000000;
	
	rateDivider r1(b, CLOCK_50, pLoad);
	
	assign enable = (pLoad==28'b0000000000000000000000000000) ? 1:0;
	regCount c1(enable, reset, CLOCK_50, outP, endGame);

endmodule


module regCount(enable, reset, clk, q, endGame);

	output reg [3:0] q;
	input enable, reset, clk;
	output reg endGame;
	
	always@(posedge clk)
		if(reset==1'b1)
		begin
				q<=4'b0110;
				endGame=1'b0;
		end
		else if (q==4'b0000)
		begin
				q=4'b0110;
				endGame=1'b1;
		end
		else if(enable)
		begin
				q<=q-1;
				endGame=1'b0;
		end
		else if (q==4'b0000)
		begin
				endGame=1'b1;
		end
				
endmodule



module rateDivider(speed, clk, out);

	input [27:0]speed; 
	
	input clk;

	output reg [27:0]out;
	
	always@(posedge clk)
		if(out==28'b0000000000000000000000000000)
			out<=speed;
		else
			out=out-28'b0000000000000000000000000001;	
	
endmodule 
		
module hex_decoder(input [3:0]a, output reg [6:0]f);
    always @(*)    
    begin    
        case(a[3:0])
        
            //Multiplexes this shit
            
            4'b0000: f[6:0] = 7'b1000000; // Do I even need to include the [6:0]?
            4'b0001: f[6:0] = 7'b1001111; // Can I just say f?
            4'b0010: f[6:0] = 7'b0100100;
            4'b0011: f[6:0] = 7'b0110000; 
            4'b0100: f[6:0] = 7'b0011001;
            4'b0101: f[6:0] = 7'b0010010;
            4'b0110: f[6:0] = 7'b0000010;
            4'b0111: f[6:0] = 7'b1111000;
            4'b1000: f[6:0] = 7'b0000000;
            4'b1001: f[6:0] = 7'b0011000;
            4'b1010: f[6:0] = 7'b0001000;
            4'b1011: f[6:0] = 7'b0000011;
            4'b1100: f[6:0] = 7'b1000110;
            4'b1101: f[6:0] = 7'b0100001;
            4'b1110: f[6:0] = 7'b0000110;
            4'b1111: f[6:0] = 7'b0001110;
            default: f[6:0] = 7'b1111111;
        endcase
    end
endmodule


module keyboard_press_driver(
  input  CLOCK_50, 
  output reg valid, makeBreak,
  output reg [7:0] outCode,
  input    PS2_DAT, // PS2 data line
  input    PS2_CLK, // PS2 clock line
  input reset
);

parameter FIRST = 1'b0, SEENF0 = 1'b1;
reg state;
reg [1:0] count;
wire [7:0] scan_code;
reg [7:0] filter_scan;
wire scan_ready;
reg read;
parameter NULL = 8'h00;

initial 
begin
	state = FIRST;
	filter_scan = NULL;
	read = 1'b0;
	count = 2'b00;
end
	

// inner driver that handles the PS2 keyboard protocol
// outputs a scan_ready signal accompanied with a new scan_code
keyboard_inner_driver kbd(
  .keyboard_clk(PS2_CLK),
  .keyboard_data(PS2_DAT),
  .clock50(CLOCK_50),
  .reset(reset),
  .read(read),
  .scan_ready(scan_ready),
  .scan_code(scan_code)
);

always @(posedge CLOCK_50)
	case(count)
		2'b00:
			if(scan_ready)
				count <= 2'b01;
		2'b01:
			if(scan_ready)
				count <= 2'b10;
		2'b10:
			begin
				read <= 1'b1;
				count <= 2'b11;
				valid <= 0;
				outCode <= scan_code;
				case(state)
					FIRST:
						case(scan_code)
							8'hF0:
								begin
									state <= SEENF0;
								end
							8'hE0:
								begin
									state <= FIRST;
								end
							default:
								begin
									filter_scan <= scan_code;
									if(filter_scan != scan_code)
										begin
											valid <= 1'b1;
											makeBreak <= 1'b1;
										end
								end
						endcase
					SEENF0:
						begin
							state <= FIRST;
							if(filter_scan == scan_code)
								begin
									filter_scan <= NULL;
								end
							valid <= 1'b1;
							makeBreak <= 1'b0;
						end
				endcase
			end
		2'b11:
			begin
				read <= 1'b0;
				count <= 2'b00;
				valid <= 0;
			end
	endcase
endmodule 



