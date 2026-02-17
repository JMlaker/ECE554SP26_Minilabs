module transmit(
  input wire clk,
  input wire rst,
  input wire b_en,
  input wire i_iocs,
  output wire o_tx,
  input wire i_iorw,
  output wire o_tbr
  );
  localparam IDLE = 2'b00;
  localparam START_BIT = 2'b01;
  localparam READING = 2'b10;
  localparam END_BIT = 2'b11;
  logic [1:0] curr_state, next_state;
  logic [2:0] counter;
  reg   [7:0] buffer;

endmodule
