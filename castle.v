/*******************************************************************************
Filename: castle.v
Author: Kyle

Description: This module is combinational logic that determines which of the
four castling scenarios, if any, are available moves. Takes top and bottom row
as inputs along with castling right flags. Outputs up to all four moves
simultaneously on one 64-bit bus along with a one-hot valid signal.

Piece Format: MSB {type, column, row, color} LSB
Move  Format: MSB {1'b0, castle, promo, capture, src_col, src_row, dest_col, dest_row}

Flag Bit / Castle Valid Decode:
    0 - white queenside
    1 - white kingside
    2 - black queenside
    3 - black kingside
*******************************************************************************/
module castle (
    input       [3:0]       flags,  // one bit for each castle
    input       [79:0]      row_1,  // MSB: A1, LSB: H1
    input       [79:0]      row_8,  // MSB: A8, LSB: H8
    input                   turn,
    output  reg [3:0]       castle_valid,   // one hot valid signal for all 4
    output  reg [63:0]      castle_moves    // all the moves
    );
`include "zezima.vh"

    // Determines if board allows castling for white
    wire h1_valid = (row_1[79:70] == {ROOK, H, ONE, WHITE}) ? 1'b1 : 1'b0;
    wire g1_valid = (row_1[69:67] == EMPTY) ? 1'b1 : 1'b0;
    wire f1_valid = (row_1[59:57] == EMPTY) ? 1'b1 : 1'b0;
    wire e1_valid = (row_1[49:40] == {KING, E, ONE, WHITE}) ? 1'b1 : 1'b0;
    wire d1_valid = (row_1[39:37] == EMPTY) ? 1'b1 : 1'b0;
    wire c1_valid = (row_1[29:27] == EMPTY) ? 1'b1 : 1'b0;
    wire b1_valid = (row_1[19:17] == EMPTY) ? 1'b1 : 1'b0;
    wire a1_valid = (row_1[ 9: 0] == {ROOK, A, ONE, WHITE}) ? 1'b1 : 1'b0;

    // Determines if board allows castling for black
    wire h8_valid = (row_8[79:70] == {ROOK, H, EIGHT, BLACK}) ? 1'b1 : 1'b0;
    wire g8_valid = (row_8[69:67] == EMPTY) ? 1'b1 : 1'b0;
    wire f8_valid = (row_8[59:57] == EMPTY) ? 1'b1 : 1'b0;
    wire e8_valid = (row_8[49:40] == {KING, E, EIGHT, BLACK}) ? 1'b1 : 1'b0;
    wire d8_valid = (row_8[39:37] == EMPTY) ? 1'b1 : 1'b0;
    wire c8_valid = (row_8[29:27] == EMPTY) ? 1'b1 : 1'b0;
    wire b8_valid = (row_8[19:17] == EMPTY) ? 1'b1 : 1'b0;
    wire a8_valid = (row_8[ 9: 0] == {ROOK, A, EIGHT, BLACK}) ? 1'b1 : 1'b0;

    // Consolidates above information into 4 valid signals
    wire white_queenside = a1_valid & b1_valid & c1_valid & d1_valid & e1_valid;
    wire white_kingside = e1_valid & f1_valid & g1_valid & h1_valid;
    wire black_queenside = a8_valid & b8_valid & c8_valid & d8_valid & e8_valid;
    wire black_kingside = e8_valid & f8_valid & g8_valid & h8_valid;

    // Formats the outputs
    always @ (*) begin
        castle_valid = 1'b0;
        castle_moves = 64'd0;

        if(flags[0] & white_queenside & (turn == WHITE)) begin
            castle_moves[15:0]  = {2'd1, 2'd0, E, ONE, C, ONE};
            castle_valid[0]     = 1'b1;
        end

        if(flags[1] & white_kingside & (turn == WHITE)) begin
            castle_moves[31:16]  = {2'd1, 2'd0, E, ONE, G, ONE};
            castle_valid[1]     = 1'b1;
        end

        if(flags[2] & black_queenside & (turn == BLACK)) begin
            castle_moves[47:32]  = {2'd1, 2'd0, E, EIGHT, C, EIGHT};
            castle_valid[2]     = 1'b1;
        end

        if(flags[3] & black_kingside & (turn == BLACK)) begin
            castle_moves[63:48]  = {2'd1, 2'd0, E, EIGHT, G, EIGHT};
            castle_valid[3]     = 1'b1;
        end
    end

endmodule
