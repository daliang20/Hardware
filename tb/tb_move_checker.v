/*
	MISSED TESTS:
		1. EN PESSANTE
		2. ALL KNIGHT EDGE CASES
		3. ALL ROOKS
		4. ALL BISHOPS
		5. ALL QUEEN
		6. ALL KING
*/

module tb_move_checker();
`include "../zezima.vh"

wire    [15:0]  formatted_move;
wire            valid;
wire            slide_valid;

reg     [9:0]   src_piece, dest_piece;

/* Test Regs */
reg	  [2:0]	 piece;
reg	  [2:0]	 file_in;    // Columns
reg	  [2:0]	 rank_in;    // Rows
reg	  [15:0]  promo_check;

integer rank;
integer file;
integer tests;
integer pass;

move_checker mc (
	.valid              (valid),
	.slide_valid         (slide_valid),
	.formatted_move     (formatted_move),
	.src_piece          (src_piece),
	.dest_piece         (dest_piece)
	);

// Piece Format: MSB {type, column, row, color} LSB
// Move  Format: MSB {2'b0, promo, capture, src_col, src_row, dest_col, dest_row} LSB
// Tests sliding, captures, promotions, and normal moves for all piece types
initial begin
	$display("COMMENCE ZEZIMA BATTLE TRAINING\n");
	promo_check = 16'b0010000000000000;
	pass = 0;
	tests = 0;

	/**********************
	********PAWNS**********
	***********************/
	$display("1. PAWNS\n");
	piece = PAWN;

	/*******VALID**********/

	$display("	VALID\n");

	/*******WHITE**********/

	$display("		WHITE\n");

	/* Valid Move, 1 space forward
			+ all files
			+ ranks 2-6
	*/
	file_in = A;
	rank_in = TWO;
	for(rank = TWO; rank <= SIX; rank = rank + 1) begin
		for(file = A; file <= H; file = file + 1) begin
			dest_piece = {EMPTY, file_in, rank_in+3'b001, WHITE};
			src_piece  = {piece, file_in, rank_in, WHITE};
			#10
			tests = tests + 1;
			if(valid != 1'b1 || (slide_valid != 1'b1 && rank_in == TWO)) begin
				$display("ERROR(WHITE PAWN): 1-Sqr Forward {Rank(%0d) File(%0d)}\n", rank, file);
			end else begin
				pass = pass + 1;
			end
			file_in = file_in + 3'b001;
			rank_in = rank_in + 3'b001;
		end
	end

	/* Valid Opening Move, 2 spaces forward
			+ all files
			+ rank 2
	*/
	file_in = A;
	rank_in = TWO;
	for(file = A; file <= H; file = file + 1) begin
		dest_piece = {EMPTY, file_in, FOUR, WHITE};
		src_piece  = {piece, file_in, TWO, WHITE};
		#10
		tests = tests + 1;
		if(valid != 1'b1) begin
			$display("ERROR(WHITE PAWN): 2-Sqr Forward {Rank(%0d) File(%0d)}\n", rank_in, file_in);
		end else begin
			pass = pass + 1;
		end
		file_in = file_in + 3'b001;
	end

	/* Valid Capture, Right & Left Diagonal
			+ files 2-7
			+ rank 2-6
	*/
	file_in = B;
	rank_in = TWO;
	for(rank = TWO; rank <= SIX; rank = rank + 1) begin
		file_in = B;
		for(file = B; file <= G; file = file + 1) begin
			/* Right */
			dest_piece = {piece, file_in+3'b001, rank_in+3'b001, BLACK};
			src_piece  = {piece, file_in, rank_in, WHITE};
			#10
			tests = tests + 1;
			if(valid != 1'b1) begin
				$display("ERROR(WHITE PAWN): Capture Right {Rank(%0d) File(%0d)}\n", rank_in, file_in);
			end else begin
					pass = pass + 1;
			end
			/* Left */
			dest_piece = {piece, file_in-3'b001, rank_in+3'b001, BLACK};
			src_piece  = {piece, file_in, rank_in, WHITE};
			#10
			tests = tests + 1;
			if(valid != 1'b1) begin
				$display("ERROR(WHITE PAWN): Capture Left {Rank(%0d) File(%0d)}\n", rank_in, file_in);
			end else begin
				pass = pass + 1;
			end
			file_in = file_in + 3'b001;
		end
		rank_in = rank_in + 3'b001;
	end

	/* Valid Capture, Right & Left Diagonal (Edges)
			+ files 1,8
			+ rank 2-6
	*/
	/* Right - File 1*/
	file_in = A;
	rank_in = TWO;
	for(rank = TWO; rank <= SIX; rank = rank + 1) begin
		dest_piece = {piece, file_in+3'b001, rank_in+3'b001, BLACK};
		src_piece  = {piece, file_in, rank_in, WHITE};
		#10
		tests = tests + 1;
		if(valid != 1'b1) begin
			$display("ERROR(WHITE PAWN): Edge Capture Right {Rank(%0d) File(%0d)}\n", rank_in, file_in);
		end else begin
			pass = pass + 1;
		end
		rank_in = rank_in + 3'b001;
	end

	/* Left - File 8*/
	file_in = H;
	rank_in = TWO;
	for(rank = TWO; rank <= SIX; rank = rank + 1) begin
		dest_piece = {piece, file_in-3'b001, rank_in+3'b001, BLACK};
		src_piece  = {piece, file_in, rank_in, WHITE};
		#10
		tests = tests + 1;
		if(valid != 1'b1) begin
			$display("ERROR(WHITE PAWN): Edge Capture Left {Rank(%0d) File(%0d)}\n", rank_in, file_in);
		end else begin
			pass = pass + 1;
		end
		rank_in = rank_in + 3'b001;
	end

	/* Valid Promotion
			+ all files
			+ rank 7
	*/
	file_in = A;
	rank_in = SEVEN;
	for(file = A; file <= H; file = file + 1) begin
		dest_piece = {EMPTY, file_in, rank_in+3'b001, WHITE};
		src_piece  = {piece, file_in, rank_in, WHITE};
		file_in = file_in + 3'b001;
		#10
		tests = tests + 1;
		if((valid != 1'b1) && ((promo_check & formatted_move) != promo_check)) begin
			$display("ERROR(WHITE PAWN): Promotion {Rank(%0d) File(%0d)}\n", rank, file);
		end else begin
			pass = pass + 1;
		end
	end

	/* Valid Capture Promotion
			+ files 2-7
			+ rank 7
	*/
	file_in = A;
	rank_in = SEVEN;
	for(file = B; file <= G; file = file + 1) begin
		/* Right */
		dest_piece = {piece, file_in+3'b001, rank_in+3'b001, BLACK};
		src_piece  = {piece, file_in, rank_in, WHITE};
		#10
		tests = tests + 1;
		if((valid != 1'b1) && ((promo_check & formatted_move) != promo_check)) begin
			$display("ERROR(WHITE PAWN): Capture Promotion Right {Rank(%0d) File(%0d)}\n", rank, file);
		end else begin
			pass = pass + 1;
		end
		/* Left */
		dest_piece = {piece, file_in-3'b001, rank_in+3'b001, BLACK};
		src_piece  = {piece, file_in, rank_in, WHITE};
		#10
		tests = tests + 1;
		if((valid != 1'b1) && ((promo_check & formatted_move) != promo_check)) begin
			$display("ERROR(WHITE PAWN): Capture Promotion Left {Rank(%0d) File(%0d)}\n", rank, file);
		end else begin
			pass = pass + 1;
		end
		file_in = file_in + 3'b001;
	end

	/* Valid Capture Promotion
		+ files 1,8
		+ rank 7
	*/
	/* Right - File 1*/
   file_in = A;
	rank_in = SEVEN;
	dest_piece = {piece, file_in+3'b001, rank_in+3'b001, BLACK};
	src_piece  = {piece, file_in, rank_in, WHITE};
	#10
	tests = tests + 1;
	if((valid != 1'b1) && ((promo_check & formatted_move) != promo_check)) begin
		$display("ERROR(WHITE PAWN): Edge Capture Promotion Right {Rank(%0d) File(%0d)}\n", rank, file);
	end else begin
		pass = pass + 1;
	end

	/* Left - File 8*/
	file_in = H;
	rank_in = SEVEN;
	dest_piece = {piece, file_in-3'b001, rank_in+3'b001, BLACK};
	src_piece  = {piece, file_in, rank_in, WHITE};
	#10
	tests = tests + 1;
	if((valid != 1'b1) && ((promo_check & formatted_move) != promo_check)) begin
		$display("ERROR(WHITE PAWN): Edge Capture Promotion Left {Rank(%0d) File(%0d)}\n", rank, file);
	end else begin
		pass = pass + 1;
	end

	/*******BLACK**********/

	$display("		BLACK\n");

	/* Valid Move, 1 space forward
			+ all files
			+ ranks 7-3
	*/
	file_in = A;
	rank_in = SEVEN;
	for(rank = SEVEN; rank >= THREE; rank = rank - 1) begin
		for(file = A; file <= H; file = file + 1) begin
			dest_piece = {EMPTY, file_in, rank_in-3'b001, BLACK};
			src_piece  = {piece, file_in, rank_in, BLACK};
			#10
			tests = tests + 1;
			if(valid != 1'b1) begin
				$display("ERROR(BLACK PAWN): 1-Sqr Forward {Rank(%0d) File(%0d)}\n", rank, file);
			end else begin
				pass = pass + 1;
			end
			file_in = file_in + 3'b001;
			rank_in = rank_in - 3'b001;
		end
	end

	/* Valid Opening Move, 2 spaces forward
			+ all files
			+ rank 7
	*/
	file_in = A;
	rank_in = SEVEN;
	for(file = A; file <= H; file = file + 1) begin
		dest_piece = {EMPTY, file_in, rank_in-3'd2, BLACK};
		src_piece  = {piece, file_in, rank_in, BLACK};
		#10
		tests = tests + 1;
		if(valid != 1'b1) begin
			$display("ERROR(BLACK PAWN): 2-Sqr Forward {Rank(%0d) File(%0d)}\n", rank, file);
		end else begin
			pass = pass + 1;
		end
		file_in = file_in + 3'b001;
	end

	/* Valid Capture, Right & Left Diagonal
			+ files 2-7
			+ rank 3-7
	*/
	file_in = B;
	rank_in = SEVEN;
	for(rank = SEVEN; rank >= THREE; rank = rank - 1) begin
		for(file = B; file <= G; file = file + 1) begin
			/* Right */
			dest_piece = {piece, file_in+3'b001, rank_in-3'd1, WHITE};
			src_piece  = {piece, file_in, rank_in, BLACK};
			#10
			tests = tests + 1;
			if(valid != 1'b1) begin
				$display("ERROR(BLACK PAWN): Capture Right {Rank(%0d) File(%0d)}\n", rank, file);
			end else begin
					pass = pass + 1;
			end
			/* Left */
			dest_piece = {piece, file_in-3'd1, rank_in-3'd1, WHITE};
			src_piece  = {piece, file_in, rank_in, BLACK};
			file_in = file_in + 3'b001;
			rank_in = rank_in - 3'b001;
			#10
			tests = tests + 1;
			if(valid != 1'b1) begin
				$display("ERROR(BLACK PAWN): Capture Left {Rank(%0d) File(%0d)}\n", rank, file);
			end else begin
				pass = pass + 1;
			end
		end
	end

	/* Valid Capture, Right & Left Diagonal (Edges)
			+ files 1,8
			+ rank 3-7
	*/
	file_in = A;
	rank_in = SEVEN;
	for(rank = SEVEN; rank >= THREE; rank = rank - 1) begin
		/* Right - File 1*/
		dest_piece = {piece, file_in+3'b001, rank_in-3'b001, WHITE};
		src_piece  = {piece, file_in, rank_in, BLACK};
		#10
		tests = tests + 1;
		if(valid != 1'b1) begin
			$display("ERROR(BLACK PAWN): Edge Capture Right {Rank(%0d) File(%0d)}\n", rank, file);
		end else begin
			pass = pass + 1;
		end
		rank_in = rank_in - 3'b001;
	end

	file_in = H;
	rank_in = SEVEN;
	for(rank = SEVEN; rank >= THREE; rank = rank - 1) begin
		/* Left - File 8*/
		dest_piece = {piece, file_in-3'b001, rank_in-3'b001, WHITE};
		src_piece  = {piece, file_in, rank_in, BLACK};
		rank_in = rank_in - 3'b001;
		#10
		tests = tests + 1;
		if(valid != 1'b1) begin
			$display("ERROR(BLACK PAWN): Edge Capture Left {Rank(%0d) File(%0d)}\n", rank, file);
		end else begin
			pass = pass + 1;
		end
	end

	/* Valid Promotion
			+ all files
			+ rank 2
	*/
	file_in = A;
	rank_in = TWO;
	for(file = A; file <= H; file = file + 1) begin
		dest_piece = {EMPTY, file_in, rank_in-3'd1, BLACK};
		src_piece  = {piece, file_in, rank_in, BLACK};
		file_in = file_in + 3'b001;
		#10
		tests = tests + 1;
		if((valid != 1'b1) && ((promo_check & formatted_move) != promo_check)) begin
			$display("ERROR(BLACK PAWN): Promotion {Rank(%0d) File(%0d)}\n", rank, file);
		end else begin
			pass = pass + 1;
		end
	end

	/* Valid Capture Promotion
			+ files 2-7
			+ rank 2
	*/
	file_in = B;
	rank_in = TWO;
	for(file = B; file <= G; file = file + 1) begin
		/* Right */
		dest_piece = {piece, file_in+3'b001, rank_in-3'd1, WHITE};
		src_piece  = {piece, file_in, rank_in, BLACK};
		#10
		tests = tests + 1;
		if((valid != 1'b1) && ((promo_check & formatted_move) != promo_check)) begin
			$display("ERROR(BLACK PAWN): Capture Promotion Right {Rank(%0d) File(%0d)}\n", rank, file);
		end else begin
			pass = pass + 1;
		end
		/* Left */
		dest_piece = {piece, file_in-3'd1, rank_in-3'd1, WHITE};
		src_piece  = {piece, file_in, rank_in, BLACK};
		file_in = file_in + 3'b001;
		#10
		tests = tests + 1;
		if((valid != 1'b1) && ((promo_check & formatted_move) != promo_check)) begin
			$display("ERROR(WHITE PAWN): Capture Promotion Left {Rank(%0d) File(%0d)}\n", rank, file);
		end else begin
			pass = pass + 1;
		end
	end

	/* Valid Capture Promotion
		+ files 1,8
		+ rank 2
	*/
	/* Right - File 1*/
	file_in = A;
	rank_in = TWO;
	dest_piece = {piece, file_in+3'b001, rank_in-3'd1, WHITE};
	src_piece  = {piece, file_in, rank_in, BLACK};
	#10
	tests = tests + 1;
	if((valid != 1'b1) && ((promo_check & formatted_move) != promo_check)) begin
		$display("ERROR(BLACK PAWN): Edge Capture Promotion Right {Rank(%0d) File(%0d)}\n", rank, file);
	end else begin
		pass = pass + 1;
	end

	/* Left - File 8*/
	file_in = H;
	rank_in = TWO;
	dest_piece = {piece, file_in-3'd1, rank_in-3'd1, WHITE};
	src_piece  = {piece, file_in, rank_in, BLACK};
	#10
	tests = tests + 1;
	if((valid != 1'b1) && ((promo_check & formatted_move) != promo_check)) begin
		$display("ERROR(BLACK PAWN): Edge Capture Promotion Left {Rank(%0d) File(%0d)}\n", rank, file);
	end else begin
		pass = pass + 1;
	end

	/******INVALID*********/

	$display("	INVALID\n");

	/*******WHITE**********/

	$display("		WHITE\n");

	/* Invalid 2-Sqr move, non-origin
			+ all files
			+ rank 3-5
	*/
	file_in = A;
	rank_in = THREE;
	for(rank = THREE; rank <= FIVE; rank = rank + 1) begin
		file_in = A;
		for(file = A; file <= H; file = file + 1) begin
			dest_piece = {EMPTY, file_in, rank_in+3'b010, WHITE};
			src_piece  = {piece, file_in, rank_in, WHITE};
			file_in = file_in + 3'b001;
			#10
			tests = tests + 1;
			if(valid != 1'b0) begin
				$display("ERROR(WHITE PAWN): [INVALID] 2-Sqr Forward Non-Origin {Rank(%0d) File(%0d)}\n", rank, file);
			end else begin
				pass = pass + 1;
			end
		end
		rank_in = rank_in + 3'b001;
	end

	/* Invalid 2-Sqr Forward, Blocking
			+ all files
			+ rank 2
	*/
	file_in = A;
	rank_in = TWO;
	for(file = A; file <= H; file = file + 1) begin
		dest_piece = {piece, file_in, rank_in+3'b010, WHITE};
		src_piece  = {piece, file_in, rank_in, WHITE};
		#10
		tests = tests + 1;
		if(valid != 1'b0) begin
			$display("ERROR(WHITE PAWN): [INVALID] 2-Sqr Friendly Forward Blocking {Rank(%0d) File(%0d)}\n", rank, file);
		end else begin
			pass = pass + 1;
		end
		dest_piece = {piece, file_in, rank_in+3'b010, BLACK};
		src_piece  = {piece, file_in, rank_in, WHITE};
		file_in = file_in + 3'b001;
		#10
		tests = tests + 1;
		if(valid != 1'b0) begin
			$display("ERROR(WHITE PAWN): [INVALID] 2-Sqr Un-Friendly Forward Blocking {Rank(%0d) File(%0d)}\n", rank, file);
		end else begin
			pass = pass + 1;
		end
	end

	/* Invalid 1-Sqr Forward, Blocking
			+ all files
			+ rank 2-7
	*/
	file_in = A;
	rank_in = TWO;
	for(rank = TWO; rank <= SEVEN; rank = rank + 1) begin
		for(file = A; file <= H; file = file + 1) begin
			dest_piece = {piece, file_in, rank_in+3'b001, WHITE};
			src_piece  = {piece, file_in, rank_in, WHITE};
			#10
			tests = tests + 1;
			if(valid != 1'b0) begin
				$display("ERROR(WHITE PAWN): [INVALID] 1-Sqr Friendly Forward Blocking {Rank(%0d) File(%0d)}\n", rank, file);
			end else begin
				pass = pass + 1;
			end
			dest_piece = {piece, file_in, rank_in+3'b001, BLACK};
			src_piece  = {piece, file_in, rank_in, WHITE};
			file_in = file_in + 3'b001;
			rank_in = rank_in + 3'b001;
			#10
			tests = tests + 1;
			if(valid != 1'b0) begin
				$display("ERROR(WHITE PAWN): [INVALID] 1-Sqr Un-Friendly Forward Blocking {Rank(%0d) File(%0d)}\n", rank, file);
			end else begin
				pass = pass + 1;
			end
		end
	end

	/* Invalid Capture, friendly piece
			+ files 2-7
			+ rank 2-7
	*/
	file_in = B;
	rank_in = TWO;
	for(rank = TWO; rank <= SEVEN; rank = rank + 1) begin
		for(file = B; file <= G; file = file + 1) begin
			/* Right */
			dest_piece = {piece, file_in+3'b001, rank_in+3'b001, WHITE};
			src_piece  = {piece, file_in, rank_in, WHITE};
			#10
			tests = tests + 1;
			if(valid != 1'b0) begin
				$display("ERROR(WHITE PAWN): [INVALID] Friendly Capture Right {Rank(%0d) File(%0d)}\n", rank, file);
			end else begin
				pass = pass + 1;
			end
			/* Left */
			dest_piece = {piece, file_in-3'b001, rank_in+3'b001, WHITE};
			src_piece  = {piece, file_in, rank_in, WHITE};
			file_in = file_in + 3'b001;
			rank_in = rank_in + 3'b001;
			#10
			tests = tests + 1;
			if(valid != 1'b0) begin
				$display("ERROR(WHITE PAWN): [INVALID] Friendly Capture Left {Rank(%0d) File(%0d)}\n", rank, file);
			end else begin
				pass = pass + 1;
			end
		end
	end

	/* Invalid Capture, friendly piece
			+ files 1,8
			+ rank 2-7
	*/
	/* Right - File 1*/
	file_in = A;
	rank_in = TWO;
	for(rank = TWO; rank <= SEVEN; rank = rank + 1) begin
		dest_piece = {piece, file_in+3'b001, rank_in+3'b001, WHITE};
		src_piece  = {piece, file_in, rank_in, WHITE};
		rank_in = rank_in + 3'b001;
		#10
		tests = tests + 1;
		if(valid != 1'b0) begin
			$display("ERROR(WHITE PAWN): [INVALID] Edge Capture Right {Rank(%0d) File(%0d)}\n", rank, file);
		end else begin
			pass = pass + 1;
		end
	end

	/* Left - File 8*/
	file_in = H;
	rank_in = TWO;
	for(rank = TWO; rank <= SEVEN; rank = rank + 1) begin
		dest_piece = {piece, file_in-3'b001, rank_in+3'b001, WHITE};
		src_piece  = {piece, file_in, rank_in, WHITE};
		rank_in = rank_in + 3'b001;
		#10
		tests = tests + 1;
		if(valid != 1'b0) begin
			$display("ERROR(WHITE PAWN): [INVALID] Edge Capture Left {Rank(%0d) File(%0d)}\n", rank, file);
		end else begin
			pass = pass + 1;
		end
	end

	/* Invalid Capture, Off Edge of Board
			+ file 1,8
			+ rank 2

		This tests the edge case where a pawn would be able to advance
		straight off the edge of the board and wrap around to the other side
	*/
	/* Right */
	file_in = H;
	rank_in = TWO;
	dest_piece = {piece, file_in+3'b001, rank_in+3'b001, BLACK};
	src_piece = {piece, file_in, rank_in, WHITE};
	#10
	tests = tests + 1;
	if(valid != 1'b0) begin
		$display("ERROR(WHITE PAWN): [INVALID] Capture Wrap Around Right {Rank(%0d) File(%0d)}\n", rank_in, file_in);
	end else begin
		pass = pass + 1;
	end
	/* Left */
	file_in = A;
	rank_in = TWO;
	dest_piece = {piece, file_in-3'b001, rank_in+3'b001, BLACK};
	src_piece = {piece, file_in, rank_in, WHITE};
	#10
	tests = tests + 1;
	if(valid != 1'b0) begin
		$display("ERROR(WHITE PAWN): [INVALID] Capture Wrap Around Left {Rank(%0d) File(%0d)}\n", rank_in, file_in);
	end else begin
		pass = pass + 1;
	end

	/* Invalid Capture, Off Edge of Board
			+ all files
			+ rank 8

		This tests the edge case where a pawn would be able to attack
		left/right off the edge of the board and wrap around to the other side
	*/
	file_in = A;
	rank_in = EIGHT;
	for(file = A; file <= H; file = file + 1) begin
		dest_piece = {EMPTY, file_in, rank_in-3'b001, WHITE};
		src_piece = {piece, file_in, rank_in, WHITE};
		file_in = file_in + 3'b001;
		#10
		tests = tests + 1;
		if(valid != 1'b0) begin
			$display("ERROR(WHITE PAWN): [INVALID] Wrap Around Forward {Rank(%0d) File(%0d)}\n", rank, file);
		end else begin
			pass = pass + 1;
		end
	end

	/* Invalid move, Pawns moving one square backwards
			+ all files
			+ ranks 2-7
	*/
	file_in = A;
	rank_in = TWO;
	for(rank = TWO; rank <= SEVEN; rank = rank + 1) begin
		for(file = A; file <= H; file = file + 1) begin
			dest_piece = {EMPTY, file_in, rank_in-3'b001, WHITE};
			src_piece  = {piece, file_in, rank_in, WHITE};
			file_in = file_in + 3'b001;
			rank_in = rank_in + 3'b001;
			#10
			tests = tests + 1;
			if(valid != 1'b0) begin
				$display("ERROR(WHITE PAWN): [INVALID] 1-Sqr Backwards {Rank(%0d) File(%0d)}\n", rank, file);
			end else begin
				pass = pass + 1;
			end
		end
	end

	/* Invalid move, Pawns moving two squares backwards
			+ all files
			+ ranks 3-7
	*/
	file_in = A;
	rank_in = THREE;
	for(rank = THREE; rank <= SEVEN; rank = rank + 1) begin
		for(file = A; file <= H; file = file + 1) begin
			dest_piece = {EMPTY, file_in, rank_in-3'd2, WHITE};
			src_piece  = {piece, file_in, rank_in, WHITE};
			file_in = file_in + 3'b001;
			rank_in = rank_in + 3'b001;
			#10
			tests = tests + 1;
			if(valid != 1'b0) begin
				$display("ERROR(WHITE PAWN): [INVALID] 2-Sqr Backwards {Rank(%0d) File(%0d)}\n", rank, file);
			end else begin
				pass = pass + 1;
			end
		end
	end

	/*******BLACK**********/

	$display("		BLACK\n");

	/* Invalid 2-Sqr move, non-origin
			+ all files
			+ rank 4-6
	*/
	file_in = A;
	rank_in = SIX;
	for(rank = SIX; rank >= FOUR; rank = rank - 1) begin
		file_in = A;
		for(file = A; file <= H; file = file + 1) begin
			dest_piece = {EMPTY, file_in, rank_in-3'd2, BLACK};
			src_piece  = {piece, file_in, rank_in, BLACK};
			file_in = file_in + 3'b001;
			#10
			tests = tests + 1;
			if(valid != 1'b0) begin
				$display("ERROR(BLACK PAWN): [INVALID] 2-Sqr Forward Non-Origin {Rank(%0d) File(%0d)}\n", rank, file);
			end else begin
				pass = pass + 1;
			end
		end
		rank_in = rank_in - 3'b001;
	end

	/* Invalid 2-Sqr Forward, Blocking
			+ all files
			+ rank 7
	*/
	file_in = A;
	rank_in = SEVEN;
	for(file = A; file <= H; file = file + 1) begin
		dest_piece = {piece, file_in, rank_in-3'd2, BLACK};
		src_piece  = {piece, file_in, rank_in, BLACK};
		#10
		tests = tests + 1;
		if(valid != 1'b0) begin
			$display("ERROR(BLACK PAWN): [INVALID] 2-Sqr Friendly Forward Blocking {Rank(%0d) File(%0d)}\n", rank, file);
		end else begin
			pass = pass + 1;
		end
		dest_piece = {piece, file_in, rank_in-3'd2, WHITE};
		src_piece  = {piece, file_in, rank_in, BLACK};
		file_in = file_in + 3'b001;
		#10
		tests = tests + 1;
		if(valid != 1'b0) begin
			$display("ERROR(BLACK PAWN): [INVALID] 2-Sqr Un-Friendly Forward Blocking {Rank(%0d) File(%0d)}\n", rank, file);
		end else begin
			pass = pass + 1;
		end
	end

	/* Invalid 1-Sqr Forward, Blocking
			+ all files
			+ rank 2-7
	*/
	file_in = A;
	rank_in = SEVEN;
	for(rank = SEVEN; rank >= TWO; rank = rank - 1) begin
		for(file = A; file <= H; file = file + 1) begin
			dest_piece = {piece, file_in, rank_in-3'd1, BLACK};
			src_piece  = {piece, file_in, rank_in, BLACK};
			#10
			tests = tests + 1;
			if(valid != 1'b0) begin
				$display("ERROR(BLACK PAWN): [INVALID] 1-Sqr Friendly Forward Blocking {Rank(%0d) File(%0d)}\n", rank, file);
			end else begin
				pass = pass + 1;
			end
			dest_piece = {piece, file_in, rank_in-3'd1, WHITE};
			src_piece  = {piece, file_in, rank_in, BLACK};
			file_in = file_in + 3'b001;
			rank_in = rank_in - 3'b001;
			#10
			tests = tests + 1;
			if(valid != 1'b0) begin
				$display("ERROR(BLACK PAWN): [INVALID] 1-Sqr Un-Friendly Forward Blocking {Rank(%0d) File(%0d)}\n", rank, file);
			end else begin
				pass = pass + 1;
			end
		end
	end

	/* Invalid Capture, friendly piece
			+ files 2-7
			+ rank 2-7
	*/
	file_in = B;
	rank_in = SEVEN;
	for(rank = SEVEN; rank >= TWO; rank = rank - 1) begin
		for(file = B; file <= G; file = file + 1) begin
			/* Right */
			dest_piece = {piece, file_in+3'b001, rank_in-3'd1, BLACK};
			src_piece  = {piece, file_in, rank_in, BLACK};
			#10
			tests = tests + 1;
			if(valid != 1'b0) begin
				$display("ERROR(BLACK PAWN): [INVALID] Friendly Capture Right {Rank(%0d) File(%0d)}\n", rank, file);
			end else begin
				pass = pass + 1;
			end
			/* Left */
			dest_piece = {piece, file_in-3'd1, rank_in-3'd1, BLACK};
			src_piece  = {piece, file_in, rank_in, BLACK};
			file_in = file_in + 3'b001;
			rank_in = rank_in - 3'b001;
			#10
			tests = tests + 1;
			if(valid != 1'b0) begin
				$display("ERROR(BLACK PAWN): [INVALID] Friendly Capture Left {Rank(%0d) File(%0d)}\n", rank, file);
			end else begin
				pass = pass + 1;
			end
		end
	end

	/* Invalid Capture, friendly piece
			+ files 1,8
			+ rank 2-7
	*/
	/* Right - File 1*/
	file_in = A;
	rank_in = SEVEN;
	for(rank = SEVEN; rank >= TWO; rank = rank - 1) begin
		dest_piece = {piece, file_in+3'b001, rank_in-3'd1, BLACK};
		src_piece  = {piece, file_in, rank_in, BLACK};
		rank_in = rank_in - 3'b001;
		#10
		tests = tests + 1;
		if(valid != 1'b0) begin
			$display("ERROR(BLACK PAWN): [INVALID] Edge Capture Right {Rank(%0d) File(%0d)}\n", rank, file);
		end else begin
			pass = pass + 1;
		end
	end

	/* Left - File 8*/
	file_in = H;
	rank_in = SEVEN;
	for(rank = SEVEN; rank >= TWO; rank = rank - 1) begin
		dest_piece = {piece, file_in-3'd1, rank_in-3'd1, BLACK};
		src_piece  = {piece, file_in, rank_in, BLACK};
		rank_in = rank_in - 3'b001;
		#10
		tests = tests + 1;
		if(valid != 1'b0) begin
			$display("ERROR(BLACK PAWN): [INVALID] Edge Capture Left {Rank(%0d) File(%0d)}\n", rank, file);
		end else begin
			pass = pass + 1;
		end
	end

	/* Invalid Capture, Off Edge of Board
			+ file 1,8
			+ rank 7

		This tests the edge case where a pawn would be able to advance
		straight off the edge of the board and wrap around to the other side
	*/
	/* Right */
	file_in = H;
	rank_in = SEVEN;
	dest_piece = {piece, file_in+3'b001, rank_in-3'd1, WHITE};
	src_piece = {piece, file_in, rank_in, BLACK};
	#10
	tests = tests + 1;
	if(valid != 1'b0) begin
		$display("ERROR(BLACK PAWN): [INVALID] Capture Wrap Around Right {Rank(%0d) File(%0d)}\n", rank, file);
	end else begin
		pass = pass + 1;
	end
	/* Left */
	file_in = A;
	rank_in = SEVEN;
	dest_piece = {piece, file_in-3'd1, rank_in-3'd1, WHITE};
	src_piece = {piece, file_in, rank_in, BLACK};
	#10
	tests = tests + 1;
	if(valid != 1'b0) begin
		$display("ERROR(BLACK PAWN): [INVALID] Capture Wrap Around Left {Rank(%0d) File(%0d)}\n", rank, file);
	end else begin
		pass = pass + 1;
	end

	/* Invalid Capture, Off Edge of Board
			+ all files
			+ rank 1

		This tests the edge case where a pawn would be able to attack
		left/right off the edge of the board and wrap around to the other side
	*/
	file_in = A;
	rank_in = ONE;
	for(file = A; file <= H; file = file + 1) begin
		dest_piece = {EMPTY, file_in, rank_in+3'd1, BLACK};
		src_piece = {piece, file_in, rank_in, BLACK};
		file_in = file_in + 3'b001;
		#10
		tests = tests + 1;
		if(valid != 1'b0) begin
			$display("ERROR(BLACK PAWN): [INVALID] Wrap Around Forward {Rank(%0d) File(%0d)}\n", rank, file);
		end else begin
			pass = pass + 1;
		end
	end

	/* Invalid move, Pawns moving one square backwards
			+ all files
			+ ranks 7-2
	*/
	file_in = A;
	rank_in = SEVEN;
	for(rank = SEVEN; rank >= TWO; rank = rank - 1) begin
		for(file = A; file <= H; file = file + 1) begin
			dest_piece = {EMPTY, file_in, rank_in+3'd1, BLACK};
			src_piece  = {piece, file_in, rank_in, BLACK};
			file_in = file_in + 3'b001;
			rank_in = rank_in - 3'b001;
			#10
			tests = tests + 1;
			if(valid != 1'b0) begin
				$display("ERROR(BLACK PAWN): [INVALID] 1-Sqr Backwards {Rank(%0d) File(%0d)}\n", rank, file);
			end else begin
				pass = pass + 1;
			end
		end
	end

	/* Invalid move, Pawns moving two squares backwards
			+ all files
			+ ranks 7-3
	*/
	file_in = A;
	rank_in = SEVEN;
	for(rank = SEVEN; rank >= THREE; rank = rank - 1) begin
		for(file = A; file <= H; file = file + 1) begin
			dest_piece = {EMPTY, file_in, rank_in+3'd2, BLACK};
			src_piece  = {piece, file_in, rank_in, BLACK};
			file_in = file_in + 3'b001;
			rank_in = rank_in - 3'b001;
			#10
			tests = tests + 1;
			if(valid != 1'b0) begin
				$display("ERROR(BLACK PAWN): [INVALID] 2-Sqr Backwards {Rank(%0d) File(%0d)}\n", rank, file);
			end else begin
				pass = pass + 1;
			end
		end
	end

	/**********************
	******BISHOPS**********
	***********************/

	piece = BISHOP;

	$display("3. BISHOPS\n");

	/*******VALID**********/

	$display("	VALID\n");

	/*******WHITE**********/

	$display("		WHITE\n");

	/*******BLACK**********/

	$display("		BLACK\n");

	/******INVALID*********/

	$display("	INVALID\n");

	/*******WHITE**********/

	$display("		WHITE\n");

	/*******BLACK**********/

	$display("		BLACK\n");

	/**********************
	********ROOKS**********
	***********************/

	piece = ROOK;

	$display("4. ROOKS\n");

	/*******VALID**********/

	$display("	VALID\n");

	/*******WHITE**********/

	$display("		WHITE\n");

	/*******BLACK**********/

	$display("		BLACK\n");

	/******INVALID*********/

	$display("	INVALID\n");

	/*******WHITE**********/

	$display("		WHITE\n");

	/*******BLACK**********/

	$display("		BLACK\n");

	/**********************
	********QUEEN**********
	***********************/

	piece = QUEEN;

	$display("5. QUEEN\n");

	/*******VALID**********/

	$display("	VALID\n");

	/*******WHITE**********/

	$display("		WHITE\n");

	/*******BLACK**********/

	$display("		BLACK\n");

	/******INVALID*********/

	$display("	INVALID\n");

	/*******WHITE**********/

	$display("		WHITE\n");

	/*******BLACK**********/

	$display("		BLACK\n");

	/**********************
	*********KING**********
	***********************/

	piece = KING;

	$display("6. KING\n");

	/*******VALID**********/

	$display("	VALID\n");

	/*******WHITE**********/

	$display("		WHITE\n");

	/*******BLACK**********/

	$display("		BLACK\n");

	/******INVALID*********/

	$display("	INVALID\n");

	/*******WHITE**********/

	$display("		WHITE\n");

	/*******BLACK**********/

	$display("		BLACK\n");

	/**********************
	*********DONE**********
	***********************/
	$display("DONE: %d of %d Tests Passed\n", pass, tests);

end

endmodule
