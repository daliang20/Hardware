/*******************************************************************************
Filename: square.v
Author: Kyle

Description: Instantiates all components within a square:
    - rx.v
    - tx.v
    - local_stack.v
Receives 16 inputs from surrounding pieces and stores them in a stack if valid.
Sliding moves are also computed and sent out on the next cycle.
*******************************************************************************/
module square (
    input           clk,
    input           rst,
    input           turn,
    input           collect_pieces,
    input           stack_read,
    input  [9:0]    original_piece,
    input           new_original,
    input  [159:0]  rx_moves,
    output [15:0]   stack_arbiter,
    output          stack_empty,
    output [159:0]  tx_moves
    //output [3:0]    stack_num
    );

    localparam [1:0]
        IDLE_ST = 2'b01,
        ITERATE_ST = 2'b10
    ;

    reg     [1:0]   fsm_st, nxt_fsm_st;
    reg     [3:0]   direction_idx, nxt_direction_idx;
    reg     [15:0]  rx_stack_in;

    wire    [9:0]   rx_tx_piece;
    wire            rx_tx_valid;
    wire    [15:0]  rx_stack_move;
    wire            rx_stack_valid;
    wire    [15:0]  fifo_out;
    wire    [3:0]   stack_num;

    // Prevents bad data to the arbiters
    assign stack_arbiter = stack_empty ? 16'd0 : fifo_out;

    // Flip flop logic
    always @ (posedge clk or negedge rst) begin
        if(!rst) begin
            fsm_st <= IDLE_ST;
            direction_idx <= 4'd0;
        end
        else begin
            fsm_st <= nxt_fsm_st;
            direction_idx <= nxt_direction_idx;
        end
    end

    // State machine logic that counts through directions
    always @ (*) begin
        nxt_fsm_st = fsm_st;
        nxt_direction_idx = direction_idx;

        case(fsm_st)
            IDLE_ST: begin
                if(collect_pieces) begin
                    nxt_fsm_st = ITERATE_ST;
                    nxt_direction_idx = 4'd0;
                end
            end

            ITERATE_ST: begin
                if(direction_idx < 4'd15) begin
                    nxt_direction_idx = direction_idx + 4'd1;
                end
                else begin
                    nxt_direction_idx = 4'd0;
                    if(!collect_pieces)
                        nxt_fsm_st = IDLE_ST;
                end
            end

            default: nxt_fsm_st = IDLE_ST;

        endcase
    end

    square_fifo square_fifo (
        .aclr      (~rst),
    	.clock     (clk),
    	.data      (rx_stack_move),
    	.rdreq     (stack_read),
    	.wrreq     (rx_stack_valid),
    	.empty     (stack_empty),
    	.q         (fifo_out),
    	.usedw     (stack_num)
    );

    rx rx (
        .moves          (rx_moves),
        .dest_piece     (original_piece),
        .collect_pieces (collect_pieces),
        .clk            (clk),
        .rst            (rst),
        .turn           (turn),
        .rx_tx_piece    (rx_tx_piece),
        .rx_tx_valid    (rx_tx_valid),
        .formatted_move (rx_stack_move),
        .stack_write    (rx_stack_valid),
        .direction_idx  (direction_idx)
    );

    tx tx (
        .rx_tx_piece    (rx_tx_piece),
        .rx_tx_valid    (rx_tx_valid),
        .original_piece (original_piece),
        .new_original   (new_original),
        .collect_pieces (collect_pieces),
        .clk            (clk),
        .rst            (rst),
        .turn           (turn),
        .move           (tx_moves),
        .direction_idx  (direction_idx)
    );

endmodule
