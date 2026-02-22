module transmit_tb ();
  logic clk;
  logic [7:0] i_data;
  logic rst;
  logic b_en;
  logic i_iocs;
  logic o_tx;
  logic i_iorw;
  logic o_tbr;

  //NOTE: ONLY SAMPLE WHEN b_en IS HIGH!
  logic i_rx;
  //Receive Data Available: indicates that a byte of data has been recieved
  //and is ready to be read from the SPART to the processor. 
  logic o_rda;
  logic [7:0] o_data;

  initial clk = 1'b0;
  initial rst = 1'b1;
  always clk = #5 ~clk;

  assign i_rx=o_tx;


  //instantiate the baud rate generator to drive the control signals for both
  //the transmit and recieve modules?
  logic [1:0] i_ioaddr_brg;
  logic [7:0] i_brg_bus;
  brg baud_rate_gen (
      .clk(clk),
      .rst(rst),
      .i_ioaddr_brg(i_ioaddr_brg),
      .i_brg_bus(i_brg_bus),
      .en(b_en)
  );

  transmit iDUT (
      .clk(clk),
      .i_data(i_data),
      .rst(rst),
      .b_en(b_en),
      .i_iocs(i_iocs),
      .o_tx(o_tx),
      .i_iorw(!i_iorw),
      .o_tbr(o_tbr)
  );

  //create a listener
  logic i_iorw_l;
  initial i_iorw_l=1'b1;
  recieve listener (
      .clk(clk),
      .b_en(b_en),
      .rst(rst),
      .i_iocs(i_iocs),
      .i_rx(i_rx),
      .i_iorw(i_iorw_l),
      .o_rda(o_rda),
      .o_data(o_data)
  );

  logic tbr_pos_edge;
  logic tbr_flop;
  always@(posedge clk)begin
    if(~rst)begin
      tbr_pos_edge<=1'b0;
      tbr_flop<=1'b0;
    end
    else begin
      if(b_en)begin
        tbr_flop<=o_tbr;
        tbr_pos_edge<=(~tbr_flop && o_tbr);
      end
    end
  end

  //task to load a value into the transmit module
   task automatic drive_val(logic [7:0] inp_val);
    //initially, transmit module is in the idle state; set the chip select to
    //high, i_iorw to LOW (indicating that it should be recieving a value from
    //the processor)
    integer i=0;
    i_iorw = 1'b0;
    i_iocs = 1'b1;
    i_data = inp_val;

    @(negedge b_en);
    i_iorw = 1'b1;
    i_iocs = 1'b1;

    while(~tbr_pos_edge)begin
      i=i+1;
      if(i>200)
        $error("TBR TOOK TOO LONG: %d PULSES OF b_en",i);
      @(posedge b_en);
    end

  endtask

  initial begin
    //initial reset state?
    rst=1'b0;
    repeat(5)@(posedge clk);
    rst=1'b1;
    $dumpfile("transmit.vcd");
    $dumpvars(0, transmit_tb);

    //load the appropriate baud rate to the baud rate generator
    i_ioaddr_brg = 2'b11;
    i_brg_bus = 8'h02;
    @(posedge clk);
    i_ioaddr_brg = 2'b10;
    i_brg_bus = 8'h8b;
    //set the i_ioaddr_brg to 00 so it no longer writes to the brg, allowing
    //it to run
    @(posedge clk);
    i_ioaddr_brg = 2'b00;
    i_brg_bus = 8'hff;
    i_iocs=1'b1;

    repeat (5) @(posedge clk);
    //try transmitting something?
    drive_val(8'hAB);
    drive_val(8'hCD);
    drive_val(8'hEF);
    drive_val(8'hFF);
    drive_val(8'hAA);
    drive_val(8'hBB);
  end




endmodule
