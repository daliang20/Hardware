/*******************************************************************************
Filename: local_stack.v
Author: Kyle

Description: Module wraps an Altera ram block to emulate a stack. The Rx side
can write moves into the stack during its discovery phase, and the top level FSM
can pull the moves out into a higher level storage using arbiters.
*******************************************************************************/
module local_stack (
    // RX side
    input       [15:0]  move_in,
    input               write,

    // Top Level Side (through arbiters)
    input               clk,
    input               rst,
    input               read,
    output              stack_empty,
    output      [15:0]  move_out
    );

    reg [4:0] index, nxt_index;
    reg ready;

    assign stack_empty = (index == 0) ? 1'b1 : 1'b0;

    wire  [15:0]    data = ready ? move_in : 16'd0;
    wire            wren = ready ? write : 1'b1;

    // Assumes that write and read do not occur simultaneously!!
    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            index <= 0;
            ready <= 0;
        end
        else begin
            case(ready)
                // Initialization
                1'b0: begin
                    if(index < 31) begin
                        index <= index + 5'd1;
                        ready <= 0;
                    end
                    else begin
                        index <= 0;
                        ready <= 1'b1;
                    end
                end

                // Ready
                1'b1: begin
                    index <= nxt_index;
                    ready <= 1'b1;
                end
            endcase
        end
    end

    stack_ram ram (
        .clock       (clk),
    	.data        (data),
    	.address     (index),
    	.wren        (wren),
    	.q           (move_out)
    );

    // Increments the stack index on valid read or write
    // Assumes that write and read do not occur simultaneously!!
    always @ (*) begin
        nxt_index = index;

        if(write && index < 5'd15)
            nxt_index = index + 5'd1;

        if(read && index != 0)
            nxt_index = index - 5'd1;

    end

endmodule
