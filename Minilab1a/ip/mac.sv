module MAC #
(
parameter DATA_WIDTH = 8
)
(
input clk,
input rst_n,
input En,
input Clr,
input [DATA_WIDTH-1:0] Ain,
input [DATA_WIDTH-1:0] Bin,
output [DATA_WIDTH*3-1:0] Cout
);
logic [DATA_WIDTH*2-1:0] out;
logic [DATA_WIDTH*3-1:0] macout;
logic [DATA_WIDTH*3-1:0] res;

MULT iMULT (
	.dataa(Ain),
	.datab(Bin),
	.result(out)
	);
	
ADD_SUB iADD_SUB (
	.dataa(out),
	.datab(macout),
	.result(res));
	
always @(posedge clk, negedge rst_n) begin
  if (~rst_n)
    macout <= 24'h00000;
  else if (Clr)
     macout <= 24'h00000;
  else if (En)
	 macout <= res;
end

assign Cout = macout;


endmodule