//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    
// Design Name: 
// Module Name:    driver 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module driver(
    input wire clk,
    input wire rst,
    input wire [1:0] br_cfg,
    output logic iocs,
    output logic iorw,
    input wire rda,
    input wire tbr,
    output logic [1:0] ioaddr,
    inout logic [7:0] databus
    );

typedef enum reg [3:0] {DIV_BUF_HIGH, DIV_BUF_LOW, POLL_TX_RX, RX_WAIT, RX, RX_END, TX_WAIT, TX, TX_END, TMP_DONE} state_t;

state_t state, nxt_state;

logic [15:0] baud_rate;

logic stash_databus;

logic [7:0] save_databus;

assign iocs = 1'b1; // assumed held high
/*
generate
    case (br_cfg)
        2'b00: assign baud_rate = 16'd4800;
        2'b01: assign baud_rate = 16'd9600;
        2'b10: assign baud_rate = 16'd19200;
        2'b11: assign baud_rate = 16'd38400;
    endcase
endgenerate
*/

always_comb begin
case(br_cfg)
 2'b00:  baud_rate = 16'd651;
  2'b01:  baud_rate = 16'd326;
        2'b10:  baud_rate = 16'd163;
        2'b11:  baud_rate = 16'd81;endcase
end

always_ff @(posedge clk, posedge rst) begin
    if (rst)
        state <= DIV_BUF_HIGH;
    else
        state <= nxt_state;
end

always_comb begin
    nxt_state = state;
    databus = 'bz;
    ioaddr = 2'b01;
    iorw = 1'b1;    // 1 = read, 0 = write
    stash_databus = 1'b0;

    case (state)
        // Send high byte of division buffer
        DIV_BUF_HIGH: begin
            ioaddr = 2'b11;
            databus = baud_rate[15:8];
            nxt_state = DIV_BUF_LOW;
        end

        // Send low byte of division buffer
        DIV_BUF_LOW: begin
            ioaddr = 2'b10;
            databus = baud_rate[7:0];
            nxt_state = POLL_TX_RX;
        end

        // Poll for TX RX status
        POLL_TX_RX: begin
            ioaddr = 2'b01;
            iorw = 1'b1;
				
				stash_databus = 1'b1;
				
            if (rda) begin
                nxt_state = RX;
                stash_databus = 1'b1;
                ioaddr = 2'b00;
            end
				if (databus[7:4] == 4'h6) begin
					nxt_state = TMP_DONE;
				end
        end

        // Read the data from the slave
        RX: begin
            ioaddr = 2'b00;
            iorw = 1'b1;

            stash_databus = 1'b0;

            if (tbr) begin
                ioaddr = 2'b00;
                iorw = 1'b1;
                nxt_state = TX;
            end
				
        end

        // Write the data to the slave
        TX: begin
            ioaddr = 2'b00;
            iorw = 1'b0;

            databus = save_databus;//8'h66;

            if (tbr) nxt_state = TMP_DONE;
				//if (databus[7:4] == 4'h6) begin
				//	nxt_state = TMP_DONE;
				//end
        end
		TMP_DONE: begin
			if(~rda) nxt_state = POLL_TX_RX;
		end
		default: begin
			ioaddr = 2'b11;
			iorw = 'b0;
		end
    endcase
end

always_ff @(posedge clk, posedge rst) begin
    if (rst)
        save_databus = 8'h55;
    else if (stash_databus == 1'b1)
        save_databus = databus;
    else
        save_databus = save_databus;
end


endmodule
