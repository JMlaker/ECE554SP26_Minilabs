module conv (
    input wire clk,
    input wire rst,
    input wire signed [12:0] row_0_0,
    input wire signed [12:0] row_0_1,
    input wire signed [12:0] row_0_2,
    input wire signed [12:0] row_1_0,
    input wire signed [12:0] row_1_1,
    input wire signed [12:0] row_1_2,
    input wire signed [12:0] row_2_0,
    input wire signed [12:0] row_2_1,
    input wire signed [12:0] row_2_2,
    input wire mode,
    output wire [17:0] y_abs

);

  //reg signed [12:0] h [8:0];
  //range of values for h is -2,-1,0,1,2
  //max value possible for a single mult = 2*2^(11)-1=8190
  //adding 9 of these yields 73710
  //clog2(73710)=17 bits required to represent it
  //1 additional bit for sign, 18 bits

  //smallest value representable is -4096*2=-8192
  //adding 9 of these yields -73728
  //clog2(73728)=17 bit require to represnet it


  /*
  always @(*) begin
    if (mode) begin
      h[0] = 12'sd1;
      h[1] = 12'sd0;
      h[2] = -12'sd1;
      h[3] = 12'sd2;
      h[4] = 12'sd0;
      h[5] = -12'sd2;
      h[6] = 12'sd1;
      h[7] = 12'sd0;
      h[8] = -12'sd1;
    end else begin
      h[0] = 12'sd1;
      h[1] = 12'sd2;
      h[2] = 12'sd1;
      h[3] = 12'sd0;
      h[4] = 12'sd0;
      h[5] = 12'sd0;
      h[6] = -12'sd1;
      h[7] = -12'sd2;
      h[8] = -12'sd1;
    end
  end
  */
  reg signed [17:0] y;
  always @(posedge clk) begin
    if (~rst) begin
      y <= 18'b0;
    end else begin
      if (mode) begin
        y <= ((row_0_0) - (row_0_2) + {row_1_0, 1'b0} - {row_1_2, 1'b0} + row_2_0 - (row_2_2));
      end else begin
        y <= ((row_0_0) + {row_0_1, 1'b0} + (row_0_2) - (row_2_0) - {row_2_1, 1'b0} - (row_2_2));
      end
    end
  end
  assign y_abs = (y < 0) ? (-y) : y;
endmodule









