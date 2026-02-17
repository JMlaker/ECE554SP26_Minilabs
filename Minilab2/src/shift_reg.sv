module shift_reg (
    input wire clk,
    input wire rst,
    input wire [11:0] inp,
    output wire [11:0] line_1_3[2:0],
    output wire [11:0] line_2_3[2:0],
    output wire [11:0] line_3_3[2:0]
);

  //2 lines, 12 bit words, 640 words per line; 1280
  //additional 3 lines; 1283
  //index as [1282:0]

  integer i = 0;
  reg [11:0] row[1282:0];

  always @(posedge clk) begin
    if (~rst) begin
      for (i = 0; i < 1283; i = i + 1) begin
        row[i] <= 'b0;
      end
    end else begin
      row[0] <= inp;
      for (i = 1; i < 1283; i = i + 1) begin
        row[i] <= row[i-1];
      end
    end
  end

  //DOUBLE CHECK THIS SHIT
  assign line_1_3 = row[1282:1280];
  assign line_1_3 = row[642:640];
  assign line_1_3 = row[2:0];
endmodule
