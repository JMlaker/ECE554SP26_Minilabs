module transmit (
    input wire clk,
    input wire [7:0] i_data,
    input wire rst,
    input wire b_en,
    input wire i_iocs,
    output logic o_tx,
    input wire i_iorw,
    output wire o_tbr
);
  localparam IDLE = 2'b00;
  localparam START_BIT = 2'b01;
  localparam TRANSMIT = 2'b10;
  localparam END_BIT = 2'b11;
  logic [1:0] curr_state, next_state;
  //counter to keep track of 8 bits to be transmitted
  logic [3:0] counter;

  //counter that counts to the "middle" of the 
  //start bit (high to low transition)
  logic [3:0] start_counter;

  //holds each bit for 16 cycles(?) (oversampling of 16)
  logic [3:0] t_counter;
  reg   [7:0] buffer;

  //recall that the tx transmission occurs as the following
  //1) see if the bus is transfering something to the recieve unit; i.e,
  //i_iorw==1 and i_iocs=1. if so, move it into the buffer. 
  //once in the buffer, begin the transmission sequence of...
  //i) se o_tx from 1->0 for 1 baud cycle (or 16 pulses, because its being
  //oversampled by a rate of 16?)
  //ii) serially shift out the values in the buffer (holding each for 16 baud
  //pulses?)
  //iii) once all 8 have been transfered out, hold it high for 16 baud pulses
  //to indicate the end of a transmission cycle

  always @(posedge clk) begin
    if (!rst) curr_state <= 2'b00;
    else curr_state <= next_state;
  end

  always_comb begin
    next_state = IDLE;
    case (curr_state)
      //if i_iocs and i_iorw are enabled, then transition into the START_BIT
      //state?
      IDLE: begin
        if (i_iocs && i_iorw) next_state = START_BIT;
        else next_state = IDLE;
      end
      START_BIT: begin
        //if 16 baud pulses have passed, start transmiting actual data?
        if (start_counter == 4'b1111) next_state = TRANSMIT;
        else next_state = START_BIT;
      end
      TRANSMIT: begin
        if (counter != 4'd8) next_state = TRANSMIT;
        else next_state = END_BIT;
      end
      END_BIT: begin
        if (start_counter == 4'b1111) next_state = IDLE;
        else next_state = END_BIT;
      end
    endcase
  end

  //transmit module should be ready/available to recieve data any time its in
  //the IDLE state?
  reg tbr;
  assign o_tbr = tbr;

  //o_tbr logic
  always @(posedge clk) begin
    if (!rst) tbr <= 1'b0;
    else begin
      //only update the tbr during baud pulses...?
      if (b_en) begin
        if (curr_state == IDLE) tbr <= 1'b1;
        else tbr <= 1'b0;
      end
    end
  end

  always @(posedge clk) begin
    if (!rst) begin
      counter <= 4'b0;
      start_counter <= 4'b0;
      t_counter <= 4'b0;
      buffer <= 4'b0;
    end else begin
      if (b_en) begin
        case (curr_state)
          IDLE: begin
            counter <= 4'b0;
            start_counter <= 4'b0;
            t_counter <= 4'b0;
            //if current state is IDLE, the chip is selected, and the transmit
            //module is selected, assume we're going to load something in?
            if (i_iocs && i_iorw) begin
              buffer <= i_data;
            end else begin
              buffer <= 4'b0;
            end
          end
          //transmit a 16 buad-pulse long 0 bit?
          START_BIT: begin
            counter <= 4'b0;
            start_counter <= start_counter + 1;
            t_counter <= 4'b0;
            buffer <= 4'b0;
          end
          TRANSMIT: begin
            start_counter <= 4'b0;
            if (t_counter == 4'b1111) begin
              counter   <= counter + 1;
              t_counter <= 4'b0;
            end else begin
              t_counter <= t_counter + 1;
            end
          end
          END_BIT: begin
            start_counter <= start_counter + 1;
            t_counter <= 4'b0;
          end
        endcase
      end
    end
  end

  //o_tx logic
  always_comb begin
    case (curr_state)
      IDLE: begin
        o_tx = 1'b1;
      end
      START_BIT: begin
        o_tx = 1'b0;
      end
      TRANSMIT: begin
        o_tx = buffer[counter];
      end
      END_BIT: begin
        o_tx = 1'b1;
      end
    endcase
  end
endmodule
