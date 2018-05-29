/*******************************************************************************
Filename: move_checker.v
Author: Kyle

Description: This module is combinational logic that compares the dest
piece on the square with a piece passed in on one of the ports. It will format
and give a valid signal for the move to store. It will also indicate to the
transfer logic where and if this piece can be passed along in the event of an
empty square. Also calculates promos and captures.

Piece Format: MSB {type, column, row, color} LSB
Move  Format: MSB {1'b0, castle, promo, capture, src_col, src_row, dest_col, dest_row}
*******************************************************************************/
module move_checker (
    input       [9:0]   src_piece,
    input       [9:0]   dest_piece,
    input               turn,
    output reg          valid,
    output reg          slide_valid,
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
    reg promo;

    assign formatted_move = {   2'b0,
		                        promo,
                                capture,
                                src_col,
                                src_row,
                                dest_col,
                                dest_row
                            };

    always @ (*)
    begin
        capture = 1'b0;
        promo = 1'b0;
        valid = 1'b0;
        slide_valid = 1'b0;

        if(dest_type != INVALID && src_color == turn) begin
            //******************************************************************
            //  Pawn
            //******************************************************************
            if(src_type == PAWN)
            begin
                if(dest_type == EMPTY || src_color != dest_color)
                begin
                    if(src_color == WHITE)
                    begin
                        // Double square first move
                        if(src_row == TWO && dest_row == THREE && dest_type == EMPTY
                            && src_col == dest_col)
                        begin
                            slide_valid = 1'b1;
                        end

                        // Move forward
                        if(dest_col == src_col
                            && dest_type == EMPTY
                            && ((src_row + 3'd1) == dest_row))
                        begin
                            if(dest_row == EIGHT)
                                promo = 1'b1;

                            valid = 1'b1;
                        end
                        // Move forward (second square)
                        else if(dest_col == src_col
                            && dest_type == EMPTY
                            && src_row == TWO
                            && dest_row == FOUR)
                        begin
                            valid = 1'b1;
                        end
                        // Move diagonal to capture
                        else if (dest_type != EMPTY
                            && src_color != dest_color
                            && ((src_row + 3'd1) == dest_row)
                            && ((src_col + 3'd1) == dest_col || (src_col - 3'd1) == dest_col))
                        begin
                            if(dest_row == EIGHT)
                                promo = 1'b1;

                            valid = 1'b1;
                            capture = 1'b1;
                        end
                    end // white pawn

                    else //black pawn
                    begin
                        // Double square first move
                        if(src_row == SEVEN && dest_row == SIX && dest_type == EMPTY
                            && src_col == dest_col)
                        begin
                            slide_valid = 1'b1;
                        end

                        // Move forward
                        if(dest_col == src_col
                            && dest_type == EMPTY
                            && ((src_row - 3'd1) == dest_row))
                        begin
                            if(dest_row == ONE)
                                promo = 1'b1;

                            valid = 1'b1;
                        end
                        // Move forward (second square)
                        else if(dest_col == src_col
                            && dest_type == EMPTY
                            && src_row == SEVEN
                            && dest_row == FIVE)
                        begin
                            valid = 1'b1;
                        end
                        // Move diagonal to capture
                        else if (dest_type != EMPTY
                            && src_color != dest_color
                            && ((src_row - 3'd1) == dest_row)
                            && ((src_col + 3'd1) == dest_col || (src_col - 3'd1) == dest_col))
                        begin
                            if(dest_row == ONE)
                                promo = 1'b1;

                            valid = 1'b1;
                            capture = 1'b1;
                        end
                    end // black pawn
                end // empty square or colors don't match
            end

            //******************************************************************
            //   Rook
            //******************************************************************
            else if (src_type == ROOK)
            begin
                if(src_row == dest_row || src_col == dest_col)
                begin
                    if(dest_type == EMPTY) begin
                        valid = 1'b1;
                        slide_valid = 1'b1;
                    end

                    else if (src_color != dest_color) begin
                        valid = 1'b1;
                        capture = 1'b1;
                    end
                end
            end

            //******************************************************************
            //   King
            //******************************************************************
            else if (src_type == KING)
            begin
                if((src_row - dest_row != 2)
                    && (src_col - dest_col != 2)
                    && (dest_col - src_col != 2)
                    && (dest_row - src_row != 2))
                begin
                    if(dest_type == EMPTY)
                        valid = 1'b1;
                    else if(src_color != dest_color && dest_type != EMPTY)
                    begin
                        valid = 1'b1;
                        capture = 1'b1;
                    end
                end
            end

            //******************************************************************
            //   Bishop
            //******************************************************************
            else if (src_type == BISHOP)
            begin
                if(src_row != dest_row && src_col != dest_col)
                begin
                    if(dest_type == EMPTY)
                    begin
                        valid = 1'b1;
                        slide_valid = 1'b1;
                    end

                    else if(src_color != dest_color)
                    begin
                        valid = 1'b1;
                        capture = 1'b1;
                    end
                end
            end

            //******************************************************************
            //   Queen
            //******************************************************************
            else if (src_type == QUEEN)
            begin
                if(dest_type == EMPTY)
                begin
                    valid = 1'b1;
                    slide_valid = 1'b1;
                end

                else if(src_color != dest_color)
                begin
                    valid = 1'b1;
                    capture = 1'b1;
                end
            end //end queen
        end // end dest_type != invalid
    end // end combinational logic

endmodule
