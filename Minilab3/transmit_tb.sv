module transmit_tb ();
  logic clk;
  logic [7:0] i_data;
  logic rst;
  logic b_en;
  logic i_iocs;
  logic o_tx;
  logic i_iorw;
  logic o_tbr;

  initial clk=1'b0;
  initial rst=1'b1;
  always clk= #5 ~clk;

endmodule
