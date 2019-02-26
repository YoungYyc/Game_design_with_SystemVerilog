//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  ball ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
					input [3:0]   KEY,				 	//keyboard inputs
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
					input [9:0]   floor_x[5],
					input [9:0]   floor_y[5],
					input [3:0]   ra_flag_1, ra_flag_2,
					output logic  [2:0]is_floor,				//whether it is floor
					output logic  [18:0] stand_read_address,			// draw the player
					output logic  [18:0] floor_read_address,			// draw the player
					output logic  is_player,
					output [3:0]  random1, random2
              );
    

	 
	 ///////////player information////////////////////
	 parameter [9:0] player_x_size = 30;
	 parameter [9:0] player_y_size = 45;
    parameter [9:0] player_x_center=160;  // Center position on the X axis
    parameter [9:0] player_y_center=100;  // Center position on the X axis
    parameter [9:0] player_x_min=0;       // Leftmost point on the X axis
    parameter [9:0] player_x_max=319;     // Rightmost point on the X axis
    parameter [9:0] player_y_min=0;       // Topmost point on the Y axis
    parameter [9:0] player_y_max=479;     // Bottommost point on the Y axis
    parameter [9:0] player_x_step=3;      // Step size on the X axis
    parameter [9:0] player_y_step=2;      // Step size on the Y axis
	 parameter [9:0] floor_step=1;
	 parameter [9:0] spike_height = 35;
	 parameter [9:0] drop_height = 60;

	 logic [9:0] floor_1_X;  //first floor
    logic [9:0] floor_1_Y;
	 
    logic [9:0] floor_2_X;  //second floor
    logic [9:0] floor_2_Y;
	 
    logic [9:0] floor_3_X;  //third floor
    logic [9:0] floor_3_Y;
	 	 
    logic [9:0] floor_4_X;  //forth floor
    logic [9:0] floor_4_Y;
	 
	 logic [9:0] floor_5_X;  //forth floor
    logic [9:0] floor_5_Y;
	 
	 assign floor_1_X = floor_x[0];
	 assign floor_2_X = floor_x[1];
	 assign floor_3_X = floor_x[2];
	 assign floor_4_X = floor_x[3];
	 assign floor_5_X = floor_x[4];
	 assign floor_1_Y = floor_y[0];
	 assign floor_2_Y = floor_y[1];
	 assign floor_3_Y = floor_y[2];
	 assign floor_4_Y = floor_y[3];
	 assign floor_5_Y = floor_y[4];
	 
    parameter [9:0] floor_X_size=90;  //floor size parameter
    parameter [9:0] floor_Y_size=20;
	 parameter [9:0] jump_boundary = 75;
	 logic on_jump_floor;
	 logic jump_state;
	 logic [1:0]on_belt_floor;
	 logic [9:0] belt_step;			//belt speed on belt floor  
	 logic [9:0] jump_step;   //jump height on bounce floor 
	 logic is_spiked;   //is player is spiked by top spike
	 logic is_spiked_buf;
	 

	 ////////////player postion control////////////////
    logic [9:0] player_x_pos, player_x_motion, player_y_pos, player_y_motion;
    logic [9:0] player_x_pos_in, player_x_motion_in, player_y_pos_in, player_y_motion_in;	 
	 logic [1:0] direction;		//ball control movement direction [1] left [0] right;
    
    //////// Do not modify the always_ff blocks. ////////
    // Detect rising edge of frame_clk
    logic frame_clk_delayed;
    logic frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
		  direction[1] <= ~KEY[3];
		  direction[0] <= ~KEY[2];
    end
    assign frame_clk_rising_edge = (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    // Update ball position and motion
    always_ff @ (posedge Clk)
    begin
        if (Reset)
        begin
				/////////palyer initial//////////
            player_x_pos <= player_x_center;
            player_y_pos <= player_y_center;
            player_x_motion <= 10'd0;
            player_y_motion <= 10'd0;
				random1 <= 0;
				random2 <= 0;
				is_spiked <= is_spiked_buf;
        end
        else if (frame_clk_rising_edge)        // Update only at rising edge of frame clock
        begin
            player_x_pos <= player_x_pos_in;
            player_y_pos <= player_y_pos_in;
            player_x_motion <= player_x_motion_in;
            player_y_motion <= player_y_motion_in;
				jump_state <= on_jump_floor;
				random1 <= ra_flag_1;
				random2 <= ra_flag_2;
				is_spiked <= is_spiked_buf;
        end
        // By defualt, keep the register values.
    end
    
    // You need to modify always_comb block.
    always_comb
    begin
        // Update the ball's position with its motion
        player_x_pos_in = player_x_pos + player_x_motion;
        player_y_pos_in = player_y_pos + player_y_motion;
		  is_spiked_buf = 0;
          
        // Be careful when using comparators with "logic" datatype because compiler treats 
        //   both sides of the operator UNSIGNED numbers. (unless with further type casting)
        // e.g. player_y_pos - player_y_size <= player_y_min 
        // If player_y_pos is 0, then player_y_pos - player_y_size will not be -4, but rather a large positive number.
        if( player_y_pos + player_y_size >= player_y_max )  // Ball is at the bottom edge
		  begin
				is_spiked_buf = 0;
            player_y_pos_in = player_y_min;  // 2's complement. 
		  end	
		  else if( player_y_pos <= spike_height)  // Ball is at the bottom edgedddd
		  begin
				is_spiked_buf = 1;
            player_y_pos_in = player_y_pos + player_y_step;  // 2's complement. 
		  end
		  else if( player_y_pos >= 0 && player_y_pos <= spike_height + drop_height && is_spiked == 1) 
		  begin
				is_spiked_buf = 1;
            player_y_pos_in = player_y_pos + player_y_step;  // 2's complement. 
		  end
		  else if(player_y_pos >= spike_height + drop_height && is_spiked == 1) 
		  begin
				is_spiked_buf = 0;
            player_y_pos_in = player_y_pos + player_y_motion;  // 2's complement. 
		  end
        
        // TODO: Add other boundary conditions and handle keypress here.
		  if( (player_x_pos+player_x_size) >= player_x_max && direction[1:0]!=2'b10)  // player is at the right edge
            player_x_pos_in = player_x_pos;  // 2's complement.  
        else if ( player_x_pos <= (player_x_min+5) && direction[1:0]!=2'b01)  // player is at the left edge
            player_x_pos_in = player_x_pos;
				
        // By default, keep motion downwards
        player_x_motion_in = belt_step;
        player_y_motion_in = player_y_step + jump_step;			 
		  	
			//key input motions
			unique case(direction[1:0])
			2'b10:		//left, move left
			begin
					player_x_motion_in = -player_x_step + belt_step;
					//when ball is on belt floor 
			end			
			2'b01:		//right, move right
			begin
					player_x_motion_in = player_x_step + belt_step;
					//when ball is on belt floor 
			end
			default:
					player_x_motion_in = belt_step;
			endcase
			
			on_jump_floor = 0;
			on_belt_floor = 2'b00;
			//ball fall on floor
			if(is_spiked == 0 && player_y_pos + player_y_size-floor_1_Y >= 10'd0 && player_y_pos + player_y_size-floor_1_Y <= floor_Y_size && player_x_pos >= floor_1_X - player_x_size && player_x_pos <= floor_X_size + floor_1_X )
			begin
				player_y_pos_in = floor_1_Y - player_y_size - floor_step;
				player_y_motion_in = 10'd0;
			end
			else if(is_spiked == 0 && player_y_pos + player_y_size-floor_2_Y >= 10'd0 && player_y_pos + player_y_size-floor_2_Y <= floor_Y_size && player_x_pos >= floor_2_X - player_x_size && player_x_pos <= floor_X_size + floor_2_X  )
			begin
				on_belt_floor = 2'b01;
				player_y_pos_in = floor_2_Y - player_y_size - floor_step;
				player_y_motion_in = 10'd0;
			end
			else if(is_spiked == 0 && player_y_pos + player_y_size-floor_3_Y >= 10'd0 && player_y_pos + player_y_size-floor_3_Y <= floor_Y_size && player_x_pos >= floor_3_X - player_x_size && player_x_pos <= floor_X_size + floor_3_X  )
			begin
				on_belt_floor = 2'b10;
				player_y_pos_in = floor_3_Y - player_y_size - floor_step;
				player_y_motion_in = 10'd0;
			end
			else if(is_spiked == 0 && player_y_pos + player_y_size-floor_4_Y >= 10'd0 && player_y_pos + player_y_size-floor_4_Y <= floor_Y_size && player_x_pos >= floor_4_X - player_x_size && player_x_pos <= floor_X_size + floor_4_X  )
			begin
				on_jump_floor = 1;
				//player_y_pos_in = floor_4_Y - player_y_size - floor_step;
				//player_y_motion_in = 10'd0;
			end
			else if(is_spiked == 0 && player_y_pos + player_y_size-floor_5_Y >= 10'd0 && player_y_pos + player_y_size-floor_5_Y <= floor_Y_size && player_x_pos >= floor_5_X - player_x_size && player_x_pos <= floor_X_size + floor_5_X  )
			begin
				on_jump_floor = 1;
				//player_y_pos_in = floor_5_Y - player_y_size - floor_step;
				//player_y_motion_in = 10'd0;
			end
			else if(is_spiked == 0 && floor_4_Y - player_y_pos  >= 10'd0 && floor_4_Y - player_y_pos <= jump_boundary && player_x_pos >= floor_4_X - player_x_size && player_x_pos <= floor_X_size + floor_4_X  )
			begin
				on_jump_floor = jump_state;
				//player_y_pos_in = floor_4_Y - player_y_size - floor_step;
				//player_y_motion_in = 10'd0;
			end
			else if(is_spiked == 0 && floor_5_Y - player_y_pos  >= 10'd0 && floor_5_Y - player_y_pos <= jump_boundary && player_x_pos >= floor_5_X - player_x_size && player_x_pos <= floor_X_size + floor_5_X  )
			begin
				on_jump_floor = jump_state;
				//player_y_pos_in = floor_5_Y - player_y_size - floor_step;
				//player_y_motion_in = 10'd0;
			end

        
    /**************************************************************************************
        ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
        Hidden Question #2/2:
          Notice that player_y_pos is updated using player_y_motion. 
          Will the new value of player_y_motion be used when player_y_pos is updated, or the old? 
          What is the difference between writing
            "player_y_pos_in = player_y_pos + player_y_motion;" and 
            "player_y_pos_in = player_y_pos + player_y_motion_in;"?
          How will this impact behavior of the ball during a bounce, and how might that interact with a response to a keypress?
          Give an answer in your Post-Lab.
    **************************************************************************************/

				
		//draw the player
		if(DrawX-player_x_pos >= 10'd0 && DrawX-player_x_pos <= player_x_size && DrawY-player_y_pos >= 10'd0 && DrawY-player_y_pos <= player_y_size)
		begin
				stand_read_address = (DrawX-player_x_pos) + (DrawY-player_y_pos)*player_x_size;
				is_player = 1;
		end
		else
		begin 
				is_player = 0;
				stand_read_address = 0;
		end
				
        
        /* The ball's (pixelated) circle is generated using the standard circle formula.  Note that while 
           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
           of the 12 available multipliers on the chip! */
			  
		 if(DrawX-floor_1_X >= 10'd0 && DrawX-floor_1_X <= floor_X_size && DrawY-floor_1_Y >= 10'd0 && DrawY-floor_1_Y <= floor_Y_size)
		 begin
			floor_read_address = (DrawX-floor_1_X) + (DrawY-floor_1_Y)*floor_X_size;
			is_floor = 3'b001;
		 end
		 else if(DrawX-floor_2_X >= 10'd0 && DrawX-floor_2_X <= floor_X_size && DrawY-floor_2_Y >= 10'd0 && DrawY-floor_2_Y <= floor_Y_size)
		 begin
		   floor_read_address = (DrawX-floor_2_X) + (DrawY-floor_2_Y)*floor_X_size;
			is_floor = 3'b010;
		 end
		 else if(DrawX-floor_3_X >= 10'd0 && DrawX-floor_3_X <= floor_X_size && DrawY-floor_3_Y >= 10'd0 && DrawY-floor_3_Y <= floor_Y_size)
		 begin
		   floor_read_address = (DrawX-floor_3_X) + (DrawY-floor_3_Y)*floor_X_size;
			is_floor = 3'b011;
		 end
		 else if(DrawX-floor_4_X >= 10'd0 && DrawX-floor_4_X <= floor_X_size && DrawY-floor_4_Y >= 10'd0 && DrawY-floor_4_Y <= floor_Y_size)
		 begin
		   floor_read_address = (DrawX-floor_4_X) + (DrawY-floor_4_Y)*floor_X_size;
			is_floor = 3'b100;
		 end
		 else if(DrawX-floor_5_X >= 10'd0 && DrawX-floor_5_X <= floor_X_size && DrawY-floor_5_Y >= 10'd0 && DrawY-floor_5_Y <= floor_Y_size)
		 begin
		   floor_read_address = (DrawX-floor_5_X) + (DrawY-floor_5_Y)*floor_X_size;
			is_floor = 3'b101;
		 end 
		else 
		begin
			floor_read_address = 0;
			is_floor = 3'b000;
		end
			
			
		////////////////////conditions on differet floors //////////////
		belt_step = 0;
		jump_step = 0;
		if(on_belt_floor == 2'b01 )
			belt_step = 2;
		if(on_belt_floor == 2'b10 )
			belt_step = -2;
		if(jump_state == 1)
			jump_step = -6;
	
        
    end
    
endmodule
