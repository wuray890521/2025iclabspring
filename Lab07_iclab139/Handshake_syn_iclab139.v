module Handshake_syn #(parameter WIDTH=32) (
    sclk,
    dclk,
    rst_n,
    sready,
    din,
    dbusy,
    sidle,
    dvalid,
    dout,

    clk1_handshake_flag1,
    clk1_handshake_flag2,
    clk1_handshake_flag3,
    clk1_handshake_flag4,

    handshake_clk2_flag1,
    handshake_clk2_flag2,
    handshake_clk2_flag3,
    handshake_clk2_flag4
);

input sclk, dclk;
input rst_n;
input sready;
input [WIDTH-1:0] din;
input dbusy;

output sidle;
output reg dvalid;
output reg [WIDTH-1:0] dout;

// You can change the input / output of the custom flag ports
input clk1_handshake_flag1;
input clk1_handshake_flag2;
output clk1_handshake_flag3;
output clk1_handshake_flag4;

input handshake_clk2_flag1;
input handshake_clk2_flag2;
output handshake_clk2_flag3;
output handshake_clk2_flag4;

// Remember:
//   Don't modify the signal name
reg sreq;
wire dreq;
reg dack;
wire sack;

// assign sidle = sreq;
assign sidle = (sready || sreq || sack) ? 0 : 1 ;
// assign sidle = !sreq && !sack;
// quote ---------------------------------------------- quote //
NDFF_syn syn_s (.D(sreq), .Q(dreq), .clk(dclk), .rst_n(rst_n));
NDFF_syn syn_d (.D(dack), .Q(sack), .clk(sclk), .rst_n(rst_n));
// quote ---------------------------------------------- quote //
// sreq by sclk -------------------------------- sreq by sclk //
always @(posedge sclk or negedge rst_n) begin
    if (!rst_n)       sreq <= 1'b0;
    else if (sack)    sreq <= 1'b0; 
    else if (sready)  sreq <= 1'b1;
    else              sreq <= sreq;
end
// scak by sclk -------------------------------- sack by sclk //
// dack by dclk -------------------------------- dack by dclk //
always @ (posedge dclk or negedge rst_n) begin 
	if (!rst_n) dack <= 0 ;
    else if (dreq) dack <= 1 ;
    else dack <= 0 ;
end
// dack by dclk -------------------------------- dack by dclk //
// dout by dclk -------------------------------- dout by dclk //
always @(posedge dclk or negedge rst_n) begin
    if (!rst_n)              dout <= 0;
    else if (!dbusy && dreq) dout <= din;
    else                     dout <= dout;
end
// dout by dclk -------------------------------- dout by dclk //
// dvalid by dclk -------------------------------- dvalid by dclk //
always @(posedge dclk or negedge rst_n) begin
    if (!rst_n)                      dvalid <= 0;
    else if (dreq && !dbusy && dack) dvalid <= 1;
    else                             dvalid <= 0;
end
// dvalid by dclk -------------------------------- dvalid by dclk //
endmodule