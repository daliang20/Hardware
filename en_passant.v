/*******************************************************************************
Filename: en_passant.v
Author: Kyle

Description: This module is combinational logic that looks for en-passant moves
given valid flags. If the software has indicated the other side just moved a
pawn 2 spaces, then this hardware will determine if current side can capture.

Piece Format: MSB {type, column, row, color} LSB
Move  Format: MSB {1'b0, castle, promo, capture, src_col, src_row, dest_col, dest_row}
*******************************************************************************/
module en_passant (
    input       [15:0]  enp_flags,  // MSB:a4...h4,a5...h5:LSB
    input       [79:0]  row_4,
    input       [79:0]  row_5,
    output reg  [1:0]   enp_valid,  // one-hot for each of two possible moves
    output reg  [31:0]  enp_moves
);
`include "zezima.vh"

    // Determines which pieces are valid for black takes white
    wire h4_valid = (row_4[79:77] == PAWN) & (row_4[70] == BLACK);
    wire g4_valid = (row_4[69:67] == PAWN) & (row_4[60] == BLACK);
    wire f4_valid = (row_4[59:57] == PAWN) & (row_4[50] == BLACK);
    wire e4_valid = (row_4[49:47] == PAWN) & (row_4[40] == BLACK);
    wire d4_valid = (row_4[39:37] == PAWN) & (row_4[30] == BLACK);
    wire c4_valid = (row_4[29:27] == PAWN) & (row_4[20] == BLACK);
    wire b4_valid = (row_4[19:17] == PAWN) & (row_4[10] == BLACK);
    wire a4_valid = (row_4[ 9: 7] == PAWN) & (row_4[ 0] == BLACK);

    // Determines which pieces are valid for white takes black
    wire h5_valid = (row_5[79:77] == PAWN) & (row_5[70] == WHITE);
    wire g5_valid = (row_5[69:67] == PAWN) & (row_5[60] == WHITE);
    wire f5_valid = (row_5[59:57] == PAWN) & (row_5[50] == WHITE);
    wire e5_valid = (row_5[49:47] == PAWN) & (row_5[40] == WHITE);
    wire d5_valid = (row_5[39:37] == PAWN) & (row_5[30] == WHITE);
    wire c5_valid = (row_5[29:27] == PAWN) & (row_5[20] == WHITE);
    wire b5_valid = (row_5[19:17] == PAWN) & (row_5[10] == WHITE);
    wire a5_valid = (row_5[ 9: 7] == PAWN) & (row_5[ 0] == WHITE);

    always @ (*) begin
        if(~(|enp_flags)) begin
            enp_valid = 2'd0;
            enp_moves = 32'd0;
        end
        else begin

            enp_valid = 2'd0;
            enp_moves = 32'd0;

            case(enp_flags)
                ///////////
                // ROW 4 //
                ///////////

                // A4
                16'h8000: begin
                    if(b4_valid) begin
                        enp_valid = 2'd1;
                        enp_moves = {16'd0, 4'd1, B, FOUR, A, THREE};
                    end
                end
                // B4
                16'h4000: begin
                    if(a4_valid) begin
                        enp_valid[1] = 1'b1;
                        enp_moves[31:16] = {4'd1, A, FOUR, B, THREE};
                    end
                    if(c4_valid) begin
                        enp_valid[0] = 1'b1;
                        enp_moves[15: 0] = {4'd1, C, FOUR, B, THREE};
                    end
                end
                // C4
                16'h2000: begin
                    if(b4_valid) begin
                        enp_valid[1] = 1'b1;
                        enp_moves[31:16] = {4'd1, B, FOUR, C, THREE};
                    end
                    if(d4_valid) begin
                        enp_valid[0] = 1'b1;
                        enp_moves[15: 0] = {4'd1, D, FOUR, C, THREE};
                    end
                end
                // D4
                16'h1000: begin
                    if(c4_valid) begin
                        enp_valid[1] = 1'b1;
                        enp_moves[31:16] = {4'd1, C, FOUR, D, THREE};
                    end
                    if(e4_valid) begin
                        enp_valid[0] = 1'b1;
                        enp_moves[15: 0] = {4'd1, E, FOUR, D, THREE};
                    end
                end
                // E4
                16'h0800: begin
                    if(d4_valid) begin
                        enp_valid[1] = 1'b1;
                        enp_moves[31:16] = {4'd1, D, FOUR, E, THREE};
                    end
                    if(f4_valid) begin
                        enp_valid[0] = 1'b1;
                        enp_moves[15: 0] = {4'd1, F, FOUR, E, THREE};
                    end
                end
                // F4
                16'h0400: begin
                    if(e4_valid) begin
                        enp_valid[1] = 1'b1;
                        enp_moves[31:16] = {4'd1, E, FOUR, F, THREE};
                    end
                    if(g4_valid) begin
                        enp_valid[0] = 1'b1;
                        enp_moves[15: 0] = {4'd1, G, FOUR, F, THREE};
                    end
                end
                // G4
                16'h0200: begin
                    if(f4_valid) begin
                        enp_valid[1] = 1'b1;
                        enp_moves[31:16] = {4'd1, F, FOUR, G, THREE};
                    end
                    if(h4_valid) begin
                        enp_valid[0] = 1'b1;
                        enp_moves[15: 0] = {4'd1, H, FOUR, G, THREE};
                    end
                end
                // H4
                16'h0100: begin
                    if(g4_valid) begin
                        enp_valid = 2'd1;
                        enp_moves = {16'd0, 4'd1, G, FOUR, H, THREE};
                    end
                end


                ///////////
                // ROW 5 //
                ///////////

                // A5
                16'h0080: begin
                    if(b5_valid) begin
                        enp_valid = 2'd1;
                        enp_moves = {16'd0, 4'd1, B, FIVE, A, SIX};
                    end
                end
                // B5
                16'h0040: begin
                    if(a5_valid) begin
                        enp_valid[1] = 1'b1;
                        enp_moves[31:16] = {4'd1, A, FIVE, B, SIX};
                    end
                    if(c5_valid) begin
                        enp_valid[0] = 1'b1;
                        enp_moves[15: 0] = {4'd1, C, FIVE, B, SIX};
                    end
                end
                // C5
                16'h0020: begin
                    if(b5_valid) begin
                        enp_valid[1] = 1'b1;
                        enp_moves[31:16] = {4'd1, B, FIVE, C, SIX};
                    end
                    if(d5_valid) begin
                        enp_valid[0] = 1'b1;
                        enp_moves[15: 0] = {4'd1, D, FIVE, C, SIX};
                    end
                end
                // D5
                16'h0010: begin
                    if(c5_valid) begin
                        enp_valid[1] = 1'b1;
                        enp_moves[31:16] = {4'd1, C, FIVE, D, SIX};
                    end
                    if(e5_valid) begin
                        enp_valid[0] = 1'b1;
                        enp_moves[15: 0] = {4'd1, E, FIVE, D, SIX};
                    end
                end
                // E5
                16'h0008: begin
                    if(d5_valid) begin
                        enp_valid[1] = 1'b1;
                        enp_moves[31:16] = {4'd1, D, FIVE, E, SIX};
                    end
                    if(f5_valid) begin
                        enp_valid[0] = 1'b1;
                        enp_moves[15: 0] = {4'd1, F, FIVE, E, SIX};
                    end
                end
                // F4
                16'h0004: begin
                    if(e5_valid) begin
                        enp_valid[1] = 1'b1;
                        enp_moves[31:16] = {4'd1, E, FIVE, F, SIX};
                    end
                    if(g5_valid) begin
                        enp_valid[0] = 1'b1;
                        enp_moves[15: 0] = {4'd1, G, FIVE, F, SIX};
                    end
                end
                // G4
                16'h0002: begin
                    if(f5_valid) begin
                        enp_valid[1] = 1'b1;
                        enp_moves[31:16] = {4'd1, F, FIVE, G, SIX};
                    end
                    if(h5_valid) begin
                        enp_valid[0] = 1'b1;
                        enp_moves[15: 0] = {4'd1, H, FIVE, G, SIX};
                    end
                end
                // H4
                16'h0001: begin
                    if(g5_valid) begin
                        enp_valid = 2'd1;
                        enp_moves = {16'd0, 4'd1, G, FIVE, H, SIX};
                    end
                end


                // En passant not possible
                default: begin
                    enp_valid = 2'd0;
                    enp_moves = 32'd0;
                end

            endcase
        end
    end

endmodule
