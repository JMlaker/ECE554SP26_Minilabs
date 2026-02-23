`default_nettype none

module recieve (
  input wire clk,
  input wire rst,
  input wire b_en,
  input wire i_iocs,
  input wire i_rx,
  input wire i_iorw,
  output wire o_rda,
  output wire [7:0] o_data
);

typedef enum {IDLE, RECIEVE} state_t;

logic shift, start, recieving;

/////////////////////////////
// Resolve Meta-Stability
/////////////////////////////

logic RX_synch, RX_stable;

always_ff @(posedge clk, negedge rst) begin
  if (~rst)
    RX_synch <= 1'b1;
  else
    RX_synch <= i_rx;
end

always_ff @(posedge clk, negedge rst) begin
  if (~rst)
    RX_stable <= 1'b1;
  else
    RX_stable <= RX_synch;
end

/////////////////////////////
// Bit Counter
/////////////////////////////

logic [3:0] bit_cnt;

always_ff @(posedge clk) begin
  unique case ({start,shift}) inside
    2'b00: bit_cnt <= bit_cnt;
    2'b01: bit_cnt <= bit_cnt + 1;
    default: bit_cnt <= 4'h0;
	endcase
end

/////////////////////////////
// State Machine
/////////////////////////////

state_t state, nxt_state;
logic set_rdy;

always_ff @(posedge clk, negedge rst) begin
  if (~rst)
    state <= IDLE;
  else
    state <= nxt_state;
end

always_comb begin
  nxt_state = state;
  recieving = 1'b0;
  start = 1'b0;
  set_rdy = 1'b0;
  unique case (state) inside
    RECIEVE: begin
      // Contrary to TX which sends 10 bits, RX only needs
      // to "recieve" 9 bits so it doesn't catch the stop bit
      if (bit_cnt == 4'b1001) begin
        nxt_state = IDLE;
        set_rdy = 1'b1;
      end
      else begin
        recieving = 1'b1;
        nxt_state = RECIEVE;
      end
    end
    // Default = IDLE
    default: begin
      if (~RX_stable) begin
        nxt_state = RECIEVE;
        start = 1'b1;
      end else
        nxt_state = IDLE;
    end
endcase
end

always_ff @(posedge clk, negedge rst) begin
  if (~rst)
    o_rda <= 1'b0;
  else if (clr_rdy)
    o_rda <= 1'b1;
  else if (set_rdy)
    o_rda <= 1'b0;
	else if (start)
		o_rda <= 1'b1;
end

/////////////////////////////
// Baud/Shift logic
/////////////////////////////

assign shift = b_en;

/////////////////////////////
// Serial Input
/////////////////////////////

logic [8:0] rx_shft_reg;

always_ff @(posedge clk) begin
  unique case ({shift}) inside
    1'b1: rx_shft_reg <= {RX_stable, rx_shft_reg[8:1]};
    default: rx_shft_reg <= rx_shft_reg;
  endcase
end

assign o_data = rx_shft_reg[7:0];

endmodule

`default_nettype wire
