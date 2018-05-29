//do this eventually
module tb_square;
`include "../zezima.vh"

    reg             clk;
    reg             rst;
    reg             collect_pieces;
    reg             stack_read;
    reg     [9:0]   original_piece;
    reg             new_original;
    reg     [159:0] rx_moves;
    wire    [15:0]  stack_arbiter;
    wire            stack_empty;
    wire    [159:0] tx_moves;

    square sq (
        .clk                (clk),
        .rst                (rst),
        .collect_pieces     (collect_pieces),
        .stack_read         (stack_read),
        .original_piece     (original_piece),
        .new_original       (new_original),
        .rx_moves           (rx_moves),
        .stack_arbiter      (stack_arbiter),
        .stack_empty        (stack_empty),
        .tx_moves           (tx_moves)
    );

    initial begin
		clk = 0;
		forever
			#10 clk = ~clk;
	end

    // Piece Format: MSB {type, column, row, color} LSB
    // Move  Format: MSB {2'b0, promo, capture, src_col, src_row, dest_col, dest_row}
    // Tests sliding, captures, promotions, and normal moves for all piece types
    initial begin
        integer i;
        rst = 0;
        collect_pieces = 0;
        original_piece = 0;
        stack_read = 0;
        new_original = 0;
        for(i = 0; i < 16; i = i + 1)
            rx_moves[i] = 0;

        // Turn off reset and prepare original piece
        #15
        rst = 1;
        original_piece = {PAWN,C,FOUR,WHITE};

        //Initalize original piece and setup a few incoming pieces
        #10
        new_original = 1;
        rx_moves[0] = {KNIGHT,C,THREE,BLACK}; //invalid
        rx_moves[1] = {KNIGHT,D,FOUR,WHITE}; //invalid
        rx_moves[2] = {BISHOP,C,FIVE,BLACK}; //invalid
        rx_moves[3] = {ROOK,B,FOUR,BLACK}; // VALID! Rook takes pawn
        rx_moves[4] = {BISHOP,B,FIVE,BLACK}; //Valid! Bishop takes pawn

        // Collect incoming pieces
        #10
        new_original = 0;
        collect_pieces = 1;
        #10
        collect_pieces = 0;

        // Check that the stack can be read
        #160
        stack_read = 1;
        #10
        stack_read = 0;

        // Finish up
        #30
        rst = 0;
    end

endmodule
