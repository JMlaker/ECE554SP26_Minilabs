module Minilab0_tb();


  logic CLOCK2_50, CLOCK3_50, CLOCK4_50, CLOCK_50;
  reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  logic [9:0] LEDR;
  logic [3:0] KEY;
  logic [9:0] SW;

  Minilab0 iDUT(.CLOCK2_50(CLOCK2_50), .CLOCK3_50(CLOCK3_50), .CLOCK4_50(CLOCK4_50), .CLOCK_50(CLOCK_50), .KEY(KEY), .SW(SW),
                .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5), .LEDR(LEDR));


  initial begin
    CLOCK_50 = 1'b0;
    CLOCK2_50 = 1'b0;
    CLOCK3_50 = 1'b0;
    CLOCK4_50 = 1'b0;
    KEY = 4'h0; // Reset
    SW = 10'h000;

    // Wait a couple of clock cycles for stabalization
    repeat(2) @(posedge CLOCK_50);
    @(posedge CLOCK_50);

    @(negedge CLOCK_50);
    KEY = 4'h1;

    // Enable the switch
    @(negedge CLOCK_50);
    SW = 10'h001;

    // DONE
    @(posedge LEDR[1]);

    // Wait some clocks
    repeat(10) @(posedge CLOCK_50);

    @(negedge CLOCK_50) begin
      if (HEX0 !== 7'h00 || HEX1 !== 7'h12 || HEX2 !== 7'h03 || HEX3 !== 7'h79 || HEX4 !== 7'h40 || HEX5 !== 7'h40) begin
        $display("ERROR! HEX0: %h, HEX1: %h, HEX2: %h, HEX3: %h, HEX4: %h, HEX5: %h",
                  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
        $stop();
      end
    end

    $display("YAHOO!! All tests passed!");
    $stop();
  end

  always
     #5 CLOCK_50 <= ~CLOCK_50;

endmodule