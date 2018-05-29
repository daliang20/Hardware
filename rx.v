/*******************************************************************************
Filename: rx.v
Author: Kyle

Description: Takes in pieces from all surrounding directions, as outlined below.
Finds any valid moves to send to stack and also rx_txs along any valid pieces to
the Tx module.
*******************************************************************************/
module rx (
    input       [159:0] moves,
    input       [3:0]   direction_idx,
    input       [9:0]   dest_piece,
    input               collect_pieces,
    input               clk,
    input               rst,
    input               turn,
    output              rx_tx_valid,
    output      [15:0]  formatted_move,
    output              stack_write,
    output      [9:0]   rx_tx_piece
    );

    // Internal signals
    wire    [15:0]  formatted_move_knight, formatted_move_normal;
    wire    [9:0]   p_out       [15:0];
    wire            rx_tx_valid_normal;
    wire            stack_write_knight, stack_write_normal;
    wire            knight_moves;

    reg     [9:0]   src_piece;

    /* debugging wires */
    wire    [9:0]   up          = p_out[0];
    wire    [9:0]   right       = p_out[1];
    wire    [9:0]   down        = p_out[2];
    wire    [9:0]   left        = p_out[3];
    wire    [9:0]   up_left     = p_out[4];
    wire    [9:0]   up_right    = p_out[5];
    wire    [9:0]   down_right  = p_out[6];
    wire    [9:0]   down_left   = p_out[7];
    wire    [9:0]   k2up1left   = p_out[8];
    wire    [9:0]   k2up1right  = p_out[9];
    wire    [9:0]   k2right1up  = p_out[10];
    wire    [9:0]   k2right1down= p_out[11];
    wire    [9:0]   k2down1right= p_out[12];
    wire    [9:0]   k2down1left = p_out[13];
    wire    [9:0]   k2left1down = p_out[14];
    wire    [9:0]   k2left1up   = p_out[15];

    // Output assignments
    assign rx_tx_piece = src_piece;
    assign formatted_move = knight_moves ? formatted_move_knight : formatted_move_normal;
    assign stack_write = knight_moves ? stack_write_knight : stack_write_normal;
    assign rx_tx_valid = knight_moves ? 1'b0 : rx_tx_valid_normal;

    // Internal assignments
    assign knight_moves = direction_idx[3];

    // Source piece mux
    always @(*) begin
        case(direction_idx)
            4'd0 : src_piece = p_out[ 0];
            4'd1 : src_piece = p_out[ 1];
            4'd2 : src_piece = p_out[ 2];
            4'd3 : src_piece = p_out[ 3];
            4'd4 : src_piece = p_out[ 4];
            4'd5 : src_piece = p_out[ 5];
            4'd6 : src_piece = p_out[ 6];
            4'd7 : src_piece = p_out[ 7];
            4'd8 : src_piece = p_out[ 8];
            4'd9 : src_piece = p_out[ 9];
            4'd10: src_piece = p_out[10];
            4'd11: src_piece = p_out[11];
            4'd12: src_piece = p_out[12];
            4'd13: src_piece = p_out[13];
            4'd14: src_piece = p_out[14];
            4'd15: src_piece = p_out[15];
            default: src_piece = 10'd0;
        endcase
    end

    // Generates the piece registers
    genvar i;
    generate
        for(i = 0; i < 16; i = i + 1) begin : piece_registers
            piece_reg p (
                .in     (moves[(i*10)+9:(i*10)]),
                .enable (collect_pieces),
                .clk    (clk),
                .rst    (rst),
                .out    (p_out[i])
            );
        end
    endgenerate

    // Move checking hardware
    move_checker mc_slide (
        .src_piece      (src_piece),
        .dest_piece     (dest_piece),
        .valid          (stack_write_normal),
        .slide_valid    (rx_tx_valid_normal),
        .formatted_move (formatted_move_normal),
        .turn           (turn)
    );
    move_checker_knight mc_knight (
        .src_piece      (src_piece),
        .dest_piece     (dest_piece),
        .valid          (stack_write_knight),
        .formatted_move (formatted_move_knight),
        .turn           (turn)
    );

endmodule
