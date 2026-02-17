//for recieving, when a transition from 1->0 is detected, this is considered
//the start bit;
//after this, 8 bits of data are recieved
//after this, remain at 1
module recieve (
    input wire clk,
    //NOTE: ONLY SAMPLE WHEN b_en IS HIGH!
    input wire b_en,
    input wire rst,
    input wire i_iocs,
    input wire i_rx,
    input wire i_iorw,
    //Receive Data Available: indicates that a byte of data has been recieved
    //and is ready to be read from the SPART to the processor. 
    output wire o_rda,
    output wire [7:0] o_data
);
  localparam IDLE = 2'b00;
  localparam START_BIT = 2'b01;
  localparam READING = 2'b10;
  localparam END_BIT = 2'b11;
  logic [1:0] curr_state, next_state;
  logic [2:0] counter;
  //NOTE: n=4, hence oversampling of 16!!!!
  logic [2:0] start_counter;
  logic [3:0] t_counter;
  reg [7:0] buffer;
  reg i_rx_reg;

  assign o_data = buffer;

  always @(posedge clk) begin
    if (!rst) i_rx_reg <= 1'b0;
    else i_rx_reg <= i_rx;
  end

  //next_state logic
  //once we detect a negedge on i_rx, wait 2 baud cycles to transition?
  always_comb begin
    //idle state
    next_state = 2'b00;
    case (curr_state)
      //if current state is IDLE and reciever samples a 0, transition to
      //START_BIT
      IDLE: begin
        if (i_rx == 1'b0 && i_rx_reg == 1'b1) next_state = START_BIT;
        else next_state = IDLE;
      end
      START_BIT: begin
        if (start_counter == 3'b111) next_state = READING;
        else next_state = START_BIT;
      end
      READING: begin
        if (counter != 3'b111) next_state = READING;
        else next_state = END_BIT;
      end
      END_BIT: begin
        if (start_counter == 3'b111) next_state = IDLE;
        else next_state = END_BIT;
      end
    endcase
  end

  //when transitioning from END_BIT to IDLE, indicates a read has been
  //completed
  //when iorw==1, indicates a read. set o_rda to 0 once this read has been
  //completed?
  reg rda;
  assign o_rda = rda;
  always @(posedge clk) begin
    if (!rst) rda <= 1'b0;
    else begin
      if (b_en) begin
        if (curr_state == END_BIT && next_state == IDLE) rda <= 1'b1;
        if (i_iocs && i_iorw == 1'b1) rda <= 1'b0;
      end
    end
  end

  always @(posedge clk) begin
    if (!rst) curr_state <= IDLE;
    else begin
      if (b_en) begin
        curr_state <= next_state;
      end
    end
  end

  //TODO: check if i_rx is maintained at 0 to check for noise?
  always @(posedge clk) begin
    if (!rst) begin
      buffer <= 8'b0;
      counter <= 3'b0;
      start_counter <= 3'b0;
      t_counter <= 0;
    end else begin
      if (b_en) begin
        case (curr_state)
          IDLE: begin
            buffer <= buffer;
            counter <= 3'b0;
            t_counter <= 0;
            start_counter <= 0;
          end
          START_BIT: begin
            buffer <= buffer;
            counter <= 3'b0;
            start_counter <= start_counter + 1;
            t_counter <= 0;
          end
          READING: begin
            start_counter <= 0;
            //check to be in the middle of the bit
            if (t_counter == 4'b1111) begin
              buffer <= {buffer[6:0], i_rx};
              counter <= counter + 1;
              t_counter <= 0;
            end else begin
              t_counter <= t_counter + 1;
            end
          end
          END_BIT: begin
            buffer <= buffer;
            start_counter <= start_counter + 1;
            t_counter <= 0;
          end
        endcase
      end
    end
  end

endmodule

