/////////////character////////


 //char ROM
module charROM
(
		input [18:0] char_read_address,
		input [3:0]  char_idx,
		input Clk,

		output logic [4:0] char_data_out
);

// mem has width of 4 bits and a total of 600 addresses
logic [4:0] mem_0 [0:1349];
logic [4:0] mem_1 [0:1349];
logic [4:0] mem_2 [0:1349];
logic [4:0] mem_3 [0:1349];
logic [4:0] mem_4 [0:1349];
logic [4:0] mem_5 [0:1349];
logic [4:0] mem_6 [0:1349];
logic [4:0] mem_7 [0:1349];
logic [4:0] mem_8 [0:1349];
logic [4:0] mem_9 [0:1349];
logic [4:0] mem_heart [0:1349];
logic [4:0] mem_half_heart [0:1349];


initial
begin
	 $readmemh("./ECE385-HelperTools-master/PNG To Hex/On-Chip Memory/sprite_bytes/0.txt", mem_0);
	 $readmemh("./ECE385-HelperTools-master/PNG To Hex/On-Chip Memory/sprite_bytes/1.txt", mem_1);
	 $readmemh("./ECE385-HelperTools-master/PNG To Hex/On-Chip Memory/sprite_bytes/2.txt", mem_2);
	 $readmemh("./ECE385-HelperTools-master/PNG To Hex/On-Chip Memory/sprite_bytes/3.txt", mem_3);
	 $readmemh("./ECE385-HelperTools-master/PNG To Hex/On-Chip Memory/sprite_bytes/4.txt", mem_4);
	 $readmemh("./ECE385-HelperTools-master/PNG To Hex/On-Chip Memory/sprite_bytes/5.txt", mem_5);
	 $readmemh("./ECE385-HelperTools-master/PNG To Hex/On-Chip Memory/sprite_bytes/6.txt", mem_6);
	 $readmemh("./ECE385-HelperTools-master/PNG To Hex/On-Chip Memory/sprite_bytes/7.txt", mem_7);
	 $readmemh("./ECE385-HelperTools-master/PNG To Hex/On-Chip Memory/sprite_bytes/8.txt", mem_8);
	 $readmemh("./ECE385-HelperTools-master/PNG To Hex/On-Chip Memory/sprite_bytes/9.txt", mem_9);
	 $readmemh("./ECE385-HelperTools-master/PNG To Hex/On-Chip Memory/sprite_bytes/heart.txt", mem_heart);
	 $readmemh("./ECE385-HelperTools-master/PNG To Hex/On-Chip Memory/sprite_bytes/half_heart.txt", mem_half_heart); 

end


always_ff @ (posedge Clk) begin
	if(char_idx == 0)
		char_data_out<= mem_0[char_read_address];
	else if(char_idx == 1)
		char_data_out<= mem_1[char_read_address];
	else if(char_idx == 2)
		char_data_out<= mem_2[char_read_address];
	else if(char_idx == 3)
		char_data_out<= mem_3[char_read_address];
	else if(char_idx == 4)
		char_data_out<= mem_4[char_read_address];
	else if(char_idx == 5)
		char_data_out<= mem_5[char_read_address];
	else if(char_idx == 6)
		char_data_out<= mem_6[char_read_address];
	else if(char_idx == 7)
		char_data_out<= mem_7[char_read_address];
	else if(char_idx == 8)
		char_data_out<= mem_8[char_read_address];
	else if(char_idx == 9)
		char_data_out<= mem_9[char_read_address];
	else if(char_idx == 10)
		char_data_out<= mem_heart[char_read_address];
	else if(char_idx == 11)
		char_data_out<= mem_half_heart[char_read_address];
	else 
		char_data_out<=0;
	
end


endmodule
