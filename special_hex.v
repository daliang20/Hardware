module hex2decseg(
   input[3:0] hex,   
   output reg[0:6] seg
);

parameter ZERO = 7'b000_0001;
parameter ONE = 7'b100_1111;
parameter TWO = 7'b001_0010;
parameter THREE = 7'b000_0110;
parameter FOUR = 7'b100_1100;
parameter FIVE = 7'b010_0100;
parameter SIX = 7'b010_0000;
parameter SEVEN = 7'b000_1111;
parameter EIGHT = 7'b000_0000;
parameter OFF = 7'b111_1111;

always@(hex)
   case(hex)
       0: seg = ZERO;
       1: seg = ONE;
       2: seg = TWO;
       3: seg = THREE;
       4: seg = FOUR;
       5: seg = FIVE;
       6: seg = SIX;
       7: seg = SEVEN;
       8: seg = EIGHT;
    default: seg = OFF;

endcase
endmodule 

module hex2textseg(
   input[3:0] hex,   
   output reg[0:6] seg
);

parameter A = 7'b000_1000;
parameter B = 7'b110_0000;
parameter C = 7'b011_0001;
parameter D = 7'b100_0010;
parameter E = 7'b011_0000;
parameter F = 7'b011_1000;
parameter G = 7'b000_0100;
parameter H = 7'b100_1000;
parameter OFF = 7'b111_1111;

always@(hex)
   case(hex)
       0: seg = A;
       1: seg = B;
       2: seg = C;
       3: seg = D;
       4: seg = E;
       5: seg = F;
       6: seg = G;
       7: seg = H;
    default: seg = OFF;

endcase
endmodule 