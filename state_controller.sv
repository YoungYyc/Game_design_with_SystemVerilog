////////////////state controller///////////////

module state_controller (input   Clk,
								input   Reset,
								input   game_enter,
								input   game_exit,
								input   game_start,
								output	[1:0] game_state);
								
							
							
					
 enum logic [2:0] {pre_game,
							in_game,
							post_game
							}cur_state, next_state;
							
							
always_ff @ (posedge Clk)
begin 
		if(Reset)
			cur_state <= pre_game;
		else
			cur_state <= next_state;
end

always_comb
begin
	next_state = cur_state;
	unique case(cur_state)
		pre_game: 
			if(game_enter == 1)
				next_state = in_game;
		in_game:
			if(game_exit == 1)
				next_state = post_game;
		post_game:
			if(game_start == 1)
				next_state = pre_game;
		default: ;
	endcase
	
	case(cur_state)
		pre_game:
			game_state = 2'b00;
		in_game:
			game_state = 2'b01;
		post_game:
			game_state = 2'b10;
		default: ;
	endcase
end
endmodule
