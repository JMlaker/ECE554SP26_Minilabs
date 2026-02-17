module brg_tb ();
  logic clk;
  logic rst;
  logic [1:0] i_ioaddr_brg;
  logic [7:0] i_brg_bus;
  logic en;

  brg iDUT (
      .clk(clk),
      .rst(rst),
      .i_ioaddr_brg(i_ioaddr_brg),
      .i_brg_bus(i_brg_bus),
      .en(en)
  );

  initial clk = 1'b0;
  initial rst = 1'b1;
  always begin
    clk = #5 ~clk;
  end

  initial begin
    $dumpfile("brg.vcd");
    $dumpvars(0, brg_tb);
    #100;
  end

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
  //measure the distance between rising edges of the enable signal?
  //the distance between them should be equal to approximtely 651 clock
  //cycles?
  integer i = 0;
  always @(posedge clk) begin
    i = i + 1;
  end
  integer last_count;
  initial begin
    last_count = 0;
    i_ioaddr_brg = 2'b11;
    i_brg_bus = 8'h02;
    @(posedge clk);
    i_ioaddr_brg = 2'b10;
    i_brg_bus = 8'h8b;
    @(posedge clk);
    i_ioaddr_brg = 2'b00;
    i_brg_bus = 8'hff;
    forever begin
      @(posedge en);
      $display("clock cycles between rising edge of en: %0d",i-last_count);
      last_count=i;
    end

  end



endmodule
