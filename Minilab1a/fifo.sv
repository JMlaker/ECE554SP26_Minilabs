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
  output [DATA_WIDTH-1:0] o_data,
  output full,
  output empty
);

localparam int ADDR_W = (DEPTH <= 1) ? 1 : $clog2(DEPTH);

logic [DATA_WIDTH-1:0] mem[DEPTH-1:0];
logic [ADDR_W:0] wptr; // Make one bit wider for full detection
logic [ADDR_W:0] rdptr;

logic [DATA_WIDTH-1:0] out_data;

// Only do write/read depending on whether the memory is not full or not empty, respectively
logic write;
logic read;
assign write = wren & ~full;
assign read = rden & ~empty;

// Address with only the lower bits
logic [ADDR_W-1:0] waddr;
logic [ADDR_W-1:0] rdaddr;
assign waddr = wptr[ADDR_W-1:0];
assign rdaddr = rdptr[ADDR_W-1:0];

integer i;
always_ff @(posedge clk, negedge rst_n)
  if (~rst_n) begin
    mem <= '{default: '0};
  end
  else if (write)
    mem[waddr] <= i_data;

// wptr logic
always_ff @(posedge clk, negedge rst_n)
  if (~rst_n)
    wptr <= '0;
  else if (write) // Only write when there is room. Otherwise, just ignore the value.
    wptr <= wptr + 1'b1;

// rdptr logic
always_ff @(posedge clk, negedge rst_n)
  if (~rst_n)
    rdptr <= '0;
  else if (read) // Only read when the memory is not empty. 
    rdptr <= rdptr + 1'b1;

// Output data on read logic
always_ff @(posedge clk, negedge rst_n)
  if (~rst_n)
    out_data <= '0;
  else if (read)
    out_data <= mem[rdaddr];

// Output logic
assign o_data = out_data;
assign empty = (wptr == rdptr);
assign full  = (wptr[ADDR_W] != rdptr[ADDR_W]) && // When the wrap bit differs (top bit) and the rest are the same, then the pointers are DEPTH entries apart
                (wptr[ADDR_W-1:0] == rdptr[ADDR_W-1:0]);


endmodule