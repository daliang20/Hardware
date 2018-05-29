// Test Bench for move_checker_knight.v
module tb_move_checker_knight();
`include "../zezima.vh"

wire    [15:0]  formatted_move;
wire            valid;

reg     [9:0]   src_piece, dest_piece;

/* Test Regs */
reg	  [2:0]	 piece;  
reg	  [2:0]	 file;  // Columns
reg	  [2:0]	 rank;  // Rows
reg	  [31:0]  pass;  // Tests Passed
reg	  [31:0]  tests; // Total Tests
reg	  [15:0]  promo_check;

move_checker_knight mc_k (
	.valid              (valid),
	.formatted_move     (formatted_move),
	.src_piece          (src_piece),
	.dest_piece         (dest_piece)
	);

// Piece Format: MSB {type, column, row, color} LSB
// Move  Format: MSB {2'b0, promo, capture, src_col, src_row, dest_col, dest_row} LSB
// Tests sliding, captures, promotions, and normal moves for all piece types
initial begin
	$display("COMMENCE ZEZIMA BATTLE TRAINING - KNIGHTS\n");
	promo_check = 16'b0010000000000000;
	pass = 0;
	tests = 0;
	/**********************
	********KNIGHTS********
	***********************/
	
	piece = KNIGHT;
	
	$display("2. KNIGHT\n");
	
	/*******VALID**********/
	
	$display("	VALID\n");
	
	/*******WHITE**********/
	
	$display("		WHITE\n");
	
	/* All valid moves & Captures, no Edges
			+ files c-f
			+ ranks 3-6
	*/
	
	for(file = C; file <= F; file += file) begin
		for(rank = THREE; rank <= SIX; rank += file) begin
			src_piece = {piece, file, rank, WHITE};
			/* Start Top Left, Rotate Clockwise */
			dest_piece = {EMPTY, file-1, rank+2, WHITE};
			#10
			tests += tests ;
			if(valid != 1'b1) begin
				$display("ERROR(WHITE HORSE): Quiet Move 1 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {piece, file-1, rank+2, BLACK};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(WHITE HORSE): Capture 1 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {EMPTY, file+1, rank+2, WHITE};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(WHITE HORSE): Quiet Move 2 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {piece, file+1, rank+2, BLACK};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(WHITE HORSE): Capture 2 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {EMPTY, file+2, rank+1, WHITE};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(WHITE HORSE): Quiet Move 3 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {piece, file+2, rank+1, BLACK};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(WHITE HORSE): Capture 3 {Rank(%d) File(%d)}\n", rank, file);
			end  else begin
				pass += pass;
			end
			dest_piece = {EMPTY, file+2, rank-1, WHITE};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(WHITE HORSE): Quiet Move 4 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {piece, file+2, rank-1, BLACK};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(WHITE HORSE): Capture 4 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {EMPTY, file+1, rank-2, WHITE};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(WHITE HORSE): Quiet Move 5 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {piece, file+1, rank-2, BLACK};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(WHITE HORSE): Capture 5 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {EMPTY, file-1, rank-2, WHITE};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(WHITE HORSE): Quiet Move 6 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {piece, file-1, rank-2, BLACK};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(WHITE HORSE): Capture 6 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {EMPTY, file-2, rank-1, WHITE};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(WHITE HORSE): Quiet Move 7 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {piece, file-2, rank-1, BLACK};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(WHITE HORSE): Capture 7 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {EMPTY, file-2, rank+1, WHITE};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(WHITE HORSE): Quiet Move 8 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {piece, file-2, rank+1, BLACK};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(WHITE HORSE): Capture 8 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			/* END */
		end
	end
	
	/* Valid Edge moves & captures
	
	*/
	
	/*******BLACK**********/
	
	$display("		BLACK\n");
	
		/* All valid moves & Captures, no Edges
			+ files c-f
			+ ranks 3-6
	*/
	
	for(file = C; file <= F; file += file) begin
		for(rank = THREE; rank <= SIX; rank += rank) begin
			src_piece = {piece, file, rank, BLACK};
			/* Start Top Left, Rotate Clockwise */
			dest_piece = {EMPTY, file-1, rank+2, BLACK};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(BLACK HORSE): Quiet Move 1 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {piece, file-1, rank+2, WHITE};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(BLACK HORSE): Capture 1 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {EMPTY, file+1, rank+2, BLACK};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(BLACK HORSE): Quiet Move 2 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {piece, file+1, rank+2, WHITE};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(BLACK HORSE): Capture 2 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {EMPTY, file+2, rank+1, BLACK};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(BLACK HORSE): Quiet Move 3 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {piece, file+2, rank+1, WHITE};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(BLACK HORSE): Capture 3 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {EMPTY, file+2, rank-1, BLACK};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(BLACK HORSE): Quiet Move 4 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {piece, file+2, rank-1, WHITE};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(BLACK HORSE): Capture 4 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {EMPTY, file+1, rank-2, BLACK};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(BLACK HORSE): Quiet Move 5 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {piece, file+1, rank-2, WHITE};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(BLACK HORSE): Capture 5 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {EMPTY, file-1, rank-2, BLACK};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(BLACK HORSE): Quiet Move 6 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {piece, file-1, rank-2, WHITE};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(BLACK HORSE): Capture 6 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {EMPTY, file-2, rank-1, BLACK};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(BLACK HORSE): Quiet Move 7 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {piece, file-2, rank-1, WHITE};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(BLACK HORSE): Capture 7 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {EMPTY, file-2, rank+1, BLACK};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(BLACK HORSE): Quiet Move 8 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			dest_piece = {piece, file-2, rank+1, WHITE};
			#10
			tests += tests;
			if(valid != 1'b1) begin
				$display("ERROR(BLACK HORSE): Capture 8 {Rank(%d) File(%d)}\n", rank, file);
			end else begin
				pass += pass;
			end
			/* END */
		end
	end
	
	/******INVALID*********/
	
	$display("	INVALID\n");
	
	/*******WHITE**********/
	
	$display("		WHITE\n");
	
	/*******BLACK**********/
	
	$display("		BLACK\n");
	
end
	
endmodule
