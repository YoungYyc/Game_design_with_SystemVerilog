//-------------------------------------------------------------------------
//      lab8.sv                                                          --
//      Christine Chen                                                   --
//      Fall 2014                                                        --
//                                                                       --
//      Modified by Po-Han Huang                                         --
//      10/06/2017                                                       --
//                                                                       --
//      Fall 2017 Distribution                                           --
//                                                                       --
//      For use with ECE 385 Lab 8                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module lab8( input               CLOCK_50,
             input        [3:0]  KEY,          //bit 0 is set up as Reset
				 input		  	[2:0]SW,
             output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
             // VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
             // CY7C67200 Interface
             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             input               OTG_INT,      //CY7C67200 Interrupt
             // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK	      //SDRAM Clock
                    );
    
    logic Reset_h, Clk;
    logic [15:0] keycode;
    logic left, right;
	 logic game_start, game_enter, game_exit;
    assign Clk = CLOCK_50;
    always_ff @ (posedge Clk) begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
		  left <= ~KEY[3];
		  right <= ~KEY[2];
		  game_start <= SW[0];
		  game_enter <= SW[1];
		  game_exit <= SW[2];
		  
    end
    
    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w, hpi_cs;
    
    // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
                            .Clk(Clk),
                            .Reset(Reset_h),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in),
                            .from_sw_data_out(hpi_data_out),
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),    
                            .OTG_RST_N(OTG_RST_N)
    );
     logic [31:0] FLOOR_EXPORT_DATA;
     // You need to make sure that the port names here match the ports in Qsys-generated codes.
     nios_system nios_system(
                             .clk_clk(Clk),         
                             .reset_reset_n(1'b1),    // Never reset NIOS
                             .sdram_wire_addr(DRAM_ADDR), 
                             .sdram_wire_ba(DRAM_BA),   
                             .sdram_wire_cas_n(DRAM_CAS_N),
                             .sdram_wire_cke(DRAM_CKE),  
                             .sdram_wire_cs_n(DRAM_CS_N), 
                             .sdram_wire_dq(DRAM_DQ),   
                             .sdram_wire_dqm(DRAM_DQM),  
                             .sdram_wire_ras_n(DRAM_RAS_N),
                             .sdram_wire_we_n(DRAM_WE_N), 
                             .sdram_clk_clk(DRAM_CLK),
                             .keycode_export(keycode),  
                             .otg_hpi_address_export(hpi_addr),
                             .otg_hpi_data_in_port(hpi_data_in),
                             .otg_hpi_data_out_port(hpi_data_out),
                             .otg_hpi_cs_export(hpi_cs),
                             .otg_hpi_r_export(hpi_r),
                             .otg_hpi_w_export(hpi_w),
									 
    );
  
    // Use PLL to generate the 25MHZ VGA_CLK. Do not modify it.
    // vga_clk vga_clk_instance(
    //     .clk_clk(Clk),
    //     .reset_reset_n(1'b1),
    //     .altpll_0_c0_clk(VGA_CLK),
    //     .altpll_0_areset_conduit_export(),    
    //     .altpll_0_locked_conduit_export(),
    //     .altpll_0_phasedone_conduit_export()
    // );
    always_ff @ (posedge Clk) begin
        if(Reset_h)
            VGA_CLK <= 1'b0;
        else
            VGA_CLK <= ~VGA_CLK;
    end
    
    // TODO: Fill in the connections for the rest of the modules 
	 logic [9:0] DrawX, DrawY;
	 logic [2:0]is_floor;
    VGA_controller vga_controller_instance(.Reset(Reset_h), .*);
	 
    logic [9:0] floor_x[5];
	 logic [9:0] floor_y[5];
	 logic [18:0] stand_read_address;
	 logic [4:0] stand_data_out;
	 logic [18:0] floor_read_address;
	 logic [4:0] floor_data_out;
	 logic  is_player;
	 logic [18:0] bg_read_address;
	 logic [4:0] bg_data_out;
	 logic [1:0]is_bg;
	 logic [3:0]random1, random2;
	 logic [3:0]ra_flag_1, ra_flag_2;

    // Which signal should be frame_clk?
	 floor floor_instance(.Reset(~(KEY[1])), .frame_clk(VGA_VS), .*); 
    ball ball_instance(.Reset(~(KEY[1])), .frame_clk(VGA_VS), .KEY, .*);
    
	 standROM stand(.*);
	 floorROM floor(.*);
	 bgCreate bg_create(.*);
 	 //bgROM bg(.*);
    color_mapper color_instance(.*);
    
	 //score keeping
	 logic [3:0]score0, score1, score2, score3;
	 logic is_char;
	 logic [3:0] char_idx;
	 logic[18:0] char_read_address;
	 logic [4:0] char_data_out;
	 score_keeper score_player1(.Reset(~(KEY[1])),.*);
	 scoreboard board (.*);
	 charROM character (.*);
    // Display keycode on hex display
    HexDriver hex_inst_0 (right, HEX0);
    HexDriver hex_inst_1 (left, HEX1);
	 HexDriver hex_inst_2 (score0, HEX2);
	 HexDriver hex_inst_3 (score1, HEX3);
	 HexDriver hex_inst_4 (score2, HEX4);
	 HexDriver hex_inst_5 (score3, HEX5);
	 HexDriver hex_inst_6 (game_state[0], HEX6);
	 HexDriver hex_inst_7 (game_state[1], HEX7);
	 
	 /////////////////game state controller////////////////
	 logic [1:0] game_state;
	 state_controller game_controller(.Reset(Reset_h), .*);
	 
	 
	 //////////////sound control/////////////
	 
	 	logic [15:0] LDATA, RDATA;
		logic  INIT;
		logic	INIT_FINISH;
		logic	adc_full;
		logic	data_over;
		logic	AUD_MCLK;
		logic	AUD_BCLK;
		logic	AUD_ADCDAT;
		logic	AUD_DACDAT;
		logic	AUD_DACLRCK, AUD_ADCLRCK;
		logic	I2C_SDAT;
		logic	I2C_SCLK;
		logic	ADCDATA;
	 	 	 
	   //audio_interface audio(.*);
    
    /**************************************************************************************
        ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
        Hidden Question #1/2:
        What are the advantages and/or disadvantages of using a USB interface over PS/2 interface to
             connect to the keyboard? List any two.  Give an answer in your Post-Lab.
    **************************************************************************************/
endmodule

