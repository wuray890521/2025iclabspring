// ##############################################################
//   You can modify by your own
//   You can modify by your own
//   You can modify by your own
// ##############################################################

module CHIP(
	// input signals
	clk,
	rst_n,
	in_valid,
	delay,
	source,
	destination,
	// output signals
	out_valid,
	worst_delay,
	path
);

input         clk, rst_n, in_valid;
input  [3:0]  delay;
input  [3:0]  source;
input  [3:0]  destination;

output        out_valid;
output [7:0]  worst_delay;
output [3:0]  path;

//==================================================================
// reg & wire
//==================================================================
wire        C_clk, C_rst_n, C_in_valid;
wire [3:0]  C_delay;
wire [3:0]  C_source;
wire [3:0]  C_destination;

wire        C_out_valid;
wire [7:0]  C_worst_delay;
wire [3:0]  C_path;

//==================================================================
// CORE
//==================================================================
STA CORE(
	// input signals
    .clk(C_clk),
    .rst_n(C_rst_n),
    .in_valid(C_in_valid),
    .delay(C_delay),
    .source(C_source),
    .destination(C_destination),
	
    // output signals
    .out_valid(C_out_valid),
    .worst_delay(C_worst_delay),
    .path(C_path)
);

//==================================================================
// INPUT PAD
// Syntax: XMD PAD_NAME ( .O(CORE_PORT_NAME), .I(CHIP_PORT_NAME), .PU(1'b0), .PD(1'b0), .SMT(1'b0));
//     Ex: XMD    I_CLK ( .O(C_clk),          .I(clk),            .PU(1'b0), .PD(1'b0), .SMT(1'b0));
//==================================================================
// You need to finish this part
XMD    I_CLK         ( .O(C_clk),          .I(clk),            .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD    I_rst_n       ( .O(C_rst_n),        .I(rst_n),          .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD    I_in_valid    ( .O(C_in_valid),     .I(in_valid),       .PU(1'b0), .PD(1'b0), .SMT(1'b0));

XMD    I_delay_0       ( .O(C_delay[0]),        .I(delay[0]),          .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD    I_delay_1       ( .O(C_delay[1]),        .I(delay[1]),          .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD    I_delay_2       ( .O(C_delay[2]),        .I(delay[2]),          .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD    I_delay_3       ( .O(C_delay[3]),        .I(delay[3]),          .PU(1'b0), .PD(1'b0), .SMT(1'b0));

XMD    I_source_0      ( .O(C_source[0]),       .I(source[0]),         .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD    I_source_1      ( .O(C_source[1]),       .I(source[1]),         .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD    I_source_2      ( .O(C_source[2]),       .I(source[2]),         .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD    I_source_3      ( .O(C_source[3]),       .I(source[3]),         .PU(1'b0), .PD(1'b0), .SMT(1'b0));

XMD    I_destination_0 ( .O(C_destination[0]),  .I(destination[0]),    .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD    I_destination_1 ( .O(C_destination[1]),  .I(destination[1]),    .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD    I_destination_2 ( .O(C_destination[2]),  .I(destination[2]),    .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD    I_destination_3 ( .O(C_destination[3]),  .I(destination[3]),    .PU(1'b0), .PD(1'b0), .SMT(1'b0));
//==================================================================
// OUTPUT PAD
// Syntax: YA2GSD PAD_NAME (.I(CORE_PIN_NAME), .O(PAD_PIN_NAME), .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
//     Ex: YA2GSD  O_VALID (.I(C_out_valid),   .O(out_valid),    .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
//==================================================================
// You need to finish this part
YA2GSD  O_VALID (.I(C_out_valid),     .O(out_valid),     .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));

YA2GSD  O_worst_0 (.I(C_worst_delay[0]),   .O(worst_delay[0]),   .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD  O_worst_1 (.I(C_worst_delay[1]),   .O(worst_delay[1]),   .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD  O_worst_2 (.I(C_worst_delay[2]),   .O(worst_delay[2]),   .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD  O_worst_3 (.I(C_worst_delay[3]),   .O(worst_delay[3]),   .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD  O_worst_4 (.I(C_worst_delay[4]),   .O(worst_delay[4]),   .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD  O_worst_5 (.I(C_worst_delay[5]),   .O(worst_delay[5]),   .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD  O_worst_6 (.I(C_worst_delay[6]),   .O(worst_delay[6]),   .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD  O_worst_7 (.I(C_worst_delay[7]),   .O(worst_delay[7]),   .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));

YA2GSD  O_path_0  (.I(C_path[0]),          .O(path[0]),          .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD  O_path_1  (.I(C_path[1]),          .O(path[1]),          .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD  O_path_2  (.I(C_path[2]),          .O(path[2]),          .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD  O_path_3  (.I(C_path[3]),          .O(path[3]),          .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
//==================================================================
// I/O power 3.3V pads x? (DVDD + DGND)
// Syntax: VCC3IOD/GNDIOD PAD_NAME ();
//    Ex1: VCC3IOD        VDDP0 ();
//    Ex2: GNDIOD         GNDP0 ();
//==================================================================
// You need to finish this part
VCC3IOD        VDDP0 ();
GNDIOD         GNDP0 ();
VCC3IOD        VDDP1 ();
GNDIOD         GNDP1 ();
VCC3IOD        VDDP2 ();
GNDIOD         GNDP2 ();
VCC3IOD        VDDP3 ();
GNDIOD         GNDP3 ();

//==================================================================
// Core power 1.8V pads x? (VDD + GND)
// Syntax: VCCKD/GNDKD PAD_NAME ();
//    Ex1: VCCKD       VDDC0 ();
//    Ex2: GNDKD       GNDC0 ();
//==================================================================
// You need to finish this part
VCCKD       VDDC0 ();
GNDKD       GNDC0 ();
VCCKD       VDDC1 ();
GNDKD       GNDC1 ();
VCCKD       VDDC2 ();
GNDKD       GNDC2 ();
VCCKD       VDDC3 ();
GNDKD       GNDC3 ();
VCCKD       VDDC4 ();
GNDKD       GNDC4 ();
VCCKD       VDDC5 ();
GNDKD       GNDC5 ();
endmodule

