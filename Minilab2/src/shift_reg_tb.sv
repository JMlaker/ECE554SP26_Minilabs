module shift_reg_tb ();
  logic clk;
  logic rst;
  logic [11:0] inp;
  wire [11:0] line_1_3[2:0];
  wire [11:0] line_2_3[2:0];
  wire [11:0] line_3_3[2:0];

  initial clk = 1'b0;
  initial rst = 1'b1;
  always begin
    #5 clk = ~clk;
  end
  initial begin
    $dumpfile("shift_reg.vcd");
    $dumpvars(0, shift_reg_tb);
    #100;
  end
endmodule
