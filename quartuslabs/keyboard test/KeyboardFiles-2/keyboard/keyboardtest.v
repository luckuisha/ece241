
`timescale 1ns / 1ns // `timescale time_unit/time_precision


module keyboardtest(CLOCK_50, SW, PS2_DAT, PS2_CLK, HEX0, HEX1);

	input CLOCK_50;
	input [9:0] SW;
	output [6:0] HEX0, HEX1;
	
	inout PS2_DAT, PS2_CLK;
	
	wire  makeBreak, valid;
	wire  reset; 
	wire [7:0] character;
	
	
	wire command_was_sent, error_communication_timed_out, received_data_en;	
	
	assign reset = SW[9];
	
 PS2_Controller psC(
		// Inputs
		CLOCK_50,
		reset,
		(8'b00000000),
		(1'b0),

		// Bidirectionals
		PS2_CLK,					// PS2 Clock
		PS2_DAT,					// PS2 Data

		// Outputs
		command_was_sent,
		error_communication_timed_out,

		character,
		received_data_en			// If 1 - new data has been received
	); 
	
	hex_decoder h2(character[3:0], HEX0);
	hex_decoder h3(character[7:4], HEX1);
		
endmodule

module hex_decoder(input [3:0]a, output reg [6:0]f);
    always @(*)    
    begin    
        case(a[3:0])
        
            //Multiplexes
            
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
