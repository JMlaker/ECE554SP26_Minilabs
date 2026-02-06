module Minilab1(
    input CLOCK_50,

    //////////// SEG7 //////////
	output	reg	     [6:0]		HEX0,
	output	reg	     [6:0]		HEX1,
	output	reg	     [6:0]		HEX2,
	output	reg	     [6:0]		HEX3,
	output	reg	     [6:0]		HEX4,
	output	reg	     [6:0]		HEX5,
	
	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// SW //////////
	input 		     [9:0]		SW
);

    parameter HEX_0 = 7'b1000000;		// zero
    parameter HEX_1 = 7'b1111001;		// one
    parameter HEX_2 = 7'b0100100;		// two
    parameter HEX_3 = 7'b0110000;		// three
    parameter HEX_4 = 7'b0011001;		// four
    parameter HEX_5 = 7'b0010010;		// five
    parameter HEX_6 = 7'b0000010;		// six
    parameter HEX_7 = 7'b1111000;		// seven
    parameter HEX_8 = 7'b0000000;		// eight
    parameter HEX_9 = 7'b0011000;		// nine
    parameter HEX_10 = 7'b0001000;	// ten
    parameter HEX_11 = 7'b0000011;	// eleven
    parameter HEX_12 = 7'b1000110;	// twelve
    parameter HEX_13 = 7'b0100001;	// thirteen
    parameter HEX_14 = 7'b0000110;	// fourteen
    parameter HEX_15 = 7'b0001110;	// fifteen
    parameter OFF   = 7'b1111111;		// all off

    logic clk, rst_n, start_top, clr;

    logic [23:0] c_out [0:7];
    logic done_top;

    // Matric_mult signals
    logic [7:0] a_data [0:7][0:7];
    logic [7:0] b_data [0:7];
    logic start, done;

    // Memory signals
    logic [31:0] address;      // 32-bit address for 8 rows
    logic read;                // Read request
    logic [63:0] readdata;     // 64-bit read data (one row)
    logic readdatavalid;       // Data valid signal
	logic waitrequest;         // Busy signal to indicate logic is processing
    logic [1:0] mem_state;

    logic [3:0] read_cnt;

    matrix_mult iMULT (
        .clk(clk), 
        .rst_n(rst_n),
        .clr(clr),
        .start(start),
        .a_data(a_data),
        .b_data(b_data), 
        .c_out(c_out),
        .done(done)
    );

    mem_wrapper iMEM (
        .clk(clk),
        .reset_n(rst_n),
        .address(address),      
        .read(read),               
        .readdata(readdata),    
        .readdatavalid(readdatavalid),      
        .waitrequest(waitrequest),
        .state(mem_state)     
    );

    typedef enum logic [1:0] {IDLE, READ_MEM, EXEC, DONE} state_t;

    state_t state, nxt_state;

    assign LEDR = {{8{1'b0}}, state};
    assign rst_n = KEY[0];
    assign start_top = ~KEY[1];
    assign clr = ~KEY[2];
    assign clk = CLOCK_50;

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end

        else begin
            state <= nxt_state;
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            read_cnt <= 4'b0000;
        end

        else begin
            if (state != READ_MEM)
                read_cnt <= 4'b0000;
            else if (readdatavalid) 
                read_cnt <= read_cnt + 4'b0001;
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            address <= 0;
        end

        else begin
            if (state != READ_MEM)
                address <= 0;
            else if (mem_state == 2'b10) 
                address <= address + 1;
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            b_data[0] <= 8'h00;
            b_data[1] <= 8'h00;
            b_data[2] <= 8'h00;
            b_data[3] <= 8'h00;
            b_data[4] <= 8'h00;
            b_data[5] <= 8'h00;
            b_data[6] <= 8'h00;
            b_data[7] <= 8'h00;
        end

        else begin
            if (readdatavalid && (read_cnt == 4'b1000)) begin
                b_data[0] <= readdata[63:56];
                b_data[1] <= readdata[55:48];
                b_data[2] <= readdata[47:40];
                b_data[3] <= readdata[39:32];
                b_data[4] <= readdata[31:24];
                b_data[5] <= readdata[23:16];
                b_data[6] <= readdata[15:8];
                b_data[7] <= readdata[7:0];
            end
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            a_data[0][0] <= 8'h00;
            a_data[0][1] <= 8'h00;
            a_data[0][2] <= 8'h00;
            a_data[0][3] <= 8'h00;
            a_data[0][4] <= 8'h00;
            a_data[0][5] <= 8'h00;
            a_data[0][6] <= 8'h00;
            a_data[0][7] <= 8'h00;
        end

        else begin
            if (readdatavalid && (read_cnt == 4'b0000)) begin
                a_data[0][0] <= readdata[63:56];
                a_data[0][1] <= readdata[55:48];
                a_data[0][2] <= readdata[47:40];
                a_data[0][3] <= readdata[39:32];
                a_data[0][4] <= readdata[31:24];
                a_data[0][5] <= readdata[23:16];
                a_data[0][6] <= readdata[15:8];
                a_data[0][7] <= readdata[7:0];
            end
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            a_data[1][0] <= 8'h00;
            a_data[1][1] <= 8'h00;
            a_data[1][2] <= 8'h00;
            a_data[1][3] <= 8'h00;
            a_data[1][4] <= 8'h00;
            a_data[1][5] <= 8'h00;
            a_data[1][6] <= 8'h00;
            a_data[1][7] <= 8'h00;
        end

        else begin
            if (readdatavalid && (read_cnt == 4'b0001)) begin
                a_data[1][0] <= readdata[63:56];
                a_data[1][1] <= readdata[55:48];
                a_data[1][2] <= readdata[47:40];
                a_data[1][3] <= readdata[39:32];
                a_data[1][4] <= readdata[31:24];
                a_data[1][5] <= readdata[23:16];
                a_data[1][6] <= readdata[15:8];
                a_data[1][7] <= readdata[7:0];
            end
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            a_data[2][0] <= 8'h00;
            a_data[2][1] <= 8'h00;
            a_data[2][2] <= 8'h00;
            a_data[2][3] <= 8'h00;
            a_data[2][4] <= 8'h00;
            a_data[2][5] <= 8'h00;
            a_data[2][6] <= 8'h00;
            a_data[2][7] <= 8'h00;
        end

        else begin
            if (readdatavalid && (read_cnt == 4'b0010)) begin
                a_data[2][0] <= readdata[63:56];
                a_data[2][1] <= readdata[55:48];
                a_data[2][2] <= readdata[47:40];
                a_data[2][3] <= readdata[39:32];
                a_data[2][4] <= readdata[31:24];
                a_data[2][5] <= readdata[23:16];
                a_data[2][6] <= readdata[15:8];
                a_data[2][7] <= readdata[7:0];
            end
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            a_data[3][0] <= 8'h00;
            a_data[3][1] <= 8'h00;
            a_data[3][2] <= 8'h00;
            a_data[3][3] <= 8'h00;
            a_data[3][4] <= 8'h00;
            a_data[3][5] <= 8'h00;
            a_data[3][6] <= 8'h00;
            a_data[3][7] <= 8'h00;
        end

        else begin
            if (readdatavalid && (read_cnt == 4'b0011)) begin
                a_data[3][0] <= readdata[63:56];
                a_data[3][1] <= readdata[55:48];
                a_data[3][2] <= readdata[47:40];
                a_data[3][3] <= readdata[39:32];
                a_data[3][4] <= readdata[31:24];
                a_data[3][5] <= readdata[23:16];
                a_data[3][6] <= readdata[15:8];
                a_data[3][7] <= readdata[7:0];
            end
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            a_data[4][0] <= 8'h00;
            a_data[4][1] <= 8'h00;
            a_data[4][2] <= 8'h00;
            a_data[4][3] <= 8'h00;
            a_data[4][4] <= 8'h00;
            a_data[4][5] <= 8'h00;
            a_data[4][6] <= 8'h00;
            a_data[4][7] <= 8'h00;
        end

        else begin
            if (readdatavalid && (read_cnt == 4'b0100)) begin
                a_data[4][0] <= readdata[63:56];
                a_data[4][1] <= readdata[55:48];
                a_data[4][2] <= readdata[47:40];
                a_data[4][3] <= readdata[39:32];
                a_data[4][4] <= readdata[31:24];
                a_data[4][5] <= readdata[23:16];
                a_data[4][6] <= readdata[15:8];
                a_data[4][7] <= readdata[7:0];
            end
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            a_data[5][0] <= 8'h00;
            a_data[5][1] <= 8'h00;
            a_data[5][2] <= 8'h00;
            a_data[5][3] <= 8'h00;
            a_data[5][4] <= 8'h00;
            a_data[5][5] <= 8'h00;
            a_data[5][6] <= 8'h00;
            a_data[5][7] <= 8'h00;
        end

        else begin
            if (readdatavalid && (read_cnt == 4'b0101)) begin
                a_data[5][0] <= readdata[63:56];
                a_data[5][1] <= readdata[55:48];
                a_data[5][2] <= readdata[47:40];
                a_data[5][3] <= readdata[39:32];
                a_data[5][4] <= readdata[31:24];
                a_data[5][5] <= readdata[23:16];
                a_data[5][6] <= readdata[15:8];
                a_data[5][7] <= readdata[7:0];
            end
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            a_data[6][0] <= 8'h00;
            a_data[6][1] <= 8'h00;
            a_data[6][2] <= 8'h00;
            a_data[6][3] <= 8'h00;
            a_data[6][4] <= 8'h00;
            a_data[6][5] <= 8'h00;
            a_data[6][6] <= 8'h00;
            a_data[6][7] <= 8'h00;
        end

        else begin
            if (readdatavalid && (read_cnt == 4'b0110)) begin
                a_data[6][0] <= readdata[63:56];
                a_data[6][1] <= readdata[55:48];
                a_data[6][2] <= readdata[47:40];
                a_data[6][3] <= readdata[39:32];
                a_data[6][4] <= readdata[31:24];
                a_data[6][5] <= readdata[23:16];
                a_data[6][6] <= readdata[15:8];
                a_data[6][7] <= readdata[7:0];
            end
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            a_data[7][0] <= 8'h00;
            a_data[7][1] <= 8'h00;
            a_data[7][2] <= 8'h00;
            a_data[7][3] <= 8'h00;
            a_data[7][4] <= 8'h00;
            a_data[7][5] <= 8'h00;
            a_data[7][6] <= 8'h00;
            a_data[7][7] <= 8'h00;
        end

        else begin
            if (readdatavalid && (read_cnt == 4'b0111)) begin
                a_data[7][0] <= readdata[63:56];
                a_data[7][1] <= readdata[55:48];
                a_data[7][2] <= readdata[47:40];
                a_data[7][3] <= readdata[39:32];
                a_data[7][4] <= readdata[31:24];
                a_data[7][5] <= readdata[23:16];
                a_data[7][6] <= readdata[15:8];
                a_data[7][7] <= readdata[7:0];
            end
        end
    end

    always_comb begin
        start = 1'b0;
        read = 1'b0;
        done_top = 1'b0;
        nxt_state = state;

        case(state) 
            IDLE: begin
                if (start_top) begin
                    nxt_state = READ_MEM;
                    read = 1'b1;
                end
            end 
            READ_MEM: begin
                read = 1'b1;

                if (read_cnt == 4'b1000) begin
                    read = 1'b0;
                end
                if (read_cnt == 4'b1001) begin
                    read = 1'b0;
                    nxt_state = EXEC;
                end
            end
            EXEC: begin
                start = 1'b1;

                if(done) begin
                    start = 1'b0;
                    nxt_state = DONE;
                end
            end
            DONE: begin
                done_top = 1'b1;

                if (start_top) begin
                    nxt_state = READ_MEM;
                    read = 1'b1;
                end
            end
        endcase
    end

    // HEX0 Logic
    always @(*) begin
        if (state == DONE & SW[0]) begin
            case(c_out[0][3:0])
            4'd0: HEX0 = HEX_0;
            4'd1: HEX0 = HEX_1;
            4'd2: HEX0 = HEX_2;
            4'd3: HEX0 = HEX_3;
            4'd4: HEX0 = HEX_4;
            4'd5: HEX0 = HEX_5;
            4'd6: HEX0 = HEX_6;
            4'd7: HEX0 = HEX_7;
            4'd8: HEX0 = HEX_8;
            4'd9: HEX0 = HEX_9;
            4'd10: HEX0 = HEX_10;
            4'd11: HEX0 = HEX_11;
            4'd12: HEX0 = HEX_12;
            4'd13: HEX0 = HEX_13;
            4'd14: HEX0 = HEX_14;
            4'd15: HEX0 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[1]) begin
            case(c_out[1][3:0])
            4'd0: HEX0 = HEX_0;
            4'd1: HEX0 = HEX_1;
            4'd2: HEX0 = HEX_2;
            4'd3: HEX0 = HEX_3;
            4'd4: HEX0 = HEX_4;
            4'd5: HEX0 = HEX_5;
            4'd6: HEX0 = HEX_6;
            4'd7: HEX0 = HEX_7;
            4'd8: HEX0 = HEX_8;
            4'd9: HEX0 = HEX_9;
            4'd10: HEX0 = HEX_10;
            4'd11: HEX0 = HEX_11;
            4'd12: HEX0 = HEX_12;
            4'd13: HEX0 = HEX_13;
            4'd14: HEX0 = HEX_14;
            4'd15: HEX0 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[2]) begin
            case(c_out[2][3:0])
            4'd0: HEX0 = HEX_0;
            4'd1: HEX0 = HEX_1;
            4'd2: HEX0 = HEX_2;
            4'd3: HEX0 = HEX_3;
            4'd4: HEX0 = HEX_4;
            4'd5: HEX0 = HEX_5;
            4'd6: HEX0 = HEX_6;
            4'd7: HEX0 = HEX_7;
            4'd8: HEX0 = HEX_8;
            4'd9: HEX0 = HEX_9;
            4'd10: HEX0 = HEX_10;
            4'd11: HEX0 = HEX_11;
            4'd12: HEX0 = HEX_12;
            4'd13: HEX0 = HEX_13;
            4'd14: HEX0 = HEX_14;
            4'd15: HEX0 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[3]) begin
            case(c_out[3][3:0])
            4'd0: HEX0 = HEX_0;
            4'd1: HEX0 = HEX_1;
            4'd2: HEX0 = HEX_2;
            4'd3: HEX0 = HEX_3;
            4'd4: HEX0 = HEX_4;
            4'd5: HEX0 = HEX_5;
            4'd6: HEX0 = HEX_6;
            4'd7: HEX0 = HEX_7;
            4'd8: HEX0 = HEX_8;
            4'd9: HEX0 = HEX_9;
            4'd10: HEX0 = HEX_10;
            4'd11: HEX0 = HEX_11;
            4'd12: HEX0 = HEX_12;
            4'd13: HEX0 = HEX_13;
            4'd14: HEX0 = HEX_14;
            4'd15: HEX0 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[4]) begin
            case(c_out[4][3:0])
            4'd0: HEX0 = HEX_0;
            4'd1: HEX0 = HEX_1;
            4'd2: HEX0 = HEX_2;
            4'd3: HEX0 = HEX_3;
            4'd4: HEX0 = HEX_4;
            4'd5: HEX0 = HEX_5;
            4'd6: HEX0 = HEX_6;
            4'd7: HEX0 = HEX_7;
            4'd8: HEX0 = HEX_8;
            4'd9: HEX0 = HEX_9;
            4'd10: HEX0 = HEX_10;
            4'd11: HEX0 = HEX_11;
            4'd12: HEX0 = HEX_12;
            4'd13: HEX0 = HEX_13;
            4'd14: HEX0 = HEX_14;
            4'd15: HEX0 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[5]) begin
            case(c_out[5][3:0])
            4'd0: HEX0 = HEX_0;
            4'd1: HEX0 = HEX_1;
            4'd2: HEX0 = HEX_2;
            4'd3: HEX0 = HEX_3;
            4'd4: HEX0 = HEX_4;
            4'd5: HEX0 = HEX_5;
            4'd6: HEX0 = HEX_6;
            4'd7: HEX0 = HEX_7;
            4'd8: HEX0 = HEX_8;
            4'd9: HEX0 = HEX_9;
            4'd10: HEX0 = HEX_10;
            4'd11: HEX0 = HEX_11;
            4'd12: HEX0 = HEX_12;
            4'd13: HEX0 = HEX_13;
            4'd14: HEX0 = HEX_14;
            4'd15: HEX0 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[6]) begin
            case(c_out[6][3:0])
            4'd0: HEX0 = HEX_0;
            4'd1: HEX0 = HEX_1;
            4'd2: HEX0 = HEX_2;
            4'd3: HEX0 = HEX_3;
            4'd4: HEX0 = HEX_4;
            4'd5: HEX0 = HEX_5;
            4'd6: HEX0 = HEX_6;
            4'd7: HEX0 = HEX_7;
            4'd8: HEX0 = HEX_8;
            4'd9: HEX0 = HEX_9;
            4'd10: HEX0 = HEX_10;
            4'd11: HEX0 = HEX_11;
            4'd12: HEX0 = HEX_12;
            4'd13: HEX0 = HEX_13;
            4'd14: HEX0 = HEX_14;
            4'd15: HEX0 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[7]) begin
            case(c_out[7][3:0])
            4'd0: HEX0 = HEX_0;
            4'd1: HEX0 = HEX_1;
            4'd2: HEX0 = HEX_2;
            4'd3: HEX0 = HEX_3;
            4'd4: HEX0 = HEX_4;
            4'd5: HEX0 = HEX_5;
            4'd6: HEX0 = HEX_6;
            4'd7: HEX0 = HEX_7;
            4'd8: HEX0 = HEX_8;
            4'd9: HEX0 = HEX_9;
            4'd10: HEX0 = HEX_10;
            4'd11: HEX0 = HEX_11;
            4'd12: HEX0 = HEX_12;
            4'd13: HEX0 = HEX_13;
            4'd14: HEX0 = HEX_14;
            4'd15: HEX0 = HEX_15;
            endcase
        end
        else begin
            HEX0 = OFF;
        end
    end


    // HEX1 Logic
    always @(*) begin
        if (state == DONE & SW[0]) begin
            case(c_out[0][7:4])
            4'd0: HEX1 = HEX_0;
            4'd1: HEX1 = HEX_1;
            4'd2: HEX1 = HEX_2;
            4'd3: HEX1 = HEX_3;
            4'd4: HEX1 = HEX_4;
            4'd5: HEX1 = HEX_5;
            4'd6: HEX1 = HEX_6;
            4'd7: HEX1 = HEX_7;
            4'd8: HEX1 = HEX_8;
            4'd9: HEX1 = HEX_9;
            4'd10: HEX1 = HEX_10;
            4'd11: HEX1 = HEX_11;
            4'd12: HEX1 = HEX_12;
            4'd13: HEX1 = HEX_13;
            4'd14: HEX1 = HEX_14;
            4'd15: HEX1 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[1]) begin
            case(c_out[1][7:4])
            4'd0: HEX1 = HEX_0;
            4'd1: HEX1 = HEX_1;
            4'd2: HEX1 = HEX_2;
            4'd3: HEX1 = HEX_3;
            4'd4: HEX1 = HEX_4;
            4'd5: HEX1 = HEX_5;
            4'd6: HEX1 = HEX_6;
            4'd7: HEX1 = HEX_7;
            4'd8: HEX1 = HEX_8;
            4'd9: HEX1 = HEX_9;
            4'd10: HEX1 = HEX_10;
            4'd11: HEX1 = HEX_11;
            4'd12: HEX1 = HEX_12;
            4'd13: HEX1 = HEX_13;
            4'd14: HEX1 = HEX_14;
            4'd15: HEX1 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[2]) begin
            case(c_out[2][7:4])
            4'd0: HEX1 = HEX_0;
            4'd1: HEX1 = HEX_1;
            4'd2: HEX1 = HEX_2;
            4'd3: HEX1 = HEX_3;
            4'd4: HEX1 = HEX_4;
            4'd5: HEX1 = HEX_5;
            4'd6: HEX1 = HEX_6;
            4'd7: HEX1 = HEX_7;
            4'd8: HEX1 = HEX_8;
            4'd9: HEX1 = HEX_9;
            4'd10: HEX1 = HEX_10;
            4'd11: HEX1 = HEX_11;
            4'd12: HEX1 = HEX_12;
            4'd13: HEX1 = HEX_13;
            4'd14: HEX1 = HEX_14;
            4'd15: HEX1 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[3]) begin
            case(c_out[3][7:4])
            4'd0: HEX1 = HEX_0;
            4'd1: HEX1 = HEX_1;
            4'd2: HEX1 = HEX_2;
            4'd3: HEX1 = HEX_3;
            4'd4: HEX1 = HEX_4;
            4'd5: HEX1 = HEX_5;
            4'd6: HEX1 = HEX_6;
            4'd7: HEX1 = HEX_7;
            4'd8: HEX1 = HEX_8;
            4'd9: HEX1 = HEX_9;
            4'd10: HEX1 = HEX_10;
            4'd11: HEX1 = HEX_11;
            4'd12: HEX1 = HEX_12;
            4'd13: HEX1 = HEX_13;
            4'd14: HEX1 = HEX_14;
            4'd15: HEX1 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[4]) begin
            case(c_out[4][7:4])
            4'd0: HEX1 = HEX_0;
            4'd1: HEX1 = HEX_1;
            4'd2: HEX1 = HEX_2;
            4'd3: HEX1 = HEX_3;
            4'd4: HEX1 = HEX_4;
            4'd5: HEX1 = HEX_5;
            4'd6: HEX1 = HEX_6;
            4'd7: HEX1 = HEX_7;
            4'd8: HEX1 = HEX_8;
            4'd9: HEX1 = HEX_9;
            4'd10: HEX1 = HEX_10;
            4'd11: HEX1 = HEX_11;
            4'd12: HEX1 = HEX_12;
            4'd13: HEX1 = HEX_13;
            4'd14: HEX1 = HEX_14;
            4'd15: HEX1 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[5]) begin
            case(c_out[5][7:4])
            4'd0: HEX1 = HEX_0;
            4'd1: HEX1 = HEX_1;
            4'd2: HEX1 = HEX_2;
            4'd3: HEX1 = HEX_3;
            4'd4: HEX1 = HEX_4;
            4'd5: HEX1 = HEX_5;
            4'd6: HEX1 = HEX_6;
            4'd7: HEX1 = HEX_7;
            4'd8: HEX1 = HEX_8;
            4'd9: HEX1 = HEX_9;
            4'd10: HEX1 = HEX_10;
            4'd11: HEX1 = HEX_11;
            4'd12: HEX1 = HEX_12;
            4'd13: HEX1 = HEX_13;
            4'd14: HEX1 = HEX_14;
            4'd15: HEX1 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[6]) begin
            case(c_out[6][7:4])
            4'd0: HEX1 = HEX_0;
            4'd1: HEX1 = HEX_1;
            4'd2: HEX1 = HEX_2;
            4'd3: HEX1 = HEX_3;
            4'd4: HEX1 = HEX_4;
            4'd5: HEX1 = HEX_5;
            4'd6: HEX1 = HEX_6;
            4'd7: HEX1 = HEX_7;
            4'd8: HEX1 = HEX_8;
            4'd9: HEX1 = HEX_9;
            4'd10: HEX1 = HEX_10;
            4'd11: HEX1 = HEX_11;
            4'd12: HEX1 = HEX_12;
            4'd13: HEX1 = HEX_13;
            4'd14: HEX1 = HEX_14;
            4'd15: HEX1 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[7]) begin
            case(c_out[7][7:4])
            4'd0: HEX1 = HEX_0;
            4'd1: HEX1 = HEX_1;
            4'd2: HEX1 = HEX_2;
            4'd3: HEX1 = HEX_3;
            4'd4: HEX1 = HEX_4;
            4'd5: HEX1 = HEX_5;
            4'd6: HEX1 = HEX_6;
            4'd7: HEX1 = HEX_7;
            4'd8: HEX1 = HEX_8;
            4'd9: HEX1 = HEX_9;
            4'd10: HEX1 = HEX_10;
            4'd11: HEX1 = HEX_11;
            4'd12: HEX1 = HEX_12;
            4'd13: HEX1 = HEX_13;
            4'd14: HEX1 = HEX_14;
            4'd15: HEX1 = HEX_15;
            endcase
        end
        else begin
            HEX1 = OFF;
        end
    end


     // HEX2 Logic
    always @(*) begin
        if (state == DONE & SW[0]) begin
            case(c_out[0][11:8])
            4'd0: HEX2 = HEX_0;
            4'd1: HEX2 = HEX_1;
            4'd2: HEX2 = HEX_2;
            4'd3: HEX2 = HEX_3;
            4'd4: HEX2 = HEX_4;
            4'd5: HEX2 = HEX_5;
            4'd6: HEX2 = HEX_6;
            4'd7: HEX2 = HEX_7;
            4'd8: HEX2 = HEX_8;
            4'd9: HEX2 = HEX_9;
            4'd10: HEX2 = HEX_10;
            4'd11: HEX2 = HEX_11;
            4'd12: HEX2 = HEX_12;
            4'd13: HEX2 = HEX_13;
            4'd14: HEX2 = HEX_14;
            4'd15: HEX2 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[1]) begin
            case(c_out[1][11:8])
            4'd0: HEX2 = HEX_0;
            4'd1: HEX2 = HEX_1;
            4'd2: HEX2 = HEX_2;
            4'd3: HEX2 = HEX_3;
            4'd4: HEX2 = HEX_4;
            4'd5: HEX2 = HEX_5;
            4'd6: HEX2 = HEX_6;
            4'd7: HEX2 = HEX_7;
            4'd8: HEX2 = HEX_8;
            4'd9: HEX2 = HEX_9;
            4'd10: HEX2 = HEX_10;
            4'd11: HEX2 = HEX_11;
            4'd12: HEX2 = HEX_12;
            4'd13: HEX2 = HEX_13;
            4'd14: HEX2 = HEX_14;
            4'd15: HEX2 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[2]) begin
            case(c_out[2][11:8])
            4'd0: HEX2 = HEX_0;
            4'd1: HEX2 = HEX_1;
            4'd2: HEX2 = HEX_2;
            4'd3: HEX2 = HEX_3;
            4'd4: HEX2 = HEX_4;
            4'd5: HEX2 = HEX_5;
            4'd6: HEX2 = HEX_6;
            4'd7: HEX2 = HEX_7;
            4'd8: HEX2 = HEX_8;
            4'd9: HEX2 = HEX_9;
            4'd10: HEX2 = HEX_10;
            4'd11: HEX2 = HEX_11;
            4'd12: HEX2 = HEX_12;
            4'd13: HEX2 = HEX_13;
            4'd14: HEX2 = HEX_14;
            4'd15: HEX2 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[3]) begin
            case(c_out[3][11:8])
            4'd0: HEX2 = HEX_0;
            4'd1: HEX2 = HEX_1;
            4'd2: HEX2 = HEX_2;
            4'd3: HEX2 = HEX_3;
            4'd4: HEX2 = HEX_4;
            4'd5: HEX2 = HEX_5;
            4'd6: HEX2 = HEX_6;
            4'd7: HEX2 = HEX_7;
            4'd8: HEX2 = HEX_8;
            4'd9: HEX2 = HEX_9;
            4'd10: HEX2 = HEX_10;
            4'd11: HEX2 = HEX_11;
            4'd12: HEX2 = HEX_12;
            4'd13: HEX2 = HEX_13;
            4'd14: HEX2 = HEX_14;
            4'd15: HEX2 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[4]) begin
            case(c_out[4][11:8])
            4'd0: HEX2 = HEX_0;
            4'd1: HEX2 = HEX_1;
            4'd2: HEX2 = HEX_2;
            4'd3: HEX2 = HEX_3;
            4'd4: HEX2 = HEX_4;
            4'd5: HEX2 = HEX_5;
            4'd6: HEX2 = HEX_6;
            4'd7: HEX2 = HEX_7;
            4'd8: HEX2 = HEX_8;
            4'd9: HEX2 = HEX_9;
            4'd10: HEX2 = HEX_10;
            4'd11: HEX2 = HEX_11;
            4'd12: HEX2 = HEX_12;
            4'd13: HEX2 = HEX_13;
            4'd14: HEX2 = HEX_14;
            4'd15: HEX2 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[5]) begin
            case(c_out[5][11:8])
            4'd0: HEX2 = HEX_0;
            4'd1: HEX2 = HEX_1;
            4'd2: HEX2 = HEX_2;
            4'd3: HEX2 = HEX_3;
            4'd4: HEX2 = HEX_4;
            4'd5: HEX2 = HEX_5;
            4'd6: HEX2 = HEX_6;
            4'd7: HEX2 = HEX_7;
            4'd8: HEX2 = HEX_8;
            4'd9: HEX2 = HEX_9;
            4'd10: HEX2 = HEX_10;
            4'd11: HEX2 = HEX_11;
            4'd12: HEX2 = HEX_12;
            4'd13: HEX2 = HEX_13;
            4'd14: HEX2 = HEX_14;
            4'd15: HEX2 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[6]) begin
            case(c_out[6][11:8])
            4'd0: HEX2 = HEX_0;
            4'd1: HEX2 = HEX_1;
            4'd2: HEX2 = HEX_2;
            4'd3: HEX2 = HEX_3;
            4'd4: HEX2 = HEX_4;
            4'd5: HEX2 = HEX_5;
            4'd6: HEX2 = HEX_6;
            4'd7: HEX2 = HEX_7;
            4'd8: HEX2 = HEX_8;
            4'd9: HEX2 = HEX_9;
            4'd10: HEX2 = HEX_10;
            4'd11: HEX2 = HEX_11;
            4'd12: HEX2 = HEX_12;
            4'd13: HEX2 = HEX_13;
            4'd14: HEX2 = HEX_14;
            4'd15: HEX2 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[7]) begin
            case(c_out[7][11:8])
            4'd0: HEX2 = HEX_0;
            4'd1: HEX2 = HEX_1;
            4'd2: HEX2 = HEX_2;
            4'd3: HEX2 = HEX_3;
            4'd4: HEX2 = HEX_4;
            4'd5: HEX2 = HEX_5;
            4'd6: HEX2 = HEX_6;
            4'd7: HEX2 = HEX_7;
            4'd8: HEX2 = HEX_8;
            4'd9: HEX2 = HEX_9;
            4'd10: HEX2 = HEX_10;
            4'd11: HEX2 = HEX_11;
            4'd12: HEX2 = HEX_12;
            4'd13: HEX2 = HEX_13;
            4'd14: HEX2 = HEX_14;
            4'd15: HEX2 = HEX_15;
            endcase
        end
        else begin
            HEX2 = OFF;
        end
    end


     // HEX3 Logic
    always @(*) begin
        if (state == DONE & SW[0]) begin
            case(c_out[0][15:12])
            4'd0: HEX3 = HEX_0;
            4'd1: HEX3 = HEX_1;
            4'd2: HEX3 = HEX_2;
            4'd3: HEX3 = HEX_3;
            4'd4: HEX3 = HEX_4;
            4'd5: HEX3 = HEX_5;
            4'd6: HEX3 = HEX_6;
            4'd7: HEX3 = HEX_7;
            4'd8: HEX3 = HEX_8;
            4'd9: HEX3 = HEX_9;
            4'd10: HEX3 = HEX_10;
            4'd11: HEX3 = HEX_11;
            4'd12: HEX3 = HEX_12;
            4'd13: HEX3 = HEX_13;
            4'd14: HEX3 = HEX_14;
            4'd15: HEX3 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[1]) begin
            case(c_out[1][15:12])
            4'd0: HEX3 = HEX_0;
            4'd1: HEX3 = HEX_1;
            4'd2: HEX3 = HEX_2;
            4'd3: HEX3 = HEX_3;
            4'd4: HEX3 = HEX_4;
            4'd5: HEX3 = HEX_5;
            4'd6: HEX3 = HEX_6;
            4'd7: HEX3 = HEX_7;
            4'd8: HEX3 = HEX_8;
            4'd9: HEX3 = HEX_9;
            4'd10: HEX3 = HEX_10;
            4'd11: HEX3 = HEX_11;
            4'd12: HEX3 = HEX_12;
            4'd13: HEX3 = HEX_13;
            4'd14: HEX3 = HEX_14;
            4'd15: HEX3 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[2]) begin
            case(c_out[2][15:12])
            4'd0: HEX3 = HEX_0;
            4'd1: HEX3 = HEX_1;
            4'd2: HEX3 = HEX_2;
            4'd3: HEX3 = HEX_3;
            4'd4: HEX3 = HEX_4;
            4'd5: HEX3 = HEX_5;
            4'd6: HEX3 = HEX_6;
            4'd7: HEX3 = HEX_7;
            4'd8: HEX3 = HEX_8;
            4'd9: HEX3 = HEX_9;
            4'd10: HEX3 = HEX_10;
            4'd11: HEX3 = HEX_11;
            4'd12: HEX3 = HEX_12;
            4'd13: HEX3 = HEX_13;
            4'd14: HEX3 = HEX_14;
            4'd15: HEX3 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[3]) begin
            case(c_out[3][15:12])
            4'd0: HEX3 = HEX_0;
            4'd1: HEX3 = HEX_1;
            4'd2: HEX3 = HEX_2;
            4'd3: HEX3 = HEX_3;
            4'd4: HEX3 = HEX_4;
            4'd5: HEX3 = HEX_5;
            4'd6: HEX3 = HEX_6;
            4'd7: HEX3 = HEX_7;
            4'd8: HEX3 = HEX_8;
            4'd9: HEX3 = HEX_9;
            4'd10: HEX3 = HEX_10;
            4'd11: HEX3 = HEX_11;
            4'd12: HEX3 = HEX_12;
            4'd13: HEX3 = HEX_13;
            4'd14: HEX3 = HEX_14;
            4'd15: HEX3 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[4]) begin
            case(c_out[4][15:12])
            4'd0: HEX3 = HEX_0;
            4'd1: HEX3 = HEX_1;
            4'd2: HEX3 = HEX_2;
            4'd3: HEX3 = HEX_3;
            4'd4: HEX3 = HEX_4;
            4'd5: HEX3 = HEX_5;
            4'd6: HEX3 = HEX_6;
            4'd7: HEX3 = HEX_7;
            4'd8: HEX3 = HEX_8;
            4'd9: HEX3 = HEX_9;
            4'd10: HEX3 = HEX_10;
            4'd11: HEX3 = HEX_11;
            4'd12: HEX3 = HEX_12;
            4'd13: HEX3 = HEX_13;
            4'd14: HEX3 = HEX_14;
            4'd15: HEX3 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[5]) begin
            case(c_out[5][15:12])
            4'd0: HEX3 = HEX_0;
            4'd1: HEX3 = HEX_1;
            4'd2: HEX3 = HEX_2;
            4'd3: HEX3 = HEX_3;
            4'd4: HEX3 = HEX_4;
            4'd5: HEX3 = HEX_5;
            4'd6: HEX3 = HEX_6;
            4'd7: HEX3 = HEX_7;
            4'd8: HEX3 = HEX_8;
            4'd9: HEX3 = HEX_9;
            4'd10: HEX3 = HEX_10;
            4'd11: HEX3 = HEX_11;
            4'd12: HEX3 = HEX_12;
            4'd13: HEX3 = HEX_13;
            4'd14: HEX3 = HEX_14;
            4'd15: HEX3 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[6]) begin
            case(c_out[6][15:12])
            4'd0: HEX3 = HEX_0;
            4'd1: HEX3 = HEX_1;
            4'd2: HEX3 = HEX_2;
            4'd3: HEX3 = HEX_3;
            4'd4: HEX3 = HEX_4;
            4'd5: HEX3 = HEX_5;
            4'd6: HEX3 = HEX_6;
            4'd7: HEX3 = HEX_7;
            4'd8: HEX3 = HEX_8;
            4'd9: HEX3 = HEX_9;
            4'd10: HEX3 = HEX_10;
            4'd11: HEX3 = HEX_11;
            4'd12: HEX3 = HEX_12;
            4'd13: HEX3 = HEX_13;
            4'd14: HEX3 = HEX_14;
            4'd15: HEX3 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[7]) begin
            case(c_out[7][15:12])
            4'd0: HEX3 = HEX_0;
            4'd1: HEX3 = HEX_1;
            4'd2: HEX3 = HEX_2;
            4'd3: HEX3 = HEX_3;
            4'd4: HEX3 = HEX_4;
            4'd5: HEX3 = HEX_5;
            4'd6: HEX3 = HEX_6;
            4'd7: HEX3 = HEX_7;
            4'd8: HEX3 = HEX_8;
            4'd9: HEX3 = HEX_9;
            4'd10: HEX3 = HEX_10;
            4'd11: HEX3 = HEX_11;
            4'd12: HEX3 = HEX_12;
            4'd13: HEX3 = HEX_13;
            4'd14: HEX3 = HEX_14;
            4'd15: HEX3 = HEX_15;
            endcase
        end
        else begin
            HEX3 = OFF;
        end
    end


     // HEX4 Logic
    always @(*) begin
        if (state == DONE & SW[0]) begin
            case(c_out[0][19:16])
            4'd0: HEX4 = HEX_0;
            4'd1: HEX4 = HEX_1;
            4'd2: HEX4 = HEX_2;
            4'd3: HEX4 = HEX_3;
            4'd4: HEX4 = HEX_4;
            4'd5: HEX4 = HEX_5;
            4'd6: HEX4 = HEX_6;
            4'd7: HEX4 = HEX_7;
            4'd8: HEX4 = HEX_8;
            4'd9: HEX4 = HEX_9;
            4'd10: HEX4 = HEX_10;
            4'd11: HEX4 = HEX_11;
            4'd12: HEX4 = HEX_12;
            4'd13: HEX4 = HEX_13;
            4'd14: HEX4 = HEX_14;
            4'd15: HEX4 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[1]) begin
            case(c_out[1][19:16])
            4'd0: HEX4 = HEX_0;
            4'd1: HEX4 = HEX_1;
            4'd2: HEX4 = HEX_2;
            4'd3: HEX4 = HEX_3;
            4'd4: HEX4 = HEX_4;
            4'd5: HEX4 = HEX_5;
            4'd6: HEX4 = HEX_6;
            4'd7: HEX4 = HEX_7;
            4'd8: HEX4 = HEX_8;
            4'd9: HEX4 = HEX_9;
            4'd10: HEX4 = HEX_10;
            4'd11: HEX4 = HEX_11;
            4'd12: HEX4 = HEX_12;
            4'd13: HEX4 = HEX_13;
            4'd14: HEX4 = HEX_14;
            4'd15: HEX4 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[2]) begin
            case(c_out[2][19:16])
            4'd0: HEX4 = HEX_0;
            4'd1: HEX4 = HEX_1;
            4'd2: HEX4 = HEX_2;
            4'd3: HEX4 = HEX_3;
            4'd4: HEX4 = HEX_4;
            4'd5: HEX4 = HEX_5;
            4'd6: HEX4 = HEX_6;
            4'd7: HEX4 = HEX_7;
            4'd8: HEX4 = HEX_8;
            4'd9: HEX4 = HEX_9;
            4'd10: HEX4 = HEX_10;
            4'd11: HEX4 = HEX_11;
            4'd12: HEX4 = HEX_12;
            4'd13: HEX4 = HEX_13;
            4'd14: HEX4 = HEX_14;
            4'd15: HEX4 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[3]) begin
            case(c_out[3][19:16])
            4'd0: HEX4 = HEX_0;
            4'd1: HEX4 = HEX_1;
            4'd2: HEX4 = HEX_2;
            4'd3: HEX4 = HEX_3;
            4'd4: HEX4 = HEX_4;
            4'd5: HEX4 = HEX_5;
            4'd6: HEX4 = HEX_6;
            4'd7: HEX4 = HEX_7;
            4'd8: HEX4 = HEX_8;
            4'd9: HEX4 = HEX_9;
            4'd10: HEX4 = HEX_10;
            4'd11: HEX4 = HEX_11;
            4'd12: HEX4 = HEX_12;
            4'd13: HEX4 = HEX_13;
            4'd14: HEX4 = HEX_14;
            4'd15: HEX4 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[4]) begin
            case(c_out[4][19:16])
            4'd0: HEX4 = HEX_0;
            4'd1: HEX4 = HEX_1;
            4'd2: HEX4 = HEX_2;
            4'd3: HEX4 = HEX_3;
            4'd4: HEX4 = HEX_4;
            4'd5: HEX4 = HEX_5;
            4'd6: HEX4 = HEX_6;
            4'd7: HEX4 = HEX_7;
            4'd8: HEX4 = HEX_8;
            4'd9: HEX4 = HEX_9;
            4'd10: HEX4 = HEX_10;
            4'd11: HEX4 = HEX_11;
            4'd12: HEX4 = HEX_12;
            4'd13: HEX4 = HEX_13;
            4'd14: HEX4 = HEX_14;
            4'd15: HEX4 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[5]) begin
            case(c_out[5][19:16])
            4'd0: HEX4 = HEX_0;
            4'd1: HEX4 = HEX_1;
            4'd2: HEX4 = HEX_2;
            4'd3: HEX4 = HEX_3;
            4'd4: HEX4 = HEX_4;
            4'd5: HEX4 = HEX_5;
            4'd6: HEX4 = HEX_6;
            4'd7: HEX4 = HEX_7;
            4'd8: HEX4 = HEX_8;
            4'd9: HEX4 = HEX_9;
            4'd10: HEX4 = HEX_10;
            4'd11: HEX4 = HEX_11;
            4'd12: HEX4 = HEX_12;
            4'd13: HEX4 = HEX_13;
            4'd14: HEX4 = HEX_14;
            4'd15: HEX4 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[6]) begin
            case(c_out[6][19:16])
            4'd0: HEX4 = HEX_0;
            4'd1: HEX4 = HEX_1;
            4'd2: HEX4 = HEX_2;
            4'd3: HEX4 = HEX_3;
            4'd4: HEX4 = HEX_4;
            4'd5: HEX4 = HEX_5;
            4'd6: HEX4 = HEX_6;
            4'd7: HEX4 = HEX_7;
            4'd8: HEX4 = HEX_8;
            4'd9: HEX4 = HEX_9;
            4'd10: HEX4 = HEX_10;
            4'd11: HEX4 = HEX_11;
            4'd12: HEX4 = HEX_12;
            4'd13: HEX4 = HEX_13;
            4'd14: HEX4 = HEX_14;
            4'd15: HEX4 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[7]) begin
            case(c_out[7][19:16])
            4'd0: HEX4 = HEX_0;
            4'd1: HEX4 = HEX_1;
            4'd2: HEX4 = HEX_2;
            4'd3: HEX4 = HEX_3;
            4'd4: HEX4 = HEX_4;
            4'd5: HEX4 = HEX_5;
            4'd6: HEX4 = HEX_6;
            4'd7: HEX4 = HEX_7;
            4'd8: HEX4 = HEX_8;
            4'd9: HEX4 = HEX_9;
            4'd10: HEX4 = HEX_10;
            4'd11: HEX4 = HEX_11;
            4'd12: HEX4 = HEX_12;
            4'd13: HEX4 = HEX_13;
            4'd14: HEX4 = HEX_14;
            4'd15: HEX4 = HEX_15;
            endcase
        end
        else begin
            HEX4 = OFF;
        end
    end

     // HEX5 Logic
    always @(*) begin
        if (state == DONE & SW[0]) begin
            case(c_out[0][23:20])
            4'd0: HEX5 = HEX_0;
            4'd1: HEX5 = HEX_1;
            4'd2: HEX5 = HEX_2;
            4'd3: HEX5 = HEX_3;
            4'd4: HEX5 = HEX_4;
            4'd5: HEX5 = HEX_5;
            4'd6: HEX5 = HEX_6;
            4'd7: HEX5 = HEX_7;
            4'd8: HEX5 = HEX_8;
            4'd9: HEX5 = HEX_9;
            4'd10: HEX5 = HEX_10;
            4'd11: HEX5 = HEX_11;
            4'd12: HEX5 = HEX_12;
            4'd13: HEX5 = HEX_13;
            4'd14: HEX5 = HEX_14;
            4'd15: HEX5 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[1]) begin
            case(c_out[1][23:20])
            4'd0: HEX5 = HEX_0;
            4'd1: HEX5 = HEX_1;
            4'd2: HEX5 = HEX_2;
            4'd3: HEX5 = HEX_3;
            4'd4: HEX5 = HEX_4;
            4'd5: HEX5 = HEX_5;
            4'd6: HEX5 = HEX_6;
            4'd7: HEX5 = HEX_7;
            4'd8: HEX5 = HEX_8;
            4'd9: HEX5 = HEX_9;
            4'd10: HEX5 = HEX_10;
            4'd11: HEX5 = HEX_11;
            4'd12: HEX5 = HEX_12;
            4'd13: HEX5 = HEX_13;
            4'd14: HEX5 = HEX_14;
            4'd15: HEX5 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[2]) begin
            case(c_out[2][23:20])
            4'd0: HEX5 = HEX_0;
            4'd1: HEX5 = HEX_1;
            4'd2: HEX5 = HEX_2;
            4'd3: HEX5 = HEX_3;
            4'd4: HEX5 = HEX_4;
            4'd5: HEX5 = HEX_5;
            4'd6: HEX5 = HEX_6;
            4'd7: HEX5 = HEX_7;
            4'd8: HEX5 = HEX_8;
            4'd9: HEX5 = HEX_9;
            4'd10: HEX5 = HEX_10;
            4'd11: HEX5 = HEX_11;
            4'd12: HEX5 = HEX_12;
            4'd13: HEX5 = HEX_13;
            4'd14: HEX5 = HEX_14;
            4'd15: HEX5 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[3]) begin
            case(c_out[3][23:20])
            4'd0: HEX5 = HEX_0;
            4'd1: HEX5 = HEX_1;
            4'd2: HEX5 = HEX_2;
            4'd3: HEX5 = HEX_3;
            4'd4: HEX5 = HEX_4;
            4'd5: HEX5 = HEX_5;
            4'd6: HEX5 = HEX_6;
            4'd7: HEX5 = HEX_7;
            4'd8: HEX5 = HEX_8;
            4'd9: HEX5 = HEX_9;
            4'd10: HEX5 = HEX_10;
            4'd11: HEX5 = HEX_11;
            4'd12: HEX5 = HEX_12;
            4'd13: HEX5 = HEX_13;
            4'd14: HEX5 = HEX_14;
            4'd15: HEX5 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[4]) begin
            case(c_out[4][23:20])
            4'd0: HEX5 = HEX_0;
            4'd1: HEX5 = HEX_1;
            4'd2: HEX5 = HEX_2;
            4'd3: HEX5 = HEX_3;
            4'd4: HEX5 = HEX_4;
            4'd5: HEX5 = HEX_5;
            4'd6: HEX5 = HEX_6;
            4'd7: HEX5 = HEX_7;
            4'd8: HEX5 = HEX_8;
            4'd9: HEX5 = HEX_9;
            4'd10: HEX5 = HEX_10;
            4'd11: HEX5 = HEX_11;
            4'd12: HEX5 = HEX_12;
            4'd13: HEX5 = HEX_13;
            4'd14: HEX5 = HEX_14;
            4'd15: HEX5 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[5]) begin
            case(c_out[5][23:20])
            4'd0: HEX5 = HEX_0;
            4'd1: HEX5 = HEX_1;
            4'd2: HEX5 = HEX_2;
            4'd3: HEX5 = HEX_3;
            4'd4: HEX5 = HEX_4;
            4'd5: HEX5 = HEX_5;
            4'd6: HEX5 = HEX_6;
            4'd7: HEX5 = HEX_7;
            4'd8: HEX5 = HEX_8;
            4'd9: HEX5 = HEX_9;
            4'd10: HEX5 = HEX_10;
            4'd11: HEX5 = HEX_11;
            4'd12: HEX5 = HEX_12;
            4'd13: HEX5 = HEX_13;
            4'd14: HEX5 = HEX_14;
            4'd15: HEX5 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[6]) begin
            case(c_out[6][23:20])
            4'd0: HEX5 = HEX_0;
            4'd1: HEX5 = HEX_1;
            4'd2: HEX5 = HEX_2;
            4'd3: HEX5 = HEX_3;
            4'd4: HEX5 = HEX_4;
            4'd5: HEX5 = HEX_5;
            4'd6: HEX5 = HEX_6;
            4'd7: HEX5 = HEX_7;
            4'd8: HEX5 = HEX_8;
            4'd9: HEX5 = HEX_9;
            4'd10: HEX5 = HEX_10;
            4'd11: HEX5 = HEX_11;
            4'd12: HEX5 = HEX_12;
            4'd13: HEX5 = HEX_13;
            4'd14: HEX5 = HEX_14;
            4'd15: HEX5 = HEX_15;
            endcase
        end
        else if (state == DONE & SW[7]) begin
            case(c_out[7][23:20])
            4'd0: HEX5 = HEX_0;
            4'd1: HEX5 = HEX_1;
            4'd2: HEX5 = HEX_2;
            4'd3: HEX5 = HEX_3;
            4'd4: HEX5 = HEX_4;
            4'd5: HEX5 = HEX_5;
            4'd6: HEX5 = HEX_6;
            4'd7: HEX5 = HEX_7;
            4'd8: HEX5 = HEX_8;
            4'd9: HEX5 = HEX_9;
            4'd10: HEX5 = HEX_10;
            4'd11: HEX5 = HEX_11;
            4'd12: HEX5 = HEX_12;
            4'd13: HEX5 = HEX_13;
            4'd14: HEX5 = HEX_14;
            4'd15: HEX5 = HEX_15;
            endcase
        end
        else begin
            HEX5 = OFF;
        end
    end

endmodule