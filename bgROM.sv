/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

 //background ROM
module bgROM
(
		input [18:0] bg_read_address,
		input Clk,

		output logic [4:0] bg_data_out
);

// mem has width of 4 bits and a total of 600 addresses
logic [4:0] mem [0:153599];

initial
begin
	 $readmemh("./ECE385-HelperTools-master/PNG To Hex/On-Chip Memory/sprite_bytes/nice_bg.txt", mem);
end


always_ff @ (posedge Clk) begin
	bg_data_out<= mem[bg_read_address];
end


endmodule
