module MAC #
(
parameter DATA_WIDTH = 8
)
(
input clk,
input rst_n,
input En,
input Clr,
input [DATA_WIDTH-1:0] Ain,
input [DATA_WIDTH-1:0] Bin,
output reg [DATA_WIDTH*3-1:0] Cout
);

logic [DATA_WIDTH*3:0] mult_out;

always_ff @(posedge clk, negedge rst_n) begin
	if (~rst_n)
		mult_out <= 0;
	else
		mult_out <= Ain * Bin;
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        Cout <= 0;
    end 

    else begin
        if (Clr) begin
            Cout <= 0;
        end 

        else if (En) begin
            Cout <= Cout + mult_out;
        end
    end 
end 


endmodule
