module tb_tx;
`include "../zezima.vh"

    reg     [79:0]  rx_tx_pcs;
    reg     [7:0]   rx_tx_valid;
    reg     [9:0]   original_piece;
    reg             new_original;
    reg             collect_pieces;
    reg             clk;
    reg             rst;
    wire    [159:0] move;

    tx dut (
        .rx_tx_pcs      (rx_tx_pcs),
        .rx_tx_valid    (rx_tx_valid),
        .original_piece (original_piece),
        .new_original   (new_original),
        .collect_pieces (collect_pieces),
        .clk            (clk),
        .rst            (rst),
        .move           (move)
    );

    initial begin
		clk = 0;
		forever
			#10 clk = ~clk;
	end

    initial begin
        rst = 1;
        rx_tx_pcs = 0;
        rx_tx_valid = 0;
        original_piece = 0;
        new_original = 0;
        collect_pieces = 0;
        #15
        rst = 0;
        original_piece = {PAWN, C, FOUR, WHITE};
        rx_tx_pcs = {10'd0, ROOK, C, ONE, WHITE, 30'd0, BISHOP, D, FIVE, BLACK, 20'd0};
        #10
        rst = 1;
        #20
        new_original = 1;
        #20
        new_original = 0;
        collect_pieces = 1;
        #20
        rx_tx_valid = 8'b0100_0100;
        collect_pieces = 0;
    end

endmodule
