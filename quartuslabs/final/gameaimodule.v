


module bosses (input paddle_l, paddle_r, input [7:0] x, dx, x_lp, x_rp, input [6:0] y, dy, y_lp, y_rp, input [2:0] player__id, input [3]SW, input [1:0] KEY, output reg go_r, speed_r, up_r, down_r);
	reg paddle_l_hold;
	reg [6:0] hold_y_lp;
	always @(*)
		if (player_id == 3'b000)
			begin
				assign speed_r = ~KEY[1];
				assign up_r = SW[3];
				assign down_r = ~SW[3];
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
			end
				
				
					
/* 			end
		else if (player_id == 3'b010)
			begin
			
			end
		else if (player_id == 3'b011)
			begin
			
			end
		else if (player_id == 3'b100)
			begin
			
			end
		else if (player_id == 3'b101)
			begin
			
			end
		else if (player_id == 3'b110)
			begin
			
			end
		else if (player_id == 3'b111)
			begin
			
			end */