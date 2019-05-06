
// Part 2 skeleton 
/*KEY[1] (Plot) is pressed. KEY[2]
should cause the entire screen to be cleared to black (Black). Note that black corresponds to (0,0,0). KEY[0]
should be the system active low Resetn.*/
`include "vga_adapter/vga_adapter.v"
`include "vga_adapter/vga_address_translator.v"
`include "vga_adapter/vga_controller.v"
`include "vga_adapter/vga_pll.v"

module ball
    (
        SW,
        CLOCK_50,                        //    On Board 50 MHz
        // Your inputs and outputs here
        KEY, 
		HEX0,HEX1, HEX2, HEX3, HEX4, HEX5,
        LEDR,// On Board Keys
        // The ports below are for the VGA output.  Do not change.
        VGA_CLK,                           //    VGA Clock
        VGA_HS,                            //    VGA H_SYNC
        VGA_VS,                            //    VGA V_SYNC
        VGA_BLANK_N,                    //    VGA BLANK
        VGA_SYNC_N,                        //    VGA SYNC
        VGA_R,                           //    VGA Red[9:0]
        VGA_G,                             //    VGA Green[9:0]
        VGA_B                           //    VGA Blue[9:0]
    );
    
    input            CLOCK_50;                //    50 MHz
    input    [8:0]   KEY;    
    input     [9:0]  SW;
    output 	[9:0] 	 LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    // Declare your inputs and outputs here
    // Do not change the following outputs
    output            VGA_CLK;                   //    VGA Clock
    output            VGA_HS;                    //    VGA H_SYNC
    output            VGA_VS;                    //    VGA V_SYNC
    output            VGA_BLANK_N;            //    VGA BLANK
    output            VGA_SYNC_N;                //    VGA SYNC
    output    [7:0]    VGA_R;                   //    VGA Red[7:0] Changed from 10 to 8-bit DAC
    output    [7:0]    VGA_G;                     //    VGA Green[7:0]
    output    [7:0]    VGA_B;                   //    VGA Blue[7:0]
    
    wire resetn;
    assign resetn = ~SW[5];
	wire resetGamen;
	assign resetGamen = ~SW[4];
	wire [23:0] c;
//	assign c[7:0] = {8 {1}};
//	assign c[15:8] = {8{1}};
//	assign c[23:16] = {8{1}};
    wire [7:0] x;  //0-159
    wire [6:0] y;  //0-119
    wire wall, wall_l, wall_r,reset,waiting,create,delete,move;
	wire down_l, down_r, up_l, up_r,speed_l,speed_r,go_l,go_r;
	wire paddle_l,paddle_r,paddle_l_floor, paddle_r_floor,paddle_l_roof, paddle_r_roof;
	wire resetS, gameOver, writeEn, create_l, create_r, delete_l, delete_r, move_l, move_r; 
	wire [3:0] score_l, score_r;
	wire [8:0] dx, dx_l, dx_r;
	wire [7:0] dy, dy_l, dy_r;
    wire [3:0] counter_ball,counter_paddle_l,counter_paddle_r;
    wire [8:0] x_r;
    wire [7:0] y_r;
    wire [23:0] c_o; 	
   wire [2:0] player_id;
	wire [8:0] x_lp, x_rp;
	wire [7:0] y_lp, y_rp;
		
	assign LEDR[7:5] = player_id;
	//wire [4:0] current_state_all;
	//assign LEDR[4:0] = current_state_all;
	assign down_l = ~SW[9];
	assign up_l = SW[9];
/* 	assign down_r = ~SW[3];
	assign up_r = SW[3];
	assign go_r = ~KEY[0];
	assign speed_r = ~KEY[1]; */
	assign go_l = ~KEY[2];
	assign speed_l = ~KEY[3];
	assign HEX2 = 7'b0111111;
	assign HEX3 = 7'b0111111;
	assign HEX0 = 7'b1111111;
	assign HEX5 = 7'b1111111;
	hex_decoder h1 ( score_l,HEX1 );
	hex_decoder h2 ( score_r,HEX4 );
	
	bosses b0(	CLOCK_50,	
				paddle_l, paddle_r,
				x, dx, x_lp, x_rp, 
				y, dy, y_lp, y_rp, 
				player_id, 
				SW[3], ~SW[3], ~KEY[0], ~KEY[1], 
				go_r, speed_r, up_r, down_r, 
				LEDR[4:0]);
    control c0(
				CLOCK_50, down_l, down_r, up_l, up_r,speed_l,speed_r,go_l,go_r,resetn, 
				resetGamen,paddle_l,paddle_r,paddle_l_floor, paddle_r_floor,paddle_l_roof, paddle_r_roof, 
				wall, wall_l,wall_r, dx, dx_l, dx_r, dy, dy_l, dy_r, reset, resetS, gameOver, writeEn,waiting,
				create,create_l, create_r, counter_ball[3:0],counter_paddle_l[3:0],counter_paddle_r[3:0], 
				delete, delete_l, delete_r,move, move_l, move_r, score_l, score_r,player_id
				);
				
	datapath d0(
				CLOCK_50,dx, dx_l,dx_r, dy,dy_l, dy_r, reset, 
				resetS, gameOver, waiting,create,delete,move, 
				create_l,delete_l, move_l, create_r, delete_r, move_r,
				counter_ball, counter_paddle_l, counter_paddle_r,
				c,
				x_r,
				y_r,
				c_o,
				wall,
				wall_l,
				wall_r, 
				paddle_l,paddle_r,
				paddle_l_floor, paddle_r_floor,
				paddle_l_roof, paddle_r_roof,
				x, x_lp, x_rp,
				y, y_lp, y_rp
				);   

				
				
    vga_adapter VGA(
            .resetn(resetn),
            .clock(CLOCK_50),
            .colour(c_o),
            .x(x_r),
            .y(y_r),
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
        defparam VGA.RESOLUTION = "320x240";
        defparam VGA.MONOCHROME = "FALSE";
        defparam VGA.BITS_PER_COLOUR_CHANNEL = 8;
        defparam VGA.BACKGROUND_IMAGE = "target.mif";
    
endmodule

module control(	input  clk,down_l,down_r,up_l,up_r,speed_l,speed_r,go_l,go_r,
				input resetn, resetGamen,
				input paddle_l,paddle_r,paddle_l_floor, paddle_r_floor,paddle_l_roof, paddle_r_roof,
				input wall, wall_l, wall_r, 
				output reg [8:0] dx, dx_l, dx_r, 
				output reg [7:0]dy,dy_l,dy_r, 
				output reg reset,resetS,gameOver,plot,waiting,create,create_l,create_r,
				output reg [4:0] counter_ball,counter_paddle_l,counter_paddle_r, 
				output reg delete,delete_l,delete_r,move,move_l,move_r, 
				output reg [3:0] score_l,score_r,
				output reg [2:0] player_id );
    localparam  
		PONG_CYCLE_START		= 5'd0,
		B_CYCLE_D			= 5'd1,
		B_CYCLE_X			= 5'd2,
		B_CYCLE_M			= 5'd3,
		B_CYCLE_C			= 5'd4,
		PONG_CYCLE_WAIT		= 5'd5,
		
		PL_CYCLE_D			= 5'd6,
		PL_CYCLE_X			= 5'd7,
		PL_CYCLE_M			= 5'd8,
		PL_CYCLE_C			= 5'd9,	

		
		PR_CYCLE_D			= 5'd10,
		PR_CYCLE_X			= 5'd11,
		PR_CYCLE_M			= 5'd12,
		PR_CYCLE_C			= 5'd13,

		PONG_CYCLE_DELETE	= 5'd14,
		PONG_CYCLE_SCORE	= 5'd15,
		
		PONG_CYCLE_GAMEOVER	= 5'd16;
		
	reg frame;
	reg [23:0] count;
	reg [23:0] count2;
	reg [23:0] count3;
	reg [4:0]  current_state_all, next_state_all;
/* 	reg [2:0] current_state_left, next_state_left;
	reg [2:0] current_state_right, next_state_right; */	
	reg deleteAll;
	reg check,check_l,check_r;
	reg goTime,goTimeL,goTimeR;
	reg button;
	reg score;
    always@(*)
        begin: ball_states
			case (current_state_all)
				PL_CYCLE_D:			next_state_all = ( ( counter_paddle_l==5'd16 ) ? ( deleteAll ? PR_CYCLE_D : PL_CYCLE_X ): PL_CYCLE_D );
				PL_CYCLE_X:			next_state_all = PL_CYCLE_M;
				PL_CYCLE_M:			next_state_all =  PL_CYCLE_C;
				PL_CYCLE_C:			next_state_all = ( counter_paddle_l==5'd16 ) ? PONG_CYCLE_WAIT : PL_CYCLE_C;
				//PR_CYCLE_WAIT:		next_state_left = resetGamen ? ( ( goTime ) ? ( PL_CYCLE_ d): PL_CYCLE_WAIT ) : PONG_CYCLE_DELETE;
				
				PR_CYCLE_D:			next_state_all = ( ( counter_paddle_r==5'd16 ) ? ( deleteAll ?( ( score ) ? PONG_CYCLE_SCORE : PONG_CYCLE_START ): PR_CYCLE_X ): PR_CYCLE_D );
				PR_CYCLE_X:			next_state_all = PR_CYCLE_M;
				PR_CYCLE_M:			next_state_all =  PR_CYCLE_C;
				PR_CYCLE_C:			next_state_all = ( counter_paddle_r==5'd16 ) ? PONG_CYCLE_WAIT : PR_CYCLE_C;
				//PR_CYCLE_WAIT:		next_state_all = resetGamen ? ( ( goTime ) ? ( PR_CYCLE_ d): PR_CYCLE_WAIT ) : PONG_CYCLE_DELETE;
				
				B_CYCLE_D:			next_state_all = ( ( counter_ball==5'd16 ) ? ( deleteAll ? PL_CYCLE_D : B_CYCLE_X ): B_CYCLE_D );
				B_CYCLE_X:			next_state_all = score ? PONG_CYCLE_WAIT :B_CYCLE_M;
				B_CYCLE_M:			next_state_all =  B_CYCLE_C;
				B_CYCLE_C:			next_state_all = ( counter_ball==5'd16 ) ? PONG_CYCLE_WAIT : B_CYCLE_C;
				
				PONG_CYCLE_WAIT:  	next_state_all = (score_l == 4'd11 || score_r == 4'd11) ? PONG_CYCLE_GAMEOVER :( (!score && resetGamen) ? ( ( goTime ) ? ( B_CYCLE_D ): ( ( goTimeL ) ? PL_CYCLE_D : ( ( goTimeR ) ? PR_CYCLE_D : PONG_CYCLE_WAIT ) ) ): PONG_CYCLE_DELETE );
				PONG_CYCLE_DELETE: 	next_state_all = B_CYCLE_D;
				PONG_CYCLE_SCORE:	next_state_all = button ? PONG_CYCLE_WAIT : PONG_CYCLE_SCORE;
				PONG_CYCLE_START:  	next_state_all = resetGamen ? PONG_CYCLE_WAIT : PONG_CYCLE_START;
				
				PONG_CYCLE_GAMEOVER:next_state_all = resetGamen ? PONG_CYCLE_GAMEOVER : PONG_CYCLE_DELETE;
				
				default:			next_state_all= PONG_CYCLE_START ;
			endcase
        end // state_table
	
/* 	always@(*)
	begin: Paddle_Left_States
		case (current_state_left)
			PL_CYCLE_D:		next_state_left = ( ( counter_paddle_l==5'd16 ) ? ( resetGamen ? PL_CYCLE_X : PONG_CYCLE_START ): PL_CYCLE_D );
			PL_CYCLE_X:		next_state_left = PL_CYCLE_M;
			PL_CYCLE_M:		next_state_left =  PL_CYCLE_C;
			PL_CYCLE_C:		next_state_left = ( counter_paddle_l==5'd16 ) ? PL_CYCLE_WAIT : PL_CYCLE_C;
			PL_CYCLE_WAIT:	next_state_left = resetGamen ? ( ( goTime ) ? ( PL_CYCLE_ d): PL_CYCLE_WAIT ) : PL_CYCLE_D;
			PL_CYCLE_START:	next_state_left = resetGamen ? PL_CYCLE_C  : PONG_CYCLE_START;
			default:		next_state_left = PONG_CYCLE_START ;
		endcase
	end // state_table for left paddle
	
	
	always@(*)
        begin: Paddle_Right_States
			case (current_state_right)
				PL_CYCLE_D:		next_state_right = ( ( counter_paddle_l==5'd16 ) ? ( resetGamen ? PL_CYCLE_X : PONG_CYCLE_START ): PL_CYCLE_D );
				PL_CYCLE_X:		next_state_right = PL_CYCLE_M;
				PL_CYCLE_M:		next_state_right =  PL_CYCLE_C;
				PL_CYCLE_C:		next_state_right = ( counter_paddle_l==5'd16 ) ? PL_CYCLE_WAIT : PL_CYCLE_C;
				PL_CYCLE_WAIT:	next_state_right = resetGamen ? ( ( goTime ) ? ( PL_CYCLE_ d): PL_CYCLE_WAIT ) : PL_CYCLE_D;
				PL_CYCLE_START:	next_state_right = resetGamen ? PL_CYCLE_C  : PONG_CYCLE_START;
				default:		next_state_right = PONG_CYCLE_START ;
			endcase
        end // state_table for right paddle */
		
	
	
    always @ (posedge clk)
    begin//Go time
		if( current_state_all == B_CYCLE_X )begin
		//count <= 24'b101111101011111000101101;//Frame +35 clocks
		//count <= 24'b100011110000111010100010 +1;//9375394 +1
		count <= 24'b010111110101111100010111;
		//count <= 24'b001111111001010010111010;
		//count <= 24'b001011111010111110001011;
		end
		if(count != 0) begin
		count <= count-1;
		goTime <=0;
		end
		else begin
		goTime <=1;
		end
		//		  if(count1 != 0 && frame==1) begin
		//        count1 <= count1-1;
		//        goTime <=1;
		//        end
		//        else begin
		//        count1 <= 4'd14;
		//        goTime <=0;
		//        end
        
    end
	
	    always @ (posedge clk)
    begin//Go time left paddle
		if( current_state_all == PL_CYCLE_X )begin
			//count2 <= 24'b101111101011111000101101;//Frame +35 clocks
			//count2 <= 24'b100011110000111010100010;//9375394
			count2 <= 24'b010111110101111100010111 +1;
			//count2 <= 24'b001111111001010010111010;
			//count2 <= 24'b001011111010111110001011;
		end
		if(count2 != 0) begin
		count2 <= count2-1;
		goTimeL <=0;
		end
		else begin
		goTimeL <=1;
		end
        
    end
	
	    always @ (posedge clk)
    begin//Go time right paddle
		if( current_state_all == PR_CYCLE_X )begin
			count3 <= 24'b101111101011111000101101  +1;//Frame +35 clocks
			//count3 <= 24'b100011110000111010100010;//9375394
			//count3 <= 24'b010111110101111100010111;
			//count3 <= 24'b001111111001010010111010;
			//count3 <= 24'b001011111010111110001011;
		end
		if(count3 != 0) begin
		count3 <= count3-1;
		goTimeR <=0;
		end
		else begin
		goTimeR <=1;
		end
        
    end
    
/* 	 always @(*)
    begin//Flags and signals for ball
		delete_l=1'b0;
		waiting_l=1'b0;
		create_l=1'b0;
		plot_l=1'b0;
		reset_l=1'b0;
		move_l=1'b0;
		check_l=1'b0;
		case (current_state_left)
			PL_CYCLE_D: begin // delete
			delete=1;
			plot=1;			 
		end
		PL_CYCLE_X: begin // Do A <- A * x 
			check=1;//wire missing
		end
		PL_CYCLE_M: //Move
		begin
			move = 1 ;		
		end
		PL_CYCLE_C: begin // create
			create=1;
			plot=1; 
		end
		PL_CYCLE_WAIT: begin //Wait and show off ball
			waiting=1;
		end

		PL_CYCLE_START:begin
			reset=1;
		end    
		endcase
	end // enable_signals */
	
/* 	always@(posedge clk)
	begin: state_FFs
		if( current_state_left == B_CYCLE_C || current_state_left ==B_CYCLE_D ) counter_ball <= counter_ball + 1;
		else counter_paddle_l <= 0;
		if( current_state_left == PONG_CYCLE_START )
		begin
			if(up)
			dy <= 7'b1111110;
			else
			dy <= 7'b0000010;
		end
		current_state_left <= next_state_left;
	end */
	

    always @(*)
    begin//Flags and signals for ball
		delete		=1'b0;
		create		=1'b0;
		move		=1'b0;
		check		=1'b0;
		
		delete_l	=1'b0;
		create_l	=1'b0;
		move_l		=1'b0;
		check_l		=1'b0;

		
		delete_r	=1'b0;
		create_r	=1'b0;
		move_r		=1'b0;
		check_r		=1'b0;
		
		gameOver	=1'b0;
		waiting		=1'b0;
		reset		=1'b0;
		resetS		=1'b0;
		plot		=1'b0;

		case (current_state_all)

		B_CYCLE_D: begin // delete
			delete=1;
			plot=1;			 
		end
		B_CYCLE_X: begin // Do A <- A * x 
			check=1;//local
		end
		B_CYCLE_M: begin //Move
			move = 1 ;		
		end
		B_CYCLE_C: begin // create
			create=1;
			plot=1; 
		end
		
		PL_CYCLE_D: begin // delete
			delete_l=1;
			plot=1;			 
		end
		PL_CYCLE_X: begin // Do A <- A * x 
			check_l=1;//local
		end
		PL_CYCLE_M: begin //Move	
			move_l = 1 ;		
		end
		PL_CYCLE_C: begin // create
			create_l=1;
			plot=1; 
		end
		
		PR_CYCLE_D: begin // delete
			delete_r = 1;
			plot = 1;			 
		end
		PR_CYCLE_X: begin // Do A <- A * x 
			check_r = 1;//local
		end
		PR_CYCLE_M: begin //Move
			move_r = 1 ;		
		end
		PR_CYCLE_C: begin // create
			create_r=1;
			plot=1; 
		end
		
		
		PONG_CYCLE_WAIT: begin //Wait and show off all
			waiting=1;
		end
		PONG_CYCLE_START:begin
			reset=1;
		end	
		PONG_CYCLE_SCORE:begin
			resetS=1;
		end	
		PONG_CYCLE_GAMEOVER:begin
			gameOver=1;
		end
		PONG_CYCLE_DELETE:begin
		
		end
		
		endcase
	end // enable_signals

	always@(posedge clk)
		begin: state_FFs	
					
			if( current_state_all == PONG_CYCLE_START )
			begin
				deleteAll <=0;
				dx		<= 9'b111111110;
				dy		<= 8'b00000010;
				dx_l	<= 9'b000000000;
				dy_l	<= 8'b00000000;//should turn to 0
				dx_r	<= 9'b000000000;
				dy_r 	<= 8'b00000000;//should turn to 0
				score 	<= 0;
				score_l <= 0;
				score_r <= 0;
				player_id<=3'b001;
			end
			
			if( current_state_all == PONG_CYCLE_SCORE )
			begin
				deleteAll <=0;
				dx		<= 9'b111111110;
				dy		<= 8'b00000010;
				dx_l	<= 9'b000000000;
				dy_l	<= 8'b00000000;
				dx_r	<= 9'b000000000;
				dy_r 	<= 8'b00000000;
				score 	<= 0;
			end
			
			if( current_state_all == PONG_CYCLE_DELETE )
			begin 
				deleteAll <=1;
			end
			
			if( go_l || go_r ) button <=1;//Go r?
			else button <= 0;
			
			//Counters to draw:

			
			if( current_state_all == B_CYCLE_C || current_state_all ==B_CYCLE_D ) counter_ball <= counter_ball + 1;
			else counter_ball <= 0;
			
			if( current_state_all == PL_CYCLE_C || current_state_all ==PL_CYCLE_D ) counter_paddle_l <= counter_paddle_l + 1;
			else counter_paddle_l <= 0;
			
			if( current_state_all == PR_CYCLE_C || current_state_all ==PR_CYCLE_D ) counter_paddle_r <= counter_paddle_r + 1;
			else counter_paddle_r <= 0;
			//
			
			if( current_state_all == B_CYCLE_X )
			begin
				if(wall)
				begin
					dy <= -dy;
				end
				if(wall_l)
				begin
					score <= 1;
					score_l <= score_l + 1;
				end
				if(wall_r)
				begin
					score <= 1;
					score_r <= score_r + 1;
				end
				if( paddle_l )
				begin
					dx <= -dx;
				end
				if( paddle_r )
				begin
					dx <= -dx;
				end
			end
			
			if( current_state_all == PL_CYCLE_X )
			begin
				if(paddle_l_floor && down_l)
					dy_l <= 0;
					else 
					if(paddle_l_roof && up_l)
						dy_l <= 0;
					else begin
						if(down_l && go_l) dy_l <= 8'b00000001;
						if(down_l && go_l && speed_l) dy_l <= 8'b00000010;
						if(up_l && go_l) dy_l <= 8'b11111111;
						if(up_l && go_l && speed_l) dy_l <= 8'b11111110;
						if( !go_l ) dy_l <= 0;
					end
			end
			
			if( current_state_all == PR_CYCLE_X )
			begin
				if(paddle_r_floor && down_r)
					dy_r <= 0;
				else 
					if(paddle_r_roof && up_r)
						dy_r <= 0;
					else begin
						if(down_r && go_r) dy_r <= 8'b00000001;
						if(down_r && go_r && speed_r) dy_r <= 8'b00000010;
						if(up_r && go_r) dy_r <= 8'b11111111;
						if(up_r && go_r && speed_r) dy_r <= 8'b11111110;
						if( !go_r ) dy_r <= 0;
					end
			end

			current_state_all <= next_state_all;
		end
		
	endmodule
                
 module datapath(
    input clk,
	input [8:0] dx, dx_l, dx_r,
	input [7:0] dy, dy_l, dy_r,
	input reset,resetS,gameOver,
	input waiting,create,delete,move,
	input create_l,delete_l,move_l,
	input create_r,delete_r,move_r,
	input [4:0] counter_ball,counter_paddle_l,counter_paddle_r,
	input [23:0] c,
	output reg [8:0] x_r,
	output reg [7:0] y_r,
	output reg [23:0] c_o,
	output reg wall,
	output reg wall_l,
	output reg wall_r,
	output reg paddle_l,paddle_r,
	output reg paddle_l_floor, paddle_r_floor,
	output reg paddle_l_roof, paddle_r_roof,
	output reg [8:0] x, x_lp, x_rp,
	output reg [7:0] y, y_lp, y_rp
    );
    always@(posedge clk) begin
		if(delete)//delete
		begin
			if( (y == 8'd236 && dy <= 8'b01111111) || (y == 8'd0 && dy > 8'b01111111)) wall <= 1; 
			if (x == 9'd316 && dx <= 9'b011111111) wall_r <= 1;
			if (x == 9'd0 && dx > 9'b011111111)  wall_l <= 1;
			//if ( x + dx > x_lp && x + dx < x_lp+1+1+1+1 && (y_lp+1+1+1+1) > y && y_lp <= y) paddle_l <= 1;  //Better code is to remove dx
			//if ( x + dx > x_rp && x + dx < x_rp+1+1+1+1 && (y_rp+1+1+1+1) > y && y_rp <= y) paddle_r <= 1;  //Better code is to remove dx
			if ( x == x_lp + 9'd4 && dx >  9'b011111111 && (y_lp+8'd3) >= y &&  y_lp <= y+8'd3) paddle_l <= 1;
			if ( x == x_rp + 9'b111111100/*-4*/ && dx <= 9'b011111111 && (y_rp+8'd3) >= y && y_rp <= y+8'd3) paddle_r <= 1; 
			x_r <= x + counter_ball[1:0];
			y_r <= y + counter_ball[3:2];
			c_o = 0;
		end 
        //There is a state in control path that changes dx and dy here.
		if(move)//Move
		begin
		if(/*0*/-dy>y && dy > 8'b01111111)
				y <=8'd0;
			else 
				if( 8'd236-dy<y  && dy <= 8'b01111111)
					y <= 8'd236; // please note it is 119 -1-1-1-1
				else
					y <= y+dy;
			if( x_lp+9'd3 - dx > x && dx > 9'b011111111 &&  y_lp  <= y +8'd3 && y_lp +8'd3  >= y  )
				x <= x_lp +9'd4;
			else
				if( x_rp - dx < x +9'd3 && dx <= 9'b011111111 &&  y_rp  <= y +8'd3 && y_rp +8'd3  >= y  )
					x <= x_rp + 9'b111111100; //-4
				else
					if( /*0*/ - dx > x && dx > 9'b011111111)
						x <= 9'd0;
					else
						if( 9'd316 - dx < x && dx <= 9'b011111111)
							x <= 9'd316;
						else
							x <= x+dx;
			wall_l <= 0;
			wall_r <= 0;
			wall <= 0;
			paddle_l <= 0;
			paddle_r <= 0;
		end
		
		if(create)//create
		begin
			x_r <= x + counter_ball[1:0];
			y_r <= y + counter_ball[3:2];
			c_o = 24'b111111111111111111111111;
		end
		
		//Game:
	 	if(waiting)
		begin
			if( y_lp == 8'd216	&& dy_l <= 8'b01111111) 
				paddle_l_floor <= 1; 
			else 
				paddle_l_floor <= 0;
			if( y_lp == 8'd0 && dy_l > 8'b01111111 ) 
				paddle_l_roof <= 1;
			else 
				paddle_l_roof <= 0;
			if( y_rp == 8'd216	&& dy_r <= 8'b01111111) 
				paddle_r_floor <= 1; 
			else 
				paddle_r_floor <=0;
			if( y_rp == 8'd0 && dy_r > 8'b01111111 ) 
				paddle_r_roof <= 1;
			else 
				paddle_r_roof <=0;
		end 
		
		if(reset)
		begin
			wall_l <= 0;
			wall_r <= 0;
			wall <= 0;
			x <= 9'd156;
			y <= 8'd116;

			x_lp <= 9'd2;
			y_lp <= 8'd116;
			
			x_rp <= 9'd314;
			y_rp <= 8'd116;
			
			paddle_l_floor <= 0;
			paddle_r_floor <= 0;
			paddle_l_roof <= 0;
			paddle_r_roof <= 0;
			paddle_l <= 0;
			paddle_r <= 0;
		end
		
		
		if(resetS)
		begin
			wall_l <= 0;
			wall_r <= 0;
			wall <= 0;
			x <= 9'd156;
			y <= 8'd116;

			x_lp <= 9'd2;
			y_lp <= 8'd116;
			
			x_rp <= 9'd314;
			y_rp <= 8'd116;
			
			paddle_l_floor <= 0;
			paddle_r_floor <= 0;
			paddle_l_roof <= 0;
			paddle_r_roof <= 0;
			paddle_l <= 0;
			paddle_r <= 0;
		end
		
		if (gameOver)
		begin
		
		end
		
		//Left paddle
		if(delete_l)//delete
		begin
			//if((y_l >= 7'd116 && dy_l <= 7'b0111111) || (y_l <= 7'd0 && dy_l > 7'b0111111)) paddle_l_roof <= 1; 
			x_r <= x_lp + counter_paddle_l[1:0];
			y_r <= y_lp + counter_paddle_l[3:2];
			c_o = 0;
		end 
        
		if(move_l)//Move
		begin
			if( y_lp < /*0*/ - dy_l && dy_l > 8'b01111111 )
				y_lp <= 8'd0;
			else 
				if( y_lp > 8'd236 - dy_l && dy_l <= 8'b01111111 )
					y_lp <= 8'd236;
				else
					y_lp <= y_lp+dy_l;
			paddle_l_roof <= 0;
			//x_lp <= x_lp+dx_l;
		end
		
		if(create_l)//create
		begin
			x_r <= x_lp + counter_paddle_l[1:0];
			y_r <= y_lp + counter_paddle_l[3:2];
			c_o = 24'b111111111111111111111111;
		end
		
		//Right Paddle:
		if(delete_r)//delete
		begin
			//if((y_r >= 7'd116 && dy_r <= 7'b0111111) || (y_r <= 7'd0 && dy_r > 7'b0111111)) paddle_r_roof <= 1; 
			x_r <= x_rp + counter_paddle_r[1:0];
			y_r <= y_rp + counter_paddle_r[3:2];
			c_o = 0;
		end 
        
		if(move_r)//Move
		begin
			if( y_rp <  8'd0 - dy_r && dy_r > 8'b01111111 )
				begin
					y_rp <= 8'd0;
				end
			else 
				begin
					if( y_rp > 8'd236- dy_r && dy_r <= 8'b01111111 )
						y_rp <= 8'd236;
					else
						y_rp <= y_rp+dy_r;
				end 
			paddle_r_roof <= 1'd0;
		end
		
		if(create_r)//create
		begin
			x_r <= x_rp + counter_paddle_r[1:0];
			y_r <= y_rp + counter_paddle_r[3:2];
			c_o = 24'b111111111111111111111111;
		end
		
		/* if(check)

		begin
			if( (y >= 7'd116 && dy <= 7'b0111111) || (y <= 7'd0 && dy > 7'b0111111)) wall <= 1; 
			if (x >= 8'd156 && dx <= 8'b01111111) wall_r <= 1;
			if (x <= 8'd0 && dx > 8'b01111111)  wall_l <= 1;

		end */
		end

endmodule




module bosses (	input clk,
				input paddle_l, paddle_r,
				input [8:0] x, dx, x_lp, x_rp, 
				input [7:0] y, dy, y_lp, y_rp, 
				input reg [2:0] player_id, 
				input up_button, down_button, go_button, speed_button,
				output reg go_r, speed_r, up_r, down_r,
				output reg[4:0] current_state_ai);
	
	
	localparam 
		AI_IDEL			= 5'd0,
		AI_ONEVONE		= 5'd1,
		AI_NOOB			= 5'd2,
		AI_RANDOM		= 5'd3,
		AI_SOMETHING	= 5'd4,
		AI_FINAL		= 5'd5;
		
	localparam
		IDEL_WAIT		= 5'd0,
	
		ONEVONE_START	= 5'd1,
		ONEVONE_LOOP	= 5'd2,		
	
		NOOB_START		= 5'd3,
		NOOB_MIDDLE		= 5'd4,
		NOOB_OPPOSITE	= 5'd5,
		NOOB_FOLLOW		= 5'd6,
		NOOB_WAIT		= 5'd7;
		
	reg [4:0] start_state_ai,/* current_state_ai,*/ next_state_ai;
	reg [7:0] hold_y_lp;
	always @(*)
	begin
		case ( player_id )
			AI_IDEL:			start_state_ai = IDEL_WAIT;
			AI_ONEVONE: 		start_state_ai = ONEVONE_START;
			AI_NOOB:			start_state_ai = NOOB_START;
			
			default: 			start_state_ai = ONEVONE_START; // changed this
		endcase
	end
	
	always @ (*)
	begin
		case ( current_state_ai )
			IDEL_WAIT: 				next_state_ai = start_state_ai;
			
			ONEVONE_START:			next_state_ai = ONEVONE_LOOP;
			ONEVONE_LOOP:			next_state_ai = ( player_id == 3'b000 ) ? IDEL_WAIT : ONEVONE_LOOP;
			
			NOOB_START:				next_state_ai = NOOB_MIDDLE;
			NOOB_MIDDLE:			next_state_ai =(dx <= 9'b011111111 && x > 9'd158) ? NOOB_FOLLOW : ( paddle_l ? NOOB_OPPOSITE :NOOB_MIDDLE );
			NOOB_OPPOSITE:			next_state_ai =  (y_rp <= 8'd46  || y_rp >= 8'd194  || (y_lp <= 8'd122 && y_lp >= 8'd78 && y_rp == 8'd116)) ? NOOB_WAIT : (dx <= 9'b011111111 && x > 9'd158) ? NOOB_FOLLOW : NOOB_OPPOSITE;
			NOOB_WAIT:				next_state_ai = (dx <= 9'b011111111 && x > 9'd158) ? NOOB_FOLLOW : NOOB_WAIT ;  
			NOOB_FOLLOW:			next_state_ai = (dx > 9'b011111111 ) ? NOOB_MIDDLE : NOOB_FOLLOW;
			default: 				next_state_ai = IDEL_WAIT;
		endcase
	end
	
	
/*  	always @(*)//Signal always block
	begin
	
	end  */
	
	
	always @(posedge clk)
	begin
		if (current_state_ai == IDEL_WAIT)
			begin
				go_r <=0;
				speed_r <=0;
				up_r <= 0;
				down_r <= 0;
				hold_y_lp <=0;
			end
		
		if (current_state_ai == ONEVONE_START)
			begin

			end
			
		if (current_state_ai == ONEVONE_LOOP)
			begin
				up_r <= up_button ;
				down_r <= down_button;
				go_r <= go_button;
				speed_r <= speed_button ;
			end
			
			
		if (current_state_ai == NOOB_START)
			begin
				
			end
			
		if (current_state_ai == NOOB_MIDDLE)
			begin
				if (dx > 9'b011111111 && y_rp < 8'd116)
					begin
						up_r <= 0;
						down_r <= 1;
						speed_r <= 1;
					end
				else if (dx > 9'b011111111 && y_rp > 8'd116)
					begin
						up_r <= 1;
						down_r <= 0;
						speed_r <= 1;
					end
				else if (dx > 9'b011111111 && y_rp == 8'd116)
					begin
						up_r <= 0;
						down_r <= 0;
						speed_r <= 0;
					end
			end	
		if (current_state_ai == NOOB_OPPOSITE)
			begin
				if (paddle_l == 1)
					hold_y_lp <= y_lp;
				if (hold_y_lp >= 8'd122 && y_rp > 8'd46 )
					begin
						up_r <= 1;
						down_r <= 0;
						speed_r <= 1;
					end
				else if (hold_y_lp <= 8'd78 && y_rp < 8'd194 )
					begin
						up_r <= 0;
						down_r <= 1;
						speed_r <= 1;
					end
			end	
		if (current_state_ai == NOOB_START)
			begin
				if ( y < y_rp )
					begin
						up_r <= 1;
						down_r <= 0;
						if (x >= 9'd309)
							speed_r <= 0;
						else speed_r <= 1;
					end
				else if ( y > y_rp )
					begin
						up_r <= 0;
						down_r <= 1;
						if (x >= 9'd309)
							speed_r <= 0;
						else speed_r <= 1;
					end	
			end
		if (current_state_ai == NOOB_WAIT)
			begin
				go_r <=0;
				speed_r <=0;
				up_r <= 0;
				down_r <= 0;
			end	

			current_state_ai <= next_state_ai;
	end
	
	
	/* reg paddle_l_hold;
	reg [6:0] hold_y_lp;
	always @(*)
		if (player_id == 3'b000)
			begin
				speed_r = speed_button;
				up_r = up_button;
				down_r = down_button;
			end
		// go_r = 0;
		// speed_r = 0;
		// up_r = 0;
		// down_r = 0;					
		else if (player_id == 3'b001)
			begin
			//puts paddle back in reset postion
				if (dx > 8'b01111111 && y_rp < 7'd56)
					begin
						up_r = 0;
						down_r = 1;
						speed_r = 1;
					end
				else if (dx > 8'b01111111 && y_rp > 7'd56)
					begin
						up_r = 1;
						down_r = 0;
						speed_r = 1;
					end
				else if (dx > 8'b01111111 && y_rp == 7'd56)
					begin
						up_r = 0;
						down_r = 0;
						speed_r = 0;
					end
					
					
			//moves when left paddle hits
				if (paddle_l == 1)
					begin
						paddle_l_hold = 1;
						hold_y_lp = y_lp;
					end
				if (paddle_l_hold == 1)
					begin
						if (hold_y_lp >= 7'd78 && y_rp > 7'd38 )
							begin
								up_r = 1;
								down_r = 0;
								speed_r = 1;
								if (y_rp == 7'd38)
									begin
										up_r = 0;
										down_r = 0;
										paddle_l_hold = 0;
										hold_y_lp = 0;
										speed_r = 0;
									end
							end
						else if (hold_y_lp <= 7'd38 && y_rp < 7'd78 )
							begin
								up_r = 0;
								down_r = 1;
								speed_r = 1;
								if (y_rp == 7'd78)
									begin
										up_r = 0;
										down_r = 0;
										paddle_l_hold = 0;
										hold_y_lp = 0;
										speed_r = 0;
									end
							end
					end
				
				//follows ball
				if (dx <= 8'b01111111 && x > 8'd76)
					begin
						if ( y < y_rp )
							begin
								up_r = 1;
								down_r = 0;
								if (x >= 8'd147)
									speed_r = 0;
								else speed_r = 1;
							end
						else if ( y > y_rp )
							begin
								up_r = 0;
								down_r = 1;
								if (x >= 8'd147)
									speed_r = 0;
								else speed_r = 1;
							end
					end
			end */
				
endmodule

module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule