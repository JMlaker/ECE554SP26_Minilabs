module matrix_mult (clk, rst_n, start, clr, a_data, b_data, c_out, done); 

input logic clk, rst_n;
input logic start, clr;
input logic [7:0] a_data [0:7][0:7];
input logic [7:0] b_data [0:7];
output logic [23:0] c_out [0:7];
output logic done;

logic a_rden [0:7];
logic wren;

logic [7:0] a_fifo_in [0:7];
logic [7:0] b_fifo_in;

logic [7:0] a [0:7];
logic [7:0] b;

logic a_full [0:7], a_empty [0:7], b_empty;

generate
  genvar i;
  for (i = 0; i < 8; i++) begin: fifo_gen
    FIFO a_fifo(.clk(clk),
              .rst_n(rst_n),
              .rden(a_rden[i]),
              .wren(wren),
              .i_data(a_fifo_in[i]),
              .o_data(a[i]),
              .full(a_full[i]),
              .empty(a_empty[i]));
  end

  FIFO b_fifo(.clk(clk), .rst_n(rst_n), .rden(a_rden[0]), .wren(wren), .i_data(b_fifo_in), .o_data(b), .full(b_full), .empty(b_empty));
endgenerate

logic full;
assign full = a_full[0] & a_full[1] & a_full[2] & a_full[3] & a_full[4] & a_full[5] & a_full[6] & a_full[7] & b_full;


typedef enum reg [2:0] {IDLE, FILL, CALC_START, CALC_END, DONE} state_t;

state_t state, next_state;

always_ff @(posedge clk, negedge rst_n) begin
  if (~rst_n)
    state <= IDLE;
  else
    state <= next_state;
end

logic [3:0] index;

always_ff @(posedge clk, negedge rst_n) begin
  if (~rst_n) begin
    index <= 0;
  end
  else begin
    if (wren) begin
      index <= index + 1;
    end
    else index <= 0;
  end
end

always_comb begin
		a_fifo_in[0] = a_data[0][index];
	  a_fifo_in[1] = a_data[1][index];
		a_fifo_in[2] = a_data[2][index];
	  a_fifo_in[3] = a_data[3][index];
	  a_fifo_in[4] = a_data[4][index];
	  a_fifo_in[5] = a_data[5][index];
	  a_fifo_in[6] = a_data[6][index];
	  a_fifo_in[7] = a_data[7][index];
	  b_fifo_in = b_data[index];
end

logic [7:0] mac_b [0:7];

always_ff @(posedge clk, negedge rst_n) begin
  if (~rst_n) begin
    mac_b[1:7] <= '{default: '0};
    a_rden[1:7] <= '{default: '0};
  end
  else begin
    if (a_rden[0] | a_rden[7]) begin
			 mac_b[1] <= mac_b[0];
     	 mac_b[2] <= mac_b[1];
     	 mac_b[3] <= mac_b[2];
     	 mac_b[4] <= mac_b[3];
     	 mac_b[5] <= mac_b[4];
     	 mac_b[6] <= mac_b[5];
     	 mac_b[7] <= mac_b[6];

      a_rden[1] <= a_rden[0];
      a_rden[2] <= a_rden[1];
      a_rden[3] <= a_rden[2];
      a_rden[4] <= a_rden[3];
      a_rden[5] <= a_rden[4];
      a_rden[6] <= a_rden[5];
      a_rden[7] <= a_rden[6];
    end
  end
end

generate
  genvar j;
  for (j = 0; j < 8; j++) begin: mac_gen
    MAC mac(.clk(clk),
            .rst_n(rst_n),
            .En(1'b1),
            .Clr(clr),
            .Ain(a[j]),
            .Bin(mac_b[j]),
            .Cout(c_out[j]));
  end
endgenerate

always_comb begin
  next_state = state;
  wren = 0;
  a_rden[0] = 1'b0;
  mac_b[0] = 0;
	done = 0;

  case (state)
    default: begin
      if (start) begin
        next_state = FILL;
      end
    end

    FILL: begin
      if (~full) begin
        wren = 1;
      end
      else begin
        next_state = CALC_START;
      end
    end

    CALC_START: begin
			a_rden[0] = 1'b1;
      mac_b[0] = b;
      if (a_empty[0])
        next_state = CALC_END;
    end

		CALC_END: begin
			if (a_empty[7]) begin
				done = 1;
				next_state = DONE;
			end
		end

		DONE: begin
			done = 1;
			if (start) begin
				next_state = FILL;
			end
		end
  endcase
end



endmodule
