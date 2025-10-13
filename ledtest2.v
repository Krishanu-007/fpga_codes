module ledtest2(
input rst,
output [7:0] led
);

assign led= rst? 8'hFF:8'h00;

endmodule
