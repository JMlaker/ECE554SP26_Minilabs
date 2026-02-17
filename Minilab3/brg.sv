//implemented using a down counter and a decoder
//enable signal is asserted for a duration of one CLK period, with a frequency
//of 2^n x baud_rate. n ranges from 2 to 4
//
//frequency of clk driving the BRG module will vary
//BRG must be programmable to maintain a fixed baud rate despite changing
//clock frequency
//
//Programming is achieved by the processor loading 2 bytes, DB(high) and
//DB(low) into the divisor buffer. 



module brg (
    input wire clk,
    input wire rst,
    input wire [1:0] i_ioaddr_brg,
    input wire [7:0] i_brg_bus,
    output wire en
);
  reg [15:0] div_buf;
  reg [15:0] down_counter;
  always @(posedge clk) begin
    if (!rst) div_buf <= 16'b0;
    else begin
      if (i_ioaddr_brg == 2'b11) begin
        div_buf[15:8] <= i_brg_bus;
        down_counter[15:8] <= i_brg_bus;
      end else if (i_ioaddr_brg == 2'b10) begin
        div_buf[7:0] <= i_brg_bus;
        down_counter[7:0] <= i_brg_bus;
      end  //if neither DB(high) or DB(low) are being set, act normally(?)
      else begin
        if (down_counter == 0) down_counter <= div_buf;
        else down_counter <= down_counter - 1;

      end
    end
  end
  assign en = (down_counter == 0);
endmodule
