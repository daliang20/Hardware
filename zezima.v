/*******************************************************************************
Filename: zezima.v
Author: Kyle

Description: This is the top-level module that connects to the CPU via FIFOs.
The overall FSM is also housed in this block.
*******************************************************************************/
module zezima (
	input 				clk,
	input 				rst,
    input           	cpu_fpga_fifo_empty,
	input 				cpu_fpga_fifo_rdata_dav,
	input 		[31:0]	cpu_fpga_fifo_rdata,
	output reg  [7: 0]  fsm_st,
    output          	fpga_cpu_interrupt,
	output reg  		fpga_cpu_fifo_wr,
	output reg	[31:0]  fpga_cpu_fifo_wdata
	);

	integer i;

	localparam DATA_LENGTH = 22;
    localparam  [7:0]
        IDLE_ST         = 8'h01,
        RCV_ST          = 8'h02,
        INIT_ST         = 8'h04,
        CASTLE_ENP_ST  	= 8'h08,
		COLLECT_PCS_ST	= 8'h10,
        PROCESS_MVS_ST  = 8'h20,
        MOVE_ORDER_ST   = 8'h40,
        TRANSFER_ST     = 8'h80
    ;

	// All registers
	reg 			turn, nxt_turn;
    reg     		collect_pieces, nxt_collect_pieces;
    reg     		new_original, nxt_new_original;
	reg 	[2:0]  	iterations, nxt_iterations;
    reg     [3:0]   direction_idx, nxt_direction_idx;
	reg 	[3:0] 	castle_enp_cnt, nxt_castle_enp_cnt;
	reg 	[4:0] 	words_rcvd, nxt_words_rcvd;
    reg     [9:0]   original_piece  [63:0], nxt_original_piece [63:0];
    reg     [7:0]   nxt_fsm_st;
	reg 	[15:0] 	en_passant_flags, nxt_en_passant_flags;
	reg 	[3:0] 	castle_flags, nxt_castle_flags;

	// Output FIFO signals
	wire [63:0] stack_empty;
    wire 		all_moves_collected = ~|(~stack_empty);
	wire [15:0] best_move;
	wire 		move_order = (fsm_st == MOVE_ORDER_ST) ? 1'b1 : 1'b0;

	// En Passant and Castling signals
	wire [79:0] row_1, row_4, row_5, row_8;
	wire [3:0] 	castle_valid;
	wire [63:0] castle_moves;
	wire [1:0] 	enp_valid;
	wire [31:0] enp_moves;

	assign fpga_cpu_interrupt = (fsm_st == TRANSFER_ST) ? 1'b1 : 1'b0;

    ////////////////////////////////////////////////////////////////////////////
    //  FLIP-FLOP LOGIC
    ////////////////////////////////////////////////////////////////////////////
    always @ (posedge clk or negedge rst) begin
        if(!rst) begin
            collect_pieces <= 1'b0;
            new_original <= 1'b0;
            fsm_st <= IDLE_ST;
            direction_idx <= 4'd0;
			iterations <= 3'd0;
			turn <= 1'b0;
			castle_flags <= 4'd0;
			en_passant_flags <= 16'd0;
			words_rcvd <= 5'd0;
			castle_enp_cnt <= 3'd0;

			for (i = 0; i < 64; i = i + 1) begin
				original_piece[i] <= 10'd0;
			end

        end
        else begin
            collect_pieces <= nxt_collect_pieces;
            new_original <= nxt_new_original;
            fsm_st <= nxt_fsm_st;
            direction_idx <= nxt_direction_idx;
			iterations <= nxt_iterations;
			turn <= nxt_turn;
			castle_flags <= nxt_castle_flags;
			en_passant_flags <= nxt_en_passant_flags;
			words_rcvd <= nxt_words_rcvd;
			castle_enp_cnt <= nxt_castle_enp_cnt;

			for (i = 0; i < 64; i = i + 1) begin
				original_piece[i] <= nxt_original_piece[i];
			end
        end
    end

    ////////////////////////////////////////////////////////////////////////////
    //  STATE MACHINE
    ////////////////////////////////////////////////////////////////////////////
    always @ (*) begin
        nxt_fsm_st = fsm_st;
        nxt_new_original = new_original;
        nxt_collect_pieces = collect_pieces;
		nxt_iterations = iterations;
		nxt_direction_idx = direction_idx;
		nxt_castle_enp_cnt = castle_enp_cnt;

        case(fsm_st)
            IDLE_ST: begin
                if(!cpu_fpga_fifo_empty)
                    nxt_fsm_st = RCV_ST;
            end

            RCV_ST: begin
				if(words_rcvd == (DATA_LENGTH-1)) begin
                	nxt_fsm_st = INIT_ST;
                	nxt_new_original = 1;
				end
            end

            INIT_ST: begin
                nxt_new_original = 0;
				nxt_castle_enp_cnt = 0;
				nxt_fsm_st = CASTLE_ENP_ST;
            end

			CASTLE_ENP_ST: begin
				if(castle_enp_cnt == 5) begin
					nxt_collect_pieces = 1;
					nxt_iterations = 0;
					nxt_fsm_st = COLLECT_PCS_ST;
				end
				else begin
					nxt_castle_enp_cnt = castle_enp_cnt + 3'd1;
				end
			end

            COLLECT_PCS_ST: begin
				nxt_collect_pieces = 0;
				nxt_fsm_st = PROCESS_MVS_ST;
				nxt_direction_idx = 3'd0;
            end

            PROCESS_MVS_ST: begin
                if (direction_idx == 14) begin
                    nxt_fsm_st = MOVE_ORDER_ST;

					if(iterations < 6) begin
	                    nxt_fsm_st = COLLECT_PCS_ST;
	                    nxt_iterations = iterations + 3'd1;
						nxt_collect_pieces = 1;
	                end
				end

                nxt_direction_idx = direction_idx + 3'd1;
            end

            MOVE_ORDER_ST: begin
                if(all_moves_collected) begin
                    nxt_fsm_st = TRANSFER_ST;
				end
            end

            TRANSFER_ST: begin
                // Interrupts CPU
                nxt_fsm_st = IDLE_ST;
            end

			default: begin
				nxt_fsm_st = IDLE_ST;
			end

        endcase
    end

	////////////////////////////////////////////////////////////////////////////
    //  FPGA TO CPU FIFO WRITE MUX
    ////////////////////////////////////////////////////////////////////////////
	always @ (*) begin
		fpga_cpu_fifo_wr = 0;
		fpga_cpu_fifo_wdata = 0;

		case (fsm_st)
			CASTLE_ENP_ST: begin
				case(castle_enp_cnt)
					3'd0: begin
						if(enp_valid[0]) begin
							fpga_cpu_fifo_wr = 1'b1;
							fpga_cpu_fifo_wdata = enp_moves[15:0];
						end
					end
					//
					3'd1: begin
						if(enp_valid[1]) begin
							fpga_cpu_fifo_wr = 1'b1;
							fpga_cpu_fifo_wdata = enp_moves[31:16];
						end
					end
					//
					3'd2: begin
						if(castle_valid[0]) begin
							fpga_cpu_fifo_wr = 1'b1;
							fpga_cpu_fifo_wdata = castle_moves[15:0];
						end
					end
					//
					3'd3: begin
						if(castle_valid[1]) begin
							fpga_cpu_fifo_wr = 1'b1;
							fpga_cpu_fifo_wdata = castle_moves[31:16];
						end
					end
					//
					3'd4: begin
						if(castle_valid[2]) begin
							fpga_cpu_fifo_wr = 1'b1;
							fpga_cpu_fifo_wdata = castle_moves[47:32];
						end
					end
					//
					3'd5: begin
						if(castle_valid[3]) begin
							fpga_cpu_fifo_wr = 1'b1;
							fpga_cpu_fifo_wdata = castle_moves[63:48];
						end
					end
					//
					default: begin
						fpga_cpu_fifo_wr = 0;
						fpga_cpu_fifo_wdata = 0;
					end
				endcase //castle_enp_cnt
			end
			//
			MOVE_ORDER_ST: begin
				if(~nxt_fsm_st[7])
					fpga_cpu_fifo_wr = 1;
				fpga_cpu_fifo_wdata = {16'd0, best_move};
			end
			//
			default: begin
				fpga_cpu_fifo_wr = 0;
				fpga_cpu_fifo_wdata = 0;
			end
		endcase //fsm_st
	end

	////////////////////////////////////////////////////////////////////////////
    //  RCV DATA MUX
    ////////////////////////////////////////////////////////////////////////////
	always @ (*) begin
		for (i = 0; i < 64; i = i + 1) begin
			nxt_original_piece[i] = original_piece[i];
		end

		nxt_turn = turn;
		nxt_en_passant_flags = en_passant_flags;
		nxt_castle_flags = castle_flags;
		nxt_words_rcvd = words_rcvd;

		if (fsm_st == RCV_ST) begin

			if(words_rcvd == (DATA_LENGTH-1))
				nxt_words_rcvd = 0;
			else if (cpu_fpga_fifo_rdata_dav)
				nxt_words_rcvd = words_rcvd + 5'd1;

			if(cpu_fpga_fifo_rdata_dav) begin
				case(words_rcvd)
					5'd0: begin
						nxt_original_piece[0] = cpu_fpga_fifo_rdata[9:0];
						nxt_original_piece[1] = cpu_fpga_fifo_rdata[19:10];
						nxt_original_piece[2] = cpu_fpga_fifo_rdata[29:20];
					end

					5'd1: begin
						nxt_original_piece[3] = cpu_fpga_fifo_rdata[9:0];
						nxt_original_piece[4] = cpu_fpga_fifo_rdata[19:10];
						nxt_original_piece[5] = cpu_fpga_fifo_rdata[29:20];
					end

					5'd2: begin
						nxt_original_piece[6] = cpu_fpga_fifo_rdata[9:0];
						nxt_original_piece[7] = cpu_fpga_fifo_rdata[19:10];
						nxt_original_piece[8] = cpu_fpga_fifo_rdata[29:20];
					end

					5'd3: begin
						nxt_original_piece[9] = cpu_fpga_fifo_rdata[9:0];
						nxt_original_piece[10] = cpu_fpga_fifo_rdata[19:10];
						nxt_original_piece[11] = cpu_fpga_fifo_rdata[29:20];
					end

					5'd4: begin
						nxt_original_piece[12] = cpu_fpga_fifo_rdata[9:0];
						nxt_original_piece[13] = cpu_fpga_fifo_rdata[19:10];
						nxt_original_piece[14] = cpu_fpga_fifo_rdata[29:20];
					end

					5'd5: begin
						nxt_original_piece[15] = cpu_fpga_fifo_rdata[9:0];
						nxt_original_piece[16] = cpu_fpga_fifo_rdata[19:10];
						nxt_original_piece[17] = cpu_fpga_fifo_rdata[29:20];
					end

					5'd6: begin
						nxt_original_piece[18] = cpu_fpga_fifo_rdata[9:0];
						nxt_original_piece[19] = cpu_fpga_fifo_rdata[19:10];
						nxt_original_piece[20] = cpu_fpga_fifo_rdata[29:20];
					end

					5'd7: begin
						nxt_original_piece[21] = cpu_fpga_fifo_rdata[9:0];
						nxt_original_piece[22] = cpu_fpga_fifo_rdata[19:10];
						nxt_original_piece[23] = cpu_fpga_fifo_rdata[29:20];
					end

					5'd8: begin
						nxt_original_piece[24] = cpu_fpga_fifo_rdata[9:0];
						nxt_original_piece[25] = cpu_fpga_fifo_rdata[19:10];
						nxt_original_piece[26] = cpu_fpga_fifo_rdata[29:20];
					end

					5'd9: begin
						nxt_original_piece[27] = cpu_fpga_fifo_rdata[9:0];
						nxt_original_piece[28] = cpu_fpga_fifo_rdata[19:10];
						nxt_original_piece[29] = cpu_fpga_fifo_rdata[29:20];
					end

					5'd10: begin
						nxt_original_piece[30] = cpu_fpga_fifo_rdata[9:0];
						nxt_original_piece[31] = cpu_fpga_fifo_rdata[19:10];
						nxt_original_piece[32] = cpu_fpga_fifo_rdata[29:20];
					end

					5'd11: begin
						nxt_original_piece[33] = cpu_fpga_fifo_rdata[9:0];
						nxt_original_piece[34] = cpu_fpga_fifo_rdata[19:10];
						nxt_original_piece[35] = cpu_fpga_fifo_rdata[29:20];
					end

					5'd12: begin
						nxt_original_piece[36] = cpu_fpga_fifo_rdata[9:0];
						nxt_original_piece[37] = cpu_fpga_fifo_rdata[19:10];
						nxt_original_piece[38] = cpu_fpga_fifo_rdata[29:20];
					end

					5'd13: begin
						nxt_original_piece[39] = cpu_fpga_fifo_rdata[9:0];
						nxt_original_piece[40] = cpu_fpga_fifo_rdata[19:10];
						nxt_original_piece[41] = cpu_fpga_fifo_rdata[29:20];
					end

					5'd14: begin
						nxt_original_piece[42] = cpu_fpga_fifo_rdata[9:0];
						nxt_original_piece[43] = cpu_fpga_fifo_rdata[19:10];
						nxt_original_piece[44] = cpu_fpga_fifo_rdata[29:20];
					end

					5'd15: begin
						nxt_original_piece[45] = cpu_fpga_fifo_rdata[9:0];
						nxt_original_piece[46] = cpu_fpga_fifo_rdata[19:10];
						nxt_original_piece[47] = cpu_fpga_fifo_rdata[29:20];
					end

					5'd16: begin
						nxt_original_piece[48] = cpu_fpga_fifo_rdata[9:0];
						nxt_original_piece[49] = cpu_fpga_fifo_rdata[19:10];
						nxt_original_piece[50] = cpu_fpga_fifo_rdata[29:20];
					end

					5'd17: begin
						nxt_original_piece[51] = cpu_fpga_fifo_rdata[9:0];
						nxt_original_piece[52] = cpu_fpga_fifo_rdata[19:10];
						nxt_original_piece[53] = cpu_fpga_fifo_rdata[29:20];
					end

					5'd18: begin
						nxt_original_piece[54] = cpu_fpga_fifo_rdata[9:0];
						nxt_original_piece[55] = cpu_fpga_fifo_rdata[19:10];
						nxt_original_piece[56] = cpu_fpga_fifo_rdata[29:20];
					end

					5'd19: begin
						nxt_original_piece[57] = cpu_fpga_fifo_rdata[9:0];
						nxt_original_piece[58] = cpu_fpga_fifo_rdata[19:10];
						nxt_original_piece[59] = cpu_fpga_fifo_rdata[29:20];
					end

					5'd20: begin
						nxt_original_piece[60] = cpu_fpga_fifo_rdata[9:0];
						nxt_original_piece[61] = cpu_fpga_fifo_rdata[19:10];
						nxt_original_piece[62] = cpu_fpga_fifo_rdata[29:20];
					end

					5'd21: begin
						nxt_original_piece[63] = cpu_fpga_fifo_rdata[9:0];
						nxt_en_passant_flags   = cpu_fpga_fifo_rdata[25:10];
						nxt_castle_flags 	   = cpu_fpga_fifo_rdata[29:26];
						nxt_turn 			   = cpu_fpga_fifo_rdata[31];
					end

					default: begin
						for (i = 0; i < 64; i = i + 1) begin
							nxt_original_piece[i] = original_piece[i];
						end

						nxt_turn 				= turn;
						nxt_en_passant_flags 	= en_passant_flags;
						nxt_castle_flags 		= castle_flags;
					end
				endcase
			end
		end
	end

	////////////////////////////////////////////////////////////////////////////
    // CASTLING AND EN PASSANT
    ////////////////////////////////////////////////////////////////////////////
	// Assigns the row values for castling and en passant
	assign row_1 = {original_piece[7], original_piece[6], original_piece[5],
					original_piece[4], original_piece[3], original_piece[2],
					original_piece[1], original_piece[0]};
	assign row_4 = {original_piece[31], original_piece[30], original_piece[29],
					original_piece[28], original_piece[27], original_piece[26],
					original_piece[25], original_piece[24]};
	assign row_5 = {original_piece[39], original_piece[38], original_piece[37],
					original_piece[36], original_piece[35], original_piece[34],
					original_piece[33], original_piece[32]};
	assign row_8 = {original_piece[63], original_piece[62], original_piece[61],
					original_piece[60], original_piece[59], original_piece[58],
					original_piece[57], original_piece[56]};

	castle c (
		.flags 			(castle_flags),
		.row_1 			(row_1),
		.row_8			(row_8),
		.turn 			(turn),
		.castle_valid   (castle_valid),
		.castle_moves 	(castle_moves)
	);

	en_passant enp (
		.enp_flags 		(en_passant_flags),
		.row_4 			(row_4),
		.row_5 			(row_5),
		.enp_valid 		(enp_valid),
		.enp_moves 		(enp_moves)
	);

	////////////////////////////////////////////////////////////////////////////
    // CHESSBOARD
    ////////////////////////////////////////////////////////////////////////////
	// Creates a net array for the pieces on the squares
	wire [639:0] original_pieces =
		{row_8, original_piece[55], original_piece[54], original_piece[53],
			original_piece[52], original_piece[51], original_piece[50],
			original_piece[49], original_piece[48], original_piece[47],
			original_piece[46], original_piece[45], original_piece[44],
			original_piece[43], original_piece[42], original_piece[41],
			original_piece[40], row_5, row_4, original_piece[23],
			original_piece[22], original_piece[21], original_piece[20],
			original_piece[19], original_piece[18], original_piece[17],
			original_piece[16], original_piece[15], original_piece[14],
			original_piece[13], original_piece[12], original_piece[11],
			original_piece[10], original_piece[ 9], original_piece[ 8], row_1
		};

	chess_board cb (
		.clk			(clk),
		.rst 			(rst),
		.turn 			(turn),
		.stack_empty  	(stack_empty),
		.original_pieces(original_pieces),
		.new_original	(new_original),
		.collect_pieces (collect_pieces),
		.best_move 		(best_move),
		.move_order 	(move_order)
	);


endmodule