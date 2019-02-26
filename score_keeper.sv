module score_keeper (input   Clk,
							input   Reset,
							output	[3:0]score0, score1, score2, score3,
							output 	[3:0]ra_flag_1, ra_flag_2);

							
	logic [50:0]cur_score;
	logic [50:0]next_score;
	logic [15:0]score_buf;
   logic frame_clk_delayed;
   logic frame_clk_rising_edge;
	always_ff @ (posedge Clk)
	begin
		if(Reset)
			cur_score <= 0;
		else
			cur_score <= next_score;
	end
	
	always_comb
	begin 
		next_score = cur_score + 1;
		score_buf = cur_score[40:25];
		score0 = score_buf%10;
		score1 = (score_buf%100)/10;
		score2 = (score_buf%1000)/100;
		score3 = (score_buf%10000)/1000;
		ra_flag_1 = cur_score[11:8];
		ra_flag_2 = cur_score[7:4];
		
	end
endmodule
