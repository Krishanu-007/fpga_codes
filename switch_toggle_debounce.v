module switch_toggle_debounce(
input clk,
input rst,
output [7:0] led);

wire debounced_sw;

debouncer #(.DEBOUNCE_LIMIT(1000000)) db_inst
(.clk(clk),.i_bouncy(rst),.o_debouncy(debounced_sw));

switch_toggle swt_inst
(.clk(clk),.rst(debounced_sw),.led(led));

endmodule
