/*******************************************************************************
Filename: zezima.v
Author: Kyle

Description: Instantiates and connects 64 squares along with an arbitration
system.
*******************************************************************************/
module chess_board (
    input               clk,
    input               rst,
    input               turn,
    input               new_original,
    input               collect_pieces,
    input               move_order,
    input       [639:0] original_pieces,
    output      [15:0]  best_move,
    output      [63:0]  stack_empty
);
    integer i;

    reg 	[159:0] rx 		[63:0];
    wire 	[159:0] tx 		[63:0];

    ////////////////////////////////////////////////////////////////////////////
    //  ARBITRATION SYSTEM
    ////////////////////////////////////////////////////////////////////////////
    // Arbiter inputs and outputs
    wire    [15:0]  arbiter_in  [63:0];
    wire    [15:0]  arbiter_l1  [31:0];
    wire    [15:0]  arbiter_l2  [15:0];
    wire    [15:0]  arbiter_l3  [7:0];
    wire    [15:0]  arbiter_l4  [3:0];
    wire    [15:0]  arbiter_l5  [1:0];
    wire    [15:0]  arbiter_out;
    wire    [5:0]   square_to_ack   = {arbiter_out[2:0], arbiter_out[5:3]};
    // TODO: MAY NEED EXTRA STATE BETWEEN THIS TO MEET TIMING
    wire    [63:0]  stack_read      = move_order ? 1<<square_to_ack : 64'd0;

    // Level 1 Arbiters
    genvar arb_a;
    generate
        for(arb_a = 0; arb_a < 64; arb_a = arb_a + 2) begin : l1_arb
            maximum_unit mu_l1 (
                .a      (arbiter_in[arb_a]),
                .b      (arbiter_in[arb_a + 1]),
                .out    (arbiter_l1[arb_a / 2])
            );
        end
    endgenerate
    // Level 2 Arbiters
    genvar arb_b;
    generate
        for(arb_b = 0; arb_b < 32; arb_b = arb_b + 2) begin : l2_arb
            maximum_unit mu_l2 (
                .a      (arbiter_l1[arb_b]),
                .b      (arbiter_l1[arb_b + 1]),
                .out    (arbiter_l2[arb_b / 2])
            );
        end
    endgenerate
    // Level 3 Arbiters
    genvar arb_c;
    generate
        for(arb_c = 0; arb_c < 16; arb_c = arb_c + 2) begin : l3_arb
            maximum_unit mu_l3 (
                .a      (arbiter_l2[arb_c]),
                .b      (arbiter_l2[arb_c + 1]),
                .out    (arbiter_l3[arb_c / 2])
            );
        end
    endgenerate
    // Level 4 Arbiters
    genvar arb_d;
    generate
        for(arb_d = 0; arb_d < 8; arb_d = arb_d + 2) begin : l4_arb
            maximum_unit mu_l4 (
                .a      (arbiter_l3[arb_d]),
                .b      (arbiter_l3[arb_d + 1]),
                .out    (arbiter_l4[arb_d / 2])
            );
        end
    endgenerate
    // Level 5 Arbiters
    genvar arb_e;
    generate
        for(arb_e = 0; arb_e < 4; arb_e = arb_e + 2) begin : l5_arb
            maximum_unit mu_l5 (
                .a      (arbiter_l4[arb_e]),
                .b      (arbiter_l4[arb_e + 1]),
                .out    (arbiter_l5[arb_e / 2])
            );
        end
    endgenerate
    // Final arbiter
    maximum_unit mu_out (
        .a      (arbiter_l5[0]),
        .b      (arbiter_l5[1]),
        .out    (arbiter_out)
    );
	 assign best_move = arbiter_out;

    ////////////////////////////////////////////////////////////////////////////
    // 64 Squares
    ////////////////////////////////////////////////////////////////////////////
    genvar k;
    generate
        for(k = 0; k < 64; k = k + 1) begin : squares
            square sq (
                .clk                (clk),
                .rst                (rst),
                .turn 				(turn),
                .collect_pieces     (collect_pieces),
                .stack_read         (stack_read[k]),
                .original_piece     (original_pieces[(k*10)+9:(k*10)]),
                .new_original       (new_original),
                .stack_arbiter      (arbiter_in[k]),
                .stack_empty        (stack_empty[k]),
                .rx_moves           (rx[k]),
                .tx_moves           (tx[k])
            );
        end
    endgenerate

    // Attaches (or doesn't attach) squares to form a board
    always @ (*) begin
        // Assigns all move wires that require connection
        for(i = 0; i < 64; i = i + 1) begin

            // Avoids latching
            rx[i] = 160'd0;

            // STANDARD SLIDING PIECES
            // Up              0
            if(i < 56)
                rx[i][9:0] 		= tx[i+8][9:0];
            // Right           1
            if(i % 8 < 7)
                rx[i][19:10]  	= tx[i+1][19:10];
            // Down            2
            if(i > 7)
                rx[i][29:20] 	= tx[i-8][29:20];
            // Left            3
            if(i % 8 > 0)
                rx[i][39:30]	= tx[i-1][39:30];
            // Up-Left         4
            if(i % 8 > 0 && i < 56)
                rx[i][49:40]	= tx[i+7][49:40];
            // Up-Right        5
            if(i % 8 < 7 && i < 56)
                rx[i][59:50]	= tx[i+9][59:50];
            // Down-Right      6
            if(i % 8 < 7 && i > 7)
                rx[i][69:60]	= tx[i-7][69:60];
            // Down-Left       7
            if(i % 8 > 0 && i > 7)
                rx[i][79:70]	= tx[i-9][79:70];

            // KNIGHTS
            // Column A
            if      (i % 8 == 0) begin
                // K-2Up1Right     9
                if(i < 48)
                    rx[i][99:90]  	= tx[i+17][99:90];
                // K-2Right1Up     10
                if(i < 56)
                    rx[i][109:100] 	= tx[i+10][109:100];
                // K-2Right1Down   11
                if(i > 7)
                    rx[i][119:110] 	= tx[i-6][119:110];
                // K-2Down1Right   12
                if(i > 15)
                    rx[i][129:120] 	= tx[i-15][129:120];
            end
            // Column B
            else if (i % 8 == 1) begin
                // K-2Up1Left      8
                // K-2Up1Right     9
                if(i < 48) begin
                    rx[i][89:80]  	= tx[i+15][89:80];
                    rx[i][99:90]  	= tx[i+17][99:90];
                end
                // K-2Right1Up     10
                if(i < 56)
                    rx[i][109:100] 	= tx[i+10][109:100];
                // K-2Right1Down   11
                if(i > 7)
                    rx[i][119:110] 	= tx[i-6][119:110];
                // K-2Down1Right   12
                // K-2Down1Left    13
                if(i > 15) begin
                    rx[i][129:120] 	= tx[i-15][129:120];
                    rx[i][139:130] 	= tx[i-17][139:130];
                end
            end
            // Column G
            else if (i % 8 == 6) begin
                // K-2Up1Left      8
                // K-2Up1Right     9
                if(i < 48) begin
                    rx[i][89:80]  	= tx[i+15][89:80];
                    rx[i][99:90]  	= tx[i+17][99:90];
                end
                // K-2Down1Right   12
                // K-2Down1Left    13
                if(i > 15) begin
                    rx[i][129:120] 	= tx[i-15][129:120];
                    rx[i][139:130] 	= tx[i-17][139:130];
                end
                // K-2Left1Down    14
                if(i > 7)
                    rx[i][149:140]  = tx[i-10][149:140];
                // K-2Left1Up      15
                if(i < 56)
                    rx[i][159:150]  = tx[i+6][159:150];
            end
            // Column H
            else if (i % 8 == 7) begin
                // K-2Up1Left      8
                if(i < 48)
                    rx[i][89:80]  	= tx[i+15][89:80];
                // K-2Down1Left    13
                if(i > 15)
                    rx[i][139:130] 	= tx[i-17][139:130];
                // K-2Left1Down    14
                if(i > 7)
                    rx[i][149:140]  = tx[i-10][149:140];
                // K-2Left1Up      15
                if(i < 56)
                    rx[i][159:150]  = tx[i+6][159:150];
            end
            // Row 1 (minus end columns)
            else if ((i > 1  && i < 6)) begin
                // K-2Up1Left      8
                rx[i][89:80]  	= tx[i+15][89:80];
                // K-2Up1Right     9
                rx[i][99:90]  	= tx[i+17][99:90];
                // K-2Right1Up     10
                rx[i][109:100] 	= tx[i+10][109:100];
                // K-2Left1Up      15
                rx[i][159:150]  = tx[i+6][159:150];
            end
            // Row 2 (minus end columns)
            else if ((i > 9  && i < 14)) begin
                // K-2Up1Left      8
                rx[i][89:80]  	= tx[i+15][89:80];
                // K-2Up1Right     9
                rx[i][99:90]  	= tx[i+17][99:90];
                // K-2Right1Up     10
                rx[i][109:100] 	= tx[i+10][109:100];
                // K-2Right1Down   11
                rx[i][119:110] 	= tx[i-6][119:110];
                // K-2Left1Down    14
                rx[i][149:140]  = tx[i-10][149:140];
                // K-2Left1Up      15
                rx[i][159:150]  = tx[i+6][159:150];
            end
            // Row 7 (minus end columns)
            else if ((i > 49 && i < 54)) begin
                // K-2Right1Up     10
                rx[i][109:100] 	= tx[i+10][109:100];
                // K-2Right1Down   11
                rx[i][119:110] 	= tx[i-6][119:110];
                // K-2Down1Right   12
                rx[i][129:120] 	= tx[i-15][129:120];
                // K-2Down1Left    13
                rx[i][139:130] 	= tx[i-17][139:130];
                // K-2Left1Down    14
                rx[i][149:140]  = tx[i-10][149:140];
                // K-2Left1Up      15
                rx[i][159:150]  = tx[i+6][159:150];
            end
            // Row 8 (minus end columns)
            else if ((i > 57 && i < 62)) begin
                // K-2Right1Down   11
                rx[i][119:110] 	= tx[i-6][119:110];
                // K-2Down1Right   12
                rx[i][129:120] 	= tx[i-15][129:120];
                // K-2Down1Left    13
                rx[i][139:130] 	= tx[i-17][139:130];
                // K-2Left1Down    14
                rx[i][149:140]  = tx[i-10][149:140];
            end
            // Middle columns (4X4)
            else begin
                // K-2Up1Left      8
                rx[i][89:80]  	= tx[i+15][89:80];
                // K-2Up1Right     9
                rx[i][99:90]  	= tx[i+17][99:90];
                // K-2Right1Up     10
                rx[i][109:100] 	= tx[i+10][109:100];
                // K-2Right1Down   11
                rx[i][119:110] 	= tx[i-6][119:110];
                // K-2Down1Right   12
                rx[i][129:120] 	= tx[i-15][129:120];
                // K-2Down1Left    13
                rx[i][139:130] 	= tx[i-17][139:130];
                // K-2Left1Down    14
                rx[i][149:140]  = tx[i-10][149:140];
                // K-2Left1Up      15
                rx[i][159:150]  = tx[i+6][159:150];
            end // knight assignments
        end // for-loop
    end // always block
endmodule
