module FIFO
#(
  parameter DEPTH=8,
  parameter DATA_WIDTH=8
)
(
  input  clk,
  input  rst_n,
  input  rden,
  input  wren,
  input  [DATA_WIDTH-1:0] i_data,
  output reg [DATA_WIDTH-1:0] o_data,
  output full,
  output empty
);

reg [DATA_WIDTH-1:0] data [DEPTH-1:0];
reg [3:0] count;
integer i;

assign empty = (count == 4'b0000);
assign full = (count == DEPTH);

always_ff @(posedge clk) begin
  if (rden) begin
    o_data <= data[0];
  end 
  else begin
    o_data <= 0;
  end 
end

always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    count <= 4'b0000;
  end 

  else begin
    if (wren && !full) begin
      count <= count + 1;
    end

    else if (rden && !empty) begin
      count <= count - 1;
    end
  end 
end

always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    for(i = 0; i < DEPTH; i = i + 1) begin
      data[i] <= 0;
    end
  end 

  else begin
    if (wren && !full) begin
      data[count] <= i_data;
    end

    else if (rden && !empty) begin
      for(i = 0; i < DEPTH - 1; i = i + 1) begin
        data[i] <= data[i + 1];
      end

      data[DEPTH - 1] <= 0;
    end 
  end 
end

endmodule