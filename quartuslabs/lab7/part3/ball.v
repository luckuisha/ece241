
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
    assign resetn = KEY[0];
	assign c = SW[2:0];
    
    // Create the colour, x, y and writeEn wires that are inputs to the controller.

    wire [7:0] x;  //0-159
    wire [6:0] y;  //0-119
    wire plot;
    wire wall,wall2,dx,dy,reset,waiting,create,move,commute;
    wire [4:0] counter;
    wire writeEn;
    wire [7:0] x_r;
    wire [6:0] y_r;
    wire [2:0] c_o; 	
    control c0(CLOCK_50, resetn, 1'b0, 1'b0, dx, dy, reset, writeEn,waiting,create,counter,move,commute);
	datapath d0(
				CLOCK_50,dx, dy, reset,waiting,create,move,commute,
				counter,
				c,
				x_r,
				y_r,
				c_o,
				wall,
				wall2
				);
/*    input clk,dx, dy, reset,waiting,create,move,commute,
	input [4:0] counter,
	input [2:0] c,
    output reg [7:0] x_r,
    output reg [6:0] y_r,
    output reg [2:0] c_o,
    output reg wall,
    output reg wall2*/
    
    // Create an Instance of a VGA controller - there can be only one!
    // Define the number of colours as well as the initial background
    // image file (.MIF) for the controller.
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
        defparam VGA.RESOLUTION = "160x120";
        defparam VGA.MONOCHROME = "FALSE";
        defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
        defparam VGA.BACKGROUND_IMAGE = "black.mif";
            
    // Put your code here. Your code should produce signals x,y,colour and writeEn
    // for the VGA controller, in addition to any other functionality your design may require.
    
    
endmodule

module control(input  clk, resetn, wall, wall2, output reg dx, dy, reset, plot,waiting,create,counter,move,commute);
    localparam  S_CYCLE_0       = 5'd0,
                S_CYCLE_0m       = 5'd1,
                S_CYCLE_0c       = 5'd2,
					S_CYCLE_0_WAIT	 = 5'd3,	

                S_CYCLE_1       = 5'd4,
                S_CYCLE_1m       = 5'd5,
                S_CYCLE_1c      = 5'd6,
					S_CYCLE_1_WAIT =5'd7,

                S_CYCLE_2       = 5'd8,
                S_CYCLE_2m       = 5'd9,
                S_CYCLE_2c       = 5'd10,
				S_CYCLE_2_WAIT  =5'd11,

                S_CYCLE_3       = 5'd12,
                S_CYCLE_3m       = 5'd13,
                S_CYCLE_3c      = 5'd14,
				S_CYCLE_3_WAIT = 5'd15,
				 
				S_CYCLE_4       = 5'd16;
    reg [1:0] current_state, next_state; 
	reg goTime;
    always@(*)
        begin: state_table 
                case (current_state)
                    S_CYCLE_0:        next_state = (wall2 ? S_CYCLE_1 :( ( counter==5'd16 ) ? ( resetn ? S_CYCLE_0m : S_CYCLE_4 ): S_CYCLE_0 ));
                    S_CYCLE_0m:       next_state =  S_CYCLE_0c;
                    S_CYCLE_0c:       next_state = ( counter==5'd16 ) ? S_CYCLE_0_WAIT : S_CYCLE_0c;
                    S_CYCLE_0_WAIT:    next_state = resetn ? (( goTime ) ? ( (wall) ? S_CYCLE_1 : S_CYCLE_0 ): S_CYCLE_0_WAIT ) : S_CYCLE_0;

                    S_CYCLE_1:        next_state = (wall2 ? S_CYCLE_2 : ( counter==5'd16 ) ? ( resetn ? S_CYCLE_1m : S_CYCLE_4 ): S_CYCLE_1  ) ;
                  	S_CYCLE_1m:       next_state =  S_CYCLE_1c;
                    S_CYCLE_1c:       next_state = ( counter==5'd16 ) ? S_CYCLE_1_WAIT : S_CYCLE_1c;
                    S_CYCLE_1_WAIT:    next_state = resetn ?(( goTime ) ? ( (wall) ? S_CYCLE_2 : S_CYCLE_1 ): S_CYCLE_1_WAIT ): S_CYCLE_1;

                    S_CYCLE_2:         next_state = (wall2 ? S_CYCLE_3 : ( counter==5'd16 ) ? ( resetn ? S_CYCLE_2m : S_CYCLE_4 ): S_CYCLE_2  )  ;
                    S_CYCLE_2m:         next_state =  S_CYCLE_2c;
                    S_CYCLE_2c:     next_state = ( counter==5'd16 ) ? S_CYCLE_2_WAIT : S_CYCLE_2c;    
                    S_CYCLE_2_WAIT:    next_state = resetn ?(( goTime ) ? ( (wall) ? S_CYCLE_3 : S_CYCLE_2 ): S_CYCLE_2_WAIT ): S_CYCLE_2;

                    S_CYCLE_3:         next_state = (wall2 ? S_CYCLE_0 : ( counter==5'd16 ) ? ( resetn ? S_CYCLE_3m : S_CYCLE_4 ): S_CYCLE_3  );
                    S_CYCLE_3m:        next_state =  S_CYCLE_3c;
                    S_CYCLE_3c:     next_state = ( counter==5'd16 ) ? S_CYCLE_3_WAIT : S_CYCLE_3c;
                    S_CYCLE_3_WAIT:    next_state = resetn ?(( goTime ) ? ( (wall) ? S_CYCLE_0 : S_CYCLE_3 ): S_CYCLE_3_WAIT ): S_CYCLE_3;

                    S_CYCLE_4:         next_state = resetn ? S_CYCLE_0_WAIT  : S_CYCLE_4;
                default:             next_state = S_CYCLE_0c ;
            endcase
        end // state_table
    reg frame;
    reg [19:0] count;
    always @ (posedge clk)
    begin
        if(count != 0) begin
        count <= count-1;
        frame <=0;
        end
        else begin
        count <= 20'b11001011011100110100;
        frame <=1;
        end
        
    end
    reg count1;
    always @ (posedge frame)
    begin
        if(count1 != 0) begin
        count1 <= count1-1;
        goTime <=0;
        end
        else begin
        count1 <= 4'd14;
        goTime <=1;
        end
        
    end
        
    always @(*)
    begin
        dx = 1'b0;
        dy = 1'b0;
        move=1'b0;
        waiting=1'b0;
        create=1'b0;
		plot=1'b0;
		reset=1'b0;
        case (current_state)
            S_CYCLE_0: begin // delete
                dx= 0;//0->- 1->+
                dy= 0;
                move=1;
                plot=1;
            end
            S_CYCLE_0m: //Move
            begin
                dx= 0;//0->- 1->+
                dy= 0;
                commute = 1 ;
            end
            S_CYCLE_0c: begin // create
                dx= 0;//0->- 1->+
                dy= 0;
                create=1;
                plot=1;
            end
            S_CYCLE_0_WAIT: begin // Do A <- A * x 
                waiting=1;
            end
            
            S_CYCLE_1: begin // Do A <- A * x 
                dx= 0;
                dy= 1;
                move=1;
            end
            S_CYCLE_1m: //Move
            begin
                dx= 0;//0->- 1->+
                dy= 1;
                commute = 1 ;
            end
            S_CYCLE_1c: begin // create
                dx= 0;//0->- 1->+
                dy= 1;
                create=1;
                plot=1;
            end
            S_CYCLE_1_WAIT: begin // Do A <- A * x 
                waiting=1;
            end
            
            S_CYCLE_2: begin // Do A <- A * x 
                dx= 1;
                dy= 1;
                move=1;
            end
            S_CYCLE_2m: //Move
            begin
                dx= 1;//0->- 1->+
                dy= 1;
                commute = 1 ;
            end
            S_CYCLE_2c: begin // create
                dx= 1;//0->- 1->+
                dy= 1;
                create=1;
                plot=1;
            end    
            S_CYCLE_2_WAIT: begin // Do A <- A * x 
                waiting=1;
            end
            
            S_CYCLE_3: begin // Do A <- A * x 
                dx= 1;
                dy= 0;
                move=1;
            end
            S_CYCLE_3m: //Move
            begin
                dx= 1;//0->- 1->+
                dy= 0;
                commute = 1 ;
            end
            S_CYCLE_3c: begin // create
                dx= 1;//0->- 1->+
                dy= 0;
                create=1;
                plot=1;
            end
            S_CYCLE_3_WAIT: begin // Do A <- A * x 
                waiting=1;
            end  
            
            S_CYCLE_4:
                reset=1;
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   

    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
        begin
            current_state <= S_CYCLE_4;
            counter <= 5'b00000;
        end
        else
        begin
            if( current_state != (S_CYCLE_0_WAIT && S_CYCLE_1_WAIT && S_CYCLE_2_WAIT && S_CYCLE_3_WAIT && S_CYCLE_4 && S_CYCLE_0m && S_CYCLE_1m && S_CYCLE_2m && S_CYCLE_3m)) counter <= counter + 1;
            current_state <= next_state;
            if( counter == 5'd16) 
            begin
                counter <= 5'b00000;
            end
        end
    end
endmodule
                


                
module datapath(
    input clk,dx, dy, reset,waiting,create,move,commute,
	input [4:0] counter,
	input [2:0] c,
    output reg [7:0] x_r,
    output reg [6:0] y_r,
    output reg [2:0] c_o,
    output reg wall,
    output reg wall2
    );
    reg [7:0] x;
    reg [6:0] y;
    always@(posedge clk) begin
        /*if(!resetn) begin
            x <= 8'd156; 
            y <= 7'd116;
            c_o <= c;
        end*/
            if(move)//delete
            begin
                wall<=0; 
                wall2<=0; 
                if( ((x+1 >= 7'd156 && dx) && (y+1 >= 6'd116 && dy)) || ( (x+1 >= 7'd156 && dx) && (y-1 <= 6'd0 && !dy) ) ||((x-1 <= 7'd0 && !dx) && (y-1 <= 6'd0 && !dy)) || ((x-1 <= 7'd0 && !dx) && (y+1 >= 6'd116 && dy))) wall2 <= 1; 
                else begin
                x_r <= x + counter[1:0];
                y_r <= y + counter[4:2];
                c_o = 3'b000;
                end
            end         
            if(commute)//move
            begin
					if(dx) x<= x+1;
					else x<= x-1;
					if(dy) y<=y+1;
					else y<=y-1;
            end
            if(create)//create
            begin
                wall<=0; 
                wall2<=0; 
                x_r <= x + counter[1:0];
                y_r <= y + counter[4:2];
                c_o = c;
                if( (x+1 >= 7'd156 && dx) || (x-1 <= 7'd0 && !dx) || (y+1 >= 6'd116 && dy) || (y-1 <= 6'd0 && !dy)) wall <= 1; 
            end

            if(reset)
            begin
            x <= 8'd156;
            y <= 7'd116;
				x_r <= 8'd156;
            y_r <= 7'd116;
            c_o= c;
            end

            /*if(waiting)

            begin

            c <= c+1;

            end*/

            end

endmodule