module ledtest1(
input rst,
output [7:0] led
);

assign led= rst? 8'h0:8'hFF;

endmodule
