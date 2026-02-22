//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:   
// Design Name: 
// Module Name:    spart 
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
module spart(
    input clk,
    input rst,
    input iocs,
    input iorw,
    output rda,
    output tbr,
    input [1:0] ioaddr,
    inout [7:0] databus,
    output txd,
    input rxd
    );

`define REGSELECT_TXRXBUF 2'b00
`define REGSELECT_STAT 2'b01
`define REGSELECT_DBL 2'b10
`define REGSELECT_DBH 2'b11

wire b_en;

wire[7:0] dbt;
assign dbt = databus;
wire[7:0] dbr;

transmit TX(
    .clk,
    .i_data(dbt),
    .rst,
    .b_en,
    .i_iocs(iocs),
    .o_tx(txd),
    .i_iorw(~iorw && (ioaddr == 2'b00)),
    .o_tbr(tbr)
);

recieve RX(
    .clk,
    .b_en,
    .rst,
    .i_iocs(iocs),
    .i_rx(rxd),
    .i_iorw(iorw && (ioaddr == 2'b00)),
    .o_rda(rda),
    .o_data(dbr)
);

brg baud_gen(
    .clk,
    .rst,
    .i_ioaddr_brg(ioaddr),
    i_brg_bus(databus),
    en(b_en)
);

// Processor <-> SPART interface
// assign databus = (~iocs | ~iorw) ? 'bz : // If chipselect asserted or processor is writing to the SPART
// 					ioaddr == `REGSELECT_TXRXBUF ?
// 						'bx : // Unused
// 					ioaddr == `REGSELECT_STAT ?
// 						{6'b0, tbr, rda} :
// 					ioaddr == `REGSELECT_DBL ? 
// 						'bx : // Unused
// 					'bx; // Unused


assign databus = (~iocs) ? 'bz :
        (ioaddr == `REGSELECT_STAT  && iorw) ?
            {6'b0, tbr, rda} :
        (ioaddr == `REGSELECT_TXRXBUF && iorw) ?
            dbr : 'bz;



endmodule
