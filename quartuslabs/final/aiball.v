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
	wire [2:0] c;
	assign c = SW[2:0];
//    wire [7:0] x;  //0-159
//    wire [6:0] y;  //0-119
    wire wall, wall_l, wall_r,reset,waiting,create,delete,move;
	wire down_l, down_r, up_l, up_r,speed_l,speed_r,go_l,go_r;
	wire paddle_l,paddle_r,paddle_l_floor, paddle_r_floor,paddle_l_roof, paddle_r_roof;
	wire resetS, gameOver, writeEn, create_l, create_r, delete_l, delete_r, move_l, move_r; 
	wire [3:0] score_l, score_r;
	wire [7:0] dx, dx_l, dx_r;
	wire [6:0] dy, dy_l, dy_r;
    wire [3:0] counter,countL,countR;
    wire [7:0] x_r;
    wire [6:0] y_r;
    wire [2:0] c_o; 	
	assign LEDR[5:0] = {wall,wall_l,wall_r,delete,move,waiting};
	assign down_l = ~SW[9];
	assign up_l = SW[9];
	assign down_r = ~SW[3];
	assign up_r = SW[3];
	assign go_r = ~KEY[0];
	assign speed_r = ~KEY[1];
	assign go_l = ~KEY[2];
	assign speed_l = ~KEY[3];
	assign HEX2 = 7'b0111111;
	assign HEX3 = 7'b0111111;
	wire [7:0] x,x_lp, x_rp;
    wire [6:0] y,y_lp, y_rp;
	wire [23:0] count;
	hex_decoder h1 ( score_l,HEX4 );
	hex_decoder h2 ( score_r,HEX1 );
	
	noobChamp AI0 (CLOCK_50, resetn,count,down_r,up_r,go_r,speed_r);
	
	
 control c0(
				CLOCK_50, down_l, down_r, up_l, up_r,speed_l,speed_r,go_l,go_r,resetn, 
				resetGamen,paddle_l,paddle_r,paddle_l_floor, paddle_r_floor,paddle_l_roof, paddle_r_roof, 
				wall, wall_l,wall_r, dx, dx_l, dx_r, dy, dy_l, dy_r, reset, resetS, gameOver, writeEn,waiting,
				create,create_l, create_r, counter[3:0],countL[3:0],countR[3:0], 
				delete, delete_l, delete_r,move, move_l, move_r, score_l, score_r,count
				);
				
	datapath d0(
				CLOCK_50,dx, dx_l,dx_r, dy,dy_l, dy_r, reset, 
				resetS, gameOver, waiting,create,delete,move, 
				create_l,delete_l, move_l, create_r, delete_r, move_r,
				counter, countL, countR,
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
				paddle_l_wall, paddle_r_wall,
				x,
x_lp, x_rp,
y,y_lp, y_rp
				);   
endmodule

	
module noobChamp (input clk, resetn, input [23:0] count, output reg down_r,up_r,go_r,speed_r);
	wire [4:0] lfsr;
	lfsr_counter a0(clk,!resetn,1'b1,lfsr);
	reg [4:0] temp;
	reg [19:0] temp2;
	always@ (posedge clk)
	begin
		if(!resetn) begin
			temp <= 0;
			temp2 <= 0;
			go_r <=0;
			down_r <= 0;
			up_r <= 1;
			speed_r <=0;end
		else
			temp <= count % lfsr;
			if(temp%10==4)
			begin
				temp2<=(count+lfsr)%1000000;
				if(temp2==20'b00)begin
					go_r <=1;
					down_r <=0;
					up_r <= 1;
				end
				if(temp2==20'b01)begin
					go_r <=1;
					down_r <=1;
					up_r <= 0;
				end
				if(temp2==20'b10)begin
					go_r <=0;
				end
			end
	end

endmodule
	
	
module control(	input  clk,down_l,down_r,up_l,up_r,speed_l,speed_r,go_l,go_r,
				input resetn, resetGamen,
				input paddle_l,paddle_r,paddle_l_floor, paddle_r_floor,paddle_l_roof, paddle_r_roof,
				input wall, wall_l, wall_r, 
				output reg [7:0] dx, dx_l, dx_r, 
				output reg [6:0]dy,dy_l,dy_r, 
				output reg reset,resetS,gameOver,plot,waiting,create,create_l,create_r,
				output reg [4:0] counter,countL,countR, 
				output reg delete,delete_l,delete_r,move,move_l,move_r, 
				output reg [3:0] score_l,score_r,
				output reg [23:0] count);
    localparam  
		ALL_CYCLE_START		= 5'd0,
		B_CYCLE_D			= 5'd1,
		B_CYCLE_X			= 5'd2,
		B_CYCLE_M			= 5'd3,
		B_CYCLE_C			= 5'd4,
		ALL_CYCLE_WAIT		= 5'd5,
		
		PL_CYCLE_D			= 5'd6,
		PL_CYCLE_X			= 5'd7,
		PL_CYCLE_M			= 5'd8,
		PL_CYCLE_C			= 5'd9,	

		
		PR_CYCLE_D			= 5'd10,
		PR_CYCLE_X			= 5'd11,
		PR_CYCLE_M			= 5'd12,
		PR_CYCLE_C			= 5'd13,

		ALL_CYCLE_DELETE	= 5'd14,
		ALL_CYCLE_SCORE	= 5'd15,
		
		GAME_CYCLE_GAMEOVER	= 5'd16;
		
	reg frame;
	reg [23:0] count2;
	reg [23:0] count3;
	reg [4:0] current_state_all, next_state_all;
/* 	reg [2:0] current_state_left, next_state_left;
	reg [2:0] current_state_right, next_state_right; */	
//TO DO;
// delteALL
// countR,countL
// goTimeL,goTimeR	
	reg goTime,goTimeL,goTimeR;
reg deleteAll;
reg score;
	reg button;
 always@(*)
        begin: ball_states
			case (current_state_all)
				PL_CYCLE_D:			next_state_all = ( ( countL==5'd16 ) ? ( deleteAll ? PR_CYCLE_D : PL_CYCLE_X ): PL_CYCLE_D );
				PL_CYCLE_X:			next_state_all = PL_CYCLE_M;
				PL_CYCLE_M:			next_state_all =  PL_CYCLE_C;
				PL_CYCLE_C:			next_state_all = ( countL==5'd16 ) ? ALL_CYCLE_WAIT : PL_CYCLE_C;
				//PR_CYCLE_WAIT:		next_state_left = resetGamen ? ( ( goTime ) ? ( PL_CYCLE_ d): PL_CYCLE_WAIT ) : ALL_CYCLE_DELETE;
				
				PR_CYCLE_D:			next_state_all = ( ( countR==5'd16 ) ? ( deleteAll ?( ( score ) ? ALL_CYCLE_SCORE : ALL_CYCLE_START ): PR_CYCLE_X ): PR_CYCLE_D );
				PR_CYCLE_X:			next_state_all = PR_CYCLE_M;
				PR_CYCLE_M:			next_state_all =  PR_CYCLE_C;
				PR_CYCLE_C:			next_state_all = ( countR==5'd16 ) ? ALL_CYCLE_WAIT : PR_CYCLE_C;
				//PR_CYCLE_WAIT:		next_state_all = resetGamen ? ( ( goTime ) ? ( PR_CYCLE_ d): PR_CYCLE_WAIT ) : ALL_CYCLE_DELETE;
				
				B_CYCLE_D:			next_state_all = ( ( counter==5'd16 ) ? ( deleteAll ? PL_CYCLE_D : B_CYCLE_X ): B_CYCLE_D );
				B_CYCLE_X:			next_state_all = B_CYCLE_M;
				B_CYCLE_M:			next_state_all =  B_CYCLE_C;
				B_CYCLE_C:			next_state_all = ( counter==5'd16 ) ? ALL_CYCLE_WAIT : B_CYCLE_C;
				
				ALL_CYCLE_WAIT:  	next_state_all = (score_l == 4'd11 || score_r == 4'd11) ? GAME_CYCLE_GAMEOVER :( (!score && resetGamen) ? ( ( goTime ) ? ( B_CYCLE_D ): ( ( goTimeL ) ? PL_CYCLE_D : ( ( goTimeR ) ? PR_CYCLE_D : ALL_CYCLE_WAIT ) ) ): ALL_CYCLE_DELETE );
				ALL_CYCLE_DELETE: 	next_state_all = B_CYCLE_D;
				ALL_CYCLE_SCORE:	next_state_all = !button ? ALL_CYCLE_WAIT : ALL_CYCLE_SCORE;
				ALL_CYCLE_START:  	next_state_all = resetGamen ? ALL_CYCLE_WAIT : ALL_CYCLE_START;
				
				GAME_CYCLE_GAMEOVER:next_state_all = resetGamen ? GAME_CYCLE_GAMEOVER : ALL_CYCLE_DELETE;
				
				default:			next_state_all= ALL_CYCLE_START ;
			endcase
        end // state_table
	
/* 	always@(*)
	begin: Paddle_Left_States
		case (current_state_left)
			PL_CYCLE_D:		next_state_left = ( ( countL==5'd16 ) ? ( resetGamen ? PL_CYCLE_X : ALL_CYCLE_START ): PL_CYCLE_D );
			PL_CYCLE_X:		next_state_left = PL_CYCLE_M;
			PL_CYCLE_M:		next_state_left =  PL_CYCLE_C;
			PL_CYCLE_C:		next_state_left = ( countL==5'd16 ) ? PL_CYCLE_WAIT : PL_CYCLE_C;
			PL_CYCLE_WAIT:	next_state_left = resetGamen ? ( ( goTime ) ? ( PL_CYCLE_ d): PL_CYCLE_WAIT ) : PL_CYCLE_D;
			PL_CYCLE_START:	next_state_left = resetGamen ? PL_CYCLE_C  : ALL_CYCLE_START;
			default:		next_state_left = ALL_CYCLE_START ;
		endcase
	end // state_table for left paddle
	
	
	always@(*)
        begin: Paddle_Right_States
			case (current_state_right)
				PL_CYCLE_D:		next_state_right = ( ( countL==5'd16 ) ? ( resetGamen ? PL_CYCLE_X : ALL_CYCLE_START ): PL_CYCLE_D );
				PL_CYCLE_X:		next_state_right = PL_CYCLE_M;
				PL_CYCLE_M:		next_state_right =  PL_CYCLE_C;
				PL_CYCLE_C:		next_state_right = ( countL==5'd16 ) ? PL_CYCLE_WAIT : PL_CYCLE_C;
				PL_CYCLE_WAIT:	next_state_right = resetGamen ? ( ( goTime ) ? ( PL_CYCLE_ d): PL_CYCLE_WAIT ) : PL_CYCLE_D;
				PL_CYCLE_START:	next_state_right = resetGamen ? PL_CYCLE_C  : ALL_CYCLE_START;
				default:		next_state_right = ALL_CYCLE_START ;
			endcase
        end // state_table for right paddle */
		
	
	
    always @ (posedge clk)
    begin//Go time
		if( current_state_all == B_CYCLE_X )begin
		//count <= 24'b101111101011111000101101;//Frame +35 clocks
		count <= 24'd100;//9375394 +1
		//count <= 24'b010111110101111100010111;
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
			count2 <= 24'd150;
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
			count3 <= 24'd180;//Frame +35 clocks
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
		if( current_state_left == B_CYCLE_C || current_state_left ==B_CYCLE_D ) counter <= counter + 1;
		else countL <= 0;
		if( current_state_left == ALL_CYCLE_START )
		begin
			if(up)
			dy <= 7'b1111110;
			else
			dy <= 7'b0000010;
		end
		current_state_left <= next_state_left;
	end */
	
	
	reg check,check_l,check_r;
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
		
		
		ALL_CYCLE_WAIT: begin //Wait and show off all
			waiting=1;
		end
		ALL_CYCLE_START:begin
			reset=1;
		end	
		ALL_CYCLE_SCORE:begin
			resetS=1;
		end	
		GAME_CYCLE_GAMEOVER:begin
			gameOver=1;
		end
		ALL_CYCLE_DELETE:begin
		
		end
		
		endcase
	end // enable_signals

	always@(posedge clk)
		begin: state_FFs	
			
			if( go_l || go_r ) button <=1;
				else button <= 0;
				
			if( current_state_all == B_CYCLE_C || current_state_all ==B_CYCLE_D ) counter <= counter + 1;
			else counter <= 0;
			
			if( current_state_all == PL_CYCLE_C || current_state_all ==PL_CYCLE_D ) countL <= countL + 1;
			else countL <= 0;
			
			if( current_state_all == PR_CYCLE_C || current_state_all ==PR_CYCLE_D ) countR <= countR + 1;
			else countR <= 0;
			
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
						if(down_l && go_l) dy_l <= 7'b0000001;
						if(down_l && go_l && speed_l) dy_l <= 7'b0000010;
						if(up_l && go_l) dy_l <= 7'b1111111;
						if(up_l && go_l && speed_l) dy_l <= 7'b1111110;
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
						if(down_r && go_r) dy_r <= 7'b0000001;
						if(down_r && go_r && speed_r) dy_r <= 7'b0000010;
						if(up_r && go_r) dy_r <= 7'b1111111;
						if(up_r && go_r && speed_r) dy_r <= 7'b1111110;
						if( !go_r ) dy_r <= 0;
					end
			end
			
			if( current_state_all == ALL_CYCLE_SCORE )
			begin
				deleteAll <=0;
				dx		<= 8'b11111110;
				dy		<= 7'b0000010;
				dx_l	<= 8'b00000000;
				dy_l	<= 7'b0000000;
				dx_r	<= 8'b00000000;
				dy_r 	<= 7'b0000000;
				score 	<= 0;
			end
			if( current_state_all == ALL_CYCLE_DELETE )
			begin 
				deleteAll <=1;
			end
			
			if( current_state_all == ALL_CYCLE_START )
			begin
				deleteAll <=0;
				dx		<= 8'b11111110;
				dy		<= 7'b0000010;
				dx_l	<= 8'b00000000;
				dy_l	<= 7'b0000000;//should turn to 0
				dx_r	<= 8'b00000000;
				dy_r 	<= 7'b0000000;//should turn to 0
				score 	<= 0;
				score_l <= 0;
				score_r <= 0;
			end
			
			current_state_all <= next_state_all;
		end
		
endmodule
                
                
module datapath(
    input clk,
	input [7:0] dx, dx_l, dx_r,
	input [6:0] dy, dy_l, dy_r,
	input reset,resetS,gameOver,
	input waiting,create,delete,move,
	input create_l,delete_l,move_l,
	input create_r,delete_r,move_r,
	input [3:0] counter,countL,countR,
	input [2:0] c,
    output reg [7:0] x_r,
    output reg [6:0] y_r,
    output reg [2:0] c_o,
    output reg wall,
    output reg wall_l,
	output reg wall_r,
	output reg paddle_l,paddle_r,
	output reg paddle_l_floor, paddle_r_floor,
	output reg paddle_l_roof, paddle_r_roof,
	output reg paddle_l_wall, paddle_r_wall,
	 output reg [7:0] x,
	output reg [7:0] x_lp, x_rp,
    output reg [6:0] y,y_lp, y_rp
    );
   
    always@(posedge clk) begin
		if(delete)//delete
		begin
			if( (y >= 7'd116 && dy <= 7'b0111111) || (y <= 7'd0 && dy > 7'b0111111)) wall <= 1; 
			if (x >= 8'd156 && dx <= 8'b01111111) wall_r <= 1;
			if (x <= 8'd0 && dx > 8'b01111111)  wall_l <= 1;
			//if ( x + dx > x_lp && x + dx < x_lp+1+1+1+1 && (y_lp+1+1+1+1) > y && y_lp <= y) paddle_l <= 1;  //Better code is to remove dx
			//if ( x + dx > x_rp && x + dx < x_rp+1+1+1+1 && (y_rp+1+1+1+1) > y && y_rp <= y) paddle_r <= 1;  //Better code is to remove dx
			if ( x == x_lp + 1+1+1+1 && dx >  8'b01111111 && (y_lp+1+1+1) >= y &&  y_lp <= y+1+1+1) paddle_l <= 1;
			if ( x == x_rp + 8'b11111100/*-4*/ && dx <= 8'b01111111 && (y_rp+1+1+1) >= y && y_rp <= y+1+1+1) paddle_r <= 1; 
			x_r <= x + counter[1:0];
			y_r <= y + counter[3:2];
			c_o = 3'b000;
		end 
        //There is a state in control path that changes dx and dy here.
		if(move)//Move
		begin
		if(0-dy>y && dy > 7'b0111111)
				y <=0;
			else 
				if( 116-dy<y  && dy <= 7'b0111111)
					y <= 116; // please note it is 119 -1-1-1-1
				else
					y <= y+dy;
			if( x_lp+1+1+1+1 - dx > x && dx > 8'b01111111 &&  y_lp  <= y +1+1+1 && y_lp +1+1+1  >= y  )
				x <= x_lp +1+1+1+1;
			else
				if( x_rp - dx < x +1+1+1 && dx <= 8'b01111111 &&  y_rp  <= y +1+1+1 && y_rp +1+1+1  >= y  )
					x <= x_rp + 8'b11111100; //-4
				else
					if( 0 - dx > x && dx > 8'b01111111)
						x <= 0;
					else
						if( 156 - dx < x && dx <= 8'b01111111)
							x <= 156;
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
			x_r <= x + counter[1:0];
			y_r <= y + counter[3:2];
			c_o = c;
		end
		
		//Game:
	 	if(waiting)
		begin
			if( y_lp >= 7'd116	&& dy_l <= 7'b0111111) paddle_l_floor <= 1;
			else paddle_l_floor <= 0;
			if( y_lp <= 7'd0		&& dy_l > 7'b0111111 ) paddle_l_roof <= 1;
			else paddle_l_roof <= 0;
			if( y_rp >= 7'd116	&& dy_r <= 7'b0111111) paddle_r_floor <= 1; 
			else paddle_r_floor <=0;
			if( y_rp <= 7'd0		&& dy_r > 7'b0111111 ) paddle_r_roof <= 1;
			else paddle_r_roof <=0;
		end 
		
		if(reset)
		begin
			wall_l <= 0;
			wall_r <= 0;
			wall <= 0;
			x <= 8'd78;
			y <= 7'd58;

			x_lp <= 8'd2;
			y_lp <= 7'd58;
			
			x_rp <= 8'd152;
			y_rp <= 7'd58;
			
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
			x <= 8'd78;
			y <= 7'd58;

			x_lp <= 8'd2;
			y_lp <= 7'd58;
			
			x_rp <= 8'd152;
			y_rp <= 7'd58;
			
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
			x_r <= x_lp + countL[1:0];
			y_r <= y_lp + countL[3:2];
			c_o = 3'b000;
		end 
        
		if(move_l)//Move
		begin
			if( y_lp < 0 - dy_l && dy_l > 7'b0111111 )
				y_lp <= 0;
			else 
				if( y_lp > 116 - dy_l && dy_l <= 7'b0111111 )
					y_lp <= 116;
				else
					y_lp <= y_lp+dy_l;
			paddle_l_roof <= 0;
			//x_lp <= x_lp+dx_l;
		end
		
		if(create_l)//create
		begin
			x_r <= x_lp + countR[1:0];
			y_r <= y_lp + countR[3:2];
			c_o = 3'b111;
		end
		
		//Right Paddle:
		if(delete_r)//delete
		begin
			//if((y_r >= 7'd116 && dy_r <= 7'b0111111) || (y_r <= 7'd0 && dy_r > 7'b0111111)) paddle_r_roof <= 1; 
			x_r <= x_rp + countR[1:0];
			y_r <= y_rp + countR[3:2];
			c_o = 3'b000;
		end 
        
		if(move_r)//Move
		begin
			if( y_rp < 0 - dy_r && dy_r > 7'b0111111 )
				y_rp <= 0;
			else 
				if( y_rp > 116 - dy_r && dy_r <= 7'b0111111 )
					y_rp <= 116;
				else
					y_rp <= y_rp+dy_r;
			paddle_r_roof <= 0;
			//x_rp <= x_rp+dx_r;		
		end
		
		if(create_r)//create
		begin
			x_r <= x_rp + countR[1:0];
			y_r <= y_rp + countR[3:2];
			c_o = 3'b111;
		end
		
		/* if(check)

		begin
			if( (y >= 7'd116 && dy <= 7'b0111111) || (y <= 7'd0 && dy > 7'b0111111)) wall <= 1; 
			if (x >= 8'd156 && dx <= 8'b01111111) wall_r <= 1;
			if (x <= 8'd0 && dx > 8'b01111111)  wall_l <= 1;

		end */
		end

endmodule

module lfsr_counter(
    input clk,
    input reset,
    input enable,
    output reg [4:0]lfsr);
	reg d0;
	reg temp;
	always @(posedge clk) begin
		if(reset) begin
			lfsr <= 0;
			d0 <= 0;
		end
		else begin
			if(enable)begin
				if( lfsr == 5'd31 ) begin lfsr <=0;
				end
				else begin
				d0 <= lfsr[2]~^lfsr[4];
				lfsr[4:0]<= {lfsr[3:0], d0};
				end
			end
		end
	end
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