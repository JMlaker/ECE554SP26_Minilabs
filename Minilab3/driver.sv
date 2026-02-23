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
    input clk,
    input rst,
    input [1:0] br_cfg,
    output iocs,
    output iorw,
    input rda,
    input tbr,
    output logic [1:0] ioaddr,
    inout [7:0] databus
    );

typedef enum reg [2:0] {DIV_BUF_HIGH, DIV_BUF_LOW, POLL_TX_RX, RX_WAIT, RX, RX_END, TX_WAIT, TX, TX_END} state_t;

state_t state, nxt_state;

wire [15:0] baud_rate;

logic stash_databus;

logic [7:0] save_databus;

assert iocs = 1'b1; // assumed held high

generate
    case (br_cfg)
        2'b00: assign baud_rate = 16'd4800;
        2'b01: assign baud_rate = 16'd9600;
        2'b10: assign baud_rate = 16'd19200;
        2'b11: assign baud_rate = 16'd38400;
    endcase
endgenerate

always_ff @(posedge clk, posedge rst) begin
    if (rst)
        state <= DIV_BUF_HIGH;
    else
        state <= nxt_state;
end

always_comb begin
    nxt_state = state;
    databus = 'bz;
    ioaddr = 2'b11;
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
            
            if (rda) begin
                nxt_state = RX;
                stash_databus = 1'b1;
                ioaddr = 2'b00;
            end
        end

        // Read the data from the slave
        RX: begin
            ioaddr = 2'b00;
            iorw = 1'b1;

            stash_databus = 1'b0;

            if (tbr) begin
                ioaddr = 2'b00;
                iorw = 1'b0;
                databus = stash_databus;
                nxt_state = TX
            end
        end

        // Write the data to the slave
        TX: begin
            ioaddr = 2'b00;
            iorw = 1'b0;

            databus = stash_databus;

            if (tbr) nxt_state = POLL_TX_RX;
        end
    endcase
end

always_ff @(posedge clk, posedge rst) begin
    if (rst)
        save_databus = 'b0;
    else if (stash_databus = 1'b1)
        save_databus = databus;
    else
        save_databus = save_databus;
end


endmodule
