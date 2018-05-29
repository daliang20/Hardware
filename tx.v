module tx (
    input       [9:0]   rx_tx_piece,
    input               rx_tx_valid,
    input       [9:0]   original_piece,
    input       [3:0]   direction_idx,
    input               new_original,
    input               collect_pieces,
    input               clk,
    input               rst,
    input               turn,
    output reg  [159:0] move
    );

    reg     [159:0]     nxt_move;

    wire allowed_to_move = (original_piece[0] == turn) ? 1'b1 : 1'b0;

    // Flip flop logic
    always @ (posedge clk or negedge rst) begin
        if(!rst) begin
            move <= 160'd0;
        end
        else begin
            move <= nxt_move;
        end
    end

    // Decides which pieces are routed
    always @ (*) begin
        nxt_move = move;

        // Send the starting piece out on all squares
        if(new_original) begin
            if(allowed_to_move) begin
                nxt_move    [ 9: 0]     = original_piece;
                nxt_move    [19:10]     = original_piece;
                nxt_move    [29:20]     = original_piece;
                nxt_move    [39:30]     = original_piece;
                nxt_move    [49:40]     = original_piece;
                nxt_move    [59:50]     = original_piece;
                nxt_move    [69:60]     = original_piece;
                nxt_move    [79:70]     = original_piece;
                nxt_move    [89:80]     = original_piece;
                nxt_move    [99:90]     = original_piece;
                nxt_move    [109:100]   = original_piece;
                nxt_move    [119:110]   = original_piece;
                nxt_move    [129:120]   = original_piece;
                nxt_move    [139:130]   = original_piece;
                nxt_move    [149:140]   = original_piece;
                nxt_move    [159:150]   = original_piece;
            end
            else
                nxt_move = 160'd0;
        end

        // Invalidate all pieces when new ones are collected
        else if (collect_pieces) begin
            nxt_move = 160'd0;
        end

        // Otherwise, slide valid pieces along
        else if(rx_tx_valid) begin
            case(direction_idx)
                4'd0: nxt_move[ 9: 0] = rx_tx_piece;
                4'd1: nxt_move[19:10] = rx_tx_piece;
                4'd2: nxt_move[29:20] = rx_tx_piece;
                4'd3: nxt_move[39:30] = rx_tx_piece;
                4'd4: nxt_move[49:40] = rx_tx_piece;
                4'd5: nxt_move[59:50] = rx_tx_piece;
                4'd6: nxt_move[69:60] = rx_tx_piece;
                4'd7: nxt_move[79:70] = rx_tx_piece;
                default: nxt_move = move;
            endcase
        end

        else
            nxt_move = move;
    end

endmodule
