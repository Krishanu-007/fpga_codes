module switch_toggle(
input clk,
input rst,
output [7:0] led);

reg prev_sw;
wire [7:0] val1=8'hF5,val2=8'h5F;
initial begin
led=val1;
end
always @(posedge clk) begin
prev_sw<=rst;

if(prev_sw==1'b1 && rst==1'b0) begin
if(led==val2) begin
led<=val1;
end
else begin
led<=val2;
end
end
end
endmodule
