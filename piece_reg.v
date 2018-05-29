/*******************************************************************************
Filename: piece_reg.v
Author: Kyle

Description: Stores a piece within a square. Retains value until enabled.
*******************************************************************************/
module piece_reg (
    input       [9:0]   in,
    input               enable,
    input               clk,
    input               rst,
    output reg  [9:0]   out
    );

    always @(posedge clk or negedge rst) begin
        if(!rst)
            out <= 0;

        else begin
            if(enable)
                out <= in;
            else
                out <= out;
        end
    end

endmodule
