module matrix_mult_tb();

    logic clk;
    logic rst_n;
    logic clr;
    logic start;
    logic [7:0] a_data [0:7][0:7];
    logic [7:0] b_data [0:7];
    logic [23:0] c_out [0:7];
    logic done;

    matrix_mult iDUT (.*); 

    initial begin
        clk = 0;
        rst_n = 0;
        start = 0;
        clr = 0;
        a_data =  '{'{8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h06, 8'h07, 8'h08}, 
                    '{8'h11, 8'h12, 8'h13, 8'h14, 8'h15, 8'h16, 8'h17, 8'h18},
                    '{8'h02, 8'h02, 8'h02, 8'h02, 8'h02, 8'h02, 8'h02, 8'h02},
                    '{8'h03, 8'h03, 8'h03, 8'h03, 8'h03, 8'h03, 8'h03, 8'h03},
                    '{8'h04, 8'h04, 8'h04, 8'h04, 8'h04, 8'h04, 8'h04, 8'h04},
                    '{8'h05, 8'h05, 8'h05, 8'h05, 8'h05, 8'h05, 8'h05, 8'h05},
                    '{8'h06, 8'h06, 8'h06, 8'h06, 8'h06, 8'h06, 8'h06, 8'h06},
                    '{8'h07, 8'h07, 8'h07, 8'h07, 8'h07, 8'h07, 8'h07, 8'h07}
                   };

        b_data = '{8'h01, 8'h01, 8'h01, 8'h01, 8'h01, 8'h01, 8'h01, 8'h01};


        @(negedge clk);
        @(negedge clk);

        rst_n = 1; 
        start = 1;

        @(posedge clk);

        start = 0;

        @(posedge done);
        @(posedge clk);
        @(posedge clk);

        $stop();
    end

    always
        #5 clk = ~clk;

endmodule