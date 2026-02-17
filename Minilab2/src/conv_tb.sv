module conv_tb ();
  logic signed [12:0] row_1[2:0];
  logic signed [12:0] row_2[2:0];
  logic signed [12:0] row_3[2:0];
  logic clk;
  logic rst;

  initial clk = 1'b0;
  always begin
    clk = #5 ~clk;
  end
  initial rst = 1'b1;
  logic mode;
  logic [17:0] y_abs;
  conv iDUT (
      .clk(clk),
      .rst(rst),
      .row_0_0(row_1[0]),
      .row_0_1(row_1[1]),
      .row_0_2(row_1[2]),

      .row_1_0(row_2[0]),
      .row_1_1(row_2[1]),
      .row_1_2(row_2[2]),

      .row_2_0(row_2[0]),
      .row_2_1(row_2[1]),
      .row_2_2(row_2[2]),
      .mode(mode),
      .y_abs(y_abs)
  );

  task drive(input signed [12:0] inp_1[2:0], input signed [12:0] inp_2[2:0],
             input signed [12:0] inp_3[2:0], input i_mode);
    row_1 = inp_1;
    row_2 = inp_2;
    row_3 = inp_3;
    mode  = i_mode;
  endtask

  integer i;


  initial begin
    $dumpfile("conv.vcd");
    $dumpvars(0, conv_tb);
    row_1[0] = 13'd1;
    row_1[1] = 13'd1;
    row_1[2] = 13'd1;

    row_2[0] = 13'b1;
    row_2[1] = 13'b1;
    row_2[2] = 13'b1;

    row_3[0] = 13'b1;
    row_3[1] = 13'b1;
    row_3[2] = 13'b1;
    drive(row_1, row_2, row_3, 0);
    #20;
    drive(row_1, row_2, row_3, 1);
    #20;
    row_1[0] = 13'h800;
    row_1[1] = -13'd2;
    row_1[2] = -13'd2;

    row_2[0] = 13'd1;
    row_2[1] = 13'd1;
    row_2[2] = 13'd1;

    row_3[0] = 13'd0;
    row_3[1] = 13'd0;
    row_3[2] = 13'd0;
    drive(row_1, row_2, row_3, 0);
    #20;
    drive(row_1, row_2, row_3, 1);
    #20;
    row_3[2] = 13'd1;
    drive(row_1, row_2, row_3, 1);
    #20;
  end


endmodule

