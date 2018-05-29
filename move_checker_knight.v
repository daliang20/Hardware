/*******************************************************************************
Filename: move_checker_knight.v
Author: Kyle

Description: Simplified move checker that only handles knights.

    Piece Format: MSB {type, column, row, color} LSB
    Move  Format: MSB {2'b0, promo, capture, src_col, src_row, dest_col, dest_row}
*******************************************************************************/
module move_checker_knight (
    input       [9:0]   src_piece,
    input       [9:0]   dest_piece,
    input               turn,
    output reg          valid,
    output      [15:0]  formatted_move
    );
`include "zezima.vh"

    // The piece that began on this square
    wire            dest_color  = dest_piece[0];
    wire    [2:0]   dest_row    = dest_piece[3:1];
    wire    [2:0]   dest_col    = dest_piece[6:4];
    wire    [2:0]   dest_type   = dest_piece[9:7];

    // The piece that has srcly been slid into the square
    wire            src_color   = src_piece[0];
    wire    [2:0]   src_row     = src_piece[3:1];
    wire    [2:0]   src_col     = src_piece[6:4];
    wire    [2:0]   src_type    = src_piece[9:7];

    reg capture;

    assign formatted_move = {   2'b0,
		                        1'b0, //promo
                                capture,
                                src_col,
                                src_row,
                                dest_col,
                                dest_row
                            };

    always @ (*)
    begin
        capture = 1'b0;
        valid = 1'b0;

        if(dest_type != INVALID && src_type == KNIGHT && src_color == turn)
        begin
            if (dest_type == EMPTY)
                valid = 1'b1;
            else if(src_color != dest_color)
            begin
                capture = 1'b1;
                valid = 1'b1;
            end
        end
    end

endmodule
