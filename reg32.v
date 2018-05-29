module reg32(
	input clock, 
	input reset_n,
	input [31:0] D,
	input [3:0] byteenable,
	output [31:0] Q
); 

reg [31:0] ram;

always @(posedge clock) 
begin 
	if(reset_n == 0) begin 
		ram <= 0;
	end else begin 
		ram[31:24] <= byteenable[3] ? D[31:24] : ram[31:24];
		ram[23:16] <= byteenable[2] ? D[23:16] : ram[23:16];
		ram[15: 8] <= byteenable[1] ? D[15: 8] : ram[15: 8]; 
		ram[7 : 0] <= byteenable[0] ? D[ 7: 0] : ram[ 7: 0];
	end
end 

assign Q = ram;

endmodule 
