module tb_rx;
`include "../zezima.vh"

    reg     [159:0] move;
    reg     [9:0]   dest_piece;
    reg             collect_pieces;
    reg             clk;
    reg             rst;

    wire    [79:0]  rx_tx_pcs;
    wire    [7:0]   rx_tx_valid;
    wire    [255:0] formatted_moves;
    wire    [15:0]  stack_write;

    rx dut (
        .move           (move),
        .dest_piece     (dest_piece),
        .collect_pieces (collect_pieces),
        .clk            (clk),
        .rst            (rst),
        .rx_tx_pcs      (rx_tx_pcs),
        .rx_tx_valid    (rx_tx_valid),
        .formatted_moves(formatted_moves),
        .stack_write    (stack_write)
    );

    initial begin
		clk = 0;
		forever
			#10 clk = ~clk;
	end

    initial begin
        rst = 1;
        move = 0;
        dest_piece = 0;
        collect_pieces = 0;
        #15
        rst = 0;
        #10
        rst = 1;
    end

endmodule
