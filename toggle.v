module toggle(
input clk,
input rst,
output [7:0] led);

reg p_rst;

always @(posedge clk) begin

p_rst<=rst;

if(p_rst==1'b1 && rst==1'b0) begin
led<=~led;
end
end
endmodule
