	component sys_vga is
		port (
			alt_vip_itc_0_clocked_video_vid_clk       : in    std_logic                     := 'X';             -- vid_clk
			alt_vip_itc_0_clocked_video_vid_data      : out   std_logic_vector(31 downto 0);                    -- vid_data
			alt_vip_itc_0_clocked_video_underflow     : out   std_logic;                                        -- underflow
			alt_vip_itc_0_clocked_video_vid_datavalid : out   std_logic;                                        -- vid_datavalid
			alt_vip_itc_0_clocked_video_vid_v_sync    : out   std_logic;                                        -- vid_v_sync
			alt_vip_itc_0_clocked_video_vid_h_sync    : out   std_logic;                                        -- vid_h_sync
			alt_vip_itc_0_clocked_video_vid_f         : out   std_logic;                                        -- vid_f
			alt_vip_itc_0_clocked_video_vid_h         : out   std_logic;                                        -- vid_h
			alt_vip_itc_0_clocked_video_vid_v         : out   std_logic;                                        -- vid_v
			clk_65_clk                                : out   std_logic;                                        -- clk
			clock_bridge_0_in_clk_clk                 : in    std_logic                     := 'X';             -- clk
			fifo_fpga_to_hps_in_writedata             : in    std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			fifo_fpga_to_hps_in_write                 : in    std_logic                     := 'X';             -- write
			fifo_fpga_to_hps_in_waitrequest           : out   std_logic;                                        -- waitrequest
			fifo_fpga_to_hps_in_csr_address           : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- address
			fifo_fpga_to_hps_in_csr_read              : in    std_logic                     := 'X';             -- read
			fifo_fpga_to_hps_in_csr_writedata         : in    std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			fifo_fpga_to_hps_in_csr_write             : in    std_logic                     := 'X';             -- write
			fifo_fpga_to_hps_in_csr_readdata          : out   std_logic_vector(31 downto 0);                    -- readdata
			fifo_hps_to_fpga_out_readdata             : out   std_logic_vector(31 downto 0);                    -- readdata
			fifo_hps_to_fpga_out_read                 : in    std_logic                     := 'X';             -- read
			fifo_hps_to_fpga_out_waitrequest          : out   std_logic;                                        -- waitrequest
			fifo_hps_to_fpga_out_csr_address          : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- address
			fifo_hps_to_fpga_out_csr_read             : in    std_logic                     := 'X';             -- read
			fifo_hps_to_fpga_out_csr_writedata        : in    std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			fifo_hps_to_fpga_out_csr_write            : in    std_logic                     := 'X';             -- write
			fifo_hps_to_fpga_out_csr_readdata         : out   std_logic_vector(31 downto 0);                    -- readdata
			hex5_0bus_export                          : out   std_logic_vector(31 downto 0);                    -- export
			hps_io_hps_io_sdio_inst_CMD               : inout std_logic                     := 'X';             -- hps_io_sdio_inst_CMD
			hps_io_hps_io_sdio_inst_D0                : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D0
			hps_io_hps_io_sdio_inst_D1                : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D1
			hps_io_hps_io_sdio_inst_CLK               : out   std_logic;                                        -- hps_io_sdio_inst_CLK
			hps_io_hps_io_sdio_inst_D2                : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D2
			hps_io_hps_io_sdio_inst_D3                : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D3
			hps_io_hps_io_usb1_inst_D0                : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D0
			hps_io_hps_io_usb1_inst_D1                : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D1
			hps_io_hps_io_usb1_inst_D2                : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D2
			hps_io_hps_io_usb1_inst_D3                : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D3
			hps_io_hps_io_usb1_inst_D4                : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D4
			hps_io_hps_io_usb1_inst_D5                : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D5
			hps_io_hps_io_usb1_inst_D6                : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D6
			hps_io_hps_io_usb1_inst_D7                : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D7
			hps_io_hps_io_usb1_inst_CLK               : in    std_logic                     := 'X';             -- hps_io_usb1_inst_CLK
			hps_io_hps_io_usb1_inst_STP               : out   std_logic;                                        -- hps_io_usb1_inst_STP
			hps_io_hps_io_usb1_inst_DIR               : in    std_logic                     := 'X';             -- hps_io_usb1_inst_DIR
			hps_io_hps_io_usb1_inst_NXT               : in    std_logic                     := 'X';             -- hps_io_usb1_inst_NXT
			hps_io_hps_io_uart0_inst_RX               : in    std_logic                     := 'X';             -- hps_io_uart0_inst_RX
			hps_io_hps_io_uart0_inst_TX               : out   std_logic;                                        -- hps_io_uart0_inst_TX
			memory_mem_a                              : out   std_logic_vector(14 downto 0);                    -- mem_a
			memory_mem_ba                             : out   std_logic_vector(2 downto 0);                     -- mem_ba
			memory_mem_ck                             : out   std_logic;                                        -- mem_ck
			memory_mem_ck_n                           : out   std_logic;                                        -- mem_ck_n
			memory_mem_cke                            : out   std_logic;                                        -- mem_cke
			memory_mem_cs_n                           : out   std_logic;                                        -- mem_cs_n
			memory_mem_ras_n                          : out   std_logic;                                        -- mem_ras_n
			memory_mem_cas_n                          : out   std_logic;                                        -- mem_cas_n
			memory_mem_we_n                           : out   std_logic;                                        -- mem_we_n
			memory_mem_reset_n                        : out   std_logic;                                        -- mem_reset_n
			memory_mem_dq                             : inout std_logic_vector(31 downto 0) := (others => 'X'); -- mem_dq
			memory_mem_dqs                            : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs
			memory_mem_dqs_n                          : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs_n
			memory_mem_odt                            : out   std_logic;                                        -- mem_odt
			memory_mem_dm                             : out   std_logic_vector(3 downto 0);                     -- mem_dm
			memory_oct_rzqin                          : in    std_logic                     := 'X';             -- oct_rzqin
			pushbutton_export                         : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- export
			ram_s2_address                            : in    std_logic_vector(10 downto 0) := (others => 'X'); -- address
			ram_s2_chipselect                         : in    std_logic                     := 'X';             -- chipselect
			ram_s2_clken                              : in    std_logic                     := 'X';             -- clken
			ram_s2_write                              : in    std_logic                     := 'X';             -- write
			ram_s2_readdata                           : out   std_logic_vector(31 downto 0);                    -- readdata
			ram_s2_writedata                          : in    std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			ram_s2_byteenable                         : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- byteenable
			sdram_clk_clk                             : out   std_logic;                                        -- clk
			sdram_wire_addr                           : out   std_logic_vector(12 downto 0);                    -- addr
			sdram_wire_ba                             : out   std_logic_vector(1 downto 0);                     -- ba
			sdram_wire_cas_n                          : out   std_logic;                                        -- cas_n
			sdram_wire_cke                            : out   std_logic;                                        -- cke
			sdram_wire_cs_n                           : out   std_logic;                                        -- cs_n
			sdram_wire_dq                             : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
			sdram_wire_dqm                            : out   std_logic_vector(1 downto 0);                     -- dqm
			sdram_wire_ras_n                          : out   std_logic;                                        -- ras_n
			sdram_wire_we_n                           : out   std_logic;                                        -- we_n
			system_ref_clk_clk                        : in    std_logic                     := 'X';             -- clk
			system_ref_reset_reset                    : in    std_logic                     := 'X';             -- reset
			to_hex_to_led_readdata                    : out   std_logic_vector(31 downto 0)                     -- readdata
		);
	end component sys_vga;

	u0 : component sys_vga
		port map (
			alt_vip_itc_0_clocked_video_vid_clk       => CONNECTED_TO_alt_vip_itc_0_clocked_video_vid_clk,       -- alt_vip_itc_0_clocked_video.vid_clk
			alt_vip_itc_0_clocked_video_vid_data      => CONNECTED_TO_alt_vip_itc_0_clocked_video_vid_data,      --                            .vid_data
			alt_vip_itc_0_clocked_video_underflow     => CONNECTED_TO_alt_vip_itc_0_clocked_video_underflow,     --                            .underflow
			alt_vip_itc_0_clocked_video_vid_datavalid => CONNECTED_TO_alt_vip_itc_0_clocked_video_vid_datavalid, --                            .vid_datavalid
			alt_vip_itc_0_clocked_video_vid_v_sync    => CONNECTED_TO_alt_vip_itc_0_clocked_video_vid_v_sync,    --                            .vid_v_sync
			alt_vip_itc_0_clocked_video_vid_h_sync    => CONNECTED_TO_alt_vip_itc_0_clocked_video_vid_h_sync,    --                            .vid_h_sync
			alt_vip_itc_0_clocked_video_vid_f         => CONNECTED_TO_alt_vip_itc_0_clocked_video_vid_f,         --                            .vid_f
			alt_vip_itc_0_clocked_video_vid_h         => CONNECTED_TO_alt_vip_itc_0_clocked_video_vid_h,         --                            .vid_h
			alt_vip_itc_0_clocked_video_vid_v         => CONNECTED_TO_alt_vip_itc_0_clocked_video_vid_v,         --                            .vid_v
			clk_65_clk                                => CONNECTED_TO_clk_65_clk,                                --                      clk_65.clk
			clock_bridge_0_in_clk_clk                 => CONNECTED_TO_clock_bridge_0_in_clk_clk,                 --       clock_bridge_0_in_clk.clk
			fifo_fpga_to_hps_in_writedata             => CONNECTED_TO_fifo_fpga_to_hps_in_writedata,             --         fifo_fpga_to_hps_in.writedata
			fifo_fpga_to_hps_in_write                 => CONNECTED_TO_fifo_fpga_to_hps_in_write,                 --                            .write
			fifo_fpga_to_hps_in_waitrequest           => CONNECTED_TO_fifo_fpga_to_hps_in_waitrequest,           --                            .waitrequest
			fifo_fpga_to_hps_in_csr_address           => CONNECTED_TO_fifo_fpga_to_hps_in_csr_address,           --     fifo_fpga_to_hps_in_csr.address
			fifo_fpga_to_hps_in_csr_read              => CONNECTED_TO_fifo_fpga_to_hps_in_csr_read,              --                            .read
			fifo_fpga_to_hps_in_csr_writedata         => CONNECTED_TO_fifo_fpga_to_hps_in_csr_writedata,         --                            .writedata
			fifo_fpga_to_hps_in_csr_write             => CONNECTED_TO_fifo_fpga_to_hps_in_csr_write,             --                            .write
			fifo_fpga_to_hps_in_csr_readdata          => CONNECTED_TO_fifo_fpga_to_hps_in_csr_readdata,          --                            .readdata
			fifo_hps_to_fpga_out_readdata             => CONNECTED_TO_fifo_hps_to_fpga_out_readdata,             --        fifo_hps_to_fpga_out.readdata
			fifo_hps_to_fpga_out_read                 => CONNECTED_TO_fifo_hps_to_fpga_out_read,                 --                            .read
			fifo_hps_to_fpga_out_waitrequest          => CONNECTED_TO_fifo_hps_to_fpga_out_waitrequest,          --                            .waitrequest
			fifo_hps_to_fpga_out_csr_address          => CONNECTED_TO_fifo_hps_to_fpga_out_csr_address,          --    fifo_hps_to_fpga_out_csr.address
			fifo_hps_to_fpga_out_csr_read             => CONNECTED_TO_fifo_hps_to_fpga_out_csr_read,             --                            .read
			fifo_hps_to_fpga_out_csr_writedata        => CONNECTED_TO_fifo_hps_to_fpga_out_csr_writedata,        --                            .writedata
			fifo_hps_to_fpga_out_csr_write            => CONNECTED_TO_fifo_hps_to_fpga_out_csr_write,            --                            .write
			fifo_hps_to_fpga_out_csr_readdata         => CONNECTED_TO_fifo_hps_to_fpga_out_csr_readdata,         --                            .readdata
			hex5_0bus_export                          => CONNECTED_TO_hex5_0bus_export,                          --                   hex5_0bus.export
			hps_io_hps_io_sdio_inst_CMD               => CONNECTED_TO_hps_io_hps_io_sdio_inst_CMD,               --                      hps_io.hps_io_sdio_inst_CMD
			hps_io_hps_io_sdio_inst_D0                => CONNECTED_TO_hps_io_hps_io_sdio_inst_D0,                --                            .hps_io_sdio_inst_D0
			hps_io_hps_io_sdio_inst_D1                => CONNECTED_TO_hps_io_hps_io_sdio_inst_D1,                --                            .hps_io_sdio_inst_D1
			hps_io_hps_io_sdio_inst_CLK               => CONNECTED_TO_hps_io_hps_io_sdio_inst_CLK,               --                            .hps_io_sdio_inst_CLK
			hps_io_hps_io_sdio_inst_D2                => CONNECTED_TO_hps_io_hps_io_sdio_inst_D2,                --                            .hps_io_sdio_inst_D2
			hps_io_hps_io_sdio_inst_D3                => CONNECTED_TO_hps_io_hps_io_sdio_inst_D3,                --                            .hps_io_sdio_inst_D3
			hps_io_hps_io_usb1_inst_D0                => CONNECTED_TO_hps_io_hps_io_usb1_inst_D0,                --                            .hps_io_usb1_inst_D0
			hps_io_hps_io_usb1_inst_D1                => CONNECTED_TO_hps_io_hps_io_usb1_inst_D1,                --                            .hps_io_usb1_inst_D1
			hps_io_hps_io_usb1_inst_D2                => CONNECTED_TO_hps_io_hps_io_usb1_inst_D2,                --                            .hps_io_usb1_inst_D2
			hps_io_hps_io_usb1_inst_D3                => CONNECTED_TO_hps_io_hps_io_usb1_inst_D3,                --                            .hps_io_usb1_inst_D3
			hps_io_hps_io_usb1_inst_D4                => CONNECTED_TO_hps_io_hps_io_usb1_inst_D4,                --                            .hps_io_usb1_inst_D4
			hps_io_hps_io_usb1_inst_D5                => CONNECTED_TO_hps_io_hps_io_usb1_inst_D5,                --                            .hps_io_usb1_inst_D5
			hps_io_hps_io_usb1_inst_D6                => CONNECTED_TO_hps_io_hps_io_usb1_inst_D6,                --                            .hps_io_usb1_inst_D6
			hps_io_hps_io_usb1_inst_D7                => CONNECTED_TO_hps_io_hps_io_usb1_inst_D7,                --                            .hps_io_usb1_inst_D7
			hps_io_hps_io_usb1_inst_CLK               => CONNECTED_TO_hps_io_hps_io_usb1_inst_CLK,               --                            .hps_io_usb1_inst_CLK
			hps_io_hps_io_usb1_inst_STP               => CONNECTED_TO_hps_io_hps_io_usb1_inst_STP,               --                            .hps_io_usb1_inst_STP
			hps_io_hps_io_usb1_inst_DIR               => CONNECTED_TO_hps_io_hps_io_usb1_inst_DIR,               --                            .hps_io_usb1_inst_DIR
			hps_io_hps_io_usb1_inst_NXT               => CONNECTED_TO_hps_io_hps_io_usb1_inst_NXT,               --                            .hps_io_usb1_inst_NXT
			hps_io_hps_io_uart0_inst_RX               => CONNECTED_TO_hps_io_hps_io_uart0_inst_RX,               --                            .hps_io_uart0_inst_RX
			hps_io_hps_io_uart0_inst_TX               => CONNECTED_TO_hps_io_hps_io_uart0_inst_TX,               --                            .hps_io_uart0_inst_TX
			memory_mem_a                              => CONNECTED_TO_memory_mem_a,                              --                      memory.mem_a
			memory_mem_ba                             => CONNECTED_TO_memory_mem_ba,                             --                            .mem_ba
			memory_mem_ck                             => CONNECTED_TO_memory_mem_ck,                             --                            .mem_ck
			memory_mem_ck_n                           => CONNECTED_TO_memory_mem_ck_n,                           --                            .mem_ck_n
			memory_mem_cke                            => CONNECTED_TO_memory_mem_cke,                            --                            .mem_cke
			memory_mem_cs_n                           => CONNECTED_TO_memory_mem_cs_n,                           --                            .mem_cs_n
			memory_mem_ras_n                          => CONNECTED_TO_memory_mem_ras_n,                          --                            .mem_ras_n
			memory_mem_cas_n                          => CONNECTED_TO_memory_mem_cas_n,                          --                            .mem_cas_n
			memory_mem_we_n                           => CONNECTED_TO_memory_mem_we_n,                           --                            .mem_we_n
			memory_mem_reset_n                        => CONNECTED_TO_memory_mem_reset_n,                        --                            .mem_reset_n
			memory_mem_dq                             => CONNECTED_TO_memory_mem_dq,                             --                            .mem_dq
			memory_mem_dqs                            => CONNECTED_TO_memory_mem_dqs,                            --                            .mem_dqs
			memory_mem_dqs_n                          => CONNECTED_TO_memory_mem_dqs_n,                          --                            .mem_dqs_n
			memory_mem_odt                            => CONNECTED_TO_memory_mem_odt,                            --                            .mem_odt
			memory_mem_dm                             => CONNECTED_TO_memory_mem_dm,                             --                            .mem_dm
			memory_oct_rzqin                          => CONNECTED_TO_memory_oct_rzqin,                          --                            .oct_rzqin
			pushbutton_export                         => CONNECTED_TO_pushbutton_export,                         --                  pushbutton.export
			ram_s2_address                            => CONNECTED_TO_ram_s2_address,                            --                      ram_s2.address
			ram_s2_chipselect                         => CONNECTED_TO_ram_s2_chipselect,                         --                            .chipselect
			ram_s2_clken                              => CONNECTED_TO_ram_s2_clken,                              --                            .clken
			ram_s2_write                              => CONNECTED_TO_ram_s2_write,                              --                            .write
			ram_s2_readdata                           => CONNECTED_TO_ram_s2_readdata,                           --                            .readdata
			ram_s2_writedata                          => CONNECTED_TO_ram_s2_writedata,                          --                            .writedata
			ram_s2_byteenable                         => CONNECTED_TO_ram_s2_byteenable,                         --                            .byteenable
			sdram_clk_clk                             => CONNECTED_TO_sdram_clk_clk,                             --                   sdram_clk.clk
			sdram_wire_addr                           => CONNECTED_TO_sdram_wire_addr,                           --                  sdram_wire.addr
			sdram_wire_ba                             => CONNECTED_TO_sdram_wire_ba,                             --                            .ba
			sdram_wire_cas_n                          => CONNECTED_TO_sdram_wire_cas_n,                          --                            .cas_n
			sdram_wire_cke                            => CONNECTED_TO_sdram_wire_cke,                            --                            .cke
			sdram_wire_cs_n                           => CONNECTED_TO_sdram_wire_cs_n,                           --                            .cs_n
			sdram_wire_dq                             => CONNECTED_TO_sdram_wire_dq,                             --                            .dq
			sdram_wire_dqm                            => CONNECTED_TO_sdram_wire_dqm,                            --                            .dqm
			sdram_wire_ras_n                          => CONNECTED_TO_sdram_wire_ras_n,                          --                            .ras_n
			sdram_wire_we_n                           => CONNECTED_TO_sdram_wire_we_n,                           --                            .we_n
			system_ref_clk_clk                        => CONNECTED_TO_system_ref_clk_clk,                        --              system_ref_clk.clk
			system_ref_reset_reset                    => CONNECTED_TO_system_ref_reset_reset,                    --            system_ref_reset.reset
			to_hex_to_led_readdata                    => CONNECTED_TO_to_hex_to_led_readdata                     --               to_hex_to_led.readdata
		);

