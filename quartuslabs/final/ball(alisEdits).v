
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
    input    [3:0]   KEY;    
    input     [9:0]  SW;
    output 	[9:0] 	 LEDR;
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
    assign resetn = KEY[1];
	wire resetGamen;
	assign resetGamen = KEY[0];
	wire [2:0] c;
	assign c = SW[2:0];
    
    // Create the colour, x, y and writeEn wires that are inputs to the controller.

    wire [7:0] x;  //0-159
    wire [6:0] y;  //0-119
    wire wall, wall_l, wall_r,reset,waiting,create,delete,move;
	wire [7:0] dx;
	wire [6:0] dy;
    wire [3:0] counter,countL,countR;
    wire writeEn;
    wire [7:0] x_r;
    wire [6:0] y_r;
    wire [2:0] c_o; 	
	 assign LEDR[5:0] = {wall,wall_l,wall_r,delete,move,waiting};
    control c0(CLOCK_50, resetn, resetGamen, wall, wall_l,wall_r, dx, dy, reset, writeEn,waiting,create,counter[3:0],countL,countR,delete,move);
	datapath d0(
				CLOCK_50,dx, dy, reset,waiting,create,delete,move,
				counter, countL, countR,
				c,
				x_r,
				y_r,
				c_o,
				wall,
				wall_l,
				wall_r
				);   
    vga_adapter VGA(
            .resetn(KEY[1]),
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
        defparam VGA.RESOLUTION = "160x120";
        defparam VGA.MONOCHROME = "FALSE";
        defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
        defparam VGA.BACKGROUND_IMAGE = "black.mif";
    
endmodule

module control(input  clk, resetn, resetGamen, wall, wall_l, wall_r, output reg [7:0] dx, output reg [6:0]dy, output reg reset, plot,waiting,create,create_l,create_r,output reg [4:0] counter,countL,countR, output reg delete,delete_l,delete_r,move,move_l,move_r);
    localparam  
		ALL_CYCLE_START	= 5'd0,
		B_CYCLE_D		= 5'd1,
		B_CYCLE_X		= 5'd2,
		B_CYCLE_M		= 5'd3,
		B_CYCLE_C		= 5'd4,
		ALL_CYCLE_WAIT		= 5'd5,
		
		PL_CYCLE_D		= 5'd6,
		PL_CYCLE_X		= 5'd7,
		PL_CYCLE_M		= 5'd8,
		PL_CYCLE_C		= 5'd9,	

		
		PL_CYCLE_D		= 5'd10,
		PL_CYCLE_X		= 5'd11,
		PL_CYCLE_M		= 5'd12,
		PL_CYCLE_C		= 5'd13,

		ALL_CYCLE_DELETE= 5'd14;
		
	reg frame;
	reg [23:0] count;
	reg [23:0] count2;
	reg [23:0] count3;
	reg [2:0] current_state_all, next_state_all;
/* 	reg [2:0] current_state_left, next_state_left;
	reg [2:0] current_state_right, next_state_right; */	
//TO DO;
// delteALL
// countR,countL
// goTimeL,goTimeR	
	reg goTime;
    always@(*)
        begin: ball_states
			case (current_state_all)
				PL_CYCLE_D:			next_state_all = ( ( countL==5'd16 ) ? ( deleteAll ? PR_CYCLE_D : PL_CYCLE_X ): PL_CYCLE_D );
				PL_CYCLE_X:			next_state_all = PL_CYCLE_M;
				PL_CYCLE_M:			next_state_all =  PL_CYCLE_C;
				PL_CYCLE_C:			next_state_all = ( countL==5'd16 ) ? ALL_CYCLE_WAIT : PL_CYCLE_C;
				//PR_CYCLE_WAIT:		next_state_left = resetGamen ? ( ( goTime ) ? ( PL_CYCLE_ d): PL_CYCLE_WAIT ) : ALL_CYCLE_DELETE;
				
				PR_CYCLE_D:			next_state_all = ( ( countR==5'd16 ) ? ( deleteAll ? ALL_CYCLE_START : PR_CYCLE_X ): PR_CYCLE_D );
				PR_CYCLE_X:			next_state_all = PR_CYCLE_M;
				PR_CYCLE_M:			next_state_all =  PR_CYCLE_C;
				PR_CYCLE_C:			next_state_all = ( countR==5'd16 ) ? ALL_CYCLE_WAIT : PR_CYCLE_C;
				//PR_CYCLE_WAIT:		next_state_all = resetGamen ? ( ( goTime ) ? ( PR_CYCLE_ d): PR_CYCLE_WAIT ) : ALL_CYCLE_DELETE;
				
				B_CYCLE_D:			next_state_all = ( ( counter==5'd16 ) ? ( deleteAll ? PL_CYCLE_D : B_CYCLE_X ): B_CYCLE_D );
				B_CYCLE_X:			next_state_all = B_CYCLE_M;
				B_CYCLE_M:			next_state_all =  B_CYCLE_C;
				B_CYCLE_C:			next_state_all = ( counter==5'd16 ) ? ALL_CYCLE_WAIT : B_CYCLE_C;
				
				ALL_CYCLE_WAIT:  	next_state_all = resetGamen ? ( ( goTime ) ? ( B_CYCLE_D ): ( ( goTimeL ) ? PL_CYCLE_D : ( ( goTimeR ) ? PR_CYCLE_D : ALL_CYCLE_WAIT ) ) ): ALL_CYCLE_DELETE;
				ALL_CYCLE_DELETE 	next_state_all = B_CYCLE_D;
				ALL_CYCLE_START:  	next_state_all = resetGamen ? B_CYCLE_C  : ALL_CYCLE_START;
				
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
		if(count != 0) begin
		count <= count-1;
		goTime <=0;
		end
		else begin
		//count <= 24'b101111101011111000101101;//Frame +35 clocks
		count <= 24'b100011110000111010100010;//9375394
		//count <= 24'b010111110101111100010111;
		//count <= 24'b001111111001010010111010;
		//count <= 24'b001011111010111110001011;
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
		if(count2 != 0) begin
		count2 <= count2-1;
		goTimeL <=0;
		end
		else begin
		//count2 <= 24'b101111101011111000101101;//Frame +35 clocks
		//count2 <= 24'b100011110000111010100010;//9375394
		count2 <= 24'b010111110101111100010111;
		//count2 <= 24'b001111111001010010111010;
		//count2 <= 24'b001011111010111110001011;
		goTimeL <=1;
		end
        
    end
	
	    always @ (posedge clk)
    begin//Go time right paddle
		if(count3 != 0) begin
		count3 <= count3-1;
		goTimeR <=0;
		end
		else begin
		count3 <= 24'b101111101011111000101101;//Frame +35 clocks
		//count3 <= 24'b100011110000111010100010;//9375394
		//count3 <= 24'b010111110101111100010111;
		//count3 <= 24'b001111111001010010111010;
		//count3 <= 24'b001011111010111110001011;
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
	
	reg deleteAll;
	reg check;
    always @(*)
    begin//Flags and signals for ball
		delete=1'b0;
		waiting=1'b0;
		create=1'b0;
		plot=1'b0;
		reset=1'b0;
		move=1'b0;
		check=1'b0;
		deleteAll=1'b0;
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
			delete=1;
			plot=1;			 
		end
		PL_CYCLE_X: begin // Do A <- A * x 
			check=1;//local
		end
		PL_CYCLE_M: begin //Move	
			move = 1 ;		
		end
		PL_CYCLE_C: begin // create
			create=1;
			plot=1; 
		end
		
		PR_CYCLE_D: begin // delete
			delete=1;
			plot=1;			 
		end
		PR_CYCLE_X: begin // Do A <- A * x 
			check=1;//local
		end
		PR_CYCLE_M: begin //Move
			move = 1 ;		
		end
		PR_CYCLE_C: begin // create
			create=1;
			plot=1; 
		end
		
		
		ALL_CYCLE_WAIT: begin //Wait and show off all
			waiting=1;
		end

		ALL_CYCLE_START:begin
			reset=1;
		end   
		ALL_CYCLE_DELETE:begin
			deleteAll=1;//local
		end    
		endcase
	end // enable_signals

	always@(posedge clk)
		begin: state_FFs
			if( current_state_all == B_CYCLE_C || current_state_all ==B_CYCLE_D ) counter <= counter + 1;
			else counter <= 0;
			if( current_state_all == B_CYCLE_X )
			begin
				if(wall)
				begin
					dy <= -dy;
				end
				if(wall_l)
				begin
					dx <= -dx;
				end
				if(wall_r)
				begin
					dx <= -dx;
				end
			end
			if( current_state_all == ALL_CYCLE_START )
			begin
				dx <= 8'b11111110;
				dy <= 7'b0000010;
			end
			current_state_all <= next_state_all;
		end
		
	endmodule
                
                
module datapath(
    input clk,
	input [7:0] dx,
	input [6:0] dy,
	input reset,waiting,create,delete,move,
	input [3:0] counter,
	countL,countR,
	input [2:0] c,
    output reg [7:0] x_r,
    output reg [6:0] y_r,
    output reg [2:0] c_o,
    output reg wall,
    output reg wall_l,
	output reg wall_r
    );
    reg [7:0] x;
    reg [6:0] y;
    always@(posedge clk) begin
		if(delete)//delete
		begin
			if( (y >= 7'd116 && dy <= 7'b0111111) || (y <= 7'd0 && dy > 7'b0111111)) wall <= 1; 
			if (x >= 8'd156 && dx <= 8'b01111111) wall_r <= 1;
			if (x <= 8'd0 && dx > 8'b01111111)  wall_l <= 1;
			x_r <= x + counter[1:0];
			y_r <= y + counter[3:2];
			c_o = 3'b000;
		end 
        
		if(move)//Move
		begin
			x <= x+dx;
			y <= y+dy;
			wall_l <= 0;
			wall_r <= 0;
			wall <= 0;
		end
		
		if(create)//create
		begin
			x_r <= x + counter[1:0];
			y_r <= y + counter[3:2];
			c_o = c;
		end
		
		if(reset)
		begin
		wall_l <= 0;
		wall_r <= 0;
		wall <= 0;
		x <= 8'd156;
		y <= 7'd0;
		x_r <= 8'd156;
		y_r <= 7'd0;
		c_o= c;
		end

		if(waiting)
		begin
			

		end
		/* if(check)

		begin
			if( (y >= 7'd116 && dy <= 7'b0111111) || (y <= 7'd0 && dy > 7'b0111111)) wall <= 1; 
			if (x >= 8'd156 && dx <= 8'b01111111) wall_r <= 1;
			if (x <= 8'd0 && dx > 8'b01111111)  wall_l <= 1;

		end */

		end

endmodule