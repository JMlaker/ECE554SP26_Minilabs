`timescale 1ns/1ps

module Minilab1_tb();

    logic CLOCK_50;
    logic [9:0] SW;
    logic [3:0] KEY;
    logic [9:0] LEDR;
    reg	     [6:0]		HEX0;
	reg	     [6:0]		HEX1;
	reg	     [6:0]		HEX2;
	reg	     [6:0]		HEX3;
	reg	     [6:0]		HEX4;
	reg	     [6:0]		HEX5;

    Minilab1 iDUT(.*);

    initial begin
        CLOCK_50 = 0;
        KEY[0] = 0;
        KEY[1] = 1;
        SW = 0;
        KEY[2] = 1;

        @(negedge CLOCK_50);
        @(negedge CLOCK_50);

        KEY[0] = 1; 
        KEY[1] = 0;;

        @(posedge CLOCK_50);
        KEY[1] = 1;

        @(posedge iDUT.done_top);
        @(posedge CLOCK_50);
        @(posedge CLOCK_50);

        $stop();

    end

    always
        #5 CLOCK_50 = ~CLOCK_50;

endmodule