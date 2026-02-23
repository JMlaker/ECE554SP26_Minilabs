`default_nettype none

module transmit (
  input wire clk,
  input wire rst, 
  input wire [7:0] i_data, 
  input wire b_en, 
  input wire i_iocs, 
  input wire i_iorw, 
  output logic o_tx, 
  output wire o_tbr
);


typedef enum {IDLE, TRANS} state_t;

logic shift, load, transmitting;

/////////////////////////////
// Bit Counter
/////////////////////////////

logic [3:0] bit_cnt;

always_ff @(posedge clk) begin
    unique case ({load,shift}) inside
        2'b00: bit_cnt <= bit_cnt;
        2'b01: bit_cnt <= bit_cnt + 1;
        default: bit_cnt <= 4'h0;
	endcase
end

/////////////////////////////
// State Machine
/////////////////////////////

state_t state, nxt_state;
logic set_done;

always_ff @(posedge clk, negedge rst) begin
    if (~rst)
        state <= IDLE;
    else
        state <= nxt_state;
end

always_comb begin
    nxt_state = state;
    transmitting = 1'b0;
    load = 1'b0;
    set_done = 1'b0;
    unique case (state) inside
        TRANS: begin
            if (bit_cnt == 4'b1010) begin
                nxt_state = IDLE;
                set_done = 1'b1;
            end
            else begin
                transmitting = 1'b1;
                nxt_state = TRANS;
            end
        end
		// Default = IDLE
        default: begin
			if (i_iocs && i_iorw) begin
				nxt_state = TRANS;
				load = 1'b1;
			end else
				nxt_state = IDLE;
        end
	endcase
end

always_ff @(posedge clk, negedge rst) begin
    if (~rst)
        tx_done <= 1'b1;
    else if (set_done)
        tx_done <= 1'b1;
	else if (load)
		tx_done <= 1'b0;
end

/////////////////////////////
// Baud/Shift logic
/////////////////////////////

assign shift = b_en;

/////////////////////////////
// Serial Out
/////////////////////////////

logic [8:0] tx_shft_reg;

always_ff @(posedge clk) begin
    if (~rst_n)
        tx_shft_reg <= '1;
    else begin
        unique case ({load,shift}) inside
            2'b00: tx_shft_reg <= tx_shft_reg;
            2'b01: tx_shft_reg <= {1'b1, tx_shft_reg[8:1]};
            default: tx_shft_reg <= {i_data, 1'b0};
		endcase
    end
end

assign o_tbr == (state == IDLE);

assign o_tx = tx_shft_reg[0];


endmodule
