`timescale 1 ps / 1 ps
module tb_zezima;
`include "../zezima.vh"
//`include "zezima.vh"

    reg                 clk;
    reg                 rst;
    reg                 cpu_fpga_fifo_empty;
    reg     [31:0]      cpu_fpga_fifo_rdata;
    reg                 cpu_fpga_fifo_rdata_dav;

    wire                fpga_cpu_interrupt;
    wire     [31:0]     fpga_cpu_fifo_wdata;
    wire                fpga_cpu_fifo_wr;

    // Internal signals
    reg [9:0] quiet_moves;
    reg [9:0] castle_moves;
    reg [9:0] capture_moves;
    reg [9:0] capture_promos;
    reg [9:0] promotion_moves;
    reg [31:0] timer;

    zezima zezima (
        .clk                    (clk),
        .rst                    (rst),
        .cpu_fpga_fifo_empty    (cpu_fpga_fifo_empty),
        .cpu_fpga_fifo_rdata    (cpu_fpga_fifo_rdata),
        .cpu_fpga_fifo_rdata_dav(cpu_fpga_fifo_rdata_dav),
        .fpga_cpu_fifo_wdata    (fpga_cpu_fifo_wdata),
        .fpga_cpu_fifo_wr       (fpga_cpu_fifo_wr),
        .fpga_cpu_interrupt     (fpga_cpu_interrupt)
    );

    initial begin
        timer = 0;
        forever
            #1 timer = timer + 32'd1;
    end

    initial begin
		clk = 0;
		forever
			#5 clk = ~clk;
	end

    always @(posedge clk) begin
        if(~rst) begin
            quiet_moves <= 10'd0;
            castle_moves <= 10'd0;
            capture_moves <= 10'd0;
            capture_promos <= 10'd0;
            promotion_moves <= 10'd0;
        end
        else begin
            if(fpga_cpu_fifo_wr) begin
                if(~(|fpga_cpu_fifo_wdata[14:12]))
                    quiet_moves <= quiet_moves + 10'd1;
                else
                    quiet_moves <= quiet_moves;

                if(fpga_cpu_fifo_wdata[12]
                        & ~(fpga_cpu_fifo_wdata[14] | fpga_cpu_fifo_wdata[13]))
                    capture_moves <= capture_moves + 10'd1;
                else
                    capture_moves <= capture_moves;

                if(fpga_cpu_fifo_wr & fpga_cpu_fifo_wdata[14]
                        & ~(fpga_cpu_fifo_wdata[13] | fpga_cpu_fifo_wdata[12]))
                    castle_moves <= castle_moves + 10'd1;
                else
                    castle_moves <= castle_moves;

                if(~fpga_cpu_fifo_wdata[14]
                        & (fpga_cpu_fifo_wdata[13] & fpga_cpu_fifo_wdata[12]))
                    capture_promos <= capture_promos + 10'd1;
                else
                    capture_promos <= capture_promos;

                if(fpga_cpu_fifo_wdata[13]
                        & (~fpga_cpu_fifo_wdata[14] & ~fpga_cpu_fifo_wdata[12]))
                    promotion_moves <= promotion_moves + 10'd1;
                else
                    promotion_moves <= promotion_moves;
            end
            else begin
                quiet_moves <= quiet_moves;
                capture_moves <= capture_moves;
                castle_moves <= castle_moves;
                capture_promos <= capture_promos;
                promotion_moves <= promotion_moves;
            end
        end
    end

    // Gives the starting board to the engine and waits for the moves out
    initial begin
        rst = 1;
        cpu_fpga_fifo_empty = 1;
        cpu_fpga_fifo_rdata_dav = 0;

        ////////////////////////////////////////////////////////////////////////
        //              TEST 1: STARTING POSITION
        ////////////////////////////////////////////////////////////////////////
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    BISHOP, C, ONE, WHITE,
                                    KNIGHT, B, ONE, WHITE,
                                    ROOK, A, ONE, WHITE
                                };
        #15
        rst = 0;
        #10
        rst = 1;
        #10
        cpu_fpga_fifo_empty = 0;
        // 20 to get into recieve state
        #20
        cpu_fpga_fifo_rdata_dav = 1;
        #10
        cpu_fpga_fifo_rdata_dav = 0;
        #10
        cpu_fpga_fifo_rdata_dav = 1;
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    BISHOP, F, ONE, WHITE,
                                    KING, E, ONE, WHITE,
                                    QUEEN, D, ONE, WHITE
                                };

        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, A, TWO, WHITE,
                                    ROOK, H, ONE, WHITE,
                                    KNIGHT, G, ONE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, D, TWO, WHITE,
                                    PAWN, C, TWO, WHITE,
                                    PAWN, B, TWO, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, G, TWO, WHITE,
                                    PAWN, F, TWO, WHITE,
                                    PAWN, E, TWO, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, B, THREE, WHITE,
                                    EMPTY, A, THREE, WHITE,
                                    PAWN, H, TWO, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, E, THREE, WHITE,
                                    EMPTY, D, THREE, WHITE,
                                    EMPTY, C, THREE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, H, THREE, WHITE,
                                    EMPTY, G, THREE, WHITE,
                                    EMPTY, F, THREE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, C, FOUR, WHITE,
                                    EMPTY, B, FOUR, WHITE,
                                    EMPTY, A, FOUR, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, F, FOUR, WHITE,
                                    EMPTY, E, FOUR, WHITE,
                                    EMPTY, D, FOUR, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, A, FIVE, WHITE,
                                    EMPTY, H, FOUR, WHITE,
                                    EMPTY, G, FOUR, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, D, FIVE, WHITE,
                                    EMPTY, C, FIVE, WHITE,
                                    EMPTY, B, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, G, FIVE, WHITE,
                                    EMPTY, F, FIVE, WHITE,
                                    EMPTY, E, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, B, SIX, WHITE,
                                    EMPTY, A, SIX, WHITE,
                                    EMPTY, H, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, E, SIX, WHITE,
                                    EMPTY, D, SIX, WHITE,
                                    EMPTY, C, SIX, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, H, SIX, WHITE,
                                    EMPTY, G, SIX, WHITE,
                                    EMPTY, F, SIX, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, C, SEVEN, BLACK,
                                    PAWN, B, SEVEN, BLACK,
                                    PAWN, A, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, F, SEVEN, BLACK,
                                    PAWN, E, SEVEN, BLACK,
                                    PAWN, D, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    ROOK, A, EIGHT, BLACK,
                                    PAWN, H, SEVEN, BLACK,
                                    PAWN, G, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    QUEEN, D, EIGHT, BLACK,
                                    BISHOP, C, EIGHT, BLACK,
                                    KNIGHT, B, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    KNIGHT, G, EIGHT, BLACK,
                                    BISHOP, F, EIGHT, BLACK,
                                    KING, E, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   WHITE,  // who's turn?
                                    1'b0,   // reserved
                                    4'hF,   // castle rights
                                    16'd0,  // en passant flags
                                    ROOK, H, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata_dav = 0;
        cpu_fpga_fifo_empty = 1;
        wait(fpga_cpu_interrupt);
        $display("\nTime: %0t", $time);
        if(quiet_moves > 10'd20)
            $display("ERROR (TEST 1): Too many moves from intial position");
        else
            $display("PASS  (TEST 1): Got 20 moves from starting board");
        #50
        rst = 0;

        ////////////////////////////////////////////////////////////////////////
        //              TEST 2: BLACK STARTING BOARD
        ////////////////////////////////////////////////////////////////////////
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    BISHOP, C, ONE, WHITE,
                                    EMPTY, B, ONE, WHITE,
                                    ROOK, A, ONE, WHITE
                                };
        #10
        rst = 1;
        cpu_fpga_fifo_empty = 0;
        cpu_fpga_fifo_rdata_dav = 1;
        // 20 to get into recieve state
        #20
        cpu_fpga_fifo_empty = 1;
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    BISHOP, F, ONE, WHITE,
                                    KING, E, ONE, WHITE,
                                    QUEEN, D, ONE, WHITE
                                };

        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, A, TWO, WHITE,
                                    ROOK, H, ONE, WHITE,
                                    KNIGHT, G, ONE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, D, TWO, WHITE,
                                    PAWN, C, TWO, WHITE,
                                    PAWN, B, TWO, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, G, TWO, WHITE,
                                    PAWN, F, TWO, WHITE,
                                    PAWN, E, TWO, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, B, THREE, WHITE,
                                    KNIGHT, A, THREE, WHITE,
                                    PAWN, H, TWO, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, E, THREE, WHITE,
                                    EMPTY, D, THREE, WHITE,
                                    EMPTY, C, THREE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, H, THREE, WHITE,
                                    EMPTY, G, THREE, WHITE,
                                    EMPTY, F, THREE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, C, FOUR, WHITE,
                                    EMPTY, B, FOUR, WHITE,
                                    EMPTY, A, FOUR, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, F, FOUR, WHITE,
                                    EMPTY, E, FOUR, WHITE,
                                    EMPTY, D, FOUR, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, A, FIVE, WHITE,
                                    EMPTY, H, FOUR, WHITE,
                                    EMPTY, G, FOUR, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, D, FIVE, WHITE,
                                    EMPTY, C, FIVE, WHITE,
                                    EMPTY, B, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, G, FIVE, WHITE,
                                    EMPTY, F, FIVE, WHITE,
                                    EMPTY, E, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, B, SIX, WHITE,
                                    EMPTY, A, SIX, WHITE,
                                    EMPTY, H, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, E, SIX, WHITE,
                                    EMPTY, D, SIX, WHITE,
                                    EMPTY, C, SIX, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, H, SIX, WHITE,
                                    EMPTY, G, SIX, WHITE,
                                    EMPTY, F, SIX, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, C, SEVEN, BLACK,
                                    PAWN, B, SEVEN, BLACK,
                                    PAWN, A, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, F, SEVEN, BLACK,
                                    PAWN, E, SEVEN, BLACK,
                                    PAWN, D, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    ROOK, A, EIGHT, BLACK,
                                    PAWN, H, SEVEN, BLACK,
                                    PAWN, G, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    QUEEN, D, EIGHT, BLACK,
                                    BISHOP, C, EIGHT, BLACK,
                                    KNIGHT, B, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    KNIGHT, G, EIGHT, BLACK,
                                    BISHOP, F, EIGHT, BLACK,
                                    KING, E, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   BLACK,  // who's turn?
                                    1'b0,   // reserved
                                    4'hF,   // castle rights
                                    16'd0,  // en passant flags
                                    ROOK, H, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata_dav = 0;
        wait(fpga_cpu_interrupt);
        $display("\nTime: %0t", $time);
        if(quiet_moves > 10'd20)
            $display("ERROR (TEST 2): Too many black moves");
        else
            $display("PASS  (TEST 2): Got 20 moves from starting black position");
        #100

        ////////////////////////////////////////////////////////////////////////
        //              TEST 3: WHITE CASTLING
        ////////////////////////////////////////////////////////////////////////
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, C, ONE, WHITE,
                                    EMPTY, B, ONE, WHITE,
                                    ROOK, A, ONE, WHITE
                                };
        #10
        rst = 1;
        cpu_fpga_fifo_empty = 0;
        cpu_fpga_fifo_rdata_dav = 1;
        // 20 to get into recieve state
        #20
        cpu_fpga_fifo_empty = 1;
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, F, ONE, WHITE,
                                    KING, E, ONE, WHITE,
                                    EMPTY, D, ONE, WHITE
                                };

        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, A, TWO, WHITE,
                                    ROOK, H, ONE, WHITE,
                                    EMPTY, G, ONE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, D, TWO, WHITE,
                                    PAWN, C, TWO, WHITE,
                                    PAWN, B, TWO, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, G, TWO, WHITE,
                                    PAWN, F, TWO, WHITE,
                                    PAWN, E, TWO, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, B, THREE, WHITE,
                                    EMPTY, A, THREE, WHITE,
                                    PAWN, H, TWO, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, E, THREE, WHITE,
                                    EMPTY, D, THREE, WHITE,
                                    EMPTY, C, THREE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, H, THREE, WHITE,
                                    EMPTY, G, THREE, WHITE,
                                    EMPTY, F, THREE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, C, FOUR, WHITE,
                                    EMPTY, B, FOUR, WHITE,
                                    EMPTY, A, FOUR, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, F, FOUR, WHITE,
                                    EMPTY, E, FOUR, WHITE,
                                    EMPTY, D, FOUR, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, A, FIVE, WHITE,
                                    EMPTY, H, FOUR, WHITE,
                                    EMPTY, G, FOUR, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, D, FIVE, WHITE,
                                    EMPTY, C, FIVE, WHITE,
                                    EMPTY, B, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, G, FIVE, WHITE,
                                    EMPTY, F, FIVE, WHITE,
                                    EMPTY, E, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, B, SIX, WHITE,
                                    EMPTY, A, SIX, WHITE,
                                    EMPTY, H, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, E, SIX, WHITE,
                                    EMPTY, D, SIX, WHITE,
                                    EMPTY, C, SIX, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, H, SIX, WHITE,
                                    EMPTY, G, SIX, WHITE,
                                    EMPTY, F, SIX, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, C, SEVEN, BLACK,
                                    PAWN, B, SEVEN, BLACK,
                                    PAWN, A, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, F, SEVEN, BLACK,
                                    PAWN, E, SEVEN, BLACK,
                                    PAWN, D, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    ROOK, A, EIGHT, BLACK,
                                    PAWN, H, SEVEN, BLACK,
                                    PAWN, G, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    QUEEN, D, EIGHT, BLACK,
                                    BISHOP, C, EIGHT, BLACK,
                                    KNIGHT, B, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    KNIGHT, G, EIGHT, BLACK,
                                    BISHOP, F, EIGHT, BLACK,
                                    KING, E, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   WHITE,  // who's turn?
                                    1'b0,   // reserved
                                    4'b1010,   // castle rights
                                    16'd0,  // en passant flags
                                    ROOK, H, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata_dav = 0;
        wait(fpga_cpu_interrupt);
        $display("\nTime: %0t", $time);
        if(castle_moves > 10'd1)
            $display("ERROR (TEST 3): Too many white castle moves");
        else
            $display("PASS  (TEST 3): Got 1 valid and 1 invalid castle move");
        #100
        rst = 0;

        ////////////////////////////////////////////////////////////////////////
        //              TEST 4: BLACK EN PASSANT
        ////////////////////////////////////////////////////////////////////////
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, C, ONE, WHITE,
                                    EMPTY, B, ONE, WHITE,
                                    ROOK, A, ONE, WHITE
                                };
        #10
        rst = 1;
        cpu_fpga_fifo_empty = 0;
        cpu_fpga_fifo_rdata_dav = 1;
        // 20 to get into recieve state
        #20
        cpu_fpga_fifo_empty = 1;
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, F, ONE, WHITE,
                                    KING, E, ONE, WHITE,
                                    EMPTY, D, ONE, WHITE
                                };

        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, A, TWO, WHITE,
                                    ROOK, H, ONE, WHITE,
                                    EMPTY, G, ONE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, D, TWO, WHITE,
                                    EMPTY, C, TWO, WHITE,
                                    PAWN, B, TWO, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, G, TWO, WHITE,
                                    PAWN, F, TWO, WHITE,
                                    PAWN, E, TWO, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, B, THREE, WHITE,
                                    EMPTY, A, THREE, WHITE,
                                    PAWN, H, TWO, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, E, THREE, WHITE,
                                    EMPTY, D, THREE, WHITE,
                                    EMPTY, C, THREE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, H, THREE, WHITE,
                                    EMPTY, G, THREE, WHITE,
                                    EMPTY, F, THREE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, C, FOUR, WHITE,
                                    PAWN, B, FOUR, BLACK,
                                    EMPTY, A, FOUR, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, F, FOUR, WHITE,
                                    EMPTY, E, FOUR, WHITE,
                                    PAWN, D, FOUR, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, A, FIVE, WHITE,
                                    EMPTY, H, FOUR, WHITE,
                                    EMPTY, G, FOUR, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, D, FIVE, WHITE,
                                    EMPTY, C, FIVE, WHITE,
                                    EMPTY, B, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, G, FIVE, WHITE,
                                    EMPTY, F, FIVE, WHITE,
                                    EMPTY, E, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, B, SIX, WHITE,
                                    EMPTY, A, SIX, WHITE,
                                    EMPTY, H, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, E, SIX, WHITE,
                                    EMPTY, D, SIX, WHITE,
                                    EMPTY, C, SIX, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, H, SIX, WHITE,
                                    EMPTY, G, SIX, WHITE,
                                    EMPTY, F, SIX, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, C, SEVEN, BLACK,
                                    EMPTY, B, SEVEN, BLACK,
                                    PAWN, A, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, F, SEVEN, BLACK,
                                    PAWN, E, SEVEN, BLACK,
                                    EMPTY, D, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    ROOK, A, EIGHT, BLACK,
                                    PAWN, H, SEVEN, BLACK,
                                    PAWN, G, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    QUEEN, D, EIGHT, BLACK,
                                    BISHOP, C, EIGHT, BLACK,
                                    KNIGHT, B, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    KNIGHT, G, EIGHT, BLACK,
                                    BISHOP, F, EIGHT, BLACK,
                                    KING, E, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   BLACK,  // who's turn?
                                    1'b0,   // reserved
                                    4'h0,   // castle rights
                                    16'h2000,  // en passant flags (white just moved to C4)
                                    ROOK, H, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata_dav = 0;
        wait(fpga_cpu_interrupt);
        $display("\nTime: %0t", $time);
        if(capture_moves > 10'd2)
            $display("ERROR (TEST 4): Too many en passant moves!");
        else
            $display("PASS  (TEST 4): Got 2 valid en passant moves");
        #100
        rst = 0;
        ////////////////////////////////////////////////////////////////////////
        //              TEST 5: PIECE SLIDE ACROSS WHOLE BOARD TO CAPTURE
        ////////////////////////////////////////////////////////////////////////
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, C, ONE, WHITE,
                                    EMPTY, B, ONE, WHITE,
                                    BISHOP, A, ONE, WHITE
                                };
        #10
        rst = 1;
        cpu_fpga_fifo_empty = 0;
        cpu_fpga_fifo_rdata_dav = 1;
        // 20 to get into recieve state
        #20
        cpu_fpga_fifo_empty = 1;
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, F, ONE, WHITE,
                                    EMPTY, E, ONE, WHITE,
                                    EMPTY, D, ONE, WHITE
                                };

        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, A, TWO, WHITE,
                                    ROOK, H, ONE, WHITE,
                                    EMPTY, G, ONE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, D, TWO, WHITE,
                                    EMPTY, C, TWO, WHITE,
                                    EMPTY, B, TWO, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, G, TWO, WHITE,
                                    EMPTY, F, TWO, WHITE,
                                    EMPTY, E, TWO, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, B, THREE, WHITE,
                                    EMPTY, A, THREE, WHITE,
                                    EMPTY, H, TWO, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, E, THREE, WHITE,
                                    EMPTY, D, THREE, WHITE,
                                    EMPTY, C, THREE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, H, THREE, WHITE,
                                    EMPTY, G, THREE, WHITE,
                                    EMPTY, F, THREE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, C, FOUR, WHITE,
                                    EMPTY, B, FOUR, BLACK,
                                    EMPTY, A, FOUR, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, F, FOUR, WHITE,
                                    EMPTY, E, FOUR, WHITE,
                                    EMPTY, D, FOUR, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, A, FIVE, WHITE,
                                    EMPTY, H, FOUR, WHITE,
                                    EMPTY, G, FOUR, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, D, FIVE, WHITE,
                                    EMPTY, C, FIVE, WHITE,
                                    EMPTY, B, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, G, FIVE, WHITE,
                                    EMPTY, F, FIVE, WHITE,
                                    EMPTY, E, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, B, SIX, WHITE,
                                    EMPTY, A, SIX, WHITE,
                                    EMPTY, H, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, E, SIX, WHITE,
                                    EMPTY, D, SIX, WHITE,
                                    EMPTY, C, SIX, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, H, SIX, WHITE,
                                    EMPTY, G, SIX, WHITE,
                                    EMPTY, F, SIX, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, C, SEVEN, BLACK,
                                    EMPTY, B, SEVEN, BLACK,
                                    EMPTY, A, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, F, SEVEN, BLACK,
                                    EMPTY, E, SEVEN, BLACK,
                                    EMPTY, D, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, A, EIGHT, BLACK,
                                    EMPTY, H, SEVEN, BLACK,
                                    EMPTY, G, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, D, EIGHT, BLACK,
                                    EMPTY, C, EIGHT, BLACK,
                                    EMPTY, B, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, G, EIGHT, BLACK,
                                    EMPTY, F, EIGHT, BLACK,
                                    EMPTY, E, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   WHITE,  // who's turn?
                                    1'b0,   // reserved
                                    4'h0,   // castle rights
                                    16'h0000,  // en passant flags
                                    ROOK, H, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata_dav = 0;
        wait(fpga_cpu_interrupt);
        $display("\nTime: %0t", $time);
        if(capture_moves > 10'd2 || quiet_moves > 10'd18) begin
            $display("ERROR (TEST 5): Too many moves! Quiet: %0d, Capture: %0d",
                quiet_moves, capture_moves);
        end
        else
            $display("PASS  (TEST 5): Got 2 captures and 18 slide moves across board with rook and bishop");
        #100
        rst = 0;
        ////////////////////////////////////////////////////////////////////////
        //              TEST 6: PROMOTIONS AND PROMOTION CAPTURES
        ////////////////////////////////////////////////////////////////////////
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, C, ONE, WHITE,
                                    EMPTY, B, ONE, WHITE,
                                    EMPTY, A, ONE, WHITE
                                };
        #10
        rst = 1;
        cpu_fpga_fifo_empty = 0;
        cpu_fpga_fifo_rdata_dav = 1;
        // 20 to get into recieve state
        #20
        cpu_fpga_fifo_empty = 1;
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, F, ONE, WHITE,
                                    EMPTY, E, ONE, WHITE,
                                    EMPTY, D, ONE, WHITE
                                };

        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, A, TWO, WHITE,
                                    EMPTY, H, ONE, WHITE,
                                    EMPTY, G, ONE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, D, TWO, WHITE,
                                    EMPTY, C, TWO, WHITE,
                                    EMPTY, B, TWO, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, G, TWO, WHITE,
                                    EMPTY, F, TWO, WHITE,
                                    EMPTY, E, TWO, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, B, THREE, WHITE,
                                    EMPTY, A, THREE, WHITE,
                                    EMPTY, H, TWO, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, E, THREE, WHITE,
                                    EMPTY, D, THREE, WHITE,
                                    EMPTY, C, THREE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, H, THREE, WHITE,
                                    EMPTY, G, THREE, WHITE,
                                    EMPTY, F, THREE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, C, FOUR, WHITE,
                                    EMPTY, B, FOUR, BLACK,
                                    EMPTY, A, FOUR, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, F, FOUR, WHITE,
                                    EMPTY, E, FOUR, WHITE,
                                    EMPTY, D, FOUR, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, A, FIVE, WHITE,
                                    EMPTY, H, FOUR, WHITE,
                                    EMPTY, G, FOUR, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, D, FIVE, WHITE,
                                    EMPTY, C, FIVE, WHITE,
                                    EMPTY, B, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, G, FIVE, WHITE,
                                    EMPTY, F, FIVE, WHITE,
                                    EMPTY, E, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, B, SIX, WHITE,
                                    EMPTY, A, SIX, WHITE,
                                    EMPTY, H, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, E, SIX, WHITE,
                                    EMPTY, D, SIX, WHITE,
                                    EMPTY, C, SIX, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, H, SIX, WHITE,
                                    EMPTY, G, SIX, WHITE,
                                    EMPTY, F, SIX, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, C, SEVEN, BLACK,
                                    PAWN, B, SEVEN, WHITE,
                                    EMPTY, A, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, F, SEVEN, BLACK,
                                    PAWN, E, SEVEN, WHITE,
                                    EMPTY, D, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    ROOK, A, EIGHT, BLACK,
                                    EMPTY, H, SEVEN, BLACK,
                                    EMPTY, G, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, D, EIGHT, BLACK,
                                    EMPTY, C, EIGHT, BLACK,
                                    EMPTY, B, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, G, EIGHT, BLACK,
                                    EMPTY, F, EIGHT, BLACK,
                                    EMPTY, E, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   WHITE,  // who's turn?
                                    1'b0,   // reserved
                                    4'h0,   // castle rights
                                    16'h0000,  // en passant flags
                                    EMPTY, H, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata_dav = 0;
        wait(fpga_cpu_interrupt);
        $display("\nTime: %0t", $time);
        if(capture_moves > 10'd1 || capture_promos > 10'd1)
            $display("ERROR (TEST 6): Too many moves!");
        else
            $display("PASS  (TEST 6): Got 1 pawn catpure and 1 capture-promotion pawn moves");
        #100
        rst = 0;
        ////////////////////////////////////////////////////////////////////////
        //              TEST 7: TESTING ALL KNIGHT DIRECTIONS
        ////////////////////////////////////////////////////////////////////////
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, C, ONE, WHITE,
                                    EMPTY, B, ONE, WHITE,
                                    EMPTY, A, ONE, WHITE
                                };
        #10
        rst = 1;
        cpu_fpga_fifo_empty = 0;
        cpu_fpga_fifo_rdata_dav = 1;
        // 20 to get into recieve state
        #20
        cpu_fpga_fifo_empty = 1;
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, F, ONE, WHITE,
                                    EMPTY, E, ONE, WHITE,
                                    EMPTY, D, ONE, WHITE
                                };

        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, A, TWO, WHITE,
                                    EMPTY, H, ONE, WHITE,
                                    EMPTY, G, ONE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, D, TWO, WHITE,
                                    EMPTY, C, TWO, WHITE,
                                    EMPTY, B, TWO, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, G, TWO, WHITE,
                                    EMPTY, F, TWO, WHITE,
                                    EMPTY, E, TWO, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, B, THREE, WHITE,
                                    EMPTY, A, THREE, WHITE,
                                    EMPTY, H, TWO, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, E, THREE, WHITE,
                                    EMPTY, D, THREE, WHITE,
                                    EMPTY, C, THREE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, H, THREE, WHITE,
                                    EMPTY, G, THREE, WHITE,
                                    EMPTY, F, THREE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, C, FOUR, WHITE,
                                    EMPTY, B, FOUR, BLACK,
                                    EMPTY, A, FOUR, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, F, FOUR, WHITE,
                                    KNIGHT, E, FOUR, WHITE,
                                    EMPTY, D, FOUR, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, A, FIVE, WHITE,
                                    EMPTY, H, FOUR, WHITE,
                                    EMPTY, G, FOUR, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, D, FIVE, WHITE,
                                    EMPTY, C, FIVE, WHITE,
                                    EMPTY, B, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    ROOK, G, FIVE, BLACK,
                                    EMPTY, F, FIVE, WHITE,
                                    EMPTY, E, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, B, SIX, WHITE,
                                    EMPTY, A, SIX, WHITE,
                                    EMPTY, H, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, E, SIX, WHITE,
                                    EMPTY, D, SIX, WHITE,
                                    EMPTY, C, SIX, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, H, SIX, WHITE,
                                    EMPTY, G, SIX, WHITE,
                                    EMPTY, F, SIX, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, C, SEVEN, BLACK,
                                    EMPTY, B, SEVEN, WHITE,
                                    EMPTY, A, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, F, SEVEN, BLACK,
                                    EMPTY, E, SEVEN, WHITE,
                                    EMPTY, D, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, A, EIGHT, BLACK,
                                    EMPTY, H, SEVEN, BLACK,
                                    EMPTY, G, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, D, EIGHT, BLACK,
                                    EMPTY, C, EIGHT, BLACK,
                                    EMPTY, B, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, G, EIGHT, BLACK,
                                    EMPTY, F, EIGHT, BLACK,
                                    EMPTY, E, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   WHITE,  // who's turn?
                                    1'b0,   // reserved
                                    4'h0,   // castle rights
                                    16'h0000,  // en passant flags
                                    EMPTY, H, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata_dav = 0;
        wait(fpga_cpu_interrupt);
        $display("\nTime: %0t", $time);
        if(capture_moves > 10'd1 || quiet_moves > 10'd7)
            $display("ERROR (TEST 7): Too many moves!");
        else
            $display("PASS  (TEST 7): Got 7 quiet and 1 capture horse moves");
        #100
        rst = 0;
        ////////////////////////////////////////////////////////////////////////
        //              TEST 8: ROOK, BISHOP, AND QUEEN STOPPED BY CAPTURE
        ////////////////////////////////////////////////////////////////////////
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, C, ONE, WHITE,
                                    EMPTY, B, ONE, WHITE,
                                    EMPTY, A, ONE, WHITE
                                };
        #10
        rst = 1;
        cpu_fpga_fifo_empty = 0;
        cpu_fpga_fifo_rdata_dav = 1;
        // 20 to get into recieve state
        #20
        cpu_fpga_fifo_empty = 1;
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, F, ONE, WHITE,
                                    EMPTY, E, ONE, WHITE,
                                    EMPTY, D, ONE, WHITE
                                };

        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, A, TWO, WHITE,
                                    EMPTY, H, ONE, WHITE,
                                    EMPTY, G, ONE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, D, TWO, WHITE,
                                    BISHOP, C, TWO, BLACK,
                                    EMPTY, B, TWO, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, G, TWO, WHITE,
                                    EMPTY, F, TWO, WHITE,
                                    ROOK, E, TWO, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, B, THREE, WHITE,
                                    EMPTY, A, THREE, WHITE,
                                    EMPTY, H, TWO, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, E, THREE, WHITE,
                                    EMPTY, D, THREE, WHITE,
                                    EMPTY, C, THREE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, H, THREE, WHITE,
                                    EMPTY, G, THREE, WHITE,
                                    EMPTY, F, THREE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, C, FOUR, WHITE,
                                    EMPTY, B, FOUR, BLACK,
                                    EMPTY, A, FOUR, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, F, FOUR, WHITE,
                                    KNIGHT, E, FOUR, WHITE,
                                    EMPTY, D, FOUR, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, A, FIVE, WHITE,
                                    EMPTY, H, FOUR, WHITE,
                                    EMPTY, G, FOUR, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, D, FIVE, WHITE,
                                    EMPTY, C, FIVE, WHITE,
                                    EMPTY, B, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, G, FIVE, BLACK,
                                    EMPTY, F, FIVE, WHITE,
                                    EMPTY, E, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, B, SIX, WHITE,
                                    EMPTY, A, SIX, WHITE,
                                    EMPTY, H, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, E, SIX, WHITE,
                                    EMPTY, D, SIX, WHITE,
                                    EMPTY, C, SIX, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, H, SIX, WHITE,
                                    EMPTY, G, SIX, WHITE,
                                    EMPTY, F, SIX, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, C, SEVEN, BLACK,
                                    EMPTY, B, SEVEN, WHITE,
                                    EMPTY, A, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, F, SEVEN, BLACK,
                                    EMPTY, E, SEVEN, WHITE,
                                    EMPTY, D, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, A, EIGHT, BLACK,
                                    QUEEN, H, SEVEN, BLACK,
                                    EMPTY, G, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, D, EIGHT, BLACK,
                                    EMPTY, C, EIGHT, BLACK,
                                    EMPTY, B, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, G, EIGHT, BLACK,
                                    EMPTY, F, EIGHT, BLACK,
                                    EMPTY, E, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   BLACK,  // who's turn?
                                    1'b0,   // reserved
                                    4'h0,   // castle rights
                                    16'h0000,  // en passant flags
                                    EMPTY, H, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata_dav = 0;
        wait(fpga_cpu_interrupt);
        $display("\nTime: %0t", $time);
        if(capture_moves > 10'd3 || quiet_moves > 10'd28)
            $display("ERROR (TEST 8): Too many moves!");
        else
            $display("PASS  (TEST 8): Got 28 quiet and 3 capture moves using bishop, rook, and queen");
        #100
        rst = 0;
        ////////////////////////////////////////////////////////////////////////
        //              TEST 9: r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq -
        ////////////////////////////////////////////////////////////////////////
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, C, ONE, WHITE,
                                    EMPTY, B, ONE, WHITE,
                                    ROOK, A, ONE, WHITE
                                };
        #10
        rst = 1;
        cpu_fpga_fifo_empty = 0;
        cpu_fpga_fifo_rdata_dav = 1;
        // 20 to get into recieve state
        #20
        cpu_fpga_fifo_empty = 1;
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, F, ONE, WHITE,
                                    KING, E, ONE, WHITE,
                                    EMPTY, D, ONE, WHITE
                                };

        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, A, TWO, WHITE,
                                    ROOK, H, ONE, WHITE,
                                    EMPTY, G, ONE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    BISHOP, D, TWO, WHITE,
                                    PAWN, C, TWO, WHITE,
                                    PAWN, B, TWO, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, G, TWO, WHITE,
                                    PAWN, F, TWO, WHITE,
                                    BISHOP, E, TWO, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, B, THREE, WHITE,
                                    EMPTY, A, THREE, WHITE,
                                    PAWN, H, TWO, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, E, THREE, WHITE,
                                    EMPTY, D, THREE, WHITE,
                                    KNIGHT, C, THREE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, H, THREE, BLACK,
                                    EMPTY, G, THREE, WHITE,
                                    QUEEN, F, THREE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, C, FOUR, WHITE,
                                    PAWN, B, FOUR, BLACK,
                                    EMPTY, A, FOUR, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, F, FOUR, WHITE,
                                    PAWN, E, FOUR, WHITE,
                                    EMPTY, D, FOUR, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, A, FIVE, WHITE,
                                    EMPTY, H, FOUR, WHITE,
                                    EMPTY, G, FOUR, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, D, FIVE, WHITE,
                                    EMPTY, C, FIVE, WHITE,
                                    EMPTY, B, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, G, FIVE, BLACK,
                                    EMPTY, F, FIVE, WHITE,
                                    KNIGHT, E, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    KNIGHT, B, SIX, BLACK,
                                    BISHOP, A, SIX, BLACK,
                                    EMPTY, H, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, E, SIX, BLACK,
                                    EMPTY, D, SIX, WHITE,
                                    EMPTY, C, SIX, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, H, SIX, WHITE,
                                    PAWN, G, SIX, BLACK,
                                    KNIGHT, F, SIX, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, C, SEVEN, BLACK,
                                    EMPTY, B, SEVEN, WHITE,
                                    PAWN, A, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, F, SEVEN, BLACK,
                                    QUEEN, E, SEVEN, BLACK,
                                    PAWN, D, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    ROOK, A, EIGHT, BLACK,
                                    EMPTY, H, SEVEN, BLACK,
                                    BISHOP, G, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, D, EIGHT, BLACK,
                                    EMPTY, C, EIGHT, BLACK,
                                    EMPTY, B, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, G, EIGHT, BLACK,
                                    EMPTY, F, EIGHT, BLACK,
                                    KING, E, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   WHITE,  // who's turn?
                                    1'b0,   // reserved
                                    4'hF,   // castle rights
                                    16'h0000,  // en passant flags
                                    ROOK, H, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata_dav = 0;
        wait(fpga_cpu_interrupt);
        $display("\nTime: %0t", $time);
        if(capture_moves > 10'd8 || quiet_moves > 10'd38 || castle_moves > 10'd2)
            $display("ERROR (TEST 9): Too many moves!");
        else
            $display("PASS  (TEST 9): Got 38 quiet, 8 capture, 2 castle from random game state");
        #100
        rst = 0;
        ////////////////////////////////////////////////////////////////////////
        //              TEST 10: 5RKb/4P1n1/2p4p/3p2p1/3B2Q1/5B2/r6k/4r3 w - -
        ////////////////////////////////////////////////////////////////////////
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, C, ONE, WHITE,
                                    EMPTY, B, ONE, WHITE,
                                    EMPTY, A, ONE, WHITE
                                };
        #10
        rst = 1;
        cpu_fpga_fifo_empty = 0;
        cpu_fpga_fifo_rdata_dav = 1;
        // 20 to get into recieve state
        #20
        cpu_fpga_fifo_empty = 1;
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, F, ONE, WHITE,
                                    ROOK, E, ONE, BLACK,
                                    EMPTY, D, ONE, WHITE
                                };

        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    ROOK, A, TWO, BLACK,
                                    EMPTY, H, ONE, WHITE,
                                    EMPTY, G, ONE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, D, TWO, WHITE,
                                    EMPTY, C, TWO, WHITE,
                                    EMPTY, B, TWO, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, G, TWO, WHITE,
                                    EMPTY, F, TWO, WHITE,
                                    EMPTY, E, TWO, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, B, THREE, WHITE,
                                    EMPTY, A, THREE, WHITE,
                                    KING, H, TWO, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, E, THREE, WHITE,
                                    EMPTY, D, THREE, WHITE,
                                    EMPTY, C, THREE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, H, THREE, BLACK,
                                    EMPTY, G, THREE, WHITE,
                                    BISHOP, F, THREE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, C, FOUR, WHITE,
                                    EMPTY, B, FOUR, BLACK,
                                    EMPTY, A, FOUR, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, F, FOUR, WHITE,
                                    EMPTY, E, FOUR, WHITE,
                                    BISHOP, D, FOUR, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, A, FIVE, WHITE,
                                    EMPTY, H, FOUR, WHITE,
                                    QUEEN, G, FOUR, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, D, FIVE, BLACK,
                                    EMPTY, C, FIVE, WHITE,
                                    EMPTY, B, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, G, FIVE, BLACK,
                                    EMPTY, F, FIVE, WHITE,
                                    EMPTY, E, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, B, SIX, BLACK,
                                    EMPTY, A, SIX, BLACK,
                                    EMPTY, H, FIVE, WHITE
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, E, SIX, BLACK,
                                    EMPTY, D, SIX, WHITE,
                                    PAWN, C, SIX, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    PAWN, H, SIX, BLACK,
                                    EMPTY, G, SIX, BLACK,
                                    EMPTY, F, SIX, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, C, SEVEN, BLACK,
                                    EMPTY, B, SEVEN, WHITE,
                                    EMPTY, A, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, F, SEVEN, BLACK,
                                    PAWN, E, SEVEN, WHITE,
                                    EMPTY, D, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, A, EIGHT, BLACK,
                                    EMPTY, H, SEVEN, BLACK,
                                    KNIGHT, G, SEVEN, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    EMPTY, D, EIGHT, BLACK,
                                    EMPTY, C, EIGHT, BLACK,
                                    EMPTY, B, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   2'd0,
                                    KING, G, EIGHT, WHITE,
                                    ROOK, F, EIGHT, WHITE,
                                    EMPTY, E, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata =   {   WHITE,  // who's turn?
                                    1'b0,   // reserved
                                    4'h0,   // castle rights
                                    16'h0000,  // en passant flags
                                    BISHOP, H, EIGHT, BLACK
                                };
        #10
        cpu_fpga_fifo_rdata_dav = 0;
        wait(fpga_cpu_interrupt);
        $display("\nTime: %0t", $time);
        // CAUTION! This is includes an illegal king move because the generator only does pseudolegal moves
        if(capture_moves > 10'd5 || promotion_moves > 10'd1 || quiet_moves > 10'd39)
            $display("ERROR (TEST10): Too many moves! Quiet: %0d, Capture: %0d, Promotions: %0d",
                quiet_moves, capture_moves, promotion_moves);
        else
            $display("PASS  (TEST10): Got 39 quiet, 5 capture (1 pseudolegal), 1 promotion from random game state");
        #100
        rst = 0;
    end

endmodule
