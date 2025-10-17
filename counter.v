module counter(
input clk,
input rst,
output reg [7:0] led);

reg [26:0] timer;
reg [7:0] count;

always @(posedge clk) begin
	if(!rst) begin
		count<=0;
		timer<=0;
		led<=0;
	end
	else begin
		if(timer==27'h5F5E100) begin
			timer<=0;
			count<=count+1;
			led<=count+1;
		end
		else begin
			timer<=timer+1;
		end
	end
end
endmodule
