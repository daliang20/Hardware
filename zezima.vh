/*******************************************************************************
Filename: zezima.vh
Author: Kyle

Description: Defines all common parameters, including
    - Piece type
    - Column
    - Row
    - Color

For reference:
Direction the piece slid to reach Rx:
Up              0
Right           1
Down            2
Left            3
Up-Left         4
Up-Right        5
Down-Right      6
Down-Left       7

K-2Up1Left      8
K-2Up1Right     9
K-2Right1Up     10
K-2Right1Down   11
K-2Down1Right   12
K-2Down1Left    13
K-2Left1Down    14
K-2Left1Up      15
*******************************************************************************/
parameter INVALID   =   3'b000;
parameter EMPTY     =   3'b001;
parameter PAWN      =   3'b010;
parameter ROOK      =   3'b011;
parameter KNIGHT    =   3'b100;
parameter BISHOP    =   3'b101;
parameter QUEEN     =   3'b110;
parameter KING      =   3'b111;

/* File */

parameter A         =   3'b000;
parameter B         =   3'b001;
parameter C         =   3'b010;
parameter D         =   3'b011;
parameter E         =   3'b100;
parameter F         =   3'b101;
parameter G         =   3'b110;
parameter H         =   3'b111;

/* Rank */

parameter ONE       =   3'b000;
parameter TWO       =   3'b001;
parameter THREE     =   3'b010;
parameter FOUR      =   3'b011;
parameter FIVE      =   3'b100;
parameter SIX       =   3'b101;
parameter SEVEN     =   3'b110;
parameter EIGHT     =   3'b111;

parameter WHITE     =   1'b0;
parameter BLACK     =   1'b1;

/*
Other useful information:

Piece Format: MSB {type, column, row, color} LSB
Move  Format: MSB {1'b0, castle, promo, capture, src_col, src_row, dest_col, dest_row}
*/
