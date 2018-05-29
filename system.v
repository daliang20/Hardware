module system(
	//Clock Pins
	input			CLOCK_50,

	// DRAM PORTS
	output	[12:0]  DRAM_ADDR,
	output	[ 1:0]	DRAM_BA,
	output 			DRAM_CAS_N,
	output			DRAM_CKE,
	output			DRAM_CLK,
	output 			DRAM_CS_N,
	inout	[15:0]	DRAM_DQ,
	output			DRAM_LDQM,
	output			DRAM_RAS_N,
	output			DRAM_UDQM,
	output			DRAM_WE_N,

	// HEX Declarations
	output 		[0:6] 	HEX0,
	output 		[0:6] 	HEX1,
	output 		[0:6]	HEX2,
	output 		[0:6]	HEX3,
	output 		[0:6]	HEX4,
	output 		[0:6]	HEX5,

	//HPS DDR3 Declarations
	output	[14:0]	HPS_DDR3_ADDR,
	output	[2:0]	HPS_DDR3_BA,
	output			HPS_DDR3_CAS_N,
	output			HPS_DDR3_CKE,
	output			HPS_DDR3_CK_N,
	output			HPS_DDR3_CK_P,
	output			HPS_DDR3_CS_N,
	output	[3:0]	HPS_DDR3_DM,
	inout	[31:0]	HPS_DDR3_DQ,
	inout	[3:0]	HPS_DDR3_DQS_N,
	inout	[3:0]	HPS_DDR3_DQS_P,
	output			HPS_DDR3_ODT,
	output			HPS_DDR3_RAS_N,
	output			HPS_DDR3_RESET_N,
	input			HPS_DDR3_RZQ,
	output			HPS_DDR3_WE_N,

	//HPS SD
	output			HPS_SD_CLK,
	inout			HPS_SD_CMD,
	inout	[3:0]	HPS_SD_DATA,

	// HPS UART
	input			HPS_UART_RX,
	output			HPS_UART_TX,

	// HPS USB
	input			HPS_USB_CLKOUT,
	inout	[7:0]	HPS_USB_DATA,
	input			HPS_USB_DIR,
	input			HPS_USB_NXT,
	output			HPS_USB_STP,

	// General PIO
	input 	[9:0]	SW,
	input	[3:0]	KEY,
	output	[9:0]	LEDR,

	// VGA
	output			VGA_BLANK_N,
	output			VGA_CLK,
	output	[7:0]	VGA_R,
	output	[7:0]	VGA_G,
	output	[7:0]	VGA_B,
	output			VGA_HS,
	output			VGA_SYNC_N,
	output			VGA_VS );

wire hps_fpga_reset_n;
wire clk_65;
wire [7:0] vid_r, vid_g, vid_b;
wire vid_v_sync;
wire vid_h_sync;
wire vid_datavalid;

assign VGA_BLANK_N  			= 1'b1;
assign VGA_SYNC_N   			= 1'b0;
assign VGA_CLK					= clk_65;
assign {VGA_B, VGA_G, VGA_R}	= {vid_b, vid_g, vid_r};
assign VGA_VS 					= vid_v_sync;
assign VGA_HS					= vid_h_sync;

wire [31:0] hex5_0bus;

// These two form {led, hex} to_hex_to_led
wire [31:0] hex;


hex2seg f1(.hex(hex[3:0]), .seg(HEX0));
hex2seg f2(.hex(hex[7:4]), .seg(HEX1));
hex2seg f3(.hex(hex[11:8]), .seg(HEX2));
hex2seg f4(.hex(hex[15:12]), .seg(HEX3));
hex2seg f5(.hex(hex[19:16]), .seg(HEX4));
hex2seg f6(.hex(hex[23:20]), .seg(HEX5));

//=======================================================
// HPS_to_FPGA FIFO state machine
//=======================================================
// --Check for data
//
// --Read data
// --add one
// --write to SRAM
// --signal HPS data_ready
//=======================================================
// Controls for Qsys sram slave exported in system module
//=======================================================
wire [31:0] sram_readdata ;
reg [31:0] sram_writedata ;
reg [7:0] sram_address;
reg sram_write ;
wire sram_clken = 1'b1;
wire sram_chipselect = 1'b1;
reg [7:0] state ;

//=======================================================
// Controls for HPS_to_FPGA FIFO
//=======================================================

reg [31:0] hps_to_fpga_readdata ;
reg hps_to_fpga_read ; // read command
// status addresses
// base => fill level
// base+1 => status bits;
//           bit0==1 if full
//           bit1==1 if empty
wire [31:0] hps_to_fpga_out_csr_address = 32'd1 ; // fill_level
wire cpu_fpga_fifo_empty = hps_to_fpga_out_csr_readdata[1];
reg[31:0] hps_to_fpga_out_csr_readdata ;
reg hps_to_fpga_out_csr_read ; // status regs read cmd
reg [7:0] HPS_to_FPGA_state ;
reg [31:0] cpu_fpga_fifo_rdata ;
reg cpu_fpga_fifo_rdata_dav ;

//=======================================================
// Controls for FPGA_to_HPS FIFO
//=======================================================
wire [31:0] fpga_cpu_fifo_wdata;
wire        fpga_cpu_fifo_wr;
wire [31:0] fpga_to_hps_in_csr_address = 32'd1 ; // fill_level
reg[31:0] fpga_to_hps_in_csr_readdata ;
reg fpga_to_hps_in_csr_read ; // status regs read cmd
reg [7:0] FPGA_to_HPS_state ;

//=======================================================
// do the work outlined above
always @(posedge CLOCK_50) begin // CLOCK_50

   // reset state machine and read/write controls
	if (~KEY[0]) begin
		HPS_to_FPGA_state <= 8'd0 ;
		sram_write <= 1'b0 ;
	end

	// =================================
	// HPS_to_FPGA state machine
	//==================================
	// Is there data in HPS_to_FPGA FIFO
	// and the last transfer is complete
	if (HPS_to_FPGA_state == 8'd0 && !cpu_fpga_fifo_empty && !cpu_fpga_fifo_rdata_dav)  begin
		hps_to_fpga_read <= 1'b1 ;
		HPS_to_FPGA_state <= 8'd2 ; //
	end

	// delay
	if (HPS_to_FPGA_state == 8'd2) begin
		// zero the read request BEFORE the data appears
		// in the next state!
		hps_to_fpga_read <= 1'b0 ;
		HPS_to_FPGA_state <= 8'd4 ;
	end

	// read the word from the FIFO
	if (HPS_to_FPGA_state == 8'd4) begin
		cpu_fpga_fifo_rdata <= hps_to_fpga_readdata ; // send back data
		cpu_fpga_fifo_rdata_dav <= 1'b1 ; // set the data ready flag
		hps_to_fpga_read <= 1'b0 ;
		HPS_to_FPGA_state <= 8'd0 ; //6
	end

    // set data back to unavailable
	if (HPS_to_FPGA_state == 8'd8) begin
		cpu_fpga_fifo_rdata_dav <= 1'b0 ; // set the data ready flag
	end
	//==================================
end // always @(posedge state_clock)

    zezima z (
        .clk                        (CLOCK_50),
        .rst                        (KEY[0]), //negated inside, sorry for bad formatting
        .cpu_fpga_fifo_empty        (cpu_fpga_fifo_empty),
        .cpu_fpga_fifo_rdata_dav    (cpu_fpga_fifo_rdata_dav),
        .cpu_fpga_fifo_rdata        (cpu_fpga_fifo_rdata),
        .fpga_cpu_interrupt         (),
        .fpga_cpu_fifo_wr           (fpga_cpu_fifo_wr),
        .fpga_cpu_fifo_wdata        (fpga_cpu_fifo_wdata)
    );

    sys_vga u0 (
        // VGA
        .alt_vip_itc_0_clocked_video_vid_clk       (~clk_65),       // alt_vip_itc_0_clocked_video.vid_clk
        .alt_vip_itc_0_clocked_video_vid_data      ({vid_r, vid_g, vid_b}),      //                            .vid_data
        .alt_vip_itc_0_clocked_video_underflow     (),     //                            .underflow
        .alt_vip_itc_0_clocked_video_vid_datavalid (vid_datavalid), //                            .vid_datavalid
        .alt_vip_itc_0_clocked_video_vid_v_sync    (vid_v_sync),    //                            .vid_v_sync
        .alt_vip_itc_0_clocked_video_vid_h_sync    (vid_h_sync),    //                            .vid_h_sync
        .alt_vip_itc_0_clocked_video_vid_f         (),         //                            .vid_f
        .alt_vip_itc_0_clocked_video_vid_h         (),         //                            .vid_h
        .alt_vip_itc_0_clocked_video_vid_v         (),         //                            .vid_v

        .clk_65_clk                                (clk_65),                                //                      clk_65.clk
        .clock_bridge_0_in_clk_clk                 (CLOCK_50),                 //       clock_bridge_0_in_clk.clk
      /* FPGA TO HPS */
        .fifo_fpga_to_hps_in_writedata      (fpga_cpu_fifo_wdata),      //      fifo_fpga_to_hps_in.writedata
        .fifo_fpga_to_hps_in_write          (fpga_cpu_fifo_wr),          //                         .write
        .fifo_fpga_to_hps_in_waitrequest    (),    //                         .waitrequest
        .fifo_fpga_to_hps_in_csr_address    (32'd1),    //  fifo_fpga_to_hps_in_csr.address
        .fifo_fpga_to_hps_in_csr_read       (1'b1),       //                         .read
        .fifo_fpga_to_hps_in_csr_writedata  (),  //                         .writedata
        .fifo_fpga_to_hps_in_csr_write      (1'b0),      //                         .write
        .fifo_fpga_to_hps_in_csr_readdata   (fpga_to_hps_in_csr_readdata),   //                         .readdata

		/* HPS TO FPGA */
        .fifo_hps_to_fpga_out_readdata      (hps_to_fpga_readdata),      //     fifo_hps_to_fpga_out.readdata
        .fifo_hps_to_fpga_out_read          (hps_to_fpga_read),          //                         .read
        .fifo_hps_to_fpga_out_waitrequest   (),   //                         .waitrequest
        .fifo_hps_to_fpga_out_csr_address   (32'd1),   // fifo_hps_to_fpga_out_csr.address
        .fifo_hps_to_fpga_out_csr_read      (1'b1),      //                         .read
        .fifo_hps_to_fpga_out_csr_writedata (), //                         .writedata
        .fifo_hps_to_fpga_out_csr_write     (1'b0),     //                         .write
        .fifo_hps_to_fpga_out_csr_readdata  (hps_to_fpga_out_csr_readdata),  //                         .readdata

		/* HEX STUFF */
        .hex5_0bus_export                   (hex5_0bus),                   //                hex5_0bus.export

		/* HPS DDR3 MEMORY */
		.memory_mem_a           (HPS_DDR3_ADDR),           //           memory.mem_a
        .memory_mem_ba          (HPS_DDR3_BA),          //                 .mem_ba
        .memory_mem_ck          (HPS_DDR3_CK_P),          //                 .mem_ck
        .memory_mem_ck_n        (HPS_DDR3_CK_N),        //                 .mem_ck_n
        .memory_mem_cke         (HPS_DDR3_CKE),         //                 .mem_cke
        .memory_mem_cs_n        (HPS_DDR3_CS_N),        //                 .mem_cs_n
        .memory_mem_ras_n       (HPS_DDR3_RAS_N),       //                 .mem_ras_n
        .memory_mem_cas_n       (HPS_DDR3_CAS_N),       //                 .mem_cas_n
        .memory_mem_we_n        (HPS_DDR3_WE_N),       //                 .mem_we_n
        .memory_mem_reset_n     (HPS_DDR3_RESET_N),     //                 .mem_reset_n
        .memory_mem_dq          (HPS_DDR3_DQ),          //                 .mem_dq
        .memory_mem_dqs         (HPS_DDR3_DQS_P),         //                 .mem_dqs
        .memory_mem_dqs_n       (HPS_DDR3_DQS_N),       //                 .mem_dqs_n
        .memory_mem_odt         (HPS_DDR3_ODT),         //                 .mem_odt
        .memory_mem_dm          (HPS_DDR3_DM),          //                 .mem_dm
        .memory_oct_rzqin       (HPS_DDR3_RZQ),       //                 .oct_rzqin

		.pushbutton_export      (~KEY[3:1]),      //       pushbutton.export
        .sdram_clk_clk          (DRAM_CLK),          //        sdram_clk.clk
        .sdram_wire_addr        (DRAM_ADDR),        //       sdram_wire.addr
        .sdram_wire_ba          (DRAM_BA),          //                 .ba
        .sdram_wire_cas_n       (DRAM_CAS_N),       //                 .cas_n
        .sdram_wire_cke         (DRAM_CKE),         //                 .cke
        .sdram_wire_cs_n        (DRAM_CS_N),        //                 .cs_n
        .sdram_wire_dq          (DRAM_DQ),          //                 .dq
        .sdram_wire_dqm         ({DRAM_UDQM, DRAM_LDQM}),         //                 .dqm
        .sdram_wire_ras_n       (DRAM_RAS_N),       //                 .ras_n
        .sdram_wire_we_n        (DRAM_WE_N),        //                 .we_n

        .system_ref_clk_clk                 (CLOCK_50),                 //           system_ref_clk.clk
        .system_ref_reset_reset             (~KEY[0]),             //         system_ref_reset.reset
        .to_hex_to_led_readdata             (hex),             //            to_hex_to_led.readdata

        .ram_s2_address                     (sram_address),                     //                   ram_s2.address
        .ram_s2_chipselect                  (sram_chipselect),                  //                         .chipselect
        .ram_s2_clken                       (sram_clken),                       //                         .clken
        .ram_s2_write                       (sram_write),                       //                         .write
        .ram_s2_readdata                    (sram_readdata),                    //                         .readdata
        .ram_s2_writedata                   (sram_writedata),                   //                         .writedata
        .ram_s2_byteenable                  (4'b1111),                         //


        .hps_io_hps_io_sdio_inst_CMD               (HPS_SD_CMD),               //                      hps_io.hps_io_sdio_inst_CMD
        .hps_io_hps_io_sdio_inst_D0                (HPS_SD_DATA[0]),                //                            .hps_io_sdio_inst_D0
        .hps_io_hps_io_sdio_inst_D1                (HPS_SD_DATA[1]),                //                            .hps_io_sdio_inst_D1
        .hps_io_hps_io_sdio_inst_CLK               (HPS_SD_CLK),               //                            .hps_io_sdio_inst_CLK
        .hps_io_hps_io_sdio_inst_D2                (HPS_SD_DATA[2]),                //                            .hps_io_sdio_inst_D2
        .hps_io_hps_io_sdio_inst_D3                (HPS_SD_DATA[3]),                //                            .hps_io_sdio_inst_D3
        .hps_io_hps_io_usb1_inst_D0                (HPS_USB_DATA[0]),                //                            .hps_io_usb1_inst_D0
        .hps_io_hps_io_usb1_inst_D1                (HPS_USB_DATA[1]),                //                            .hps_io_usb1_inst_D1
        .hps_io_hps_io_usb1_inst_D2                (HPS_USB_DATA[2]),                //                            .hps_io_usb1_inst_D2
        .hps_io_hps_io_usb1_inst_D3                (HPS_USB_DATA[3]),                //                            .hps_io_usb1_inst_D3
        .hps_io_hps_io_usb1_inst_D4                (HPS_USB_DATA[4]),                //                            .hps_io_usb1_inst_D4
        .hps_io_hps_io_usb1_inst_D5                (HPS_USB_DATA[5]),                //                            .hps_io_usb1_inst_D5
        .hps_io_hps_io_usb1_inst_D6                (HPS_USB_DATA[6]),                //                            .hps_io_usb1_inst_D6
        .hps_io_hps_io_usb1_inst_D7                (HPS_USB_DATA[7]),                //                            .hps_io_usb1_inst_D7
        .hps_io_hps_io_usb1_inst_CLK               (HPS_USB_CLKOUT),               //                            .hps_io_usb1_inst_CLK
        .hps_io_hps_io_usb1_inst_STP               (HPS_USB_STP),               //                            .hps_io_usb1_inst_STP
        .hps_io_hps_io_usb1_inst_DIR               (HPS_USB_DIR),               //                            .hps_io_usb1_inst_DIR
        .hps_io_hps_io_usb1_inst_NXT               (HPS_USB_NXT),               //                            .hps_io_usb1_inst_NXT
        .hps_io_hps_io_uart0_inst_RX               (HPS_UART_RX),               //                            .hps_io_uart0_inst_RX
        .hps_io_hps_io_uart0_inst_TX               (HPS_UART_TX)                //                            .hps_io_uart0_inst_TX
    );

endmodule
