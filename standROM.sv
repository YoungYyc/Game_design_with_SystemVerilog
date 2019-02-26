/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module standROM
(
		input [18:0] stand_read_address,
		input Clk,

		output logic [4:0] stand_data_out
);

// mem has width of 4 bits and a total of 600 addresses
logic [4:0] mem [0:1349];

initial
begin
	 $readmemh("./ECE385-HelperTools-master/PNG To Hex/On-Chip Memory/sprite_bytes/stand2.txt", mem);
end


always_ff @ (posedge Clk) begin
	stand_data_out<= mem[stand_read_address];
end

endmodule
