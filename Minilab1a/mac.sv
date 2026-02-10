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

logic [DATA_WIDTH*3-1:0] result;
logic [DATA_WIDTH*3-1:0] out;
assign result = Ain * Bin + out;

always_ff @(posedge clk, negedge rst_n)
  if (~rst_n)
    out <= '0;
  else if (Clr)
    out <= '0;
  else if (En)
    out <= result;

assign Cout = out;


endmodule