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

wire TBR;
wire RDA;

// Processor <-> SPART interface
assign databus = (~iocs | ~iorw) ? 'bz : // If chipselect asserted or processor is writing to the SPART
					ioaddr == `REGSELECT_TXRXBUF ?
						'bx : // Unused
					ioaddr == `REGSELECT_STAT ?
						{6'b0, TBR, RDA} :
					ioaddr == `REGSELECT_DBL ? 
						'bx : // Unused
					'bx; // Unused



endmodule
