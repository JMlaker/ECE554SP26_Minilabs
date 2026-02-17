module recieve_tb ();
  logic clk;
  logic b_en;
  logic rst;
  logic i_iocs;
  logic i_rx;
  logic i_iorw;
  logic o_rda;
  logic [7:0] o_data;

  initial clk = 0;
  always begin
    clk = #5 ~clk;
  end
  initial rst = 1;
  initial i_rx = 1'b1;

  logic [1:0] i_ioaddr_brg;
  logic [7:0] i_brg_bus;
  brg baud_rate_gen (
      .clk(clk),
      .rst(rst),
      .i_ioaddr_brg(i_ioaddr_brg),
      .i_brg_bus(i_brg_bus),
      .en(b_en)
  );

recieve iDUT(
  .clk(clk),
  .b_en(b_en),
  .rst(rst),
  .i_iocs(i_iocs),
  .i_rx(i_rx),
  .i_iorw(i_iorw),
  .o_rda(o_rda),
  .o_data(o_data)
  );

  logic[7:0] shft_reg;


  //try showing the reciver a value and then seeing if it acually "read" it in
  //correctly?
  task drive_val(input [7:0] val);
    integer i,j;
    shft_reg=val;
    //recall that a reciver transmission is done by
    //1) high to low
    //2) at every following b_en, a new value should be present (new bit?)
    //3) remain high
    $display("called at %t",$time);

    //when called, set i_rx from high to low
    i_rx = 1'b0;
    for ( j = 0; j < 16; j = j + 1) @(posedge b_en);
    for ( i = 0; i < 8; i = i + 1) begin
      //present some data
      //assumed that data is held for 16 b_en pulses?
      i_rx=shft_reg[7];
      shft_reg<=shft_reg<<<1;
      for ( j = 0; j < 16; j = j + 1) begin
        @(posedge b_en);
      end
    end

    i_rx=1'b1;
    for(j=0;j<16;j=j+1)@(posedge b_en);
    //after this, attempt to read from the module
    @(posedge b_en)begin
      if(o_data!=val)begin
        $display("ERROR: read value:%b, transmitted value:%b",o_data,val);
      end
    end
  endtask

  //DETERMINE THE BAUD RATE TO TRY AND FEED INTO THE DUT FOR TESTING
  //buad rate of 9600, oversampling rate of n=4
  //i.e, generated b_en signal (ideally from baud rate module, but here just
  //generate it) 
  //baud rate of 9600 implies that 9600 bits are read per second. 
  //second. 
  //oversampling by n=4, or 2^n=16 implies that its actually 16 times faster(
  //improves resolution?). 
  //given that the clock here is set to be 10 ns period, 1*10^8 hz, 100 MHz
  //(100*10^6)?(16*9600)=651.04=651
  logic[7:0] rand_val;
  initial begin
    i_rx=1'b1;
    $dumpfile("recieve.vcd");
    $dumpvars(0, recieve_tb);
    i_ioaddr_brg = 2'b11;
    i_brg_bus = 8'h02;
    @(posedge clk);
    i_ioaddr_brg = 2'b10;
    i_brg_bus = 8'h8b;
    @(posedge clk);
    i_ioaddr_brg = 2'b00;
    i_brg_bus = 8'hff;
    repeat(5)begin
      @(posedge b_en);
    end
    $display("what the fuck is going on");
    repeat(100)begin
      rand_val=$urandom();
      drive_val(rand_val);
    end

  end
endmodule
